
class ContactsConfig {

    static timestamp :=  FormatTime(A_Now, 'yyyy-MM-dd_HH-mm-ss')
    static CommaReplacement := Chr(0xFCCC) '1' Chr(0xFCCC)
    static SetDate() {
        this.Today := DateObj.FromTimestamp(A_Now)
        this.LastMonth := DateObj.FromTimestamp(A_Now).AddToNew(this.Today.Day * -1 - 1, 'D')
        this.LastMonth.Day := '01'
        this.LastMonth.Hour := this.LastMonth.Minute := this.LastMonth.Second := '00'
    }
    static __date := this.SetDate() || this.LastMonth.Year '-' this.LastMonth.Month

    static out := this.__Date
    static PathOut[Date := this.__Date] => Format('{}\{}-output.csv', this.out, Date)

    static In := this.__Date
    static PathInCalls[Date := this.__Date] => Format('{}\{}-calls.csv', this.In, Date)
    static PathInGroups[Date := this.__Date] => Format('{}\{}-groups.csv', this.In, Date)
    static PathInVoicemails[Date := this.__Date] => Format('{}\{}-voicemails.csv', this.In, Date)
    static PathInPracticeMeetIng[Date := this.__Date] => Format('{}\{}-practice.csv', this.In, Date)
    static PathInAttendance[Date := this.__Date] => Format('{}\{}-attendance-cleaned.csv', this.In, Date)
    static PathInGlpi[Date := this.__Date] => Format('{}\{}-glpi.csv', this.In, Date)
    static PathInGlpi_Cleaned[Date := this.__Date] => Format('{}\{}-glpi-cleaned.csv', this.In, Date)

    static  CallFrom := ['1060', '1063']
    , DID := '6027614950'
    , CallTo := ['6', '8', '17', '1060', '1063', '6027614950', 'vmu3000', 'vmb6003']
    , DestNumber := ['6', '8', '17', '1060', '1063', '6027614950', 'vmu3000', 'vmb6003', '6003@default,b']
    , DestAnsweredBy := ['6', '8', '17', '1060', '1063', '6027614950', 'vmu3000', 'vmb6003']

    , OptGui := {Title: 'Ahk.Contacts', BgColor: 'White', Opt: '+Resize +Owner -DPIScale', MarginX: 10, MarginY: 10}
    , OptFont := {Size: 11, Family: 'Consolas', Color: 'Black', Opt: ''}
    , OptSection := { InitialX: 10, InitialY: 10 }
    , ListViewParams := Map()

    static ErrorGui := {
        Width: 800
      , BtnWidth: 80
      , FontName: 'Mono,Arial Rounded MT,Roboto Mono,Ubuntu Mono,IBM Plex Mono'
      , FontOpt: 's11 q5'
      , EdtRows: 8
      , ThreadDpiAwarenessContext: -3
    }
}

class Strings {
    class ErrorGui {
        static TxtMain := 'There was a problem opening "{1}".`r`nTo select a new file click "Select".'
    }
}


class ParseCSVConfig {
    static Set(Name) {
        switch Name, 0 {
            case 'Voicemails', 'Calls', 'Groups', 'Attendance', 'Glpi':
                this.QuoteChar := '"'
        }
        this.PathIn := ContactsConfig.PathIn%Name%
    }
    static Breakpoint := ''
    static BreakpointAction := ''
    static CollectionArrayBuffer := 1000
    static Constructor := ''
    static Encoding := ''
    static FieldDelimiter := ','
    static Headers := ''
    static MaxReadSizeBytes := 0
    static PathIn := ''
    static QuoteChar := ''
    static RecordDelimiter := '`n'
    static Start := true
}

/*
Not in use

class Tables {
    static ByQueue := [
        {Title: 'Queue {1}', Rows: [
            {Text: 'Answered - 15 minutes before', Value: 0, Type: 'Data'}
              , {Text: 'Answered - 15 minutes after', Value: 0, Type: 'Data'}
              , {Text: 'Sum:', Value: 0, Type: 'Sum'}
              , {Text: 'No answer - 15 minutes before', Value: 0, Type: 'Data'}
              , {Text: 'No answer - 15 minutes after', Value: 0, Type: 'Data'}
              , {Text: 'Sum:', Value: 0, Type: 'Sum'}
              , {Text: 'Answered - not within 15', Value: 0, Type: 'Data'}
              , {Text: 'No answer - not within 15', Value: 0, Type: 'Data'}
              , {Text: 'Sum:', Value: 0, Type: 'Sum'}
              , {Text: 'Total answered:', Value: 0, Type: 'Total'}
              , {Text: 'Total no answer:', Value: 0, Type: 'Total'}
            ]
        }
      , {Text: 'Grand total:', Value: 0, Type: 'GrandTotal'}
    ]

    static ByDay := [
        {
            Title: 'Group Day - {1}', Rows: [
              , {Text: 'Total - Fifteen before', Value: 0, Type: 'Data'}
              , {Text: 'Total - Fifteen after', Value: 0, Type: 'Data'}
              , {Text: 'Total - Not within fifteen', Value: 0, Type: 'Data'}
            ]
        }
      , {Text: 'Grand total:', Value: 0, Type: 'GrandTotal'}
    ]

    static WhereCallsAreGoing := [
        {
            Title: 'Day: {1}', Rows: [
                {Text: 'Voicemail', Value: 0, Type: 'Data'}
              , {Text: 'Time conditions', Value: 0, Type: 'Data'}
              , {Text: 'Recording', Value: 0, Type: 'Data'}
              , {Text: 'Background', Value: 0, Type: 'Data'}
            ]
        }
      , {
            Title: 'Totals:', Rows: [
                {Text: 'Voicemail', Value: 0, Type: 'Total'}
              , {Text: 'Time conditions', Value: 0, Type: 'Total'}
              , {Text: 'Recording', Value: 0, Type: 'Total'}
              , {Text: 'Background', Value: 0, Type: 'Total'}
            ]
        }
    ]

    static DistributionsByDy := {
        Title: 'Day: {1}', Table: {
            Header: 'Start time {1}', Rows: [
                {Text: 'Groups', Value: 0, Type: 'Data'}
              , {Text: 'Attendees - attended', Value: 0, Type: 'Data'}
              , {Text: 'Attendees - no show', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen before - all', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen after - all', Value: 0, Type: 'Data'}
              , {Text: 'Sum - all', Value: 0, Type: 'Sum'}
              , {Text: 'Fifteen before - answered by meeting support', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen after - answered by meeting support', Value: 0, Type: 'Data'}
              , {Text: 'Sum - answered by meeting support', Value: 0, Type: 'Sum'}
              , {Text: 'Fifteen before - missed by meeting support', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen after - missed by meeting support', Value: 0, Type: 'Data'}
              , {Text: 'Sum - missed by meeting support', Value: 0, Type: 'Sum'}
              , {Text: 'Fifteen before - answered by other', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen after - answered by other', Value: 0, Type: 'Data'}
              , {Text: 'Sum - answered by other', Value: 0, Type: 'Sum'}
              , {Text: 'Fifteen before - missed by all', Value: 0, Type: 'Data'}
              , {Text: 'Fifteen after - missed by all', Value: 0, Type: 'Data'}
              , {Text: 'Sum - missed by all', Value: 0, Type: 'Sum'}
              , {Text: 'Total - answered by all', Value: 0, Type: 'Total'}
              , {Text: 'Not within fifteen', Value: 0, Type: 'Data'}
            ]
        }
    }

    static CallerBehavior := {

    }
}
