import UIKit

final class SplashScreenViewController: UIViewController {
    
    private let storage = AuthStorage()
    private let imageView = UIImageView(image: .logo)
    
    private var isFirstJoin: Bool {
        storage.firstJoin == nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isFirstJoin {
            switchToTabBar()
        } else {
            switchToOnboardingVC()
        }
    }
}

extension SplashScreenViewController {
    
    private func setupUI() {
        view.backgroundColor = .ypBlue
        setupImageView()
    }
    
    private func setupImageView() {
        
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 94),
            imageView.widthAnchor.constraint(equalToConstant: 91)
        ])
    }
}

extension SplashScreenViewController {
    
    private func switchToTabBar() {
        guard
            let window = UIApplication.shared.windows.first else { fatalError("Gabella") }
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
    }
    
    private func switchToOnboardingVC() {
        guard
            let window = UIApplication.shared.windows.first else { fatalError("Gabella") }
        let onboardVC = OnboardingViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        window.rootViewController = onboardVC
    }
}
