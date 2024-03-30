import UIKit


final class EditTrackerViewController: UIViewController {
    
    private var emojiType = TypeCollection.emoji.rawValue
    private var colorType = TypeCollection.color.rawValue
    private let params = GeometricParams(cellCount: 6, leftInset: 18, rightInset: 19, cellSpacing: 5)
    private var selectEmoji: SelectEmoji?
    private var selectColor: SelectColor?
    
    var selectedDays: String = ""
    var selectedCategory: String = ""
    private var colorsForSelectInString: [String] = []
    
    var contentView = UIView()
    var buttonsStackView = UIStackView()
    
    private let countDaysLabel = UILabel()
    private var countDays = Int()
    lazy var nameTrackerTextField = UITextField()
    
    lazy var cancelButton = UIButton()
    lazy var createButton = UIButton()
    
    lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    var tableView = UITableView()
    var scrollView = UIScrollView()
    
    var schedule: [ScheduleModel] = [.monday, .tuesday, .wednesday, .thursday, .friday, .sunday, .saturday]
    var category: TrackerCategory? = nil
    private let tracker: Tracker
    weak var delegate: CreateNewTrackerViewControllerDelegate?
    private let uiColorMarshalling = UIColorMarshalling()
    private let recordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private let categoryStore = CategoryStore()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateUI()
        
        setParamsFromTracker()
    }
    
    init(_ tracker: Tracker, with category: TrackerCategory) {
        self.tracker = tracker
        self.category = category
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - NavigationController
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = NSLocalizedString("EditTracker", comment: "")
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    func setParamsFromTracker() {
        
        setColorsByString()
        nameTrackerTextField.text = tracker.title
        setColor()
        setEmoji()
    }
    
    func setColorsByString() {
        colorsForSelect.colors.forEach {
            colorsForSelectInString.append(uiColorMarshalling.hexString(from: $0))
        }
    }
    
    func setColor() {
        guard
            let row = colorsForSelectInString.firstIndex(of: uiColorMarshalling.hexString(from: tracker.color))
        else {
            selectColor = SelectColor(color: colorsForSelect.colors[0],
                                      indexPath: IndexPath(row: 0, section: 1))
            return
        }
        selectColor = SelectColor(color: tracker.color, indexPath: IndexPath(row: row, section: 1))
    }
    
    func setEmoji() {
        guard
            let row = emojisForSelect.emojis.firstIndex(of: tracker.emoji)
        else {
            selectEmoji = SelectEmoji(title: tracker.emoji,
                                      indexPath: IndexPath(row: 0, section: 0))
            return
        }
        selectEmoji = SelectEmoji(title: tracker.emoji, indexPath: IndexPath(row: row, section: 0))
    }
    
    //MARK: - OBJC Methods
    @objc
    private func cancelButtonTouchUpInside() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func createButtonTouchUpInside() {
        
        if let emoji = selectEmoji?.title,
           let color = selectColor?.color,
           let categoryTitle = category?.title,
           let categoryID = category?.id
        {
            let newTracker: Tracker = Tracker(
                id: tracker.id,
                title: nameTrackerTextField.text ?? "None",
                color: color,
                emoji: emoji,
                date: schedule,
                isPin: tracker.isPin
            )
            
            trackerStore.updateTracker(
                with: trackerStore.fetchTrackerID(with: tracker.id),
                categoryCoreData: categoryStore.fetchCategory(with: categoryStore.fetchCategoryID(with: categoryID)),
                and: newTracker
            )
            navigationController?.viewControllers.first?.dismiss(animated: true)
        }
        delegate?.reloadTrackers()
    }
}

// MARK: - Add UI-Elements on View
extension EditTrackerViewController {
    
    func activateUI() {
        
        view.backgroundColor = .hdWhite
        setupScrollView()
        setupContentView()
        setupLabel()
        setupTextField()
        setupTableView()
        setupUICollectionView()
        setupButtonsStackViewOnView()
        setupCancelButton()
        setupCreateButton()
    }
    
    func toCountDays() -> Int {
        
        var collection = recordStore.collection
        collection.removeAll { record in
            record.id != tracker.id
        }
        return collection.count
    }
    
    func setupLabel() {
        
        countDaysLabel.text = "\(toCountDays().days())"
        countDaysLabel.numberOfLines = 1
        countDaysLabel.font = .systemFont(ofSize: 32,weight: .bold)
        countDaysLabel.textColor = .hdBlack
        countDaysLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countDaysLabel)
        
        NSLayoutConstraint.activate([
            countDaysLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            countDaysLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 24)
        ])
    }
    
    func setupTextField() {
        
        let placeholderTitle = NSAttributedString(
            string: NSLocalizedString("Placeholder.Tracker.TextField", comment: ""),
            attributes: [NSAttributedString.Key.foregroundColor:UIColor.hdGray    ]
        )
        nameTrackerTextField.attributedPlaceholder = placeholderTitle
        nameTrackerTextField.setLeftViewForTextField()
        nameTrackerTextField.setRightViewForTextField()
        nameTrackerTextField.borderStyle = .none
        nameTrackerTextField.layer.cornerRadius = 16
        nameTrackerTextField.backgroundColor = .hdBackground
        nameTrackerTextField.font = .systemFont(ofSize: 17, weight: .regular)
        nameTrackerTextField.translatesAutoresizingMaskIntoConstraints = false
        nameTrackerTextField.delegate = self
        contentView.addSubview(nameTrackerTextField)
        
        NSLayoutConstraint.activate([
            nameTrackerTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: countDaysLabel.bottomAnchor, constant: 40),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        contentView.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat((75 * 2) - 1))
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        tableView.reloadData()
    }
    
    func setupUICollectionView() {
        
        collection.isScrollEnabled = false
        collection.backgroundColor = .hdWhite
        contentView.addSubview(collection)
        collection.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collection.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collection.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        collection.dataSource = self
        collection.delegate = self
        collection.allowsMultipleSelection = true
        collection.register(EmojisCell.self,
                            forCellWithReuseIdentifier: EmojisCell.identifier)
        collection.register(ColorsCell.self,
                            forCellWithReuseIdentifier: ColorsCell.identifier)
        collection.register(SupplementaryView.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: SupplementaryView.identifier)
        collection.reloadData()
    }
    
    func setupContentView() {
        
        scrollView.addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(equalToConstant: 816)
        ])
    }
    
    func setupButtonsStackViewOnView() {
        
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        view.addSubview(buttonsStackView)
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            buttonsStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupCancelButton() {
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle(NSLocalizedString("Cancel", comment: ""), for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.hdRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.hdRed.cgColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
    }
    
    func setupCreateButton() {
        
        createButton.setTitle(NSLocalizedString("Save", comment: ""), for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.hdWhite, for: .normal)
        createButton.backgroundColor = .hdGray
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(createButton)
        createButton.addTarget(self, action: #selector(createButtonTouchUpInside), for: .touchUpInside)
    }
    
    func setupScrollView() {
        
        scrollView.showsVerticalScrollIndicator = true
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -60)
        ])
    }
    
    func setupSubtitleSchedule() {
        
        checkSubtitle(with: selectedDays, in: ButtonType.schedule.rawValue)
    }
    
    func setupSubtitleCategory() {
        
        checkSubtitle(with: selectedCategory, in: ButtonType.category.rawValue)
    }
    
    func checkSubtitle(with data: String, in buttonType: Int) {
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: buttonType, section: 0)) as? ButtonCell else { assertionFailure("Cannot find cell in tableView"); return}
        
        switch data.isEmpty {
        case true:
            cell.switchLabelsBack()
        case false:
            cell.switchLabels()
            cell.subTitle.text = data
        }
    }
}

//MARK: - UICollectionViewDataSource
extension EditTrackerViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        emojisAndColorsForSelect[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        emojisAndColorsForSelect.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch indexPath.section {
        case emojiType:
            guard
                let emojiForSelect = emojisAndColorsForSelect[emojiType] as? EmojisModel,
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: EmojisCell.identifier,
                    for: indexPath) as? EmojisCell else { return UICollectionViewCell() }
            cell.prepareForReuse()
            
            let emoji = emojiForSelect.emojis[indexPath.row]
            cell.emojiLabel.text = emoji
            
            if indexPath == selectEmoji?.indexPath
            {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                cell.cellView.backgroundColor = .hdLightGray
            }
            
            return cell
            
        case colorType:
            guard
                let colorForSelect = emojisAndColorsForSelect[colorType] as? ColorsModel,
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ColorsCell.identifier,
                    for: indexPath) as? ColorsCell else { return UICollectionViewCell() }
            cell.prepareForReuse()
            
            let color = colorForSelect.colors[indexPath.row]
            cell.cellView.backgroundColor = color
            cell.selectionView.layer.borderColor = UIColor.hdWhite.cgColor
            
            if indexPath == selectColor?.indexPath
            {
                collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .left)
                cell.selectionView.layer.borderColor = color.cgColor
            }
            
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: SupplementaryView.identifier,
            for: indexPath) as? SupplementaryView else {
            return UICollectionReusableView()
        }
        
        let text = emojisAndColorsForSelect[indexPath.section].title
        view.titleLabel.text = text
        view.titleLabel.font = .boldSystemFont(ofSize: 19)
        view.titleLabel.textAlignment = .left
        
        return view
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension EditTrackerViewController: UICollectionViewDelegateFlowLayout {
    
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
        return CGSize(width: cellWidth, height: 52)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 12, left: params.leftInset, bottom: 12, right: params.rightInset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case emojiType:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojisCell
            
            guard let emoji = cell?.emojiLabel.text else { return assertionFailure("Nill EMOJI In Collection") }
            if let selectEmoji = selectEmoji {
                let cell = collectionView.cellForItem(at: selectEmoji.indexPath) as? EmojisCell
                
                cell?.cellView.backgroundColor = .clear
                collectionView.deselectItem(at: selectEmoji.indexPath, animated: true)
            }
            selectEmoji = SelectEmoji(title: emoji, indexPath: indexPath)
            cell?.cellView.backgroundColor = .hdLightGray
            
        case colorType:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell
            
            let color = colorsForSelect.colors[indexPath.row]
            if let selectColor = selectColor {
                let cell = collectionView.cellForItem(at: selectColor.indexPath) as? ColorsCell
                
                cell?.selectionView.layer.borderColor = UIColor.clear.cgColor
                collectionView.deselectItem(at: selectColor.indexPath, animated: true)
            }
            selectColor = SelectColor(color: color, indexPath: indexPath)
            cell?.selectionView.layer.borderColor = color.cgColor

        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case emojiType:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojisCell
            
            selectEmoji = nil
            cell?.cellView.backgroundColor = .clear
            
        case colorType:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell
            
            selectColor = nil
            cell?.selectionView.layer.borderColor = UIColor.clear.cgColor
            
        default:
            return
        }
    }
}

//MARK: - UITableViewDataSource
extension EditTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ButtonCell.reuseIdentifier,
            for: indexPath) as? ButtonCell else { return UITableViewCell() }
        
        cell.accessoryType = .disclosureIndicator
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        switch indexPath.row {
        case TrackerType.event.rawValue:
            
            cell.title.text = NSLocalizedString("Category", comment: "")
            cell.switchLabels()
            cell.subTitle.text = category?.title
            
        case TrackerType.habit.rawValue:
            
            cell.title.text = NSLocalizedString("Schedule", comment: "")
            cell.switchLabels()
            var scheduleSort = schedule
            scheduleSort.sort { $0.compareValue < $1.compareValue }
            switch scheduleSort {
            case [.monday, .tuesday, .wednesday, .thursday, .friday]:
                selectedDays = NSLocalizedString("Weekdays", comment: "")
            case ScheduleModel.allCases:
                selectedDays = NSLocalizedString("EveryDay", comment: "")
            case [.saturday, .sunday]:
                selectedDays = NSLocalizedString("Weekend", comment: "")
            default:
                let days = schedule.map{ "\($0.shortName)" }
                selectedDays = days.joined(separator: ", ")
            }
            cell.subTitle.text = selectedDays

        default:
            return cell
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension EditTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case ButtonType.category.rawValue:
            
            let vc = CategoryViewController(with: category)
            vc.delegate = self
            let viewToPresent = UINavigationController(rootViewController: vc)
            self.present(viewToPresent, animated: true)
        case ButtonType.schedule.rawValue:
            
            let vc = ScheduleViewController(with: schedule)
            vc.delegate = self
            let viewToPresent = UINavigationController(rootViewController: vc)
            self.present(viewToPresent, animated: true)
        default:
            return
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

//MARK: - ScheduleDelegate
extension EditTrackerViewController: ScheduleDelegate, CategoryDelegate {
    
    func deselectButton(with type: Int) {
        
        let indexPath = IndexPath(row: type, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ButtonCell {
            cell.isSelected.toggle()
        }
    }
    
    func setDescription(with schedule: [ScheduleModel]) {
        
        var scheduleSort = schedule
        scheduleSort.sort { $0.compareValue < $1.compareValue }
        switch scheduleSort {
        case [.monday, .tuesday, .wednesday, .thursday, .friday]:
            selectedDays = NSLocalizedString("Weekdays", comment: "")
        case ScheduleModel.allCases:
            selectedDays = NSLocalizedString("EveryDay", comment: "")
        case [.saturday, .sunday]:
            selectedDays = NSLocalizedString("Weekend", comment: "")
        default:
            let days = schedule.map{ "\($0.shortName)" }
            selectedDays = days.joined(separator: ", ")
        }
        setupSubtitleSchedule()
    }
    
    func setDescription(with category: String) {
        
        selectedCategory = category
        setupSubtitleCategory()
    }
}

//MARK: - TextFieldDelegate
extension EditTrackerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
