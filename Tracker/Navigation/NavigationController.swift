import UIKit

final class NavigationController: UINavigationController {
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        configureNavigationBar()
    }
    
    // MARK: - Configuration
    private func configureNavigationBar() {
        navigationBar.tintColor = .ypAccent
        navigationBar.prefersLargeTitles = true
    }
}
