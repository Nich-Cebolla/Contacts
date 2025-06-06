

class IVoicemails {
    static __New() {
        if this.Prototype.__Class == 'IVoicemails' {
            this.Individuals := MapEx()
        }
    }

    static Parse() {
        ParseCsvConfig.Set('Voicemails')
        ParseCsvConfig.Constructor := ObjBindMethod(this.Voicemails, 'Add')
        ParseCsv(, Main.Content.Voicemails)
    }

    class Voicemails extends ArrayClass {
        static __New() {
            if this.Prototype.__Class == 'IVoicemails.Voicemails' {
                this.__Item := []
                this.ByPhoneNumber := MapEx()
            }
        }
        static Add(Fields, Parser) {
            this.Push(Voicemail := IVoicemails.Voicemail(Fields, Parser))
            Individual := IIndividuals.AddVoicemail(Voicemail)
            if !this.ByPhoneNumber.Has(Voicemail.PhoneNumber) {
                this.ByPhoneNumber.Set(Voicemail.PhoneNumber, Individual)
            }
        }
    }

    class Voicemail extends MapEx {
        __New(Fields, Parser) {
            static Parser_Glpi := Main.Parsers.Glpi
            , Parser_Voicemail := Main.Parsers.Voicemail
            for Header in Parser.Headers {
                switch Header, 0 {
                    case 'Opening Date', 'Last Update':
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Parser_Glpi(Fields[A_Index]) })
                    case 'ID':
                        this.DefineProp('ID', { Value: StrReplace(Fields[A_Index], ',', '') })
                    case 'Description':
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Fields[A_Index] })
                        this.DefineProp('Date', { Value: Parser_Voicemail(Fields[A_Index]) })
                        this.DefineProp('PhoneNumber'
                        , { Value: RegExMatch(Fields[A_Index], 'i)(?<=<)\d+(?=>)', &MatchPhone) ? MatchPhone[0] : '' })
                    default:
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Fields[A_Index] })
                }
            }
        }
    }
}
