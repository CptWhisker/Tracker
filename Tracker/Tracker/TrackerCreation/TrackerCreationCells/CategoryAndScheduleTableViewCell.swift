import UIKit

final class CategoryAndScheduleTableViewCell: UICollectionViewCell {
    // MARK: - Properties
    static let identifier = "CategoryAndScheduleTableViewCell"
    private weak var delegate: NewCategoryAndScheduleTableViewDelegate?
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
    
    // MARK: - Public Methods
    func setInitializerTag(to initializerTag: InitializerTag) {
        self.initializerTag = initializerTag
    }
    
    func setDelegate(delegate: NewCategoryAndScheduleTableViewDelegate) {
        self.delegate = delegate
    }
    
    func setSelectedWeekDaysLabel(weekdays: [WeekDays]) {
        let weekdayString = weekdays.map { $0.abbreviation }.joined(separator: ", ")
        
        let indexPath = IndexPath(row: 1, section: 0)
        
        if let cell = categoryAndScheduleTableView.cellForRow(at: indexPath) as? CategoryAndScheduleCell {
            cell.setSelectionLabel(to: weekdayString)
            print(weekdayString)
        }
    }
}

// MARK: - UITableViewDataSource
extension CategoryAndScheduleTableViewCell: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = CategoryAndScheduleCell()
        cell.setTitleLabel(to: tableViewOptions[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoryAndScheduleTableViewCell: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return contentView.frame.height / CGFloat(tableViewOptions.count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.removeSeparator()
        } else {
            cell.setLeftAndRightSeparatorInsets(to: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let delegate else {
        print("[CategoryAndScheduleTableViewCell didSelectRowAt]: delegateError - Delegate is not set")
        return
    }
        
        switch tableViewOptions[indexPath.row] {
        case "Категория":
        delegate.didTapCategoryButton()
            
        case "Расписание":
        delegate.didTapScheduleButton()
            
        default:
            fatalError("Unexpected index path")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
