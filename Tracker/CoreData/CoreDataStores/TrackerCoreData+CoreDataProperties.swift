import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var trackerID: UUID?
    @NSManaged public var title: String?
    @NSManaged public var color: String?
    @NSManaged public var emoji: String?
    @NSManaged var schedule: DaysValue?
    @NSManaged public var category: TrackerCategoryCoreData?
    @NSManaged public var record: TrackerRecordCoreData?

}

extension TrackerCoreData : Identifiable {

}
