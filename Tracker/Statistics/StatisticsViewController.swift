import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "statisticsStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("statistics.stub", comment: "Text for the stub label")
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
    private lazy var statisticsView: StatisticsView = {
        let view = StatisticsView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        return view
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if trackerStore.readTrackersExist() {
            removeStubImageAndText()
            
            let score = trackerRecordStore.readAllRecords()
            statisticsView.setScore(to: score)
        } else {
            configureStubImageAndText()
        }
    }
    
    // MARK: - Private Methods
    private func configureNavigationBar() {
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Title for Statistics screen")
    }
    
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func removeStubImageAndText() {
        stubStackView.removeFromSuperview()
    }
}

//MARK: - UIConfigurationProtocol
extension StatisticsViewController: UIConfigurationProtocol {
    func configureUI() {
        view.backgroundColor = .ypMain
        
        configureNavigationBar()
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(statisticsView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            statisticsView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            statisticsView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            statisticsView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            statisticsView.heightAnchor.constraint(equalToConstant: 90)
        ])
    }
}
