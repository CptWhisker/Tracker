import UIKit

final class FilterCell: UITableViewCell {
    // MARK: - UI Elements
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypAccent
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private let checkmarkIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "categoryCheckmark")
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.tintColor = .ypBlue
        return imageView
    }()
    private lazy var customSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setTitleLabel(to string: String) {
        titleLabel.text = string
    }
    
    func setCheckmarkVisible(_ isVisible: Bool) {
        checkmarkIndicator.isHidden = !isVisible
    }
    
    func roundLowerCorners() {
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 16
        contentView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }
    
    func removeCornerRadius() {
        contentView.layer.cornerRadius = 0
    }
    
    func hideSeparator(_ hide: Bool) {
        customSeparator.isHidden = hide
    }
}

// MARK: - UIConfigurationProtocol
extension FilterCell: UIConfigurationProtocol {
    func configureUI() {
        selectionStyle = .none
        contentView.backgroundColor = .ypBackground
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(checkmarkIndicator)
        contentView.addSubview(titleLabel)
        contentView.addSubview(customSeparator)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            // Accessory
            checkmarkIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checkmarkIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            checkmarkIndicator.heightAnchor.constraint(equalToConstant: 24),
            checkmarkIndicator.widthAnchor.constraint(equalToConstant: 24),
            
            // Label
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: checkmarkIndicator.leadingAnchor, constant: -16),
            
            // Separator
            customSeparator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            customSeparator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            customSeparator.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            customSeparator.heightAnchor.constraint(equalToConstant: 0.5)
        ])
    }
}

