import UIKit

final class EmojiCellSupplementaryView: UICollectionReusableView {
    static let identifier = "Header"
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
extension EmojiCellSupplementaryView: UIConfigurationProtocol {
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
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12)
        ])
    }
}
