import Foundation

enum InitializerTag {
    case habit, event
}

enum WeekDays: String, CaseIterable, Codable { 
    case monday = "weekdays.monday"
    case tuesday = "weekdays.tuesday"
    case wednesday = "weekdays.wednesday"
    case thursday = "weekdays.thursday"
    case friday = "weekdays.friday"
    case saturday = "weekdays.saturday"
    case sunday = "weekdays.sunday"

}

extension WeekDays {
    var localizedName: String {
        return NSLocalizedString(self.rawValue, comment: "Weekday name")
    }
    
    var abbreviation: String {
        let abbreviation = "\(self.rawValue).short"
        return NSLocalizedString(abbreviation, comment: "Weekday abbreviation")
    }
    
    static func from(weekday: Int) -> WeekDays? {
        switch weekday {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return nil
        }
    }
}
