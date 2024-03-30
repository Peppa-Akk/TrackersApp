import UIKit

enum StatisticList: String {
    
    case completeTrackers = "Statistic.Completed"
}

final class StatisticsViewController: UIViewController {
    
    private var tableView = UITableView()
    
    private let recordStore = TrackerRecordStore(context: (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    private let statisticList: [StatisticList] = [.completeTrackers]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recordStore.delegate = self
        activateUI()
    }
}

// MARK: - Add UI-Elements on View
extension StatisticsViewController {
    
    func activateUI() {
        addTitleLabel()
        setupTableView()
    }
    
    func addTitleLabel() {
        navigationItem.title = NSLocalizedString("Statistic", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 77),
            tableView.heightAnchor.constraint(equalToConstant: 90 * 4)
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.reuseIdentifier)
        tableView.reloadData()
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

extension StatisticsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticCell.reuseIdentifier,
            for: indexPath) as? StatisticCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        print(recordStore.collection)
        cell.titleLabel.text = NSLocalizedString(statisticList[indexPath.row].rawValue, comment: "")
        cell.resultLabel.text = "\(recordStore.collection.count)"
        
        return cell
    }
}

extension StatisticsViewController: StoreDelegate {
    
    func didUpdate() {
        tableView.reloadData()
    }
}
