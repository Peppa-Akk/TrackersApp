import UIKit

struct Tracker {
    let id: UUID
    let title: String
    let color: UIColor
    let emoji: String
    let date: [ScheduleModel]
    let isPin: Bool
}

struct TrackerCategory {
    let id: UUID
    let title: String
    let trackers: [Tracker]
}

struct TrackerRecord {
    let id: UUID
    let date: Date
}
