import UIKit

final class NameTextfieldCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "NameTextfieldCell"
    private weak var delegate: NameTextfieldCellDelegate?
    private lazy var nameTextfield: UITextField = {
        let textfield = PaddedTextField(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.cornerRadius = 16
        textfield.backgroundColor = .ypBackground
        textfield.placeholder = "Введите название трекера"
        textfield.addTarget(self, action: #selector(textTyped), for: .editingChanged)
        return textfield
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func configureCell() {
        contentView.addSubview(nameTextfield)
        
        NSLayoutConstraint.activate([
            nameTextfield.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameTextfield.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    @objc private func textTyped() {
        guard let text = nameTextfield.text else { return }
        
        delegate?.didTypeText(text)
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: NameTextfieldCellDelegate) {
        self.delegate = delegate
    }
}
