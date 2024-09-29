import UIKit

final class PageViewController: UIPageViewController {
    
    // MARK: - UI Elements
    private lazy var pages: [UIViewController] = {
        let firstVC = OnboardingViewController()
        if let firstImage = UIImage(named: "onboardingFirst") {
            firstVC.setBackgroundImage(to: firstImage)
        }
        let firstTitle = NSLocalizedString("pageView.title.first", comment: "Text for the first onboarding screen")
        firstVC.setTitleLabel(to: firstTitle)
        
        let secondVC = OnboardingViewController()
        if let secondImage = UIImage(named: "onboardingSecond") {
            secondVC.setBackgroundImage(to: secondImage)
        }
        let secondTitle = NSLocalizedString("pageView.title.second", comment: "Text for the second onboarding screen")
        secondVC.setTitleLabel(to: secondTitle)
        
        return [firstVC, secondVC]
    }()
    
    private lazy var pageControl: UIPageControl = {
       let control = UIPageControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.numberOfPages = pages.count
        control.currentPage = 0
        control.currentPageIndicatorTintColor = .black
        control.pageIndicatorTintColor = .lightGray
        return control
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        configureUI()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134)
        ])
    }
}

// MARK: - UIPageViewControllerDataSource
extension PageViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else { return nil }
        
        return pages[previousIndex]
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else { return nil }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else { return nil }
        
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate
extension PageViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        if
            let currentViewController = pageViewController.viewControllers?.first,
            let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}
