import Foundation

enum ScheduleModel: String, CaseIterable, Codable {
    
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
    
    var shortName: String {
        switch self {
        case .monday:
            "Пн"
        case .tuesday:
            "Вт"
        case .wednesday:
            "Ср"
        case .thursday:
            "Чт"
        case .friday:
            "Пт"
        case .saturday:
            "Сб"
        case .sunday:
            "Вс"
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
