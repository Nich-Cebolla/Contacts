
class IGroups {
    static DayCodes := ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU']

    static Parse() {
        ParseCsvConfig.Set('Groups')
        ParseCsvConfig.Constructor := _Constructor
        ParseCsv(, Main.Content.Groups)

        _Constructor(Fields, *) {
            this.Groups.AddToList(Group := this.Group(Fields))
        }
    }

    class Groups extends MapExClass {
        static __New() {
            if this.Prototype.__Class == 'IGroups.Groups' {
                this.__Item := Map()
                for dc in IGroups.DayCodes {
                    this.Set(dc, MapEx(false))
                    this.Get(dc).DayCode := dc
                }
            }
        }
        static AddToList(Group) {
            for dc in Group.DayCodes {
                Groups := this.Get(dc)
                if !Groups.Has(Group.StartTime) {
                    Groups.Set(Group.StartTime, IGroups.StartTime(Group))
                }
                Groups.Get(Group.StartTime).Push(Group)
            }
        }
        static IsWithinFifteen(DayCode, DaySeconds) {
            for Time, StartTimeCollection in this.Get(DayCode) {
                if Result := StartTimeCollection.IsWithinFifteen(DaySeconds) {
                    return Result
                }
            }
        }
    }


    class Group extends MapEx {

        __New(Fields) {
            this.Id := Fields[1]
            this.Name := Fields[2]
            this.Type := Fields[3]
            this.Track := Fields[4]
            this.Gender := Fields[5]
            this.Day := Fields[6]
            t := StrSplit(Fields[7], ':', '`s`t')
            this.__StartTime := DateObj.FromTimestamp(SubStr(ContactsConfig.LastMonth.Timestamp, 1, 8) Format('{:02}', t[1]) Format('{:2}', t[2]) '00')
            this.Location := Fields[8]
            this.DayCodes := []
            for dc in IGroups.DayCodes {
                if InStr(this.Day, dc) {
                    this.DayCodes.Push(dc)
                }
            }
        }

        DaySeconds => this.__StartTime.DaySeconds
        StartTime => SubStr(this.__StartTime.Timestamp, 9, 4)
    }

    class StartTime extends Array {
        __New(Group) {
            this.StartTime := Group.StartTime
            this.DaySeconds := Group.DaySeconds
            this.Push(Group)
        }

        IsWithinFifteen(DaySeconds) {
            Diff := DaySeconds - this.DaySeconds
            if Diff > -900 && Diff <= 0 {
                return 'Before'
            } else if Diff > 0 && Diff < 900 {
                return 'After'
            }
        }
    }
}
