import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private var trackersToDisplay: [AnyObject]?
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "stubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    private lazy var stubStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubImage, stubLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Interface Configuration
    private func configureInterface() {
        view.backgroundColor = .white
        
        configureNavigationItems()
        configureTrackers()
    }
    
    private func configureNavigationItems() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "navBarAdd"),
            style: .plain,
            target: self,
            action: #selector(addHabitOrEvent)
        )
        
        navigationItem.title = "Трекеры"
    }
    
    private func configureTrackers() {
        guard let trackersToDisplay else {
            configureStubImageAndText()
            return
        }
        
        // Show trackers
    }
    
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc private func addHabitOrEvent() {
        // Add habit or irregular event
    }
}

