import UIKit

final class CategoryCreationViewController: UIViewController {
    // MARK: - Properties
    private weak var delegate: CategoryCreationDelegate?
    
    // MARK: - UI Elements
    private lazy var categoryNameTextField: UITextField = {
        let textfield = PaddedTextField(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.delegate = self
        textfield.layer.cornerRadius = 16
        textfield.backgroundColor = .ypBackground
        textfield.placeholder = NSLocalizedString("categoryCreation.placeholder", comment: "Text for category creation textfield's placeholder")
        textfield.addTarget(self, action: #selector(textTyped), for: .editingChanged)
        return textfield
    }()
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        let title = NSLocalizedString("categoryCreation.completeButton", comment: "Title for 'Done' button")
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle(title, for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(completeCreation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addTapGestureToHideKeyboard()
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: CategoryCreationDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Actions
    @objc private func textTyped() {
        let forbiddenString = NSLocalizedString("categoryCreation.forbiddenName", comment: "Forbidden name for pre-existing system category 'Pinned'")
        let forbiddenName: Bool = categoryNameTextField.text?.lowercased() == forbiddenString ? true : false
        let textFieldEmpty = categoryNameTextField.text?.isEmpty ?? true
        completeButton.isEnabled = !textFieldEmpty && !forbiddenName
        completeButton.backgroundColor = !textFieldEmpty && !forbiddenName ? .ypAccent : .ypGray
    }
    
    @objc private func completeCreation() {
        guard let delegate,
              let categoryName = categoryNameTextField.text else { return }
        
        let newCategory = TrackerCategory(categoryName: categoryName, trackersInCategory: [])
        delegate.didCreateCategory(newCategory)
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIConfigurationProtocol
extension CategoryCreationViewController: UIConfigurationProtocol {
    func configureUI() {
        title = "Новая категория"
        view.backgroundColor = .ypMain
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(categoryNameTextField)
        view.addSubview(completeButton)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension CategoryCreationViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
