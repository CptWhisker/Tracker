import UIKit

final class NavigationController: UINavigationController {
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = .black
        navigationBar.prefersLargeTitles = true
    }
}
