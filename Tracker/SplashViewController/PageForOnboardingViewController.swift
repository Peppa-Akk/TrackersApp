import UIKit

enum PageVC: Int {
    
    case first = 0
    case second = 1
}

final class PageForOnboardingViewController: UIViewController {
    
    private var imageView = UIImageView()
    private var welcomeLabel = UILabel()
    
    private let storage = AuthStorage()
    private var page: PageVC
    let backgroundImage: [UIImage] = [
        UIImage(resource: .onboardImage1),
        UIImage(resource: .onboardImage2)
    ]
    let textLabel: [String] = [
        "Отслеживайте только\nто, что хотите",
        "Даже если это\nне литры воды и йога"
    ]
    
    lazy var entranceButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(firstEntrance), for: .touchUpInside)
        button.backgroundColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 1)
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.contentMode = .center
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    init(page: PageVC) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activateUI()
    }
    
    @objc
    private func firstEntrance() {
        storage.firstJoin = true
        
        guard let window = UIApplication.shared.windows.first else { storage.firstJoin = false; return }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
}

//MARK: - UI
extension PageForOnboardingViewController {
    
    func activateUI() {
        
        setupImageView()
        setupLabel()
        setupConstraints()
    }
    
    func setupImageView() {
        
        imageView.image = backgroundImage[page.rawValue]
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.isUserInteractionEnabled = false
    }
    
    func setupLabel() {
        
        welcomeLabel.text = textLabel[page.rawValue]
        welcomeLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        welcomeLabel.textColor = .black
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textAlignment = .center
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setupConstraints() {
        [imageView, welcomeLabel, entranceButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16),
            
            
            entranceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            entranceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            entranceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            entranceButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
