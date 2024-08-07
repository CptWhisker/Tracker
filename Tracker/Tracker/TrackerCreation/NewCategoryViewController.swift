import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - Properties
    private var categories: [TrackerCategory]?
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "trackersStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.text = """
            Привычки и события можно
            объединить по смыслу
            """
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()
    private lazy var stubStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [stubImage, stubLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        return stackView
    }()
    private lazy var categoriesTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .ypMain
        tableView.layer.cornerRadius = 16
        return tableView
    }()
    private lazy var newCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.clipsToBounds = true
        button.backgroundColor = .ypAccent
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.ypMain, for: .normal)
        button.addTarget(self, action: #selector(createNewCategory), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Interface Configuration
    private func configureInterface() {
        title = "Категория"
        view.backgroundColor = .ypMain
        
        configureNewCategoryButton()
        
        guard categories != nil else {
            configureStubImageAndText()
            return
        }
        
        configureCategoryTableView()
    }
    
    private func configureNewCategoryButton() {
        view.addSubview(newCategoryButton)
        
        NSLayoutConstraint.activate([
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func configureCategoryTableView() {
        view.addSubview(categoriesTableView)
        
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Actions
    @objc private func createNewCategory() {
        let categoryCreationViewController = CategoryCreationViewController()
        categoryCreationViewController.setDelegate(delegate: self)
        let categoryCreationNavigationController = UINavigationController(rootViewController: categoryCreationViewController)
        
        present(categoryCreationNavigationController, animated: true, completion: nil)
    }
}

extension NewCategoryViewController: CategoryCreationDelegate {
    func didCreateCategory() {
        dismiss(animated: true, completion: nil)
    }
}
