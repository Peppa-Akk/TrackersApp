import Foundation

enum ScheduleModel: String, CaseIterable, Codable {
    
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
    
    var shortName: String {
        switch self {
        case .monday:
            NSLocalizedString("Monday.ShortName", comment: "")
        case .tuesday:
            NSLocalizedString("Tuesday.ShortName", comment: "")
        case .wednesday:
            NSLocalizedString("Wednesday.ShortName", comment: "")
        case .thursday:
            NSLocalizedString("Thursday.ShortName", comment: "")
        case .friday:
            NSLocalizedString("Friday.ShortName", comment: "")
        case .saturday:
            NSLocalizedString("Saturday.ShortName", comment: "")
        case .sunday:
            NSLocalizedString("Sunday.ShortName", comment: "")
        }
    }
    
    var numberValue: Int {
        switch self {
        case .monday:
            2
        case .tuesday:
            3
        case .wednesday:
            4
        case .thursday:
            5
        case .friday:
            6
        case .saturday:
            7
        case .sunday:
            1
        }
    }
    
    var compareValue: Int {
        switch self {
        case .monday:
            1
        case .tuesday:
            2
        case .wednesday:
            3
        case .thursday:
            4
        case .friday:
            5
        case .saturday:
            6
        case .sunday:
            7
        }
    }
}
