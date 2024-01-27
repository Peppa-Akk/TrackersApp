import UIKit


protocol ScheduleDelegate: AnyObject {
    
    var schedule: [ScheduleModel] { get set }
    func deselectButton()
}

final class ScheduleViewController: UIViewController {
    
    private var tableView = UITableView()
    private var readyButton = UIButton()
    
    weak var delegate: ScheduleDelegate?
    private var week: [ScheduleModel] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    private var selectedDays: [ScheduleModel]
    
    init(with selectedDays: [ScheduleModel]) {
        
        self.selectedDays = selectedDays
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        delegate?.deselectButton()
    }
    
    @objc
    private func toggleSwitch(_ sender: UISwitch) {
        
        if sender.isOn {
            selectedDays.append(week[sender.tag])
        }
        if !sender.isOn {
            selectedDays.removeAll {
                $0 == week[sender.tag]
            }
        }
    }
    
    @objc
    private func chooseWeekDays() {
        
        delegate?.schedule = selectedDays
        self.dismiss(animated: true)
    }
}


//MARK: - NavigationController
extension ScheduleViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Расписание"
    }
}


// MARK: - Add UI-Elements on View
extension ScheduleViewController {
    
    func activateUI() {
        
        setupTableView()
        setupButton()
    }
    
    func setupTableView() {
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.tableHeaderView = UIView()
        tableView.isScrollEnabled = false
        view.addSubview(tableView)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -16),
            tableView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat((75 * 7) - 7))
        ])
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.reuseIdentifier)
        tableView.reloadData()
    }
    
    func setupButton() {
        
        readyButton.backgroundColor = .hdBlack
        readyButton.setTitle("Готово", for: .normal)
        readyButton.setTitleColor(.hdWhite, for: .normal)
        readyButton.titleLabel?.contentMode = .center
        readyButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        readyButton.layer.cornerRadius = 16
        readyButton.layer.masksToBounds = true
        view.addSubview(readyButton)
        readyButton.translatesAutoresizingMaskIntoConstraints = false
        readyButton.addTarget(self, action: #selector(chooseWeekDays), for: .touchUpInside)
        
        let safeArea = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            readyButton.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

//MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleCell.reuseIdentifier,
            for: indexPath) as? ScheduleCell else { return UITableViewCell() }
        
        let switchView = UISwitch(frame: .zero)
        switchView.tag = indexPath.row
        switchView.addTarget(
            self,
            action: #selector(toggleSwitch(_:)),
            for: .valueChanged)
        if selectedDays.contains(week[indexPath.row]) {
            switchView.setOn(true, animated: true)
        }
        
        cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        cell.accessoryView = switchView
        cell.selectionStyle = .none
        
        cell.title.text = week[indexPath.row].rawValue
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}
