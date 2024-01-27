import UIKit


final class HabitOrIrregularEventViewController: UIViewController {
    
    private var habitButton = UIButton()
    private var irregularEventButton = UIButton()
    private var stackView = UIStackView()
    
    weak var delegate: CreateNewTrackerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateUI()
        setupNavigationController()
    }
    
    @objc
    private func createNewHabit() {
        
        let vc = CreateNewTrackerViewController(trackerType: .habit)
        vc.delegate = delegate
        navigationController?.pushViewController(vc, animated: true)
//        self.present(viewToPresent, animated: true)
    }
    
    @objc
    private func createNewEvent() {
        
        let vc = CreateNewTrackerViewController(trackerType: .event)
        vc.delegate = delegate
        let viewToPresent = UINavigationController(rootViewController: vc)
        self.present(viewToPresent, animated: true)
    }
}

//MARK: - NavigationController
extension HabitOrIrregularEventViewController {
    
    func setupNavigationController() {
        navigationController?.view.backgroundColor = .hdWhite
        navigationController?.navigationBar.isTranslucent = false
        self.navigationItem.title = "Создание трекера"
    }
}

// MARK: - Add UI-Elements on View
extension HabitOrIrregularEventViewController {
    
    func activateUI() {
        view.backgroundColor = .hdWhite
        addStackViewOnView()
        addHabitButtonOnView()
        addIrregularEventOnView()
    }
    
    func addStackViewOnView() {
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    func addHabitButtonOnView() {
        habitButton.backgroundColor = .hdBlack
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.hdWhite, for: .normal)
        habitButton.titleLabel?.contentMode = .center
        habitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        habitButton.layer.cornerRadius = 16
        habitButton.layer.masksToBounds = true
        stackView.addArrangedSubview(habitButton)
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        habitButton.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    func addIrregularEventOnView() {
        irregularEventButton.backgroundColor = .hdBlack
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.setTitleColor(.hdWhite, for: .normal)
        irregularEventButton.titleLabel?.contentMode = .center
        irregularEventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.layer.masksToBounds = true
        stackView.addArrangedSubview(irregularEventButton)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        irregularEventButton.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
