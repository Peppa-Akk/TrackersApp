import UIKit
import DateHelper

final class TrackersViewController: UIViewController {
    
    private let analyticService = AnalyticsService.shared
    
    //MARK: - UI Components
    private var zeroTrackerLabel = UILabel()
    private var zeroTrackerImageView = UIImageView()
    
    private var zeroTrackerByFilterLabel = UILabel()
    private var zeroTrackerByFilterImageView = UIImageView()
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var searchController = UISearchController(searchResultsController: nil)
    private var searchTextField = UISearchTextField()
    private var datePicker = UIDatePicker()
    private var addTrackerButton = UIButton()
    private var filterButton = UIButton()
    
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
    
    private var currentFilter: FilterType = .allTrackers {
        didSet {
            switch currentFilter {
            case .allTrackers:
                var tempCategory: [TrackerCategory] = []
                var tempPinnedTrackers: [Tracker] = []
                var tempTrackers: [Tracker] = []
                categories = categoryStore.collection
                categories.forEach { category in
                    category.trackers.forEach { tracker in
                        if tracker.isPin {
                            tempPinnedTrackers.append(tracker)
                        } else {
                            tempTrackers.append(tracker)
                        }
                    }
                    tempCategory.append(TrackerCategory(id: category.id, title: category.title, trackers: tempTrackers))
                    tempTrackers.removeAll()
                }
                tempCategory.append(TrackerCategory(id: UUID(), title: NSLocalizedString("Pin.Trackers", comment: ""),
                                                    trackers: tempPinnedTrackers))
                categories = tempCategory.reversed()
                
            case .todayTrackers:
                var tempCategory: [TrackerCategory] = []
                var tempPinnedTrackers: [Tracker] = []
                var tempTrackers: [Tracker] = []
                categories = categoryStore.collection
                categories.forEach { category in
                    category.trackers.forEach { tracker in
                        if tracker.isPin {
                            tempPinnedTrackers.append(tracker)
                        } else {
                            tempTrackers.append(tracker)
                        }
                    }
                    tempCategory.append(TrackerCategory(id: category.id, title: category.title, trackers: tempTrackers))
                    tempTrackers.removeAll()
                }
                tempCategory.append(TrackerCategory(id: UUID(), title: NSLocalizedString("Pin.Trackers", comment: ""),
                                                    trackers: tempPinnedTrackers))
                categories = tempCategory
                datePicker.setDate(today, animated: true)
                
            case .completedTrackers:
                categories = categoryStore.collection
                var tempCategory: [TrackerCategory] = []
                var tempPinnedTrackers: [Tracker] = []
                var tempTrackers: [Tracker] = []
                var uniqueRecords = [TrackerRecord]()
                var ids = Set<UUID>()
                for record in completedTrackers {
                    if !ids.contains(record.id) {
                        uniqueRecords.append(record)
                        ids.insert(record.id)
                    }
                }
                categories.forEach { category in
                    category.trackers.forEach { tracker in
                        uniqueRecords.forEach {
                            if $0.id == tracker.id,
                               isTrackerCompletedToday(id: tracker.id) {
                                if tracker.isPin {
                                    tempPinnedTrackers.append(tracker)
                                } else {
                                    tempTrackers.append(tracker)
                                }
                            }
                        }
                    }
                    if !tempTrackers.isEmpty {
                        tempCategory.append(TrackerCategory(id: category.id, title: category.title, trackers: tempTrackers))
                        tempTrackers.removeAll()
                    }
                }
                tempCategory.append(TrackerCategory(id: UUID(), title: NSLocalizedString("Pin.Trackers", comment: ""),
                                                    trackers: tempPinnedTrackers))
                categories = tempCategory.reversed()
                
            case .nonCompletedTrackers:
                categories = categoryStore.collection
                var tempRecordID: [UUID] = []
                var tempPinnedTrackers: [Tracker] = []
                for record in completedTrackers {
                    if !tempRecordID.contains(record.id) {
                        tempRecordID.append(record.id)
                    }
                }

                var tempCategory: [TrackerCategory] = []
                var tempTrackers: [Tracker] = []
                categories.forEach { category in
                    category.trackers.forEach { tracker in
                        if !isTrackerCompletedToday(id: tracker.id) {
                            if tracker.isPin {
                                tempPinnedTrackers.append(tracker)
                            } else {
                                tempTrackers.append(tracker)
                            }
                        }
                    }
                    if !tempTrackers.isEmpty {
                        tempCategory.append(TrackerCategory(id: category.id, title: category.title, trackers: tempTrackers))
                        tempTrackers.removeAll()
                    }
                }
                tempCategory.append(TrackerCategory(id: UUID(), title: NSLocalizedString("Pin.Trackers", comment: ""),
                                                    trackers: tempPinnedTrackers))
                categories = tempCategory.reversed()
            }
        }
    }
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        analyticService.report(event: "Opened TrackersViewController", params: ["event": "open", "screen": "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        analyticService.report(event: "Closed TrackersViewController", params: ["event": "close", "screen": "Main"])
    }
    
    //MARK: - Class Methods
    private func reloadData() {
        datePickerValueChanged()
    }
    
    private func updatesFilter() {
        
        switch currentFilter {
        case .allTrackers, .todayTrackers:
            currentFilter = .allTrackers
        case .completedTrackers:
            currentFilter = .completedTrackers
        case .nonCompletedTrackers:
            currentFilter = .nonCompletedTrackers
        }
    }
    
    //MARK: - OBJC Methods
    @objc
    private func datePickerValueChanged() {
        
        analyticService.report(event: "Date picker date changed on TrackersViewController", params: ["event": "change", "screen": "Main"])
        updatesFilter()
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
        analyticService.report(event: "Add tracker button tapped on TrackersViewController", params: ["event": "click", "screen": "Main", "item": "add_track"])
        let vc = HabitOrIrregularEventViewController()
        vc.delegate = self
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
    
    @objc
    private func setFilterButtonAction() {
        
        analyticService.report(event: "Did press the filters button on TrackersViewController", params: ["event": "click", "screen": "Main", "item": "filter"])
        let vc = FiltersViewController(with: currentFilter)
        vc.delegate = self
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
}

// MARK: - Add UI-Elements on View
extension TrackersViewController {
    func activateUI() {
        view.backgroundColor = .hdWhite
//        FOR TRACKERS TEST SNAPSHOT
//        view.backgroundColor = .green
        addDatePicker()
        addImageViewOnView()
        addLabelOnView()
        setupPlug(with: visibleCategories.isEmpty)
        addAddTrackerButton()
        addTitleLabel()
        setupSearchController()
        setupUICollectionView()
        setupDelegates()
        setupFilterButton()
        setupZeroTrackerByFilterImageView()
        setupZeroTrackerByFilterLabel()
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
        
        collection.contentInset.bottom = 66
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
        
        zeroTrackerLabel.text = NSLocalizedString("Placeholder.Trackers", comment: "")
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
    
    func setupZeroTrackerByFilterImageView() {
        zeroTrackerByFilterImageView.image = .zeroTrackerByFilter
        zeroTrackerByFilterImageView.clipsToBounds = true
        zeroTrackerByFilterImageView.translatesAutoresizingMaskIntoConstraints = false
        zeroTrackerByFilterImageView.isHidden = true
        view.addSubview(zeroTrackerByFilterImageView)
        
        NSLayoutConstraint.activate([
            zeroTrackerByFilterImageView.widthAnchor.constraint(equalToConstant: 80),
            zeroTrackerByFilterImageView.heightAnchor.constraint(equalToConstant: 80),
            zeroTrackerByFilterImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            zeroTrackerByFilterImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupZeroTrackerByFilterLabel() {
        
        zeroTrackerByFilterLabel.text = NSLocalizedString("Placeholder.Trackers.Filters", comment: "")
        zeroTrackerByFilterLabel.numberOfLines = 0
        zeroTrackerByFilterLabel.font = .systemFont(ofSize: 12)
        zeroTrackerByFilterLabel.textColor = .hdBlack
        zeroTrackerByFilterLabel.translatesAutoresizingMaskIntoConstraints = false
        zeroTrackerByFilterLabel.isHidden = true
        view.addSubview(zeroTrackerByFilterLabel)
        
        NSLayoutConstraint.activate([
            zeroTrackerByFilterLabel.centerXAnchor.constraint(equalTo: zeroTrackerByFilterImageView.centerXAnchor),
            zeroTrackerByFilterLabel.topAnchor.constraint(equalTo: zeroTrackerByFilterImageView.bottomAnchor, constant: 8)
        ])
    }
    
    func setupPlugByFilter(with isTrackersEmpty: Bool) {
        
        if isTrackersEmpty {
            zeroTrackerByFilterLabel.isHidden = false
            zeroTrackerByFilterImageView.isHidden = false
            zeroTrackerLabel.isHidden = true
            zeroTrackerImageView.isHidden = true
            collection.isHidden = true
        } else {
            zeroTrackerByFilterLabel.isHidden = true
            zeroTrackerByFilterImageView.isHidden = true
            collection.isHidden = false
        }
    }
    
    func setupPlug(with isTrackersEmpty: Bool) {
        if isTrackersEmpty {
            zeroTrackerLabel.isHidden = false
            zeroTrackerImageView.isHidden = false
            zeroTrackerByFilterLabel.isHidden = true
            zeroTrackerByFilterImageView.isHidden = true
            collection.isHidden = true
        } else {
            zeroTrackerLabel.isHidden = true
            zeroTrackerImageView.isHidden = true
            collection.isHidden = false
        }
    }
    
    func addTitleLabel() {
        navigationItem.title = NSLocalizedString("Trackers", comment: "")
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
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = NSLocalizedString("Search", comment: "")
        
        navigationItem.searchController = searchController
        definesPresentationContext = false
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupFilterButton() {
        
        filterButton.backgroundColor = .hdBlue
        filterButton.setTitle(NSLocalizedString("Filters", comment: ""), for: .normal)
        filterButton.setTitleColor(.white, for: .normal)
        filterButton.titleLabel?.contentMode = .center
        filterButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        filterButton.layer.cornerRadius = 16
        filterButton.layer.masksToBounds = true
        view.addSubview(filterButton)
        filterButton.translatesAutoresizingMaskIntoConstraints = false
        filterButton.addTarget(self, action: #selector(setFilterButtonAction), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
        ])
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
        
        analyticService.report(event: "Attempted searching for trackers on TrackersViewController", params: ["event": "search", "screen": "Main"])
        setupPlugByFilter(with: false)
        var filteredData: [TrackerCategory] = []
        var filteredTrackers: [Tracker] = []
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            visibleCategories.forEach {
                if $0.title.lowercased().contains(searchText.lowercased()) {
                    filteredData.append($0)
                }
                if filteredData.isEmpty {
                    $0.trackers.forEach {
                        if $0.title.lowercased().contains(searchText.lowercased()) {
                            filteredTrackers.append($0)
                        }
                    }
                    if !filteredTrackers.isEmpty {
                        filteredData.append(TrackerCategory(id: $0.id, title: $0.title, trackers: filteredTrackers))
                    }
                }
            }
            visibleCategories = filteredData
            collection.reloadData()
            setupPlugByFilter(with: filteredData.isEmpty)
        } else {
            reloadData()
        }
    }
}

//MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
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
        
        analyticService.report(event: "Tracker is complete on TrackersViewController", params: ["event": "click", "screen": "Main"])
        if currentDay <= today {
            let trackerRecord = TrackerRecord(id: id, date: currentDay.adjust(for: .startOfDay)!)
            completedTrackers.append(trackerRecord)
            recordStore.addNewRecord(trackerRecord, with: id)
            
            collection.reloadItems(at: [indexPath])
        }
    }
    
    func uncompleted(id: UUID, at indexPath: IndexPath) {
        
        analyticService.report(event: "Tracker is uncomplete on TrackersViewController", params: ["event": "click", "screen": "Main"])
        completedTrackers.removeAll { trackerRecord in
            let isSameDay = Calendar.current.isDate(trackerRecord.date, inSameDayAs: datePicker.date)
            return trackerRecord.id == id && isSameDay
        }
        recordStore.deleteRecord(with: id, and: currentDay.adjust(for: .startOfDay)!)
        collection.reloadItems(at: [indexPath])
    }
    
    func pinTracker(id: UUID) {
        trackerStore.pinTracker(with: id)
        updatesFilter()
        reloadData()
    }
    
    func editTracker(id: UUID) {
        let trackerCoreDataID = trackerStore.fetchTrackerID(with: id)
        let trackerCoreData = trackerStore.fetchTracker(with: trackerCoreDataID)
        let category = try! categoryStore.convertToCategory(from: trackerCoreData.category!)
        let tracker = try! trackerStore.convertToTracker(from: trackerCoreData)
        
        let vc = EditTrackerViewController(tracker, with: category)
        vc.delegate = self
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
    
    func deleteTracker(id: UUID) {
        
        let actionSheet: UIAlertController = {
            let alert = UIAlertController()
            alert.title = NSLocalizedString("Alert.ChooseDelete.ContextMenu", comment: "")
            return alert
        }()
        let actionDelete = UIAlertAction(title: NSLocalizedString("Delete.ContextMenu", comment: ""),
                                         style: .destructive) {_ in
            self.analyticService.report(event: "Confirme delete tracker on TrackersViewController", params: ["event": "click", "screen": "Main", "item": "delete"])
            self.trackerStore.deleteTracker(with: id)
            self.updatesFilter()
            self.reloadData()
        }
        let actionCancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""),
                                         style: .cancel) { _ in
            self.analyticService.report(event: "Cancel delete tracker on TrackersViewController", params: ["event": "click", "screen": "Main", "item": "delete"])
        }
        actionSheet.addAction(actionDelete)
        actionSheet.addAction(actionCancel)
        present(actionSheet, animated: true)
    }
}

//MARK: - CreateNewTrackerViewControllerDelegate
extension TrackersViewController: CreateNewTrackerViewControllerDelegate {
    
    func reloadTrackers() {
        reloadData()
    }
    
    func saveAndReloadData(with newTracker: Tracker, and category: String, _ id: UUID) {
        
        addTracker(with: newTracker, and: category, id)
        reloadData()
    }
}

//MARK: - FilterDelegate
extension TrackersViewController: FilterDelegate {
    
    func applyFilters(by filter: FilterType) {
        currentFilter = filter
        reloadData()
        setupPlugByFilter(with: visibleCategories.isEmpty)
    }
}

//MARK: - StoreDelegate
extension TrackersViewController: StoreDelegate {
    
    func didUpdate() {
        collection.reloadData()
    }
}

//MARK: - TextFieldDelegate
extension TrackersViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
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
