import UIKit

final class TrackerCategorySupplementaryView: UICollectionReusableView {
    // MARK: - Properties
    static let identifier = "Header"
    
    // MARK: - UI Elements
    private lazy var headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypAccent
        label.font = .systemFont(ofSize: 19, weight: .bold)
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setHeaderLabel(to headerString: String) {
        headerLabel.text = headerString
    }
}

// MARK: - UIConfigurationProtocol
extension TrackerCategorySupplementaryView: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        addSubview(headerLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 28)
        ])
    }
}
