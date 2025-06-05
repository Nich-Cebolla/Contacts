/*
    Github: https://github.com/Nich-Cebolla/AutoHotkey-DateObj/blob/main/DateObj.ahk
    Author: Nich-Cebolla
    Version: 1.0.1
    License: MIT
*/

class DateObj extends DateObj.Base {

    /**
     * @description - Creates a `DateObj` instance from a date string and date format string. The
     * parser is created in the process, and is available from the property `DateObjInstance.Parser`.
     * @param {String} DateString - The date string to create the `DateObj` instance from.
     * @param {String} DateFormat - The format of the date string. The format follows the same rules as
     * described on the AHK `FormatDate` page: {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm}.
     * - The format string can include any of the following units: 'y', 'M', 'd', 'H', 'h', 'm', 's', 't'.
     * See the link for details.
     * - Only numeric day units are recognized by this function. This function will not match with
     * days like 'Mon', 'Tuesday', etc.
     * - In addition to the units, RegEx is viable within the format string. To permit compatibility
     * between the unit characters and RegEx, please adhere to these guidelines:
     * - If you intend to use any of 'y, m, d, h, s, t' or their capitalized counterparts literally,
     * you must escape the character with double backticks (e.g. '``y', '``m', '``d', etc.).
     * - To write a literal backtick followed by one of those letters, use quadruple backticks.
     * - Characters inside character classes (e.g. '[a-zA-Z]') and inside subcapture group names
     * (e.g. "mygroup" in `(?<mygroup>``mon|``tue)`) do not need to be escaped.
     * - All other verbs and special methods available in RegEx require escaped 'ymdhst' characters
     * with the double backtick, at least until I add support for callouts and verbs without backticks.
     * - Remember, the whole pattern must match on the date string for the function to succeed, so you
     * will sometimes want to leverage '.+?' to match arbitary substrings in-between the date units.
     * @example
        DateStr := 'Jan 02, 1992 @ 2 after 5 pm'
        DateFormat := 'MMM dd, yyyy.+?m.+?h tt'

        DateStr := '2024-01-28 19:00'
        DateFormat := 'yyyy-MM-dd HH:mm'

        DateStr := '2024-01-28 07:00 PM'
        DateFormat := 'yyyy-MM-dd hh:mm tt'

        DateStr := '12, Dec, around 2 AM'
        DateFormat := 'dd, MMM.+?h tt'

        ; You can use '?' when a unit may or may not be present in a string. Note that it can be
        ; challenging to get the pattern to match the way you want when using the '?' quantifier.
        ; The RegEx engine might skip the unit completely, even when present in the date string,
        ; if the content of your pattern is ambiguous. In the below example, this matches as expected.
        ; Without the '``sec' at the end, the pattern does not match correctly with the minutes.
        DateStr1 := 'In first place at just under 59 seconds'
        DateStr2 := 'In second place at 1 minute 2 seconds'
        DateFormat := 'm? \w+ ?s ``sec'

        ; If the '?' quantifier is not working as expected, it might be more effective to group the
        ; variable units with some nearby text that you know will appear along with the unit.
        DateStr1 := 'Appointment time: Fri @ 3:30 PM'
        DateStr2 := 'Appointment time: Fri, March 3, @ 3:30 PM'
        DateFormat := '(?:, MMMM d,)? @ h:mm tt'

        ; The `RegExMatchInfo` object is set to the property `Match`. If there's other information
        ; in the string you are interested in, you can capture that in your format string too.
        DateStr := 'Born March 30, 1992 - the year of the monkey'
        DateFormat := 'MMMM d, yyyy.+?(?<animal>``year.+)'

        ; You may sometimes want to use single-digit version of a unit insted of the two-digit unit.
        DateStr1 := '2024-11-28 11:05:01'
        DateStr2 := '2024-1-9 8:43:09'
        ; If we use 'yyyy-MM-dd HH:mm:ss', even though it matches the first, it will fail to match
        ; the second. The below format string will match both.
        DateFormat := 'yyyy-M-d H:mm:ss'
    @
    * @param {Boolean} [RegExOptions='i)'] - The RegEx options to add to the beginning of the pattern.
    * @param {Integer} [Cache=1] - Any one of the following flags:
    * - 1: If the `DateFormat` string is in the cache, the associated object will be retrieved and
    * set as this object's base. This instance will inherit the properties from the cached object.
    * If the current input `IfShortYear` or `RegExOptions` values are different from the values
    * set on the cached object, this instance will reflect the new values. No further processing
    * is done to this instance. If `DateFormat` has not been cached, this instance will be added
    * to the cache with the key being the `DateFormat` string.
    * - 2: The cache is ignored and a new object is created. Nothing is added to the cache.
    * - 3: The cache is ignored and a new object is created, and this instance is added to the
    * cache, overwriting any existing cached object with the same `DateFormat` string.
    * @param {String} [IfShortYear] - Use this to specify the century when the year is 1 or 2
    * digits length. When unset, the current century is used. Example: '20' for 2020, or if the
    * year has 1 digit, '200' for 2009.
    * @returns {DateObj} - The `DateObj` instance. You can retrieve the parser object from
    * `DateObjInstance.Parser`.
    */
    static Call(DateString, DateFormat, RegExOptions := 'i)', Cache := 1, IfShortYear?, Validate := false) {
        return DateObj.Parser(DateFormat, RegExOptions, Cache, IfShortYear ?? unset)(DateString, Validate)
    }

    /**
     * @description - Creates a `DateObj` instance from a timestamp string.
     * @param {String} Timestamp - The timestamp string to create the `DateObj` instance from.
     * @returns {DateObj} - The `DateObj` instance.
     */
    static FromTimestamp(Timestamp) {
        loop 14 - StrLen(Timestamp) {
            Timestamp .= '0'
        }
        ObjSetBase(Date := {
            Year: SubStr(Timestamp, 1, 4)
          , Month: SubStr(Timestamp, 5, 2)
          , Day: SubStr(Timestamp, 7, 2)
          , Hour: SubStr(Timestamp, 9, 2)
          , Minute: SubStr(Timestamp, 11, 2)
          , Second: SubStr(Timestamp, 13, 2)
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
     * @description - `TimeUnits` contains the static data needed to parse date strings. This creates
     * a copy of it.
     * @returns {Map} - The `TimeUnits` map.
     */
    static GetTimeUnits() {
        TimeUnits := Map(
              'y', { Name: 'Year', Special: 3, Count: Map(1, '{1,2}', 2, '{2}', 4, '{4}', '?', '{0,4}') }
            , 'M', { Name: 'Month', Special: 4, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}')  }
            , 'd', { Name: 'Day', Special: 5, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}') }
            , 'H', { Name: 'Hour', Special: 5, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}') }
            , 'h', { Name: 'Hour', Special: 1, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}') }
            , 'm', { Name: 'Minute', Special: 5, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}') }
            , 's', { Name: 'Second', Special: 5, Count: Map(1, '{1,2}', 2, '{2}', '?', '{0,2}') }
            , 't', { Name: 't', Special: 2, Pattern: ['(?<t>[ap]{1})', '(?<t>(?:[ap]m){1})'] }
        )
        TimeUnits.Default := ''
        return TimeUnits
    }

    /**
     * @description - Initializes the `TimeUnits` map.
     */
    static SetTimeUnits() {
        DateObj.Base.Prototype.DefineProp('__TimeUnits', { Value: this.GetTimeUnits() })
    }

    /**
     * @description - Set a default value that the date objects will use for the timestamp when the
     * value is absent.
     * @param {String:Variadic} [Defaults] - When used, the values passed to this function should
     * consist of alternating name and value pairs, where the name comes before the value. Example:
     * `DateObj.SetDefault('Hour', '00', 'Minute', '00', 'Year', '2020')`. This will set the default
     * values for each of the included properties.
     */
    static SetDefault(Defaults*) {
        Proto := DateObj.Base.Prototype
        if Mod(Defaults.Length, 2)
            throw ValueError('The number of parameters must be even.', -1)
        loop Defaults.Length / 2
            Proto.DefineProp(Defaults[A_Index * 2 - 1], { Value: Defaults[A_Index * 2] })
    }

    /**
     * @property {Map} Cache - A cache of `DateObj` instances. The key is the `DateFormat` string,
     * and the value is the `DateObj` instance.
     */
    static Cache := Map()

    /**
     * @property {DateObj.Parser} Parser - The parser object used to create this `DateObj` instance.
     * It can be reused to create more `DateObj` instances from the same format string.
     */
    Parser := ''

    /**
     * @property {Integer} DaySeconds - The number of seconds from midnight.
     */
    DaySeconds => (this.Hour||0) * 3600 + (this.Minute||0) * 60 + (this.Second||0)
    /**
     * @property {String} Timestamp - The timestamp of the date object.
     */
    Timestamp => this.GetTimestamp()


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
     * @description - Adds the time to this object's timestamp, returning a new timestamp.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm}
     * @param {Number} Time - The amount of time to add.
     * @param {String} TimeUnits - The meaning of the Time parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {String} - The new timestamp.
     */
    Add(Time, TimeUnits) => DateAdd(this.Timestamp, Time, TimeUnits)

    /**
     * @description - Adds the time to this object's timestamp, then creates a new object.
     * {@link https://www.autohotkey.com/docs/v2/lib/DateAdd.htm}
     * @param {Number} Time - The amount of time to add.
     * @param {String} TimeUnits - The meaning of the Time parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {DateObj} - The new `DateObj` instance.
     */
    AddToNew(Time, TimeUnits) => DateObj.FromTimestamp(this.Add(Time, TimeUnits))

    /**
     * @description - Adds the time to this object's timestamp, modifying this objects value.
     * @param {Number} Time - The amount of time to add.
     * @param {String} TimeUnits - The meaning of the Time parameter. TimeUnits may be one of the
     * following strings (or just the first letter): Seconds, Minutes, Hours or Days.
     * @returns {DateObj} - A reference to this object.
     */
    Adjust(Time, TimeUnits) {
        Timestamp := this.Add(Time, TimeUnits)
        this.Year := SubStr(Timestamp, 1, 4)
        this.Month := SubStr(Timestamp, 5, 2)
        this.Day := SubStr(Timestamp, 7, 2)
        this.Hour := SubStr(Timestamp, 9, 2)
        this.Minute := SubStr(Timestamp, 11, 2)
        this.Second := SubStr(Timestamp, 13, 2)
        return this
    }

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
     * @description - Get the timestamp from the date object. Note that "global" defaults can
     * be set from `DateObj.SetDefault()`.
     * @param {String} [DefaultYear] - The default year to use if the year is not set.
     * @param {String} [DefaultMonth] - The default month to use if the month is not set.
     * @param {String} [DefaultDay] - The default day to use if the day is not set.
     * @param {String} [DefaultHour='00'] - The default hour to use if the hour is not set.
     * @param {String} [DefaultMinute='00'] - The default minute to use if the minute is not set.
     * @param {String} [DefaultSecond='00'] - The default second to use if the second is not set.
     * @returns {String} - The timestamp.
     */
    GetTimestamp(DefaultYear?, DefaultMonth?, DefaultDay?, DefaultHour := '00', DefaultMinute := '00', DefaultSecond := '00') {
        return (
            (this.Year || DefaultYear ?? SubStr(A_Now, 1, 4))
            (this.Month || DefaultMonth ?? SubStr(A_Now, 5, 2))
            (this.Day || DefaultDay ?? SubStr(A_Now, 7, 2))
            (this.Hour || DefaultHour)
            (this.Minute || DefaultMinute)
            (this.Second || DefaultSecond)
        )
    }

    /**
     * @description - Adds options to the timestamp.
     * @param {String} Options - The options to add to the timestamp.
     * @see https://www.autohotkey.com/docs/v2/lib/FormatTime.htm#Additional_Options
     */
    Opt(Options) => this.Options := Options

    /**
     * @description - Enables the ability to get a numeric value by adding 'N' to the front of a
     * property name.
     * @example
        Date := DateObj('2024-01-28 19:15', 'yyyy-MM-dd HH:mm')
        MsgBox(Type(Date.Minute)) ; String
        MsgBox(Type(Date.NMinute)) ; Integer

        ; AHK handles conversions most of the time anyway.
        z := 10
        MsgBox(Date.NMinute + z) ; 25
        MsgBox(Date.Minute + z) ; 25

        ; Map object keys are strictly typed.
        m := Map(15, 'val')
        MsgBox(m[Date.NMinute]) ; 'val'
        MsgBox(m[Date.Minute]) ; Error: Item has no value.

     * @
     */
    __Get(Name, *) {
        if SubStr(Name, 1, 1) = 'N' && this.HasOwnProp(SubStr(Name, 2)) {
            return Number(this.%SubStr(Name, 2)%||0)
        }
        throw PropertyError('Unknown property.', -1, Name)
    }

    ; @todo - Add in support for callouts and verbs so they can be used without special handling
    ; of 'ymdhst' characters. */
    class Parser extends DateObj.Base {
        /**
         * @description - Constructs a `DateObj.Parser` that can be reused to make `DateObj` objects
         * from date strings.
         * @param {String} DateFormat - The format of the date string. The format follows the same rules as
         * described on the AHK `FormatDate` page: {@link https://www.autohotkey.com/docs/v2/lib/FormatTime.htm}.
         * - The format string can include any of the following units: 'y', 'M', 'd', 'H', 'h', 'm', 's', 't'.
         * See the link for details.
         * - Only numeric day units are recognized by this function. This function will not match with
         * days like 'Mon', 'Tuesday', etc.
         * - In addition to the units, RegEx is viable within the format string. To permit compatibility
         * between the unit characters and RegEx, please adhere to these guidelines:
         * - If you intend to use any of 'y, m, d, h, s, t' or their capitalized counterparts literally,
         * you must escape the character with double backticks (e.g. '``y', '``m', '``d', etc.).
         * - To write a literal backtick followed by one of those letters, use quadruple backticks.
         * - Characters inside character classes (e.g. '[a-zA-Z]') and inside subcapture group names
         * (e.g. "mygroup" in `(?<mygroup>``mon|``tue)`) do not need to be escaped.
         * - All other verbs and special methods available in RegEx require escaped 'ymdhst' characters
         * with the double backtick, at least until I add support for callouts and verbs without backticks.
         * - Remember, the whole pattern must match on the date string for the function to succeed, so you
         * will sometimes want to leverage '.+?' to match arbitary substrings in-between the date units.
         * @example
            DateStr := 'Jan 02, 1992 @ 2 after 5 pm'
            DateFormat := 'MMM dd, yyyy.+?m.+?h tt'

            DateStr := '2024-01-28 19:00'
            DateFormat := 'yyyy-MM-dd HH:mm'

            DateStr := '2024-01-28 07:00 PM'
            DateFormat := 'yyyy-MM-dd hh:mm tt'

            DateStr := '12, Dec, around 2 AM'
            DateFormat := 'dd, MMM.+?h tt'

            ; You can use '?' when a unit may or may not be present in a string. Note that it can be
            ; challenging to get the pattern to match the way you want when using the '?' quantifier.
            ; The RegEx engine might skip the unit completely, even when present in the date string,
            ; if the content of your pattern is ambiguous. In the below example, this matches as expected.
            ; Without the '``sec' at the end, the pattern does not match correctly with the minutes.
            DateStr1 := 'In first place at just under 59 seconds'
            DateStr2 := 'In second place at 1 minute 2 seconds'
            DateFormat := 'm? \w+ ?s ``sec'

            ; If the '?' quantifier is not working as expected, it might be more effective to group the
            ; variable units with some nearby text that you know will appear along with the unit.
            DateStr1 := 'Appointment time: Fri @ 3:30 PM'
            DateStr2 := 'Appointment time: Fri, March 3, @ 3:30 PM'
            DateFormat := '(?:, MMMM d,)? @ h:mm tt'

            ; The `RegExMatchInfo` object is set to the property `Match`. If there's other information
            ; in the string you are interested in, you can capture that in your format string too.
            DateStr := 'Born March 30, 1992 - the year of the monkey'
            DateFormat := 'MMMM d, yyyy.+?(?<animal>``year.+)'

            ; You may sometimes want to use single-digit version of a unit insted of the two-digit unit.
            DateStr1 := '2024-11-28 11:05:01'
            DateStr2 := '2024-1-9 8:43:09'
            ; If we use 'yyyy-MM-dd HH:mm:ss', even though it matches the first, it will fail to match
            ; the second. The below format string will match both.
            DateFormat := 'yyyy-M-d H:mm:ss'
        @
        * @param {Boolean} [RegExOptions='i)'] - The RegEx options to add to the beginning of the pattern.
        * @param {Integer} [Cache=1] - Any one of the following flags:
        * - 1: If the `DateFormat` string is in the cache, the associated object will be retrived and
        * set as this object's base. This instance will inherit the properties from the cached object.
        * If the current input `IfShortYear` or `RegExOptions` values are different from the values
        * set on the cached object, this instance will reflect the new values. No further processing
        * is done to this instance. If `DateFormat` has not been cached, this instance will be added
        * to the cache with the key being the `DateFormat` string.
        * - 2: The cache is ignored and a new object is created. Nothing is added to the cache.
        * - 3: The cache is ignored and a new object is created, and this instance is added to the
        * cache, overwriting any existing cached object with the same `DateFormat` string.
        * @param {String} [IfShortYear] - Use this to specify the century when the year is 1 or 2
        * digits length. When unset, the current century is used. Example: '20' for 2020, or if the
        * year has 1 digit, '200' for 2009.
        * @returns {DateObj.Parser} - The `DateObj.Parser` instance.
        */
        __New(DateFormat, RegExOptions := 'i)', Cache := 1, IfShortYear?) {
            static PatternTemplate := '(?<{1}>\d{2})'
            , PatternMonth := '(?<Month>(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec){1}[a-zA-Z]*)'
            local TimeUnits, Len, Split, i, Previous, PreviousCount, Char, Descriptor
            TimeUnits := this.TimeUnits
            S1 := TimeUnits['h'].Special
            S2 := TimeUnits['t'].Special
            S3 := TimeUnits['y'].Special
            S4 := TimeUnits['M'].Special
            this.RegExOptions := RegExOptions
            this.IfShortYear := IfShortYear ?? ''
            if Cache == 1 {
                if DateObj.Cache.Has(DateFormat)
                    ObjSetBase(this, DateObj.Cache.Get(DateFormat))
                else {
                    _GetPattern()
                    DateObj.Cache.Set(DateFormat, this)
                }
            } else {
                _GetPattern()
                if Cache == 3
                    DateObj.Cache.Set(DateFormat, this)
            }
            if this.HasOwnProp('Special') && this.Special == S1
                throw ValueError('The input ``DateFormat`` indicates the date string will have 12-hour formatted hours'
                '`nbut does not include an am/pm indicator to determine what the hours represent in the date string.', -1)
            return

            _GetPattern() {
                this.Pattern := ''
                this.List := []
                Len := StrLen(DateFormat)
                Split := StrSplit(DateFormat)
                i := 1
                Previous := _ProcessGet()
                PreviousCount := 1
                while i < Split.Length {
                    ++i
                    Char := _ProcessGet()
                    if Char == Previous {
                        PreviousCount++
                    } else if Previous {
                        _Process()
                    } else {
                        Previous := Char
                        PreviousCount := 1
                    }
                }
                _Process()
            }
            _Process() {
                if Descriptor := TimeUnits.Get(Previous) {
                    if Descriptor.Special <= S2 {
                        if this.HasOwnProp('Special') {
                            if Descriptor.Special == S1 {
                                if this.Special == S2
                                    this.Special := 0
                                else
                                    _ThrowSeparateGroupError()
                            } else if Descriptor.Special == S2 {
                                if this.Special == S1
                                    this.Special := 0
                                else
                                    _ThrowSeparateGroupError()
                            }
                        } else
                            this.Special := Descriptor.Special
                    }
                    if Descriptor.Special == S4 {
                        if PreviousCount > 2 {
                            if Char == '?' {
                                this.Pattern .= Format(PatternMonth, '?')
                                Char := _ProcessPrepareNext()
                            } else {
                                this.Pattern .= Format(PatternMonth, '')
                            }
                            this.List.Push(Descriptor)
                        } else {
                            if Char == '?' {
                                this.Pattern .= Format(PatternTemplate, Descriptor.Name, Descriptor.Count['?'])
                                Char := _ProcessPrepareNext()
                            } else {
                                this.Pattern .= Format(PatternTemplate, Descriptor.Name, Descriptor.Count[PreviousCount])
                            }
                            this.List.Push({ Name: 'Month', Special: 5 })
                        }
                    } else {
                        if Descriptor.Special == S2 {
                            if Char == '?' {
                                this.Pattern .= Format(Descriptor.Pattern[PreviousCount == 1 ? 1 : 2], '?')
                                Char := _ProcessPrepareNext()
                            } else {
                                this.Pattern .= Format(Descriptor.Pattern[PreviousCount == 1 ? 1 : 2], '')
                            }
                        } else {
                            if Char == '?' {
                                this.Pattern .= Format(PatternTemplate, Descriptor.Name, Descriptor.Count['?'])
                                Char := _ProcessPrepareNext()
                            } else {
                                this.Pattern .= Format(PatternTemplate, Descriptor.Name, Descriptor.Count[PreviousCount])
                            }
                            this.List.Push(Descriptor)
                        }
                    }
                } else {
                    _ProcessAddPrevious()
                }
                Previous := Char
                PreviousCount := 1
            }
            _ProcessAddPrevious() {
                if IsSet(PreviousCount) {
                    loop PreviousCount
                        this.Pattern .= Previous
                } else {
                    return
                }
            }
            _ProcessCharacterClass() {
                local Str := Char
                _ProcessAddPrevious()
                loop {
                    Str .= Char := Split[++i]
                    if Char == ']'
                        break
                }
                this.Pattern .= Str
                return _ProcessPrepareNext()
            }
            _ProcessEscapeSequence() {
                _ProcessAddPrevious()
                local Count := 1, Str := Char
                while (Char := Split[++i]) == '``'
                    Count++, Str .= Char
                if Mod(Count, 2) {
                    switch Char, 0 {
                        case 'y', 'm', 'd', 'h', 's', 't':
                            if Count > 1
                                this.Pattern .= SubStr(Str, 1, -1)
                            this.Pattern .= Char
                        default:
                            this.Pattern .= Str Char
                    }
                } else {
                    this.Pattern .= Str Char
                }
                return _ProcessPrepareNext()
            }
            _ProcessGet() {
                if (Char := Split[i]) == '[' {
                    return _ProcessCharacterClass()
                } else if Char == '``' {
                    return _ProcessEscapeSequence()
                } else if Char == '(' {
                    return _ProcessGroup()
                } else {
                    return Char
                }
            }
            _ProcessGroup() {
                local Str := Char
                _ProcessAddPrevious()
                if (Char := Split[++i]) == '?' {
                    Str .= Char
                    loop 2 {
                        switch (Char := Split[++i]), 0 {
                            case 'p':
                                Str .= Char
                            case '`'':
                                Str .= Char
                                while (Char := Split[++i]) !== '`''
                                    Str .= Char
                                Str .= Char
                                break
                            case '<':
                                Str .= Char
                                switch (Char := Split[++i]) {
                                    case '=', '!':
                                        Str .= Char
                                        break
                                }
                                Str .= Char
                                while (Char := Split[++i]) !== '>'
                                    Str .= Char
                                Str .= Char
                                break
                            default:
                                this.Pattern .= Str Char
                                return _ProcessPrepareNext()
                        }
                    }
                } else {
                    this.Pattern .= Str
                    return _ProcessPrepareNext()
                }
                this.Pattern .= Str
                return _ProcessPrepareNext()
            }
            _ProcessPrepareNext() {
                Previous := ''
                if i == Split.Length
                    return ''
                ++i
                return _ProcessGet()
            }
            _ThrowSeparateGroupError() {
                throw ValueError('There are two separate groups of the same unit in the input ``DateFormat``'
                ', which is invalid.', -2, Previous)
            }
        }
        /**
         * @description - Parse the input date string and return a `DateObj` instance.
         * @param {String} DateStr - The date string to parse.
         * @param {Boolean} [Validate=false] - When true, the values of each property are validated
         * before the function completes. The values are compared numerically, and if any value exceeds
         * the maximum value for that property, an error is thrown.
         * @returns {DateObj} - The `DateObj` instance.
         */
        Call(DateStr, Validate := false) {
            local Match
            TimeUnits := this.TimeUnits
            S1 := TimeUnits['h'].Special
            S2 := TimeUnits['t'].Special
            S3 := TimeUnits['y'].Special
            S4 := TimeUnits['M'].Special
            ObjSetBase(Date := {}, DateObj.Prototype)
            Date.DefineProp('Parser', { Value: this })
            Date.DateStr := DateStr
            if HasProp(this, 'Special')
                this.Special := 0
            _ProcessMatch()
            if Validate
                _Validate()
            return Date

            _ProcessMatch() {
                if !RegExMatch(DateStr, this.RegExOptions this.Pattern, &Match)
                    return
                Date.DefineProp('Match', { Value: Match })
                for Descriptor in this.List {
                    switch Descriptor.Special {
                        case S1, S2:
                            if !HasProp(this, 'Special')
                                throw Error('The script encountered an internal logic error.', -1)
                            if this.Special
                                continue
                            else
                                _Handle12HourFormat(Descriptor)
                        case S3:
                            _HandleYear(Descriptor)
                        case S4:
                            _HandleMonth(Descriptor)
                        default:
                            if Match.Len[Descriptor.Name] == 1
                                Date.DefineProp(Descriptor.Name, { Value: '0' Match[Descriptor.Name] })
                            else
                                Date.DefineProp(Descriptor.Name, { Value: Match[Descriptor.Name] })
                    }
                }
            }
            _Handle12HourFormat(Descriptor) {
                h := TimeUnits['h'].Name
                t := TimeUnits['t'].Name
                Date.DefineProp(t, { Value: Match[t] })
                n := Number(Match[h])
                this.Special := 1

                switch SubStr(Match[t], 1, 1), 0 {
                    case 'a':
                        if n == 12 {
                            Date.DefineProp(h, { Value: '00' })
                        } else if Match.Len[h] == 1 {
                            Date.DefineProp(h, { Value: '0' Match[h] })
                        } else {
                            Date.DefineProp(h, { Value: Match[h] })
                        }
                    case 'p':
                        if n == 12 {
                            Date.DefineProp(h, { Value: '12' })
                        } else {
                            Date.DefineProp(h, { Value: n + 12 })
                        }
                }
            }
            _HandleMonth(Descriptor) {
                if !Match[Descriptor.Name]
                    return
                Date.DefineProp(Descriptor.Name, { Value: _GetMonth() })
                _GetMonth() {
                    switch SubStr(Match[Descriptor.Name], 1, 3), 0 {
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
                            throw ValueError('The script encountered an unexpected value for "Month".'
                            , -1, Match[Descriptor.Name])
                    }
                }
            }
            _HandleYear(Descriptor) {
                switch StrLen(Match[Descriptor.Name]) {
                    case 1:
                        Date.DefineProp(Descriptor.Name, { Value: (this.IfShortYear || SubStr(A_Now, 1, 3)) Match[Descriptor.Name] })
                    case 2:
                        Date.DefineProp(Descriptor.Name, { Value: (this.IfShortYear || SubStr(A_Now, 1, 3)) Match[Descriptor.Name] })
                    case 4:
                        Date.DefineProp(Descriptor.Name, { Value: Match[Descriptor.Name] })
                    default:
                        throw ValueError('The resulting match with the year produced an irregular string length.'
                        , -1, 'Length: ' Match.Len[Descriptor.Name])
                }
            }
            _Validate() {
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
            _ThrowInvalidResultError(Value) {
                throw ValueError('The result produced an invalid date.', -2, Value)
            }
        }
    }

    class Base {
        /**
         * @description - The `TimeUnits` property contains a map with the static data needed to parse
         * date strings. It can be adjusted if needed. It's best to adjust it from the instance
         * `DateObj.Parser` object, so as to not override the default values for all instances. You
         * can get a copy of it by calling `DateObj.GetTimeUnits()`.
         */
        TimeUnits[Char?] {
            Get {
                if !HasProp(this, '__TimeUnits')
                    DateObj.SetTimeUnits()
                return IsSet(Char) ? this.__TimeUnits.Get(Char) : this.__TimeUnits
            }
            Set {
                if !HasProp(this, '__TimeUnits')
                    DateObj.SetChars()
                if IsSet(Char)
                    this.__TimeUnits.Set(Char, Value)
                else
                    this.DefineProp('__TimeUnits', { Value: Value })
            }
        }
        Year {
            Get => HasProp(this, '__Year') ? this.__Year : this.__Year := ''
            Set => this.__Year := Value
        }
        Month {
            Get => HasProp(this, '__Month') ? this.__Month : this.__Month := ''
            Set => this.__Month := Value
        }
        Day {
            Get => HasProp(this, '__Day') ? this.__Day : this.__Day := ''
            Set => this.__Day := Value
        }
        Hour {
            Get => HasProp(this, '__Hour') ? this.__Hour : this.__Hour := ''
            Set => this.__Hour := Value
        }
        Minute {
            Get => HasProp(this, '__Minute') ? this.__Minute : this.__Minute := ''
            Set => this.__Minute := Value
        }
        Second {
            Get => HasProp(this, '__Second') ? this.__Second : this.__Second := ''
            Set => this.__Second := Value
        }
        Options {
            Get => HasProp(this, '__Options') ? this.__Options : this.__Options := ''
            Set => this.__Options := Value
        }
        t {
            Get => HasProp(this, '__t') ? this.__t : this.__t := ''
            Set => this.__t := Value
        }
    }
}


