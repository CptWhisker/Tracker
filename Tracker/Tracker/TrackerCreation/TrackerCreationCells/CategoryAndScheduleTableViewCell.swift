import UIKit

final class CategoryAndScheduleTableViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CategoryAndScheduleTableViewCell"
    private var initializerTag: InitializerTag? {
        didSet {
            categoryAndScheduleTableView.reloadData()
        }
    }
    private lazy var tableViewOptions: [String] =  {
        if initializerTag == .habit {
            return ["Категория", "Расписание"]
        } else {
            return ["Категория"]
        }
    }()
    private lazy var categoryAndScheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        return tableView
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
        contentView.addSubview(categoryAndScheduleTableView)
        
        NSLayoutConstraint.activate([
            categoryAndScheduleTableView.topAnchor.constraint(equalTo: contentView.topAnchor),
            categoryAndScheduleTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            categoryAndScheduleTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            categoryAndScheduleTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
    
    private func configureSeparatorInsets(_ tableView: UITableView, forCell cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    // MARK: - Public Methods
    func setInitializerTag(to initializerTag: InitializerTag) {
        self.initializerTag = initializerTag
    }
}

// MARK: - UITableViewDataSource
extension CategoryAndScheduleTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = tableViewOptions[indexPath.row]
        cell.backgroundColor = .ypBackground
        cell.accessoryType = .disclosureIndicator
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryAndScheduleTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentView.frame.height / CGFloat(tableViewOptions.count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        configureSeparatorInsets(tableView, forCell: cell, forRowAt: indexPath)
    }
}
