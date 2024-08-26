import UIKit

final class CancelAndCreateButtonsCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CancelAndCreateButtonsCell"
    private weak var delegate: CancelAndCreateButtonsCellDelegate?
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypMain
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()
    private lazy var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Создать", for: .normal)
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
            cancelButton.widthAnchor.constraint(equalTo: createButton.widthAnchor)
        ])
        return stackView
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
        contentView.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            buttonsStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            buttonsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4)
        ])
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: CancelAndCreateButtonsCellDelegate) {
        self.delegate = delegate
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
