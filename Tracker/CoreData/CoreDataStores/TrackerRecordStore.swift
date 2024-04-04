import UIKit
import CoreData

//MARK: - Errors
enum TrackerStoreRecordError: Error {
    
    case decodingErrorInvalidID
    case decodingErrorInvalidDate
}

final class TrackerRecordStore: NSObject {
    
    //MARK: - Variables
    weak var delegate: StoreDelegate?
    
    static let shared = TrackerRecordStore()
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerRecordCoreData.date), ascending: true)]
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
        self.trackerStore = TrackerStore(context: context)
        super.init()
    }
    
    convenience override init() {
        let context = AppDelegate.persistentContainer.viewContext
        self.init(context: context)
    }
    
    var collection: [TrackerRecord] {
        guard let objects = self.fetchedResultsController.fetchedObjects,
              let collection = try? objects.map( { try self.convertToRecord(from: $0) })
        else { return[] }
        return collection
    }
    
    //MARK: - Methods
    func addNewRecord(_ record: TrackerRecord, with trackerID: UUID) {
        
        let trackerRecordCoreData = TrackerRecordCoreData(context: context)
        updateExistingRecord(trackerRecordCoreData, with: record, and: trackerID)
        AppDelegate.saveContext()
    }
    
    func updateExistingRecord(_ recordCoreData: TrackerRecordCoreData, with record: TrackerRecord, and trackerID: UUID) {
        
        recordCoreData.recordID = record.id
        recordCoreData.date = record.date
        trackerStore.relationshipWithRecord(recordCoreData, by: trackerID)
        AppDelegate.saveContext()
    }
    
    func deleteRecord(with recordID: UUID, and date: Date) {
        
        context.delete(fetchRecord(with: fetchRecordID(with: recordID, and: date)))
        AppDelegate.saveContext()
    }
    
    func fetchRecordID(with id: UUID, and date: Date) -> NSManagedObjectID {

        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.recordID), id.uuidString,
            #keyPath(TrackerRecordCoreData.date), date as NSDate
        )
        
        let recordID = try! context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        let id = recordID.finalResult![0] as! NSManagedObjectID
        return id
    }

    func fetchRecord(with id: NSManagedObjectID) -> TrackerRecordCoreData {

        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.returnsObjectsAsFaults = false
        
        guard let record = context.object(with: id) as? TrackerRecordCoreData else { assertionFailure("INVALID RECORD OBJECT"); return TrackerRecordCoreData()}
        
        return record
    }
    
    func convertToRecord(from recordCoreData: TrackerRecordCoreData) throws -> TrackerRecord {
        
        guard let id = recordCoreData.recordID else { throw TrackerStoreRecordError.decodingErrorInvalidID}
        guard let date = recordCoreData.date else { throw TrackerStoreRecordError.decodingErrorInvalidDate}
        
        return TrackerRecord(
            id: id,
            date: date
        )
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension TrackerRecordStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}

