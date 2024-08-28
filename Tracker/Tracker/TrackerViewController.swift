import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private var trackersToDisplay: [Tracker?] = [] {
        didSet {
            let weekday = Calendar.current.component(.weekday, from: selectedDate)
            filterTrackersBy(weekday: weekday)
        }
    }
    private var filteredTrackers: [Tracker?] = []
    private var categories: [TrackerCategory?] = []
    private var completedTrackers = Set<TrackerRecord>()
    private var selectedDate: Date = Date().dateWithoutTime
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        return datePicker
    }()
    private lazy var stubImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "trackersStubImage"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private lazy var stubLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
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
    private lazy var trackerCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            TrackerCell.self,
            forCellWithReuseIdentifier: TrackerCell.identifier
        )
        collectionView.register(
            TrackerCategorySupplementaryView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategorySupplementaryView.identifier
        )
        return collectionView
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Interface Configuration
    private func configureInterface() {
        view.backgroundColor = .ypMain
        
        configureNavigationBar()
        configureTrackers()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "navBarAddButton"),
            style: .plain,
            target: self,
            action: #selector(addHabitOrIrregularEvent)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        
        navigationItem.searchController = UISearchController()
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        // TODO: Create custom SearchController
        
        navigationItem.title = "Трекеры"
    }
    
    private func checkTrackers() {
        if !filteredTrackers.isEmpty {
            removeStubImageAndText()
        } else {
            configureStubImageAndText()
        }
    }
    private func configureTrackers() {
        view.addSubview(trackerCollectionView)
        
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        checkTrackers()
    }
    
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
    
    // MARK: - Tracker Filtering
    private func filterTrackersBy(weekday: Int) {
        let weekDayEnum: WeekDays?
        
        switch weekday {
        case 1: weekDayEnum = .sunday
        case 2: weekDayEnum = .monday
        case 3: weekDayEnum = .tuesday
        case 4: weekDayEnum = .wednesday
        case 5: weekDayEnum = .thursday
        case 6: weekDayEnum = .friday
        case 7: weekDayEnum = .saturday
        default: weekDayEnum = nil
        }
        
        guard let dayToFilter = weekDayEnum else { return }
        
        let filteredTrackers = trackersToDisplay.compactMap { tracker -> Tracker? in
            guard let tracker = tracker else { return nil }
            
            if tracker.habitSchedule?.contains(dayToFilter) == true {
                return tracker
            } else {
                return nil
            }
        }
        
        self.filteredTrackers = filteredTrackers
        
        checkTrackers()
        
        trackerCollectionView.reloadData()
    }
    
    // MARK: - Actions
    @objc private func addHabitOrIrregularEvent() {
        let trackerCreationViewController = TrackerCreationViewController()
        trackerCreationViewController.setDelegate(delegate: self)
        let trackerCreationNavigationController = UINavigationController(rootViewController: trackerCreationViewController)
        present(trackerCreationNavigationController, animated: true)
    }
    
    @objc private func dateChanged(_ datePicker: UIDatePicker) {
        selectedDate = datePicker.date.dateWithoutTime
        
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: selectedDate)
        
        filterTrackersBy(weekday: weekday)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell,
              let tracker = filteredTrackers[indexPath.item] else {
            print("[TrackerViewController cellForItemAt]: typecastError - Unable to dequeue cell as TrackerCell")
            return UICollectionViewCell()
        }
        
        let count = completedTrackers.filter { $0.trackerID == tracker.habitID }.count
        let isCompleted = completedTrackers.contains { $0.trackerID == tracker.habitID && datePicker.date.dateWithoutTime == $0.completionDate }
        
        cell.configure(with: tracker, completed: count, isCompleted: isCompleted)
        cell.setDelegate(delegate: self)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard filteredTrackers.count > 0 else {
            return UICollectionReusableView()
        }
        
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategorySupplementaryView.identifier,
            for: indexPath
        ) as? TrackerCategorySupplementaryView else {
            print("[TrackerViewCOntroller viewForSupplementaryElementOfKind]: typecastError - Unable to dequeue view as TrackerCategorySupplementaryView")
            return UICollectionReusableView()
        }
        
        view.setHeaderLabel(to: "Тестовая Категория")
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = (collectionView.frame.width - 40) / CGFloat(2)
        let cellHeight = CGFloat(148)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return CGFloat(8)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard filteredTrackers.count > 0 else {
            return CGSize.zero
        }
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(
            CGSize(
                width: collectionView.frame.width,
                height: UIView.layoutFittingExpandedSize.height
            ),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
    }
}

// MARK: - NewHabitOrIrregularEventDelegate
extension TrackerViewController: NewHabitOrIrregularEventDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        trackersToDisplay.append(tracker)
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCell) {
        guard let indexPath = trackerCollectionView.indexPath(for: cell),
              let tracker = filteredTrackers[indexPath.item] else { return }
        
        let day = selectedDate
        let record = TrackerRecord(trackerID: tracker.habitID, completionDate: day)
        
        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }
        
        let count = completedTrackers.filter { $0.trackerID == tracker.habitID}.count
        let isCompleted = completedTrackers.contains { $0.trackerID == tracker.habitID && datePicker.date.dateWithoutTime == $0.completionDate }
        
        if let updatedCell = trackerCollectionView.cellForItem(at: indexPath) as? TrackerCell {
            updatedCell.configure(completed: count, isCompleted: isCompleted)
        }
    }
}
