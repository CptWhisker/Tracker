import UIKit

final class CancelAndCreateButtonsCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CancelAndCreateButtonsCell"
    private weak var delegate: CancelAndCreateButtonsCellDelegate?
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
    private lazy var createButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("createButton.title", comment: "Title for 'Create' button")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypGray
        button.isEnabled = false
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.addTarget(self, action: #selector(createAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [cancelButton, createButton])
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
    func setDelegate(delegate: CancelAndCreateButtonsCellDelegate) {
        self.delegate = delegate
    }
    
    func setCreateButtonState(isEnabled: Bool) {
        createButton.backgroundColor = isEnabled ? .ypAccent : .ypGray
        createButton.isEnabled = isEnabled
    }
    
    // MARK: - Actions
    @objc private func cancelAction() {
        guard let delegate else {
            print("[CancelAndCreateButtonsCell cancelAction]: delegateError - Delegate is not set")
            return
        }
        
        delegate.didTapCancelButton()
    }
    
    @objc private func createAction() {
        guard let delegate else {
            print("[CancelAndCreateButtonsCell cancelAction]: delegateError - Delegate is not set")
            return
        }
        
        delegate.didTapCreateButton()
    }
}

// MARK: - UIConfigurationProtocol
extension CancelAndCreateButtonsCell: UIConfigurationProtocol {
    func configureUI() {
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        contentView.addSubview(buttonsStackView)

    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor),
            
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
}
