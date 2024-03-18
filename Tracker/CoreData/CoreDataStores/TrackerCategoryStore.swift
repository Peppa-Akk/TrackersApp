//import UIKit
//import CoreData
//
////MARK: - Errors
//enum TrackerStoreCategoryError: Error {
//    
//    case decodingErrorInvalidID
//    case decodingErrorInvalidTitle
//    case decodingErrorInvalidTrackers
//}
//
////MARK: - Protocols
//protocol TrackerStoreCategoryProtocol {
//    
//    var numberOfSections: Int { get }
//    func numberOfRowsInSection(_ section: Int) -> Int
//}
//
////MARK: - TrackerCategoryStore
//class TrackerCategoryStore: NSObject {
//    
//    //MARK: - Variables
//    weak var delegate: StoreDelegate?
//    
//    static let shared = TrackerCategoryStore()
//    private let uiColorMarshalling = UIColorMarshalling.shared
//    
//    private var context: NSManagedObjectContext
//    
//    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
//        
//        let fetchRequest = TrackerCoreData.fetchRequest()
//        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(TrackerCoreData.trackerID), ascending: true)]
//        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
//                                                                  managedObjectContext: context,
//                                                                  sectionNameKeyPath: nil,
//                                                                  cacheName: nil)
//        
//        fetchedResultsController.delegate = self
//        try? fetchedResultsController.performFetch()
//        return fetchedResultsController
//    }()
//    
//    //MARK: - inits
//    init(context: NSManagedObjectContext) {
//        self.context = context
//        TrackerStore()
//        super.init()
//    }
//    
//    convenience override init() {
//        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
//        self.init(context: context)
//    }
//    
////    var collection: [TrackerCategory] {
////        guard
////            let objects = self.fetchedResultsController.fetchedObjects,
////            let collection = try? objects.map( { try self.convertToCategory(from: $0) })
////        else { return [] }
////        return collection
////    }
//    
//    //MARK: - Methods
//    func addNewCategory(_ category: TrackerCategory) {
//        
//        let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
//        updateExistingCategory(trackerCategoryCoreData, with: category)
//        (UIApplication.shared.delegate as! AppDelegate).saveContext()
//    }
//    
//    func updateExistingCategory(_ categoryCoreData: TrackerCategoryCoreData, with category: TrackerCategory) {
//        
//        categoryCoreData.title = category.title
//    }
//    
//    
//    func convertToCategory(from categoryCoreData: TrackerCategoryCoreData) throws -> TrackerCategory {
//        
//        guard let id = categoryCoreData.categoryID else { throw  TrackerStoreCategoryError.decodingErrorInvalidID }
//        guard let title = categoryCoreData.title else { throw  TrackerStoreCategoryError.decodingErrorInvalidTitle }
//        var trackers: [Tracker] = []
//        guard let trackersCoreData = categoryCoreData.trackers?.allObjects as? [TrackerCoreData] else { throw TrackerStoreCategoryError.decodingErrorInvalidTrackers }
//        trackersCoreData.forEach { trackers.append(try! convertToTracker(from: $0)) }
//        
//        return TrackerCategory(
//            id: id,
//            title: title,
//            trackers: trackers
//        )
//    }
//    
//    func convertToTracker(from trackerCoreData: TrackerCoreData) throws -> Tracker {
//        
//        guard let id = trackerCoreData.trackerID else { throw TrackerStoreError.decodingErrorInvalidID }
//        guard let title = trackerCoreData.title else { throw TrackerStoreError.decodingErrorInvalidTitle }
//        guard let color = trackerCoreData.color else { throw TrackerStoreError.decodingErrorInvalidColor }
//        guard let emoji = trackerCoreData.emoji else { throw TrackerStoreError.decodingErrorInvalidEmoji }
//        guard let schedule = trackerCoreData.schedule else { throw TrackerStoreError.decodingErrorInvalidSchedule }
//        
//        return Tracker(
//            id: id,
//            title: title,
//            color: uiColorMarshalling.color(from: color),
//            emoji: emoji,
//            date: schedule.schedule
//        )
//    }
//    
//    func fetchCategoryID(with id: UUID) -> NSManagedObjectID {
//        
//        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
//        request.resultType = .managedObjectIDResultType
//        request.predicate = NSPredicate(format: "categoryID = %@", id.uuidString)
//        
//        guard let categoryID = try! context.fetch(request) as? [NSManagedObjectID] else { assertionFailure("DECODING ERROR INVALID CATEGORY ID"); return NSManagedObjectID()}
//        
//        return categoryID[0]
//    }
//    
//    func fetchCategory(with id: NSManagedObjectID) -> TrackerCategoryCoreData {
//        
//        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
//        request.returnsObjectsAsFaults = false
//        
//        guard let category = context.object(with: id) as? TrackerCategoryCoreData else { assertionFailure("INVALID CATEGORY OBJECT"); return TrackerCategoryCoreData()}
//        
//        return category
//    }
//}
//
////// MARK: - TrackerStoreProtocol
////extension TrackerCategoryStore: TrackerStoreCategoryProtocol {
////    
////    var numberOfSections: Int {
////        fetchedResultsController.sections?.count ?? 0
////    }
////    
////    func numberOfRowsInSection(_ section: Int) -> Int {
////        fetchedResultsController.sections?[section].numberOfObjects ?? 0
////    }
////}
//
//// MARK: - NSFetchedResultsControllerDelegate
//extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {
//    
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        delegate?.didUpdate()
//    }
//}
