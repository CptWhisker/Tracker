import UIKit

final class NewCategoryViewController: UIViewController {
    private var categories: [TrackerCategory]?
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "trackersStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = """
            Привычки и события можно
            объединить по смыслу
            """
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    private func configureInterface() {
        title = "Категория"
        view.backgroundColor = .ypMain
        
        guard categories != nil else {
            configureStubImageAndText()
            return
        }
        
        // TODO: Configure labels
    }
    
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
}
