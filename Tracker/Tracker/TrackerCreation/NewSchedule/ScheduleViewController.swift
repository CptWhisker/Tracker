import UIKit

final class ScheduleViewController: UIViewController {
    // MARK: - Properties
    private let weekDays: [WeekDays] = WeekDays.allCases
    private var selectedWeekDays: [WeekDays] = []
    private var delegate: ScheduleViewControllerDelegate?
    
    // MARK: - UI Elements
    private lazy var scheduleTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsSelection = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .red
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.layer.cornerRadius = 16
        tableView.register(ScheduleCell.self, forCellReuseIdentifier: ScheduleCell.identifier)
        return tableView
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
        button.addTarget(self, action: #selector(complete), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: ScheduleViewControllerDelegate) {
        self.delegate = delegate
    }
    
    // MARK: - Actions
    @objc private func complete() {
        delegate?.didSelectWeekDays(weekdays: selectedWeekDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDataSource
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ScheduleCell()
        cell.setTitle(to: weekDays[indexPath.row])
        cell.setDelegate(delegate: self)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height / CGFloat(weekDays.count)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            cell.removeSeparator()
        } else {
            cell.setLeftAndRightSeparatorInsets(to: 16)
        }
    }
}

// MARK: - ScheduleCreationDelegate
extension ScheduleViewController: ScheduleCreationDelegate {
    func addWeekDay(_ weekday: String) {
        guard let weekDay = WeekDays(rawValue: weekday) else {
            print("[ScheduleViewController addWeekDay]: weekdayError - Weekday is not found")
            return
        }
        selectedWeekDays.append(weekDay)
    }
    
    func removeWeekDay(_ weekday: String) {
        guard let weekDay = WeekDays(rawValue: weekday) else {
            print("[ScheduleViewController removeWeekDay]: weekdayError - Weekday is not found")
            return
        }
        selectedWeekDays.removeAll(where: {$0 == weekDay})
    }
}

// MARK: - UIConfigurationProtocol
extension ScheduleViewController: UIConfigurationProtocol {
    func configureUI() {
        view.backgroundColor = .ypMain
        title = "Расписание"
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(scheduleTableView)
        view.addSubview(completeButton)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            scheduleTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 25),
            scheduleTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scheduleTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scheduleTableView.heightAnchor.constraint(equalToConstant: 525),
            
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            completeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            completeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            completeButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
}
