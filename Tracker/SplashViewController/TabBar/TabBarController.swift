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
            title: NSLocalizedString("Trackers", comment: ""),
            image: UIImage(named: "TrackersIcon"),
            selectedImage: nil
        )
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("Statistic", comment: ""),
            image: UIImage(named: "StatisticsIcon"),
            selectedImage: nil
        )
        
        let navigationTrackersViewController = UINavigationController(rootViewController: trackersViewController)
        navigationTrackersViewController.view.backgroundColor = .hdWhite
        navigationTrackersViewController.navigationBar.isTranslucent = false
        
        let navigationStatisticViewController = UINavigationController(rootViewController: statisticsViewController)
        navigationStatisticViewController.view.backgroundColor = .hdWhite
        navigationStatisticViewController.navigationBar.isTranslucent = false
        
        self.viewControllers = [navigationTrackersViewController, navigationStatisticViewController]
    }
}
