import UIKit


protocol CategoryDelegate: AnyObject {
    
    var category: TrackerCategory? { get set }
    func deselectButton(with type: Int)
    func setDescription(with category: String)
}

final class CategoryViewController: UIViewController {
    
    private var tableView = UITableView()
    private var readyButton = UIButton()
    private var placeHolder = UIImageView()
    private var placeholderLabel = UILabel()
    
    weak var delegate: CategoryDelegate?
    private var selectedCategory: TrackerCategory?
    
    private var viewModel: CategoryViewModel!
    
    init(with selectedCategory: TrackerCategory?) {
        
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = CategoryViewModel()
        viewModel.categoryBinding = { [weak self] _ in
            guard let self = self else { return }
            self.tableView.reloadData()
        }
        activateUI()
        setupNavigationController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.deselectButton(with: ButtonType.category.rawValue)
    }
    
    @objc
    private func addNewCategory() {
        
        let vc = CreateCategoryViewController(with: viewModel)
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
}


//MARK: - NavigationController
extension CategoryViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Категория"
    }
}


// MARK: - Add UI-Elements on View
extension CategoryViewController {
    
    func activateUI() {
        
        setupButton()
        setupTableView()
        setupPlaceholder()
        setupPlaceholderLabel()
        setupPlug()
    }
    
    func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.tableHeaderView = UIView()
        self.updateViewConstraints()
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.bottomAnchor.constraint(equalTo: readyButton.topAnchor, constant: -39)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.reuseIdentifier)
        tableView.reloadData()
    }
    
    func setupButton() {
        
        readyButton.backgroundColor = .hdBlack
        readyButton.setTitle("Добавить категорию", for: .normal)
        readyButton.setTitleColor(.hdWhite, for: .normal)
        readyButton.titleLabel?.contentMode = .center
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.layer.cornerRadius = 16
        readyButton.layer.masksToBounds = true
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func setupPlaceholder() {
        
        placeHolder.image = UIImage(resource: .zeroTracker)
        view.addSubview(placeHolder)
        placeHolder.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            placeHolder.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor),
            placeHolder.centerYAnchor.constraint(equalTo: safeArea.centerYAnchor),
            placeHolder.widthAnchor.constraint(equalToConstant: 80),
            placeHolder.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    func setupPlaceholderLabel() {
        
        placeholderLabel.text = "Привычки и события можно\nобъединить по смыслу"
        placeholderLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .hdBlack
        placeholderLabel.numberOfLines = 2
        placeholderLabel.textAlignment = .center
        view.addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            placeholderLabel.topAnchor.constraint(equalTo: placeHolder.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: safeArea.centerXAnchor)
        ])
    }
    
    func setupPlug() {
        let isHidePlaceholders = viewModel.categoryList.isEmpty
        placeHolder.isHidden = !isHidePlaceholders
        placeholderLabel.isHidden = !isHidePlaceholders
    }
}

//MARK: - UITableViewDataSource
extension CategoryViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.categoryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: CategoryCell.reuseIdentifier,
            for: indexPath) as? CategoryCell else { return UITableViewCell() }
        
        cell.viewModel = viewModel.categoryList[indexPath.item]
        
        let cellCount = tableView.numberOfRows(inSection: indexPath.section)
        if cellCount == 1 {
            cell.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner,
                                        .layerMinXMinYCorner,.layerMaxXMinYCorner]
            cell.separatorInset.right = tableView.bounds.width
        } else {
            switch indexPath.row {
            case 0:
                cell.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
            case cellCount - 1:
                cell.layer.maskedCorners = [.layerMaxXMaxYCorner,.layerMinXMaxYCorner]
                cell.separatorInset.right = tableView.bounds.width
            default:
                cell.layer.cornerRadius = 0
            }
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension CategoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? CategoryCell
        cell?.accessoryView?.isHidden = false
        
        selectedCategory = cell?.viewModel.getCategory()
        
        guard let title = selectedCategory?.title else { self.dismiss(animated: true); return }
        delegate?.category = selectedCategory
        delegate?.setDescription(with: title)
        self.dismiss(animated: true)
    }
}
