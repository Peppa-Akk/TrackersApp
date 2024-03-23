import UIKit
import DateHelper

final class TrackersViewController: UIViewController {
    //MARK: - UI Components
    private var zeroTrackerLabel = UILabel()
    private var zeroTrackerImageView = UIImageView()
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchTextField = UISearchTextField()
    private var datePicker = UIDatePicker()
    private var addTrackerButton = UIButton()
    
    //MARK: Store init
    private let trackerStore = TrackerStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    private let categoryStore = CategoryStore.shared
    private let recordStore = TrackerRecordStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    
    //MARK: - Variables
    private var currentDay = Date()
    private var today = Date()
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter
    }()
    
    private var categories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private let params = GeometricParams(cellCount: 2, leftInset: 16, rightInset: 16, cellSpacing: 9)
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let calendar = Calendar.current
        var interval = TimeInterval()
        calendar.dateInterval(of: .day, start: &today, interval: &interval, for: Date())
        today = calendar.date(byAdding: .second, value: Int(interval-1), to: today)!
        
        categories = categoryStore.collection

        completedTrackers = recordStore.collection
        activateUI()
        reloadData()
    }
    
    //MARK: - Class Methods
    private func reloadData() {
        datePickerValueChanged()
    }
    
    //MARK: - OBJC Methods
    @objc
    private func datePickerValueChanged() {
        
        currentDay = datePicker.date
        let calendar = Calendar.current
        let filterWeekday = calendar.component(.weekday, from: currentDay)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.date.contains { weekDay in
                    weekDay.numberValue == filterWeekday
                }
            }
            if trackers.isEmpty {
                return nil
            }
            
            return TrackerCategory(
                id: UUID(),
                title: category.title,
                trackers: trackers
            )
        }
        setupPlug(with: visibleCategories.isEmpty)
        collection.reloadData()
    }
    
    @objc
    private func addTrackerButtonAction() {
//        FOR DELETE KEYCHAIN PROPERTY
//        let storage = AuthStorage()
//        storage.cleanData()
        let vc = HabitOrIrregularEventViewController()
        vc.delegate = self
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
}

// MARK: - Add UI-Elements on View
extension TrackersViewController {
    func activateUI() {
        view.backgroundColor = .hdWhite
        addDatePicker()
        addImageViewOnView()
        addLabelOnView()
        setupPlug(with: visibleCategories.isEmpty)
        addAddTrackerButton()
        addTitleLabel()
        setupSearchController()
        setupUICollectionView()
        setupDelegates()
    }
    
    func setupUICollectionView() {
        collection.backgroundColor = .hdWhite
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: safeArea.topAnchor),
            collection.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        collection.dataSource = self
        collection.delegate = self
        collection.allowsMultipleSelection = false
        collection.register(TrackerCollectionViewCell.self,
                            forCellWithReuseIdentifier: TrackerCollectionViewCell.identifier)
        collection.register(SupplementaryView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: SupplementaryView.identifier)
        collection.reloadData()
    }
    
    func addImageViewOnView() {
        zeroTrackerImageView.image = UIImage(named: "ZeroTracker")
        zeroTrackerImageView.clipsToBounds = true
        zeroTrackerImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zeroTrackerImageView)
        
        NSLayoutConstraint.activate([
            zeroTrackerImageView.widthAnchor.constraint(equalToConstant: 80),
            zeroTrackerImageView.heightAnchor.constraint(equalToConstant: 80),
            zeroTrackerImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            zeroTrackerImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func addLabelOnView() {
        zeroTrackerLabel.text = "Что будем отслеживать?"
        zeroTrackerLabel.numberOfLines = 0
        zeroTrackerLabel.font = .systemFont(ofSize: 12)
        zeroTrackerLabel.textColor = .hdBlack
        zeroTrackerLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(zeroTrackerLabel)
        
        NSLayoutConstraint.activate([
            zeroTrackerLabel.centerXAnchor.constraint(equalTo: zeroTrackerImageView.centerXAnchor),
            zeroTrackerLabel.topAnchor.constraint(equalTo: zeroTrackerImageView.bottomAnchor, constant: 8)
        ])
    }
    
    func setupPlug(with isTrackersEmpty: Bool) {
        if isTrackersEmpty {
            zeroTrackerLabel.isHidden = false
            zeroTrackerImageView.isHidden = false
            collection.isHidden = true

        } else {
            zeroTrackerLabel.isHidden = true
            zeroTrackerImageView.isHidden = true
            collection.isHidden = false
        }
    }
    
    func addTitleLabel() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func addDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        datePicker.date = Date()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func addAddTrackerButton() {
        
        let button = UIBarButtonItem(image: .addTracker, style: .plain, target: self, action: #selector(addTrackerButtonAction))
        button.tintColor = .hdBlack
        navigationItem.leftBarButtonItem = button
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Поиск"
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupDelegates() {
        trackerStore.delegate = self
        categoryStore.delegate = self
        recordStore.delegate = self
    }
}

//MARK: - Work With Stores
extension TrackersViewController {
    
    func addTracker(with tracker: Tracker, and category: String, _ id: UUID) {
        
        let categoryCoreDataID = categoryStore.fetchCategoryID(with: id)
        trackerStore.addNewTracker(tracker, with: categoryCoreDataID)
        categories = categoryStore.collection
        collection.reloadData()
    }
    
//    func updateTracker(with trackers: [Tracker], and category: String, _ id: UUID) {
//        
//        let categoryCoreDataID = categoryStore.fetchCategoryID(with: id)
//        let categoryCoreData = categoryStore.fetchCategory(with: categoryCoreDataID)
//        let tracker
//        trackerStore.updateTracker(
//            with: trackerStore.fetchTrackerID(with: trac),
//            categoryCoreData: categoryCoreData,
//            and: trackers.last!
//        )
//        categories.append(TrackerCategory(id: id,
//                                          title: category,
//                                          trackers: trackers))
//    }
}

//MARK: - Search Controller
extension TrackersViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        // TODO: maybe later
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.identifier,
            for: indexPath) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.prepareForReuse()
        
        let cellData = visibleCategories
        let tracker = cellData[indexPath.section].trackers[indexPath.row]
        
        let color = tracker.color
        let emoji = tracker.emoji
        let cardTitleText = tracker.title
        
        cell.cardView.backgroundColor = color
        cell.emojiView.backgroundColor = color
        cell.plusButton.tintColor = color
        cell.emojiLabel.text = emoji
        cell.nameLabel.text = cardTitleText
        
        cell.delegate = self
        
        let isCompletedToday = isTrackerCompletedToday(id: tracker.id)
        let completedDays = completedTrackers.filter { $0.id == tracker.id }.count
        cell.configureTrackerCompletion(
            with: tracker,
            isCompletedToday: isCompletedToday, 
            completedDays: completedDays,
            indexPath: indexPath
        )
        return cell
    }
    
    private func isTrackerCompletedToday(id: UUID) -> Bool {
        completedTrackers.contains { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryView.identifier,
            for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        view.titleLabel.textAlignment = .left
        view.titleLabel.font = .boldSystemFont(ofSize: 19)
        view.titleLabel.text = visibleCategories[indexPath.section].title
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(
            collectionView,
            viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader,
            at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let avaiableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = avaiableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 12, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
}

//MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
    func completeTracker(id: UUID, at indexPath: IndexPath) {
        
        if currentDay <= today {
            let trackerRecord = TrackerRecord(id: id, date: currentDay.adjust(for: .startOfDay)!)
            completedTrackers.append(trackerRecord)
            recordStore.addNewRecord(trackerRecord, with: id)
            
            collection.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleted(id: UUID, at indexPath: IndexPath) {
        
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
        recordStore.deleteRecord(with: id, and: currentDay.adjust(for: .startOfDay)!)
        collection.reloadItems(at: [indexPath])
    }
}

//MARK: - CreateNewTrackerViewControllerDelegate
extension TrackersViewController: CreateNewTrackerViewControllerDelegate {
    
    func saveAndReloadData(with newTracker: Tracker, and category: String, _ id: UUID) {
        
        addTracker(with: newTracker, and: category, id)
        reloadData()
    }
}

extension TrackersViewController: StoreDelegate {
    
    func didUpdate() {
        collection.reloadData()
    }
}

extension Date {
    static func fromString(_ dateString: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        return nil
    }
    
    func formattedString(style: DateFormatter.Style) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = style
        return formatter.string(from: self)
    }
}
