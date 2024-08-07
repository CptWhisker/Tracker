import UIKit

final class CategoryCreationViewController: UIViewController {
    // MARK: - Properties
    private weak var delegate: CategoryCreationDelegate?
    private lazy var categoryNameTextField: UITextField = {
        let textfield = PaddedTextField(padding: UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        textfield.translatesAutoresizingMaskIntoConstraints = false
        textfield.layer.cornerRadius = 16
        textfield.backgroundColor = .ypBackground
        textfield.placeholder = "Введите название категории"
        return textfield
    }()
    private lazy var completeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypAccent
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.addTarget(self, action: #selector(completeCreation), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Interface Configuration
    private func configureInterface() {
        title = "Новая категория"
        view.backgroundColor = .ypMain
        
        configureCategoryNameTextField()
        configureCompleteButton()
    }
    
    private func configureCategoryNameTextField() {
        view.addSubview(categoryNameTextField)

        NSLayoutConstraint.activate([
            categoryNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryNameTextField.heightAnchor.constraint(equalToConstant: 75),
        ])
    }
    
    private func configureCompleteButton() {
        view.addSubview(completeButton)

        NSLayoutConstraint.activate([
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: CategoryCreationDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Actions
    @objc private func completeCreation() {
        dismiss(animated: true, completion: nil)
    }
    
    deinit {
        guard let delegate else {
            print("[CategoryCreationViewController completeCreation]: delegateError - Delegate is not set")
            return
        }
        
        delegate.didCreateCategory()
    }
}
