import UIKit

final class ProgressLabelCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "ProgressLabelCell"
    
    // MARK: - UI Elements
    private lazy var progressLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
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
    func setProgress(to days: Int) {
        let dayFormatString = NSLocalizedString("daysPlural", comment: "Number of days a tracker was completed in plural configuration")
        let dayResultString = String.localizedStringWithFormat(dayFormatString, days)
        progressLabel.text = dayResultString
    }
}

// MARK: - UIConfigurationProtocol
extension ProgressLabelCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(progressLabel)

    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            progressLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            progressLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            progressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            progressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}
