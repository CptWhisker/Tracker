import UIKit

final class CategoryAndScheduleCell: UITableViewCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypAccent
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    private let selectionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .ypGray
        label.font = .systemFont(ofSize: 17)
        label.text = ""
        return label
    }()
    private let disclosureIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .ypGray
        return imageView
    }()
    
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
    
    func setSelectionLabel(to string: String) {
        selectionLabel.text = string
    }
}

// MARK: - UIConfigurationProtocol
extension CategoryAndScheduleCell: UIConfigurationProtocol {
    func configureUI() {
        contentView.backgroundColor = .ypBackground

        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(disclosureIndicator)

        contentView.addSubview(titleLabel)
        contentView.addSubview(selectionLabel)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            // Accessory
            disclosureIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            disclosureIndicator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            disclosureIndicator.widthAnchor.constraint(equalToConstant: 10),
            disclosureIndicator.heightAnchor.constraint(equalToConstant: 16),
            
            // Labels
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: disclosureIndicator.leadingAnchor, constant: -16),
            selectionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            selectionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            selectionLabel.widthAnchor.constraint(equalTo: titleLabel.widthAnchor)
        ])
    }
}
