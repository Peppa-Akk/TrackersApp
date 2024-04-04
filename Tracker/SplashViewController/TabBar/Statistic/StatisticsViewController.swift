import UIKit

enum StatisticList: String {
    
    case completeTrackers = "Statistic.Completed"
}

final class StatisticsViewController: UIViewController {
    
    private var tableView = UITableView()
    private var placeholderImageView = UIImageView()
    private var placeholderLabel = UILabel()
    
    private let recordStore = TrackerRecordStore(context: AppDelegate.persistentContainer.viewContext)
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
        setupPlaceholderImage()
        setupPlaceholderText()
        setupPlugs(with: recordStore.collection.isEmpty)
    }
    
    func addTitleLabel() {
        navigationItem.title = NSLocalizedString("Statistic", comment: "")
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupTableView() {
        tableView.backgroundColor = .hdWhite
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 77),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(90 * statisticList.count))
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticCell.self, forCellReuseIdentifier: StatisticCell.reuseIdentifier)
        tableView.reloadData()
    }
    
    func setupPlaceholderImage() {
        
        placeholderImageView.image = .zeroStatistic
        placeholderImageView.clipsToBounds = true
        placeholderImageView.translatesAutoresizingMaskIntoConstraints = false
        placeholderImageView.isHidden = true
        view.addSubview(placeholderImageView)
        
        NSLayoutConstraint.activate([
            placeholderImageView.widthAnchor.constraint(equalToConstant: 80),
            placeholderImageView.heightAnchor.constraint(equalToConstant: 80),
            placeholderImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func setupPlaceholderText() {
        
        placeholderLabel.text = NSLocalizedString("Placeholder.Statistic", comment: "")
        placeholderLabel.numberOfLines = 0
        placeholderLabel.textAlignment = .center
        placeholderLabel.font = .systemFont(ofSize: 12, weight: .medium)
        placeholderLabel.textColor = .hdBlack
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.isHidden = true
        view.addSubview(placeholderLabel)
        
        NSLayoutConstraint.activate([
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImageView.centerXAnchor),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImageView.bottomAnchor, constant: 8)
        ])
    }
    
    func setupPlugs(with isStatisticEmpty: Bool) {
        if isStatisticEmpty {
            tableView.isHidden = true
            placeholderImageView.isHidden = false
            placeholderLabel.isHidden = false
        } else {
            tableView.isHidden = false
            placeholderImageView.isHidden = true
            placeholderLabel.isHidden = true
        }
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

extension StatisticsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        statisticList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: StatisticCell.reuseIdentifier,
            for: indexPath) as? StatisticCell else { return UITableViewCell() }
        
        cell.selectionStyle = .none
        cell.backgroundColor = .hdWhite
        cell.titleLabel.text = NSLocalizedString(statisticList[indexPath.row].rawValue, comment: "")
        cell.resultLabel.text = "\(recordStore.collection.count)"
        
        return cell
    }
}

extension StatisticsViewController: StoreDelegate {
    
    func didUpdate() {
        tableView.reloadData()
        setupPlugs(with: recordStore.collection.isEmpty)
    }
}
