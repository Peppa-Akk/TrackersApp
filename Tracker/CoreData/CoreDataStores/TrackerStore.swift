import UIKit
import CoreData

//MARK: - Errors
enum TrackerStoreError: Error {
    
    case decodingErrorInvalidID
    case decodingErrorInvalidTitle
    case decodingErrorInvalidColor
    case decodingErrorInvalidEmoji
    case decodingErrorInvalidSchedule
}

//MARK: - Protocols
protocol TrackerStoreProtocol {
    
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
}

// MARK: - TrackerStore
class TrackerStore: NSObject {
    
    //MARK: - Variables
    weak var delegate: StoreDelegate?
    
    static let shared = TrackerStore()
    private let categoryStore = CategoryStore.shared
    private let uiColorMarshalling = UIColorMarshalling.shared
    private let context: NSManagedObjectContext
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCoreData.trackerID), ascending: true)]
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    //MARK: - inits
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    convenience override init() {
        let context = AppDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    //MARK: - Methods
    func addNewTracker(_ tracker: Tracker, with categoryID: NSManagedObjectID) {
        let trackerCoreData = TrackerCoreData(context: context)
        updateExistingTracker(trackerCoreData, with: tracker, and: categoryID)
        AppDelegate.saveContext()
    }
    
    func updateExistingTracker(_ trackerCoreData: TrackerCoreData, with tracker: Tracker, and categoryID: NSManagedObjectID) {
        
        trackerCoreData.category = categoryStore.fetchCategory(with: categoryID)
        trackerCoreData.trackerID = tracker.id
        trackerCoreData.title = tracker.title
        trackerCoreData.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = DaysValue(schedule: tracker.date)
    }
    
    func convertToTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
        
        guard let id = trackerCoreData.trackerID else { throw TrackerStoreError.decodingErrorInvalidID }
        guard let title = trackerCoreData.title else { throw TrackerStoreError.decodingErrorInvalidTitle }
        guard let color = trackerCoreData.color else { throw TrackerStoreError.decodingErrorInvalidColor }
        guard let emoji = trackerCoreData.emoji else { throw TrackerStoreError.decodingErrorInvalidEmoji }
        guard let schedule = trackerCoreData.schedule else { throw TrackerStoreError.decodingErrorInvalidSchedule }
        let isPin = trackerCoreData.isPin
        
        return Tracker(
            id: id,
            title: title,
            color: uiColorMarshalling.color(from: color),
            emoji: emoji,
            date: schedule.schedule,
            isPin: isPin
        )
    }
    
    func fetchTrackerID(with id: UUID) -> NSManagedObjectID {
        
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.resultType = .managedObjectIDResultType
        request.predicate = NSPredicate(format: "trackerID = %@", id.uuidString)
        
        let trackerID: NSAsynchronousFetchResult<NSFetchRequestResult>?
        do {
            trackerID = try context.execute(request) as? NSAsynchronousFetchResult<NSFetchRequestResult> ?? nil
        } catch {
            trackerID = nil
            assertionFailure("Error:/n\(error)")
        }
        guard let trackerID = trackerID else { assertionFailure("TRACKER ID IS NIL"); return NSManagedObjectID() }
        guard let id = trackerID.finalResult?[0] as? NSManagedObjectID else { return NSManagedObjectID() }
        return id
    }
    
    func fetchTracker(with id: NSManagedObjectID) -> TrackerCoreData {
        
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        request.returnsObjectsAsFaults = false
        
        guard let tracker = context.object(with: id) as? TrackerCoreData else { assertionFailure("INVALID TRACKER OBJECT"); return TrackerCoreData()}
        
        return tracker
    }
    
    func updateTracker(with idTracker: NSManagedObjectID, categoryCoreData: TrackerCategoryCoreData, and newData: Tracker) {
        
        guard let object = try? context.existingObject(with: idTracker) as? TrackerCoreData else { assertionFailure("INVALID EXISTING TRACKER OBJECT"); return}

        object.title = newData.title
        object.color = uiColorMarshalling.hexString(from: newData.color)
        object.emoji = newData.emoji
        object.schedule = DaysValue(schedule: newData.date)
        object.category = categoryCoreData
        
        AppDelegate.saveContext()
    }
    
    func relationshipWithRecord(_ record: TrackerRecordCoreData, by trackerID: UUID) {
        
        let tracker = fetchTracker(with: fetchTrackerID(with: trackerID))
        tracker.record = record
    }
    
    func pinTracker(with id: UUID) {
        
        let idTracker = fetchTrackerID(with: id)
        let tracker = fetchTracker(with: idTracker)
        tracker.isPin = !tracker.isPin
        AppDelegate.saveContext()
    }
    
    func deleteTracker(with id: UUID) {
        
        let idTracker = fetchTrackerID(with: id)
        let tracker = fetchTracker(with: idTracker)
        var records: [TrackerRecordCoreData] = []
        
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "%K == %@",
                                        #keyPath(TrackerRecordCoreData.recordID),
                                        id.uuidString)
        do {
            records = try context.fetch(request)
        } catch {
            records = []
            assertionFailure("Error:/n\(error)")
        }
        for record in records {
            context.delete(record)
            AppDelegate.saveContext()
        }
        context.delete(tracker)
        AppDelegate.saveContext()
    }
}

// MARK: - TrackerStoreProtocol
extension TrackerStore: TrackerStoreProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
