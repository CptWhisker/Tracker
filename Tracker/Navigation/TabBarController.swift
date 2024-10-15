import UIKit

final class TabBarController: UITabBarController {
    // MARK: - Properties
    let trackersImage = UIImage(named: "tabBarTrackers")
    let statisticsImage = UIImage(named: "tabBarStatistics")
    private lazy var borderView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .ypGray
        return view
    }()
    
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
        
        setupBorder()
    }
    
    // MARK: - Configuration
    private func configureTrackerVC() -> UINavigationController {
        let trackerViewController = TrackerViewController()
        let trackerNavigationController = NavigationController(rootViewController: trackerViewController)
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.item.trackers", comment: "Title for TabBar's 'Trackers' item"),
            image: trackersImage,
            tag: 0
        )
        
        return trackerNavigationController
    }
    
    private func configureStatisticsVC() -> UINavigationController {
        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = NavigationController(rootViewController: statisticsViewController)
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.item.statistics", comment: "Title for TabBar's 'Statistics' item"),
            image: statisticsImage,
            tag: 1
        )
        
        return statisticsNavigationController
    }
    
    private func configureTabBar() {
        tabBar.tintColor = .ypBlue
    }
    
    private func setupBorder() {
        tabBar.addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor, constant: -10),
            borderView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor, constant: 10),
            borderView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            borderView.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}
