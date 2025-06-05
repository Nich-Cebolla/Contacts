
GetAverageTime(contacts) {
    total := 0
    for contact in contacts {
        if !RegExMatch(contact['Talk'], 'J)(?:^(?P<min>\d+) min\w+ (?P<sec>\d+) sec)|(?:^(?P<sec>\d+) sec)', &match)
            throw Error('The value is not in the expected format: ' contact['Talk' ])
        total += Number(match['min']||0) * 60 + Number(match['sec']||0)
    }
    avg := total / contacts.Length, avgMin := Floor(avg / 60), avgSec := Mod(avg, 60)
    return {total:total, count:contacts.length, avg:avg, avgNice: avgMin ' minutes ' avgSec ' seconds'}
}



SwitchDayCode(Day) {
    switch Day, 0 {
        case 'monday', 'mon', '2': return 'MO'
        case 'tuesday', 'tue', '3': return 'TU'
        case 'wednesday', 'wed', '4': return 'WE'
        case 'thursday', 'thu', '5': return 'TH'
        case 'friday', 'fri', '6': return 'FR'
        case 'saturday', 'sat', '7': return 'SA'
        case 'sunday', 'sun', '1': return 'SU'
    }
}
