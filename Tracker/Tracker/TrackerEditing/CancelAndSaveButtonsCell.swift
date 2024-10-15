import UIKit

final class CancelAndSaveButtonsCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CancelAndCreateButtonsCell"
    private weak var delegate: CancelAndSaveButtonsCellDelegate?
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("cancelButton.title", comment: "Title for 'Cancel' button")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypMain
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()
    private lazy var saveButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("saveButton.title", comment: "Title for 'Save' button")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, saveButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        
        NSLayoutConstraint.activate([
            
        ])
        return stackView
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
    func setDelegate(delegate: CancelAndSaveButtonsCellDelegate) {
        self.delegate = delegate
    }
    
    func setSaveButtonState(isEnabled: Bool) {
        saveButton.backgroundColor = isEnabled ? .ypAccent : .ypGray
        saveButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @objc private func cancelAction() {
        guard let delegate else {
            print("[CancelAndSaveButtonsCell cancelAction]: delegateError - Delegate is not set")
            return
        }
        
        delegate.didTapCancelButton()
    }
    
    @objc private func saveAction() {
        guard let delegate else {
            print("[CancelAndSaveButtonsCell saveAction]: delegateError - Delegate is not set")
            return
        }
        
        delegate.didTapSaveButton()
    }
}

// MARK: - UIConfigurationProtocol
extension CancelAndSaveButtonsCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(buttonsStackView)

    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalTo: saveButton.widthAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
}
