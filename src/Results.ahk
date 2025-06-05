
class Results {

    static Call() {
        this.GetOutbound()
        this.GetDisposition()
        this.GetQueue()
        this.GetWithinFifteen()
    }

    static GetOutbound() {

    }

    static GetDisposition() {
        this.Disposition.Make(IContacts.Contacts, &Answered, &Unanswered)
        this.Dispisition_Answered := Answered
        this.Disposition_Unanswered := Unanswered
    }

    static GetQueue() {
        this.Queue.Make(IContacts.Contacts, &MeeteingSupport, &EveningSupport)
        this.Queue_MeetingSupport := MeeteingSupport
        this.Queue_EveningSupport := EveningSupport
    }

    static GetWithinFifteen() {
        for Name, Arr in this.WithinFifteen.Make(IContacts.Contacts) {
            this.DefineProp(Name, { Value: Arr })
        }
    }

    ; static GetLeftInLobby() {
    ;     IIndividuals.Individuals.Default := ''
    ;     for Name, Arr in this.LeftInLobby.Make(
    ;         IGlpi.Notes.Categories.Get('Client Support > Client’s report being left in lobby')
    ;       , IAttendance.ClientAttendance
    ;       , IIndividuals.Individuals
    ;     ) {
    ;         this.DefineProp('LeftInLobby_' Name, { Value: Arr })
    ;     }
    ; }

    class LeftInLobby {
        static Make(GlpiLobby, Attendance, Individuals) {
            Attendance.Default := ''
            Result := Map(
                'Matched', Matched := []
              , 'GroupTypes', GroupTypes := MapEx()
              , 'NoClientId', NoClientId := []
              , 'ClientIdNotFound', ClientIdNotFound := []
              , 'MatchingDateNotFound', MatchingDateNotFound := []
              , 'SameDayCallsBefore', SameDayCallsBefore := { Inbound: [], Outbound: [], SumCalls: 0
              , AvgCallCount: 0, AvgDiff: 0, GreatestDiff: 0, LeastDiff: 0, SumDiff: 0
              , UniqueNumbers: [] }
              , 'SameDayCallsAfter', SameDayCallsAfter := { Inbound: [], Outbound: [], SumCalls: 0
              , AvgCallCount: 0, AvgDiff: 0, GreatestDiff: 0, LeastDiff: 0, SumDiff: 0
              , UniqueNumbers: [] }
            )
            for Note in GlpiLobby {
                if Note.ClientId {
                    if ClientAttendance := Attendance.Get(Note.ClientId) {
                        Flag := 0
                        Note.Attendance := ClientAttendance
                        for AttendanceItem in ClientAttendance {
                            if AttendanceItem.StartTime.NMonth = Note.OpeningDate.NMonth
                            && AttendanceItem.StartTime.NDay = Note.OpeningDate.Day
                            && AttendanceItem.NoteType != 'TelehealthAssessment' {
                                Matched.Push({ Note: Note, Attendance: AttendanceItem })
                                GroupTypes.AddToList(AttendanceItem.NoteType, Note)
                                Flag := 1
                                break
                            }
                        }
                        if !Flag {
                            MatchingDateNotFound.Push(Note)
                        }
                    } else {
                        ClientIdNotFound.Push(Note)
                    }
                } else {
                    NoClientId.Push(Note)
                }
            }

            for MatchObj in Matched {
                Note := MatchObj.Note
                AttendanceItem := MatchObj.Attendance
                SameDayCalls := Note.SameDayCalls := { Inbound: [], Outbound: [] }
                for Individual in [
                    IndividualPrimary := Individuals.Get(Note.Attendance[1].PhoneNumber)
                    , IndividualSecondary := Individuals.Get(Note.Attendance[1].SecondaryNumber)
                ] {
                    if Individual {
                        for Prop in ['Inbound', 'Outbound'] {
                            for Contact in Individual.%Prop% {
                                if Contact.CallDate.NMonth = AttendanceItem.StartTime.NMonth
                                && Contact.CallDate.NDay = AttendanceItem.StartTime.NDay {
                                    TimeDiff := Contact.CallDate.DaySeconds - AttendanceItem.StartTime.DaySeconds
                                    Collection := TimeDiff > 0 ? SameDayCallsAfter : SameDayCallsBefore
                                    Collection.%Prop%.Push({
                                        Contact: Contact
                                        , TimeDiff: TimeDiff
                                        , Note: Note
                                    })
                                    Collection.SumCalls++
                                    Collection.SumDiff += TimeDiff
                                    if !Collection.UniqueNumbers.IndexOf(Individual.PhoneNumber, , , false, false) {
                                        Collection.UniqueNumbers.Push(Individual.PhoneNumber)
                                    }
                                }
                            }
                        }
                    }
                }
            }

            for Collection in [ SameDayCallsBefore, SameDayCallsAfter ] {
                Collection.AvgCallCount := Collection.SumCalls / Collection.UniqueNumbers.Length
                Collection.AvgDiff := Collection.SumDiff / Collection.SumCalls
            }

            for Note in MatchingDateNotFound {
                for AttendanceItem in Note.Attendance {
                    if AttendanceItem.StartTime.NMonth = Note.OpeningDate.NMonth
                    && AttendanceItem.StartTime.NDay > Note.OpeningDate.Day {
                        Note.GroupBeforeTicket := A_Index > 1 ? Note.Attendance[A_Index - 1] : ''
                        break
                    }
                }
            }
            return Result
        }
    }

    class Disposition extends Array {
        static Make(List, &OutAnswered, &OutUnanswered) {
            OutAnswered := this('Answered', List.Length)
            OutUnanswered := this('Unanswered', List.Length)
            OutAnswered.Capacity := OutUnanswered.Capacity := IContacts.Contacts.Length
            for Item in List {
                if Item.Disposition = 'Answered' {
                    OutAnswered.Push(Item)
                } else {
                    OutUnanswered.Push(Item)
                }
            }
            OutAnswered.Capacity := OutAnswered.Length
            OutUnanswered.Capacity := OutUnanswered.Length
        }
        __New(Name, Total) {
            this.Name := Name
            this.Total := Total
        }
    }

    class Queue extends Array {
        static Make(List, &OutMeetingSupport, &OutEveningSupport) {
            OutMeetingSupport := this('MeetingSupport', List.Length)
            OutEveningSupport := this('EveningSupport', List.Length)
            OutMeetingSupport.Capacity := OutEveningSupport.Capacity := IContacts.Contacts.Length
            for Item in List {
                if Item.CallDate.NHour < 17 || (Item.CallDate.NHour == 17 && Item.CallDate.NMinute < 30) {
                    OutMeetingSupport.Push(Item)
                } else {
                    OutEveningSupport.Push(Item)
                }
            }
            OutMeetingSupport.Capacity := OutMeetingSupport.Length
            OutEveningSupport.Capacity := OutEveningSupport.Length
        }
        __New(Name, Total) {
            this.Name := Name
            this.Total := Total
        }

    }

    class WithinFifteen extends Array {
        static Make(List) {
            Result := Map(
                'WithinFifteen_Answered_Before', WithinFifteen_Answered_Before := this(List.Length, 'Answered', true, 'Before')
              , 'WithinFifteen_Answered_After', WithinFifteen_Answered_After := this(List.Length, 'Answered', true, 'After')
              , 'WithinFifteen_Unanswered_Before', WithinFifteen_Unanswered_Before := this(List.Length, 'Unanswered', true, 'Before')
              , 'WithinFifteen_Unanswered_After', WithinFifteen_Unanswered_After := this(List.Length, 'Unanswered', true, 'After')
              , 'NotWithinFifteen_Answered', NotWithinFifteen_Answered := this(List.Length, 'Answered', true, '')
              , 'NotWithinFifteen_Unanswered', NotWithinFifteen_Unanswered := this(List.Length, 'Unanswered', true, '')
            )
            for Item in List {
                if Which := Item.IsWithinFifteen {
                    if Item.Disposition = 'Answered' {
                        WithinFifteen_Answered_%Which%.Push(Item)
                    } else {
                        WithinFifteen_Unanswered_%Which%.Push(Item)
                    }
                } else {
                    if Item.Disposition = 'Answered' {
                        NotWithinFifteen_Answered.Push(Item)
                    } else {
                        NotWithinFifteen_Unanswered.Push(Item)
                    }
                }
            }
            return Result
        }
        __New(Total, Disposition, IsWithinFifteen, Which) {
            this.Disposition := Disposition
            this.Capacity := this.Length
            this.Type := Which
        }
        Count => this.Length
        Alt => this.Total - this.Length
    }
}
