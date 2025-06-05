
class IGlpi {
    static Parse() {
        ParseCsvConfig.Set('Glpi')
        ParseCsvConfig.Constructor := ObjBindMethod(this.Notes, 'Add')
        ParseCsv()
    }

    class Notes extends MapExClass {
        static __New() {
            if this.Prototype.__Class == 'IGlpi.Notes' {
                this.__Item := Map()
                this.Categories := MapEx(false)
                this.ByClientId := MapEx()
            }
        }
        static Add(Fields, *) {
            Note := IGlpi.Note(Fields)
            this.Set(Note.Id, Note)
            this.Categories.AddToList(Note.Category, Note)
            this.ByClientId.AddToList(Note.ClientId, Note)
        }
    }

    class Note {
        __New(Fields) {
            static DateParser := Main.Parsers.Glpi
            this.Fields := Fields
            this.Id := StrReplace(Fields[1], ',', '')
            this.LastUpdate := DateParser(Fields[4])
            this.OpeningDate := DateParser(Fields[5])
            ; Trying to get client id
            ; Taking out the ticket Id so it doesn't interfere with matching client ids.
            Title := RegExReplace(Fields[2], ' \(\d{5}\)$', '', &Count)
            ; Taking out replies to ticket emails that contain the ticket id.
            Title := RegExReplace(Title, 'i)Re:\s+\[SAGE #\d+\]', '')
            ; Taking out dates from the title.
            Title := RegExReplace(Title, '\d{2,4}[-/\\]\d{1,2}[-/\\]\d{1,2}', '')
            if RegExMatch(Title, 'i)client\s+id\s+\K\d+', &Match) {
                this.ClientId := Match[0]
            } else if InStr(this.AssignedToTech, 'Nicholas West')
            && (RegExMatch(this.Description, 'i)^Client:\s+\K\d+', &Match)
            || RegExMatch(this.Description, 'i)^cx\s+\K\d+', &Match)) {
                this.ClientId := Match[0]
            } else if InStr(this.Title, 'Client Support Request')
            && RegExMatch(this.Description, 'i)Client\s+ID\s+:\s+\K\d+', &Match) {
                this.ClientId := Match[0]
            ; If nothing else, try to get any 4-5 digit number in the title
            } else if RegExMatch(Title, '\d{4,5}', &Match) {
                this.ClientId := Match[0]
            }

            if this.HasOwnProp('ClientId') {
                ; Double check we didn't accidentally capture the ticket id
                if this.ClientId == this.Id {
                    this.ClientId := ''
                }
            } else {
                this.ClientId := ''
            }
            this.IsVoicemail := InStr(this.Title, 'SAGE Voicemail Notification') ? 1 : 0
        }

        ; ID - set by constructor
        Title => this.Fields[2]
        Status => this.Fields[3]
        ; LastUpdate - set by constructor
        ; OpeningDate - set by constructor
        Priority => this.Fields[6]
        RequesterRequester => this.Fields[7]
        AssignedToTech => this.Fields[8]
        AssignedToGroup => this.Fields[9]
        Category => this.Fields[10]
        Description => this.Fields[11]
        FollowupsDescription => this.Fields[12]
        FollowupsWriter => this.Fields[13]
    }


    static Cleaned := false
    static FieldIndex := MapEx(false,
      , 1, 'Id', 'Id', 1
      , 2, 'Title', 'Title', 2
      , 3, 'Status', 'Status', 3
      , 4, 'LastUpdate', 'LastUpdate', 4
      , 5, 'OpeningDate', 'OpeningDate', 5
      , 6, 'Priority', 'Priority', 6
      , 7, 'Requester', 'Requester', 7
      , 8, 'AssignedToTech', 'AssignedToTech', 8
      , 9, 'AssignedToGroup', 'AssignedToGroup', 9
      , 10, 'Category', 'Category', 10
      , 11, 'Description', 'Description', 11
      , 12, 'FollowupsDescription', 'FollowupsDescription', 12
      , 13, 'FollowupsDate', 'FollowupsDate', 13
    )
    static CategoriesClientSupport := [
        'Client Support'
      , 'Client Support > Barracuda Message'
      , 'Client Support > Cell Phone Request'
      , 'Client Support > Client Phone Return'
      , 'Client Support > Client Portal Issues'
      , 'Client Support > Client’s report being left in lobby'
      , 'Client Support > Clients received incorrect codes'
      , 'Client Support > Dropped while in group'
      , 'Client Support > Equipment'
      , 'Client Support > Form Dr.'
      , 'Client Support > Group not started'
      , 'Client Support > Group Teams Link'
      , 'Client Support > Info Box Support'
      , 'Client Support > IT Practice Meeting'
      , 'Client Support > LMS'
      , 'Client Support > Non-Technical Issue'
      , 'Client Support > Payment Portal not working'
      , 'Client Support > Technical Issues with Teams'
      , 'Credible'
      , 'Credible > Billing Matrix Update'
      , 'Credible > Form Error'
      , 'Credible > Forms Creation Request'
      , 'Credible > New Program'
      , 'Credible > Report Request'
    ]
    static Categories := [
        'DBxtra'
      , 'Email'
      , 'Equipment'
      , 'Equipment > Equipment Request'
      , 'Equipment > Equipment Service'
      , 'Facilities Request'
      , 'Folder Access'
      , 'Marketing'
      , 'On-Call'
      , 'Printer'
      , 'Printer > Printer/Copier Toner'
      , 'Purchases'
      , 'Purchases > Equipment'
      , 'Purchases > Service'
      , 'Purchases > Software'
      , 'Software'
      , 'User Support (IT)'
      , 'User Support (IT) > Form Dr.'
      , 'User Support (IT) > Password/Login Assistance'
      , 'User Support (IT) > PBX Changes'
      , 'User Support (IT) > User Creation'
      , 'User Support (IT) > User Deactivation'
      , 'User Support (IT) > User Onboarding'
      , 'User Support (IT) > User Training'
      , 'Website'
      , 'Website > internal site support'
      , 'Website > Intranet'
      , 'Website > Main Website'
      , 'Website > portal.sagecounseling.net'
      , 'Website > Referral Submission Website'
      , 'Website > RPS'
      , 'Website > Survey Website'
    ]
}
