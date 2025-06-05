
class IContacts {

    static Parse() {
        ParseCsvConfig.Set('Calls')
        ParseCsvConfig.Constructor := _Constructor
        ParseCsv()

        _Constructor(Fields, Parser) {
            this.Contacts.Add(Contact := this.Contact(Fields, Parser))
            IIndividuals.Add(Contact)
        }
    }

    class Contacts extends ArrayClass {
        __New() {
            if this.Prototype.__Class == 'IContacts.Contacts' {
                this.__Item := []
            }
        }
        static Add(Contact) {
            this.__Item.Push(Contact)
        }
    }

    class Contact {
        __New(Fields, Parser) {
            static Parser_CallDate := Main.Parsers.CallDate
            , Parser_Duration := Main.Parsers.Duration
            for Header in Parser.Headers {
                switch Header, 0 {
                    case 'Call Date':
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Parser_CallDate(Fields[A_Index]) })
                    case 'Total Time', 'Talk Time', 'Ring Time':
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Parser_Duration(Fields[A_Index]) })
                    default:
                        this.DefineProp(StrReplace(Header, ' ', ''), { Value: Fields[A_Index] })
                }
            }
            this.Individual := IContacts.Contact.Individual(this.CallTo, this.CallFrom)
            this.__IsWithinFifteen := IGroups.Groups.IsWithinFifteen(this.DayCode, this.DaySeconds) || '0'
        }

        DayCode => SwitchDayCode(this.CallDate.WDay)
        IsWithinFifteen => this.__IsWithinFifteen
        DaySeconds => this.CallDate.DaySeconds

        __Get(Name, Params) {
            if HasProp(this.CallDate, Name) {
                if Params.Length {
                    return this.CallDate.%Name%[Params*]
                } else {
                    return this.CallDate.%Name%
                }
            }
        }

        class Individual {
            __New(CallToNumber, CallFromNumber) {
                this.CallToNumber := CallToNumber
                this.CallFromNumber := CallFromNumber
            }
            Outbound => IIndividuals.Individuals.Get(this.CallToNumber)
            Inbound => IIndividuals.Individuals.Get(this.CallFromNumber)
        }
    }
}
