import UIKit
import CoreData

//MARK: - Errors
enum CategoryStoreError: Error {
    
    case decodingErrorInvalidID
    case decodingErrorInvalidTitle
    case decodingErrorInvalidTrackers
}

final class CategoryStore: NSObject {
    
    weak var delegate: StoreDelegate?
    
    private let context: NSManagedObjectContext
    static let shared = CategoryStore()
    private let uiColorMarshalling = UIColorMarshalling.shared
    
    private lazy var fetchedResultController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCategoryCoreData.categoryID), ascending: true)]
        let fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: nil,
                                                                cacheName: nil)
        
        fetchResultsController.delegate = self
        try? fetchResultsController.performFetch()
        return fetchResultsController
    }()
    
    convenience override init() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        try! self.init(context: context)
    }
    
    init(context: NSManagedObjectContext) throws {
        self.context = context
        super.init()
    }
    
    var collection: [TrackerCategory] {
        guard
            let objects = self.fetchedResultController.fetchedObjects,
            let collection = try? objects.map({ try self.convertToCategory(from: $0) })
        else { return [] }
        return collection
    }
    
    func addNewCategory(_ category: TrackerCategory) throws {
        let trackerCategory = TrackerCategoryCoreData(context: context)
        updateExistingCategory(trackerCategory, with: category)
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func updateExistingCategory(_ categoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
        categoryCoreData.categoryID = category.id
        categoryCoreData.title = category.title
    }
    
    func convertToCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
        guard let categoryID = categoryCoreData.categoryID else { throw CategoryStoreError.decodingErrorInvalidID }
        guard let title = categoryCoreData.title else { throw CategoryStoreError.decodingErrorInvalidTitle }
        var trackers: [Tracker] = []
        let allTrackers = categoryCoreData.trackers?.allObjects as! [TrackerCoreData]
        for tracker in allTrackers {
            if
                let id = tracker.trackerID,
                let title = tracker.title,
                let emoji = tracker.emoji,
                let color = tracker.color,
                let schedule = tracker.schedule
            {
                let isPin = tracker.isPin
                let newTracker = Tracker(
                    id: id,
                    title: title,
                    color: uiColorMarshalling.color(from: color),
                    emoji: emoji,
                    date: schedule.schedule, 
                    isPin: isPin
                )
                trackers.append(newTracker)
            }
        }
        
        return TrackerCategory(
            id: categoryID,
            title: title,
            trackers: trackers
        )
    }
    
    func fetchCategoryID(with id: UUID) -> NSManagedObjectID {

        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false
        request.resultType = .managedObjectIDResultType
        request.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryID), id.uuidString)

        let categoryID = try! context.execute(request) as! NSAsynchronousFetchResult<NSFetchRequestResult>
        let id = categoryID.finalResult![0] as! NSManagedObjectID
        return id
    }

    func fetchCategory(with id: NSManagedObjectID) -> TrackerCategoryCoreData {

        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.returnsObjectsAsFaults = false

        guard let category = context.object(with: id) as? TrackerCategoryCoreData else { assertionFailure("INVALID CATEGORYOBJECT"); return TrackerCategoryCoreData()}

        return category
    }
}

extension CategoryStore: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate()
    }
}
