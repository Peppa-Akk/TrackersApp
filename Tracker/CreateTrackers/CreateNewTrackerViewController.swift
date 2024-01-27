import UIKit


protocol CreateNewTrackerViewControllerDelegate: AnyObject {
    
    func saveAndReloadData(with newData: Tracker, and category: String)
}

enum TrackerType: Int {
    
    case event = 0
    case habit = 1
    
    var trackerText: String {
        switch self {
        case .event:
            return "Новое нерегулярное событие"
        case .habit:
            return "Новая привычка"
        }
    }
}

enum TypeCollection: Int {
    
    case emoji = 0
    case color = 1
}

enum ButtonType: Int {
    
    case category = 0
    case schedule = 1
}

let emojisForSelect: EmojisModel = EmojisModel(title: "Emoji", emojis:
    [
        "🙂", "😻", "🌺", "🐶", "❤️", "😱",
        "😇", "😡", "🥶", "🤔", "🙌", "🍔",
        "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"
    ])
let colorsForSelect: ColorsModel = ColorsModel(title: "Цвет", colors:
    [
        .colorSelection1, .colorSelection2, .colorSelection3, .colorSelection4, .colorSelection5, .colorSelection6,
        .colorSelection7, .colorSelection8, .colorSelection9, .colorSelection10, .colorSelection11, .colorSelection12,
        .colorSelection13, .colorSelection14, .colorSelection15, .colorSelection16, .colorSelection17, .colorSelection18,
    ])

let emojisAndColorsForSelect: [EmojisAndColorsModel] = [emojisForSelect, colorsForSelect]


final class CreateNewTrackerViewController: UIViewController {
    
    private var trackerType: TrackerType
    private var emojiType = TypeCollection.emoji.rawValue
    private var colorType = TypeCollection.color.rawValue
    private let params = GeometricParams(cellCount: 6, leftInset: 18, rightInset: 19, cellSpacing: 5)
    
    private lazy var nameTrackerTextField = UITextField()
    private var stackView = UIStackView()
    private lazy var cancelButton = UIButton()
    private lazy var createButton = UIButton()
    
    private lazy var collection: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return collectionView
    }()
    private var tableView = UITableView()
    
    var schedule: [ScheduleModel] = []
    weak var delegate: CreateNewTrackerViewControllerDelegate?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavigationController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateUI()
    }
    
    init(trackerType: TrackerType) {
        self.trackerType = trackerType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func cancelButtonTouchUpInside() {
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    private func createButtonTouchUpInside() {
        
        delegate?.saveAndReloadData(
            with: Tracker(
                id: UUID(),
                title: "Sprint_14",
                color: .colorSelection1,
                emoji: "🤡",
                date: schedule),
            and: "Module 3")
        navigationController?.viewControllers.first?.dismiss(animated: true)
    }
}


//MARK: - NavigationController
extension CreateNewTrackerViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "\(trackerType.trackerText)"
        navigationItem.setHidesBackButton(true, animated: false)
    }
}

// MARK: - Add UI-Elements on View
extension CreateNewTrackerViewController {
    
    func activateUI() {
        
        view.backgroundColor = .hdWhite
        setupTextField()
        setupTableView()
//        setupUICollectionView()
        setupStackViewOnView()
        setupCancelButton()
        setupCreateButton()
    }
    
    func setupTextField() {
        
        let placeholderTitle = NSAttributedString(
            string: "Введите название трекера",
            attributes: [NSAttributedString.Key.foregroundColor:UIColor.hdGray	]
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
        view.addSubview(nameTrackerTextField)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            nameTrackerTextField.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            nameTrackerTextField.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            nameTrackerTextField.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            nameTrackerTextField.heightAnchor.constraint(equalToConstant: 75)
        ])
    }
    
    func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.alwaysBounceVertical = false
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: nameTrackerTextField.bottomAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(75 * (trackerType.rawValue + 1) - 1))
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ButtonCell.self, forCellReuseIdentifier: ButtonCell.reuseIdentifier)
        tableView.reloadData()
    }
    
    func setupUICollectionView() {
        
        collection.backgroundColor = .hdWhite
        collection.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collection)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collection.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collection.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            collection.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collection.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    
    func setupStackViewOnView() {
        
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupCancelButton() {
        
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.masksToBounds = true
        cancelButton.layer.borderWidth = 1
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.hdRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.hdRed.cgColor
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(cancelButton)
        cancelButton.addTarget(self, action: #selector(cancelButtonTouchUpInside), for: .touchUpInside)
    }
    
    func setupCreateButton() {
        
        createButton.setTitle("Создать", for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.hdWhite, for: .normal)
        createButton.backgroundColor = .hdGray
        createButton.layer.cornerRadius = 16
        createButton.layer.masksToBounds = true
        createButton.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(createButton)
        createButton.addTarget(self, action: #selector(createButtonTouchUpInside), for: .touchUpInside)
    }
}

//MARK: - UICollectionViewDataSource
extension CreateNewTrackerViewController: UICollectionViewDataSource {
    
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
extension CreateNewTrackerViewController: UICollectionViewDelegateFlowLayout {
    
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
            
            cell?.cellView.backgroundColor = .hdLightGray
            
        case colorType:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell
            
            let color = colorsForSelect.colors[indexPath.row]
            cell?.selectionView.layer.borderColor = color.cgColor

        default:
            return
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case emojiType:
            let cell = collectionView.cellForItem(at: indexPath) as? EmojisCell
            
            cell?.cellView.backgroundColor = .clear
            
        case colorType:
            let cell = collectionView.cellForItem(at: indexPath) as? ColorsCell
            
            cell?.selectionView.layer.borderColor = UIColor.clear.cgColor
            
        default:
            return
        }
    }
}

//MARK: - UITableViewDataSource
extension CreateNewTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerType.rawValue + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ButtonCell.reuseIdentifier,
            for: indexPath) as? ButtonCell else { return UITableViewCell() }
        
        cell.accessoryType = .disclosureIndicator
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        
        switch indexPath.row {
        case TrackerType.event.rawValue:
            
            cell.title.text = "Категория"
            
        case TrackerType.habit.rawValue:
            
            cell.title.text = "Расписание"
            
        default:
            return cell
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CreateNewTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case ButtonType.category.rawValue:
            
            let viewToPresent = UINavigationController(rootViewController: CategoryViewController())
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
extension CreateNewTrackerViewController: ScheduleDelegate {
    
    func deselectButton() {
        
        let indexPath = IndexPath(row: ButtonType.schedule.rawValue, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? ButtonCell {
            cell.isSelected.toggle()
        }
    }
}

//MARK: - TextFieldDelegate
extension CreateNewTrackerViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
}
