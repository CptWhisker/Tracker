import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private var trackersToDisplay: [Tracker]?
    private var categories: [TrackerCategory]?
    private var completedTrackers: [TrackerRecord]?
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        return datePicker
    }()
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "trackersStubImage"))
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
        view.backgroundColor = .ypMain
        
        configureNavigationBar()
        configureTrackers()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "navBarAddButton"),
            style: .plain,
            target: self,
            action: #selector(addHabitOrIrregularEvent)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        // TODO: Create custom SearchController
        
        navigationItem.title = "Трекеры"
    }
    
    private func configureTrackers() {
        guard trackersToDisplay != nil else {
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
    @objc private func addHabitOrIrregularEvent() {
        let trackerCreationViewController = TrackerCreationViewController()
        let trackerCreationNavigationController = UINavigationController(rootViewController: trackerCreationViewController)
        present(trackerCreationNavigationController, animated: true)
    }
}

