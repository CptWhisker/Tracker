import UIKit

final class NameTextfieldCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "NameTextfieldCell"
    private weak var view: UIViewController?
    private weak var delegate: NameTextfieldCellDelegate?
    lazy var nameTextfield: UITextField = {
        let textfield = PaddedTextField(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        textfield.layer.cornerRadius = 16
        textfield.backgroundColor = .ypBackground
        textfield.placeholder = NSLocalizedString("nameTextfield.placeholder", comment: "Text for the placeholder")
        textfield.addTarget(self, action: #selector(textTyped), for: .editingChanged)
        return textfield
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    @objc private func textTyped() {
        guard let text = nameTextfield.text else { return }
        
        delegate?.didTypeText(text)
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: NameTextfieldCellDelegate) {
        self.delegate = delegate
    }
}

//MARK: - UIConfigurationProtocol
extension NameTextfieldCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(nameTextfield)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            nameTextfield.topAnchor.constraint(equalTo: contentView.topAnchor),
            nameTextfield.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            nameTextfield.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameTextfield.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension NameTextfieldCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
