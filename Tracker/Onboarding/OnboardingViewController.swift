import UIKit

final class OnboardingViewController: UIViewController {
    
    // MARK: - UI Elements
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 3
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    private lazy var navigationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let title = NSLocalizedString("onboarding.navigationButton.title", comment: "The button that takes a user to the main app")
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(navigateToTracker), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        completeOnboarding()
    }
    
    // MARK: - UI Configuration
    private func configureUI() {
        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)
        view.addSubview(navigationButton)
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            navigationButton.heightAnchor.constraint(equalToConstant: 60),
            navigationButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            navigationButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            navigationButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50)
            
        ])
    }
    
    // MARK: - Public Methods
    func setBackgroundImage(to image: UIImage) {
        backgroundImageView.image = image
    }
    
    func setTitleLabel(to title: String) {
        titleLabel.text = title
    }
    
    func completeOnboarding() {
        UserDefaults.standard.setValue(true, forKey: "onboardingCompleted")
    }
    
    // MARK: - Actions
    @objc private func navigateToTracker() {
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        
        let tabBarController = TabBarController()
        window.rootViewController = tabBarController
        UIView.transition(
            with: window,
            duration: 0.5,
            options: .transitionFlipFromRight,
            animations: nil,
            completion: nil
        )
    }
}
