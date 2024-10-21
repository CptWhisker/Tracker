import UIKit

protocol TrackerFilteringViewControllerDelegate: AnyObject {
    func updateFilter(with filter: Filters)
}

enum Filters: String {
    case all = "All"
    case today = "Trackers for today"
    case completed = "Completed"
    case incompleted = "Not completed"
}

final class TrackerFilteringViewController: UIViewController {
    // MARK: - Properties
    private weak var delegate: TrackerFilteringViewControllerDelegate?
    private let filters: [Filters]  = [.all, .today, .completed, .incompleted]
    private var selectedFilter: Filters
    
    // MARK: - UI Elements
    private lazy var filterTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .none
        tableView.register(FilterCell.self, forCellReuseIdentifier: "FilterCell")
        return tableView
    }()
    
    // MARK: - Initialization
    init(selectedFilter: Filters) {
        self.selectedFilter = selectedFilter
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: TrackerFilteringViewControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
}

// MARK: - UITableViewDataSource
extension TrackerFilteringViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath) as? FilterCell else {
            print("[TrackerFilteringViewController cellForRowAt]: typecastError - Unable to dequeue cell as FilterCell")
            return UITableViewCell()
        }
        
        let filter = filters[indexPath.row]
        cell.setTitleLabel(to: filter.rawValue)
        cell.setCheckmarkVisible(filter == selectedFilter)
        
        
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.roundLowerCorners()
        } else {
            cell.removeCornerRadius()
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension TrackerFilteringViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let filterCell = cell as? FilterCell {
            let isLastCell = indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
            filterCell.hideSeparator(isLastCell)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedFilter = filters[indexPath.row]
                
        delegate?.updateFilter(with: selectedFilter)
        
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIConfigurationProtocol
extension TrackerFilteringViewController: UIConfigurationProtocol {
    func configureUI() {
        title = "Filters"
        view.backgroundColor = .ypMain
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(filterTableView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            filterTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            filterTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            filterTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            filterTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}
