/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk
    Author: Nich-Cebolla
    Version: 2.0.0
    License: MIT
*/

class DateObj {

    /**
     * @description - Creates a `DateObj` instance from a date string and date format string. The
     * parser is created in the process, and is available from the property `DateObjInstance.Parser`.
     * @param {String} DateStr - The date string to parse.
     * @param {String} DateFormat - The format of the date string. The format follows the same rules as
     * described on the AHK `FormatTime` page: {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm}.
     * - The format string can include any of the following units: 'y', 'M', 'd', 'H', 'h', 'm', 's', 't'.
     * See the link for details.
     * - Only numeric day units are recognized by this function. This function will not match with
     * days like 'Mon', 'Tuesday', etc.
     * - In addition to the units, RegEx is viable within the format string. To permit compatibility
     * between the unit characters and RegEx, please adhere to these guidelines:
     *   - If the format string contains one or more literal "y", "M", "d", "H", "h", "m", "s" or "t"
     * characters, you must escape the date format units using this escape: \t{...}
     * @example
     *  DateStr := '2024-01-28 19:15'
     *  DateFormat := 'yyyy-MM-dd HH:mm'
     *  Date := DateObj(DateStr, DateFormat)
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute) ; 2024-01-28 19:15
     * @
     * @example
     *  DateStr := 'Voicemail From <1-555-555-5555> at 2024-01-28 07:15:20'
     *  DateFormat := 'at \t{yyyy-MM-dd HH:mm:ss}'
     *  Date := DateObj(DateStr, DateFormat)
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 2024-01-28 07:15:20
     * @
     *
     *   - You can include multiple sets of \t escaped format units.
     * @example
     *  DateStr := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15:20 AM'
     *  DateFormat := 'Received \t{MMMM dd, yyyy} at \t{hh:mm:ss tt}'
     *  Date := DateObj(DateStr, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 2024-01-28 00:15:20
     * @
     *
     *   - You can use the "?" quantifier.
     * @example
     *  DateStr1 := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15 AM'
     *  DateStr2 := 'Voicemail From <1-555-555-5555> Received January 28, 2024 at 12:15:12 AM'
     *  DateFormat := 'Received \t{MMMM dd, yyyy} at \t{hh:mm:?ss? tt}'
     *  Date1 := DateObj(DateStr1, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  Date2 := DateObj(DateStr2, DateFormat, 'i)')
     *  MsgBox(Date1.Year '-' Date1.Month '-' Date1.Day ' ' Date1.Hour ':' Date1.Minute ':' Date1.Second) ; 2024-01-28 00:15:00
     *  Date2 := DateObj(DateStr2, DateFormat)
     *  MsgBox(Date2.Year '-' Date2.Month '-' Date2.Day ' ' Date2.Hour ':' Date2.Minute ':' Date2.Second) ; 2024-01-28 00:15:12
     * @
     *
     *   - The match object is set to the property `DateObjInstance.Match`. Include any extra subcapture
     * groups that you are interested in.
     * @example
     *  DateStr := 'The child was born May 2, 1990, the year of the horse'
     *  DateFormat := '\t{MMMM d, yyyy}, the year of the (?<animal>\w+)'
     *  Date := DateObj(DateStr, DateFormat, 'i)') ; Use case insensitive matching when matching a month by name.
     *  MsgBox(Date.Year '-' Date.Month '-' Date.Day ' ' Date.Hour ':' Date.Minute ':' Date.Second) ; 1990-05-02 00:00:00
     *  MsgBox(Date.Match['animal']) ; horse
     * @
     *
     * @param {String} [RegExOptions=""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     * @param {Boolean} [SubcaptureGroup=true] - When true, each \t escaped format group is captured
     * in an unnamed subcapture group. When false, the function does not include any additional
     * subcapture groups.
     * @param {Boolean} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used.
     * @param {Boolean} [Validate=false] - When true, the values of each property are validated
     * before the function completes. The values are validated numerically, and if any value exceeds
     * the maximum value for that property, an error is thrown. For example, if the month is greater
     * than 12 or the hour is greater than 24, an error is thrown.
     * @returns {DateObj} - The `DateObj` object.
     */
    static Call(DateStr, DateFormat, RegExOptions := '', SubcaptureGroup := true, Century?, Validate := false) {
        return DateParser(DateFormat, RegExOptions, SubcaptureGroup)(DateStr, Century ?? unset, Validate)
    }

    /**
     * @description - Creates a `DateObj` object from a timestamp string.
     * @param {String} Timestamp - The timestamp string to create the `DateObj` object from. `Timestamp`
     * should at least be 4 characters long containing the year. The rest is optional.
     * @returns {DateObj} - The `DateObj` object.
     */
    static FromTimestamp(Timestamp) {
        ObjSetBase(Date := {
            Year: SubStr(Timestamp, 1, 4)
          , Month: StrLen(Timestamp) > 4 ? SubStr(Timestamp, 5, 2) : unset
          , Day:  StrLen(Timestamp) > 6 ? SubStr(Timestamp, 7, 2) : unset
          , Hour:  StrLen(Timestamp) > 8 ? SubStr(Timestamp, 9, 2) : unset
          , Minute:  StrLen(Timestamp) > 10 ? SubStr(Timestamp, 11, 2) : unset
          , Second:  StrLen(Timestamp) > 12 ? SubStr(Timestamp, 13, 2) : unset
        }, DateObj.Prototype)
        return Date
    }

    /**
     * @description - Get the number of days in a month.
     * @param {Integer} Month - The month to get the number of days for.
     * @param {Integer} [Year] - The year to get the number of days for.
     * If not set, the current year is used.
     * @returns {Integer} - The number of days in the month.
     */
    static GetMonthDays(Month, Year?) {
        switch Month, 0 {
            case '1', '3', '5', '7', '8', '10', '12':
                return 31
            case '4', '6', '9', '11':
                return 30
            case '2':
                return Mod(Year ?? SubStr(A_Now, 1, 4), 4) ? 28 : 29
            default:
                throw ValueError('``Month`` must be an integer between 1 and 12.', -1, 'Value: ' Month)
        }
    }

    /**
     * @description - Returns the month index. Indices are 1-based. (January is 1).
     * @param {String} MonthStr - Three or more of the first characters of the month's name.
     * @param {Boolean} [TwoDigits=false] - When true, the return value is padded to always be 2 digits.
     * @returns {String} - The 1-based index.
     */
    static GetMonthIndex(MonthStr, TwoDigits := false) {
        if TwoDigits {
            switch SubStr(MonthStr, 1, 3), 0 {
                case 'jan': return '01'
                case 'feb': return '02'
                case 'mar': return '03'
                case 'apr': return '04'
                case 'may': return '05'
                case 'jun': return '06'
                case 'jul': return '07'
                case 'aug': return '08'
                case 'sep': return '09'
                case 'oct': return '10'
                case 'nov': return '11'
                case 'dec': return '12'
                default:
                    throw ValueError('Unexpected value for "Month".', -1, MonthStr)
            }
        } else {
            switch SubStr(MonthStr, 1, 3), 0 {
                case 'jan': return '1'
                case 'feb': return '2'
                case 'mar': return '3'
                case 'apr': return '4'
                case 'may': return '5'
                case 'jun': return '6'
                case 'jul': return '7'
                case 'aug': return '8'
                case 'sep': return '9'
                case 'oct': return '10'
                case 'nov': return '11'
                case 'dec': return '12'
                default:
                    throw ValueError('Unexpected value for "Month".', -1, MonthStr)
            }
        }
    }

    /**
     * @description - Sets the default values that the date objects will use for the timestamp when
     * the value is absent.
     * @param {String} [year] - Year.
     * @param {String} [month] - Month.
     * @param {String} [day] - Day.
     * @param {String} [hour] - Hour.
     * @param {String} [minute] - Minute.
     * @param {String} [second] - Second.
     * @param {String} [options] - Options.
     */
    static SetDefault(year?, month?, day?, hour?, minute?, second?, options?) {
        Proto := DateObj.Prototype
        if IsSet(year)
            Proto.Year := year
        if IsSet(month)
            Proto.Month := month
        if IsSet(day)
            Proto.Day := day
        if IsSet(hour)
            Proto.Hour := hour
        if IsSet(minute)
            Proto.Minute := minute
        if IsSet(second)
            Proto.Second := second
        if IsSet(options)
            Proto.Options := options
    }

    /**
     * @property {DateObj.Parser} Parser - The parser object used to create this `DateObj` object.
     * It can be reused to create more `DateObj` objects from the same format string.
     */
    Parser := ''

    /**
     * @property {Integer} DaySeconds - The number of seconds from midnight.
     */
    DaySeconds => this.Hour * 3600 + this.Minute * 60 + this.Second
    /**
     * @property {String} Timestamp - The timestamp of the date object.
     */
    Timestamp => this.GetTimestamp()
    /**
     * @property {Integer} YearSeconds - The number of seconds since January 01, 00:00:00 of the current year.
     */
    YearSeconds {
        Get {
            s := 0
            loop this.Month - 1 {
                s += DateObj.GetMonthDays(A_Index) * 24 * 3600
            }
            return s + (this.Day - 1) * 24 * 3600 + this.DaySeconds
        }
    }

    /**
     * {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Standalone_Formats}
     */
    /**
     * @property {String} LongDate - Long date representation for the current user's locale,
     * such as Friday, April 23, 2004.
     */
    LongDate => FormatTime(this.Timestamp ' ' this.Options, 'LongDate')
    /**
     * @property {String} ShortDate - Short date representation for the current user's locale,
     * such as 02/29/04.
     */
    ShortDate => FormatTime(this.Timestamp ' ' this.Options, 'ShortDate')
    /**
     * @property {String} Time - Time representation for the current user's locale, such as 5:26 PM.
     */
    Time => FormatTime(this.Timestamp ' ' this.Options, 'Time')
    /**
     * @property {String} ToLocale - "Leave Format blank to produce the time followed by the long date.
     * For example, in some locales it might appear as 4:55 PM Saturday, November 27, 2004"
     */
    ToLocale => FormatTime(this.Timestamp)
    /**
     * @property {String} WDay - Day of the week (1 – 7). Sunday is 1.
     */
    WDay => FormatTime(this.Timestamp ' ' this.Options, 'WDay')
    /**
     * @property {String} YDay - Day of the year without leading zeros (1 – 366).
     */
    YDay => FormatTime(this.Timestamp ' ' this.Options, 'YDay')
    /**
     * @property {String} YDay0 - Day of the year with leading zeros (001 – 366).
     */
    YDay0 => FormatTime(this.Timestamp ' ' this.Options, 'YDay0')
    /**
     * @property {String} YearMonth - Year and month format for the current user's locale, such as
     * February, 2004.
     */
    YearMonth => FormatTime(this.Timestamp ' ' this.Options, 'YearMonth')
    /**
     * @property {String} YWeek - The ISO 8601 full year and week number.
     */
    YWeek => FormatTime(this.Timestamp ' ' this.Options, 'YWeek')

    /**
     * @description - Adds the time to this object's timestamp.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm}
     * @param {Integer} Time - The amount of time to add, as an integer or floating-point number.
     * Specify a negative number to perform subtraction.
     * @param {String} TimeUnits - The meaning of the Time parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {String} - The new timestamp.
     */
    Add(Time, TimeUnits) => DateAdd(this.Timestamp, Time, TimeUnits)

    /**
     * @description - Adds the time to this object's timestamp, then creates a new object.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm}
     * @param {Integer} Time - The amount of time to add, as an integer or floating-point number.
     * Specify a negative number to perform subtraction.
     * @param {String} TimeUnits - The meaning of the Time parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {DateObj} - The new `DateObj` object.
     */
    AddToNew(Time, TimeUnits) => DateObj.FromTimestamp(this.Add(Time, TimeUnits))

    /**
     * @description - Get the difference between two dates.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateDiff.htm}
     * @param {String} Unit - Units to measure the difference in. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @param {String} [Timestamp] - The timestamp to compare to. If not set, the current time is used.
     * @returns {Integer} - The difference between the two dates.
     */
    Diff(Unit, Timestamp?) => DateDiff(this.Timestamp, Timestamp ?? A_Now, Unit)

    /**
     * @description - Get the timestamp from the date object. You can pass default values to
     * any of the parameters. Also see {@link DateObj.SetDefault}.
     * @param {String} [DefaultYear] - The default year to use if the year is not set.
     * @param {String} [DefaultMonth] - The default month to use if the month is not set.
     * @param {String} [DefaultDay] - The default day to use if the day is not set.
     * @param {String} [DefaultHour] - The default hour to use if the hour is not set.
     * @param {String} [DefaultMinute] - The default minute to use if the minute is not set.
     * @param {String} [DefaultSecond] - The default second to use if the second is not set.
     * @returns {String} - The timestamp.
     */
    GetTimestamp(DefaultYear?, DefaultMonth?, DefaultDay?, DefaultHour?, DefaultMinute?, DefaultSecond?) {
        return (
            (this.HasOwnProp('Year') ? this.Year : DefaultYear ?? this.Base.Year)
            (this.HasOwnProp('Month') ? this.Month : DefaultMonth ?? this.Base.Month)
            (this.HasOwnProp('Day') ? this.Day : DefaultDay ?? this.Base.Day)
            (this.HasOwnProp('Hour') ? this.Hour : DefaultHour ?? this.Base.Hour)
            (this.HasOwnProp('Minute') ? this.Minute : DefaultMinute ?? this.Base.Minute)
            (this.HasOwnProp('Second') ? this.Second : DefaultSecond ?? this.Base.Second)
        )
    }

    /**
     * @description - Adds options that get used when accessing any of the time format properties.
     * @param {String} Options - The options to use.
     * @see https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Additional_Options
     */
    Opt(Options) => this.Options := Options

    /**
     * @description - Enables the ability to get a numeric value by adding 'N' to the front of a
     * property name.
     * @example
     *  Date := DateObj('2024-01-28 19:15', 'yyyy-MM-dd HH:mm')
     *  MsgBox(Type(Date.Minute)) ; String
     *  MsgBox(Type(Date.NMinute)) ; Integer
     *
     *  ; AHK handles conversions most of the time anyway.
     *  z := 10
     *  MsgBox(Date.NMinute + z) ; 25
     *  MsgBox(Date.Minute + z) ; 25
     *
     *  ; Map object keys do not convert.
     *  m := Map(15, 'val')
     *  MsgBox(m[Date.NMinute]) ; 'val'
     *  MsgBox(m[Date.Minute]) ; Error: Item has no value.
     * @
     */
    __Get(Name, *) {
        if SubStr(Name, 1, 1) = 'N' && this.HasOwnProp(SubStr(Name, 2)) {
            return Number(this.%SubStr(Name, 2)%||0)
        }
        throw PropertyError('Unknown property.', -1, Name)
    }

    static __New() {
        if this.Prototype.__Class == 'DateObj' {
            Proto := this.Prototype
            Proto.Year := SubStr(A_Now, 1, 4)
            Proto.Month := '01'
            Proto.Day := '01'
            Proto.Hour := '00'
            Proto.Minute := '00'
            Proto.Second := '00'
            Proto.Options := ''
        }
    }
}

class DateParser {

    /**
     * @description - Contains three built-in patterns to parse date strings. These are the literal patterns:
     * @example
     *  p1 := '(?<Year>\d{4}).(?<Month>\d{1,2}).(?<Day>\d{1,2})(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?'
     *  p2 := '(?<Month>\d{1,2}).(?<Day>\d{1,2}).(?<Year>(?:\d{4}|\d{2}))(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?'
     *  p3 := '(?<Hour>\d{1,2}):(?<Minute>\d{1,2})(?::(?<Second>\d{1,2}))?'
     * @
     *
     * The patterns represent strings like these. This is not an exhaustive list:
     * "yyyy-M-d H:m:s" - the time units are optional, seconds optional within the time units
     * "M/d/yyyy H:m:s" - the time units are optional, seconds optional within the time units
     * "M/d/yy H:m:s" - the time units are optional, seconds optional within the time units
     * "h:m:s" - time by itself, the seconds optional
     *
     * @param {String} DateStr - The date string to parse.
     * @returns {DateObj} - The `DateObj` object.
     */
    static Parse(DateStr) {
        if RegExMatch(DateStr, '(?<Year>\d{4}).(?<Month>\d{1,2}).(?<Day>\d{1,2})(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?', &match)
        || RegExMatch(DateStr, '(?<Month>\d{1,2}).(?<Day>\d{1,2}).(?<Year>(?:\d{4}|\d{2}))(?:.+?(?<Hour>\d{1,2}).(?<Minute>\d{1,2})(?:.(?<Second>\d{1,2}))?)?', &match) {
            ObjSetBase(Date := {
                Year: match.Len['Year'] == 2 ? SubStr(A_Now, 1, 2) match['Year'] : match['Year']
              , Month: (match.Len['Month'] == 1 ? '0' : '') match['Month']
              , Day: (match.Len['Day'] == 1 ? '0' : '') match['Day']
              , Hour: match.Len['Hour'] ? (match.Len['Hour'] == 1 ? '0' : '') match['Hour'] : unset
              , Minute: match.Len['Minute'] ? (match.Len['Minute'] == 1 ? '0' : '') match['Minute'] : unset
              , Second: match.Len['Second'] ? (match.Len['Second'] == 1 ? '0' : '') match['Second'] : unset
            }, DateObj.Prototype)
        } else if RegExMatch(DateStr, '(?<Hour>\d{1,2}):(?<Minute>\d{1,2})(?::(?<Second>\d{1,2}))?', &match) {
            ObjSetBase(Date := {
                Hour: (match.Len['Hour'] == 1 ? '0' : '') match['Hour']
              , Minute: (match.Len['Minute'] == 1 ? '0' : '') match['Minute']
              , Second: match['Second'] ? (match.Len['Second'] == 1 ? '0' : '') match['Second'] : unset
            }, DateObj.Prototype)
        }
        Date.Match := match
        return Date
    }

    /**
     * @description - Creates a `DateParser` object that can be reused to create `DateObj` objects.
     * @param {String} DateFormat - The format of the date string. See the `DateObj.Call`
     * description for details.
     * @param {String} [RegExOptions=""] - The RegEx options to add to the beginning of the pattern.
     * Include the close parenthesis, e.g. "i)".
     * @param {Boolean} [SubcaptureGroup=true] - When true, each \t escaped format group is captured
     * in an unnamed subcapture group. When false, the function does not include any additional
     * subcapture groups.
     * @returns {DateParser} - The `DateParser` object.
     */
    __New(DateFormat, RegExOptions := '', SubcaptureGroup := true) {
        rc := Chr(0xFFFD) ; replacement character
        replacement := []
        replacement.Capacity := 20
        flag_period := false
        pos := 1
        i := 0
        while RegExMatch(DateFormat, '\\t\{([^}]+)\}', &matchgroup, pos) {
            copy := matchgroup[1]
            pos := matchgroup.Pos + matchgroup.Len
            _Proc(&copy)
            if SubcaptureGroup {
                DateFormat := StrReplace(DateFormat, matchgroup[0], '(' copy ')', , , 1)
            } else {
                DateFormat := StrReplace(DateFormat, matchgroup[0], '(?:' copy ')', , , 1)
            }
        }
        if !i {
            _Proc(&DateFormat)
        }
        if this.12hour && !flag_period {
            throw Error('The date format string indicates 12-hour time format, but does not include an AM/PM indicator', -1)
        }
        for r in replacement {
            DateFormat := StrReplace(DateFormat, r.temp, r.pattern, , , 1)
        }
        this.RegExOptions := RegExOptions
        this.Pattern := DateFormat

        _Proc(&p) {
            if RegExMatch(p, '(y+)(\??)', &match) {
                replacement.Push({ pattern: '(?<Year>\d{' (match.Len[1] == 1 ? '1,2' : match.Len[1]) '})' match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
            }
            if RegExMatch(p, '(M+)(\??)', &match) {
                if match.Len[1] == 1 {
                    pattern := '(?<Month>\d{1,2})'
                } else if match.Len[1] == 2 {
                    pattern := '(?<Month>\d{2})'
                } else if match.Len[1] == 3 {
                    pattern := '(?<Month>(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec))'
                } else if match.Len[1] == 4 {
                    pattern := '(?<Month>(?:january|february|march|april|may|june|july|august|september|october|november|december))'
                }
                replacement.Push({ pattern: pattern match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
            }
            if RegExMatch(p, '(h+)(\??)', &match) {
                replacement.Push({ pattern: '(?<Hour>\d{' (match.Len[1] == 1 ? '1,2' : '2') '})' match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                this.12hour := true
            }
            if RegExMatch(p, '(t+)(\??)', &match) {
                if match.Len[1] == 1 {
                    pattern := '(?<Period>[ap])'
                } else {
                    pattern := '(?<Period>[ap]m)'
                }
                replacement.Push({ pattern: pattern match[2], temp: rc (++i) rc })
                p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                flag_period := true
            }
            for ch, name in Map('d', 'Day', 'H', 'Hour', 'm', 'Minute', 's', 'Second') {
                if RegExMatch(p, '(' ch '+)(\??)', &match) {
                    replacement.Push({ pattern: '(?<' name '>\d{' (match.Len[1] == 1 ? '1,2' : '2') '})' match[2], temp: rc (++i) rc })
                    p := StrReplace(p, match[0], replacement[-1].temp, true, , 1)
                }
            }
        }
    }

    /**
     * @description - Parses the input date string and returns a `DateObj` object.
     * @param {String} DateStr - The date string to parse.
     * @param {String} [Century] - The century to use when parsing a 1- or 2-digit year. If not set,
     * the current century is used.
     * @param {Boolean} [Validate=false] - When true, the values of each property are validated
     * before the function completes. The values are validated numerically, and if any value exceeds
     * the maximum value for that property, an error is thrown. For example, if the month is greater
     * than 13 or the hour is greater than 24, an error is thrown.
     * @returns {DateObj} - The `DateObj` object.
     */
    Call(DateStr, Century?, Validate := false) {
        local Match
        if !RegExMatch(DateStr, this.RegExOptions this.Pattern, &match) {
            return ''
        }
        ObjSetBase(Date := {}, DateObj.Prototype)
        Date.DefineProp('Parser', { Value: this })
        Date.DefineProp('Match', { Value: match })
        for unit, str in match {
            switch unit {
                case 'Year':
                    if match.Len['Year'] {
                        switch match.Len['Year'] {
                            case 1: Date.DefineProp('Year', { Value: (Century ?? SubStr(A_Now, 1, 3)) match['Year'] })
                            case 2: Date.DefineProp('Year', { Value: (Century ?? SubStr(A_Now, 1, 2)) match['Year'] })
                            case 4: Date.DefineProp('Year', { Value: match['Year'] })
                        }
                    }
                case 'Month':
                    if match.Len['Month'] {
                        if IsNumber(match['Month']) {
                            if match.Len['Month'] == 1 {
                                Date.DefineProp('Month', { Value: '0' match['Month'] })
                            } else {
                                Date.DefineProp('Month', { Value: match['Month'] })
                            }
                        } else {
                            Date.DefineProp('Month', { Value: DateObj.GetMonthIndex(match['Month'], true) })
                        }
                    }
                case 'Hour':
                    if match.Len['Hour'] {
                        if this.12hour {
                            n := Number(match['Hour'])
                            switch SubStr(match['Period'], 1, 1), 0 {
                                case 'a':
                                    if n == 12 {
                                        Date.DefineProp('Hour', { Value: '00' })
                                    } else if Match.Len['Hour'] == 1 {
                                        Date.DefineProp('Hour', { Value: '0' match['Hour'] })
                                    } else {
                                        Date.DefineProp('Hour', { Value: match['Hour'] })
                                    }
                                case 'p':
                                    if n == 12 {
                                        Date.DefineProp('Hour', { Value: '12' })
                                    } else {
                                        Date.DefineProp('Hour', { Value: String(n + 12) })
                                    }
                            }
                        } else {
                            if match.Len['Hour'] == 1 {
                                Date.DefineProp('Hour', { Value: '0' match['Hour'] })
                            } else if match.Len['Hour'] == 2 {
                                Date.DefineProp('Hour', { Value: match['Hour'] })
                            }
                        }
                    }
                case 'Minute', 'Second', 'Day':
                    if match.Len[unit] {
                        if match.Len[unit] == 1 {
                            Date.DefineProp(unit, { Value: '0' match[unit] })
                        } else if match.Len[unit] == 2 {
                            Date.DefineProp(unit, { Value: match[unit] })
                        }
                    }
            }
        }
        if Validate {
            if Date.NMonth > 12
                _ThrowInvalidResultError('Month: ' Date.Month)
            ; If we don't know the year and the month is February, use 29 as the value by default
            if Date.Month == '02' && !Date.Year {
                if Date.NDay > 29
                    _ThrowInvalidResultError('Day: ' Date.Day)
            } else if Date.NDay > DateObj.GetMonthDays(Date.NMonth, Date.NYear)
                _ThrowInvalidResultError('Day: ' Date.Day)
            if Date.NHour > 24
                _ThrowInvalidResultError('Hour: ' Date.Hour)
            if Date.NMinute > 60
                _ThrowInvalidResultError('Minute: ' Date.Minute)
            if Date.NSecond > 60
                _ThrowInvalidResultError('Second: ' Date.Second)
        }
        return Date

        _ThrowInvalidResultError(Value) {
            throw ValueError('The result produced an invalid date.', -2, Value)
        }
    }

    static __New() {
        if this.Prototype.__Class == 'DateParser' {
            this.Prototype.12hour := false
        }
    }
}
