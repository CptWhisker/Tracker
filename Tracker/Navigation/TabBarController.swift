import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Properties
    let trackersImage = UIImage(named: "tabBarTrackers")
    let statisticsImage = UIImage(named: "tabBarStatistics")
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tracker = configureTrackerVC()
        let statistics = configureStatisticsVC()
        configureTabBar()
        
        self.viewControllers = [
            tracker,
            statistics
        ]
    }
    
    // MARK: - Configuration
    private func configureTrackerVC() -> UINavigationController {
        let trackerViewController = TrackerViewController()
        let trackerNavigationController = NavigationController(rootViewController: trackerViewController)
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: trackersImage,
            tag: 0
        )
        
        return trackerNavigationController
    }
    
    private func configureStatisticsVC() -> UINavigationController {
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = NavigationController(rootViewController: statisticsViewController)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: statisticsImage,
            tag: 1
        )
        
        return statisticsNavigationController
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .ypBlue
        tabBar.layer.borderColor = UIColor.ypGray.cgColor
        tabBar.layer.borderWidth = 1
        tabBar.clipsToBounds = true
    }
}
