import UIKit

enum PageVC: Int {
    
    case first = 0
    case second = 1
}

final class PageForOnboardingViewController: UIViewController {
    
    private var imageView = UIImageView()
    private var welcomeLabel = UILabel()
    
    var page: PageVC
    let backgroundImage: [UIImage] = [
        UIImage(resource: .onboardImage1),
        UIImage(resource: .onboardImage2)
    ]
    let textLabel: [String] = [
        "Отслеживайте только\nто, что хотите",
        "Даже если это\nне литры воды и йога"
    ]
    
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
}

//MARK: - UI
extension PageForOnboardingViewController {
    
    func activateUI() {
        
        setupImageView()
        setupLabel()
    }
    
    func setupImageView() {
        
        imageView.image = backgroundImage[page.rawValue]
        imageView.contentMode = .scaleAspectFit
        imageView.frame = view.bounds
        imageView.isUserInteractionEnabled = false
        view.addSubview(imageView)
    }
    
    func setupLabel() {
        
        welcomeLabel.text = textLabel[page.rawValue]
        welcomeLabel.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        welcomeLabel.textColor = .black
        welcomeLabel.numberOfLines = 0
        welcomeLabel.textAlignment = .center
        view.addSubview(welcomeLabel)
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            welcomeLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            welcomeLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            welcomeLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 16)
        ])
    }
}
