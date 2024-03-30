import UIKit

enum FilterType: String {
    case allTrackers = "AllTrackers"
    case todayTrackers = "TodayTrackers"
    case completedTrackers = "Completed"
    case nonCompletedTrackers = "Uncompleted"
}

protocol FilterDelegate: AnyObject {
    func applyFilters(by filter: FilterType)
}

final class FiltersViewController: UIViewController {
    
    private var tableView = UITableView()
    
    private var currentFilter: FilterType
    private let filters: [FilterType] = [.allTrackers, .todayTrackers, .completedTrackers, .nonCompletedTrackers]
    
    weak var delegate: FilterDelegate?
    
    init(with currentFilter: FilterType) {
        
        self.currentFilter = currentFilter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateUI()
        setupNavigationController()
    }
}


//MARK: - NavigationController
extension FiltersViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = NSLocalizedString("Filters", comment: "")
    }
}


// MARK: - Add UI-Elements on View
extension FiltersViewController {
    
    func activateUI() {
        
        setupTableView()
    }
    
    func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        self.updateViewConstraints()
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: (75 * 4) + 4)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FiltersCell.self, forCellReuseIdentifier: FiltersCell.reuseIdentifier)
        tableView.reloadData()
    }
}

//MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FiltersCell.reuseIdentifier,
            for: indexPath) as? FiltersCell else { return UITableViewCell() }
        
//        cell.title.text = filters[indexPath.row].rawValue
        cell.filter = filters[indexPath.row]
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryView = UIImageView(image: .selectCategory)
        if NSLocalizedString(currentFilter.rawValue, comment: "") == cell.title.text {
            cell.accessoryView?.isHidden = false
        } else {
            cell.accessoryView?.isHidden = true
        }
        
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
extension FiltersViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? FiltersCell else { return }
        
        delegate?.applyFilters(by: cell.filter)
        
        self.dismiss(animated: true)
    }
}
