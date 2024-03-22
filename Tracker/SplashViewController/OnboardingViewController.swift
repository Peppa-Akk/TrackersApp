import UIKit

final class OnboardingViewController: UIPageViewController {
    
    private let storage = AuthStorage()
    
    lazy var pages: [UIViewController] = {
        let firstPage = PageForOnboardingViewController(page: PageVC.first)
        let secondPage = PageForOnboardingViewController(page: PageVC.second)
        
        return [firstPage, secondPage]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.isUserInteractionEnabled = false
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor(red: 26/255, green: 27/255, blue: 34/255, alpha: 0.3)
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
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
    
    override func viewDidLoad() {
        delegate = self
        dataSource = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true)
        }
        
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

extension OnboardingViewController {
    
    func activateUI() {
        setupConstraints()
    }
    
    func setupConstraints() {
        [pageControl, entranceButton].forEach { view.addSubview($0) }
        
        NSLayoutConstraint.activate([
            entranceButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            entranceButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            entranceButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            entranceButton.heightAnchor.constraint(equalToConstant: 60),
            
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: entranceButton.topAnchor, constant: -24)
        ])
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return pages.last
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return pages.first
        }
        
        return pages[nextIndex]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
