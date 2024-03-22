import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        let lineView = UIView(frame: CGRect(x: 0, y: 0,
                                            width: tabBar.frame.size.width,
                                            height: 1))
        lineView.backgroundColor = .hdBlack
        tabBar.addSubview(lineView)
                
        let trackersViewController = TrackersViewController()
        let statisticsViewController = StatisticsViewController()
        
        trackersViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "TrackersIcon"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "StatisticsIcon"),
            selectedImage: nil
        )
        
        let navigationControllerViewController = UINavigationController(rootViewController: trackersViewController)
        navigationControllerViewController.view.backgroundColor = .hdWhite
        navigationControllerViewController.navigationBar.isTranslucent = false
        
        self.viewControllers = [navigationControllerViewController, statisticsViewController]
    }
}
