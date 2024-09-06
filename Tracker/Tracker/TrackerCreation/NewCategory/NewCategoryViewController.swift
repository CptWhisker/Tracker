import UIKit

final class NewCategoryViewController: UIViewController {
    // MARK: - Properties
    private var trackerCategoryStore = TrackerCategoryStore()
    private weak var delegate: CategorySelectionDelegate?
    private var categories: [TrackerCategory] = []
    private var selectedCategory: TrackerCategory? {
        didSet {
            categoriesTableView.reloadData()
        }
    }
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
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.register(NewCategoryTVCell.self, forCellReuseIdentifier: "NewCategoryCell")
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
        
        categories = trackerCategoryStore.readTrackerCategories()
        configureUI()
    }
    
    // MARK: - Stub Image
    private func configureStubImageAndText() {
        view.addSubview(stubStackView)
        
        NSLayoutConstraint.activate([
            stubStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stubStackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    private func removeStubImageAndText() {
        stubStackView.removeFromSuperview()
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: CategorySelectionDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Actions
    @objc private func createNewCategory() {
        let categoryCreationViewController = CategoryCreationViewController()
        categoryCreationViewController.setDelegate(delegate: self)
        let categoryCreationNavigationController = UINavigationController(rootViewController: categoryCreationViewController)
        
        present(categoryCreationNavigationController, animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension NewCategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewCategoryCell", for: indexPath) as? NewCategoryTVCell else {
            print("[NewCategoryViewController cellForRowAt]: typecastError - Unable to dequeue cell as NewCategoryTVCell")
            return UITableViewCell()
        }
        
        let category = categories[indexPath.row]
        cell.setTitleLabel(to: category.categoryName)
        cell.setCheckmarkVisible(category.categoryName == selectedCategory?.categoryName)
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.roundLowerCorners()
        } else {
            cell.removeCornerRadius()
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

extension NewCategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let categoryCell = cell as? NewCategoryTVCell {
            let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            categoryCell.hideSeparator(isLastCell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let category = categories[indexPath.row]
        
        if category.categoryName != selectedCategory?.categoryName {
            selectedCategory = category
            delegate?.didSelectCategory(category)
        } else {
            selectedCategory = nil
        }
    }
}

// MARK: - CategoryCreationDelegate
extension NewCategoryViewController: CategoryCreationDelegate {
    func didCreateCategory(_ category: TrackerCategory) {
        trackerCategoryStore.createTrackerCategory(category)
        categories.append(category)
        categoriesTableView.reloadData()
        removeStubImageAndText()
    }
}

// MARK: - UIConfigurationProtocol
extension NewCategoryViewController: UIConfigurationProtocol {
    func configureUI() {
        title = "Категория"
        view.backgroundColor = .ypMain
        
        addSubviews()
        addConstraints()
        
        if categories.isEmpty {
            configureStubImageAndText()
        }
    }
    
    func addSubviews() {
        view.addSubview(newCategoryButton)
        view.addSubview(categoriesTableView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            newCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            newCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            newCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            newCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoriesTableView.bottomAnchor.constraint(equalTo: newCategoryButton.topAnchor, constant: -24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16)
        ])
    }
}
