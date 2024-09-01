import UIKit

final class StatisticsViewController: UIViewController {
    // MARK: - Properties
    private var statisticsToDisplay: [AnyObject]?
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "statisticsStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Анализировать пока нечего"
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
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Private Methods
    private func configureNavigationBar() {
        navigationItem.title = "Статистика"
    }
    
    private func configureStatistics() {
        guard statisticsToDisplay != nil else {
            configureStubImageAndText()
            return
        }
        
        // Show statistics
    }
    
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}

//MARK: - UIConfigurationProtocol
extension StatisticsViewController: UIConfigurationProtocol {
    func configureUI() {
        view.backgroundColor = .white
        
        configureNavigationBar()
        configureStatistics()
    }
    
    func addSubviews() {}
    
    func addConstraints() {}
    
    
}
