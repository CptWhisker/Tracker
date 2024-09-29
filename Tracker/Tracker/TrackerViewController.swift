import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private var categories: [TrackerCategory] = [] {
        didSet {
            let weekday = Calendar.current.component(.weekday, from: selectedDate)
            filterTrackersInCategoriesBy(weekday: weekday)
        }
    }
    private var filteredCategories: [TrackerCategory] = []
    private var selectedDate: Date = Date().dateWithoutTime
    
    // MARK: - UI Elements
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
        label.text = NSLocalizedString("tracker.stub", comment: "Text for the stub label")
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
        
        configureUI()
        fetchCategories()
        checkTrackers()
    }
    
    // MARK: - UI Configuration
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
        
        navigationItem.title = NSLocalizedString("tracker.title", comment: "Title for Trackers screen")
    }
    
    private func checkTrackers() {
        let hasTrackers = filteredCategories.contains { $0.trackersInCategory?.isEmpty == false }
            if hasTrackers {
            removeStubImageAndText()
        } else {
            configureStubImageAndText()
        }
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
    private func filterTrackersInCategoriesBy(weekday: Int) {
        guard let dayToFilter = WeekDays.from(weekday: weekday) else { return }
        
        filteredCategories = categories.map { category -> TrackerCategory in
            let filteredTrackers = category.trackersInCategory?.filter { tracker in
                if let schedule = tracker.habitSchedule {
                    return schedule.contains(dayToFilter)
                } else {
                    return Calendar.current.isDate(selectedDate, inSameDayAs: Date())
                }
            } ?? []
            
            let sortedTrackers = filteredTrackers.sorted { $0.habitName < $1.habitName }
            
            return TrackerCategory(categoryName: category.categoryName, trackersInCategory: sortedTrackers)
        }.filter { !($0.trackersInCategory?.isEmpty ?? true) }
        
        checkTrackers()
        trackerCollectionView.reloadData()
    }

    // MARK: - Private Methods
    private func fetchCategories() {
        categories = trackerCategoryStore.readTrackerCategories()
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
        
        filterTrackersInCategoriesBy(weekday: weekday)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return filteredCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        
        return filteredCategories[section].trackersInCategory?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell,
              let tracker = filteredCategories[indexPath.section].trackersInCategory?[indexPath.item]
        else {
            print("[TrackerViewController cellForItemAt]: typecastError - Unable to dequeue cell as TrackerCell")
            return UICollectionViewCell()
        }

        let count = trackerRecordStore.readTrackerRecordCount(tracker.habitID)
        let isCompleted = trackerRecordStore.readTrackerRecordIsCompleted(tracker.habitID, for: datePicker.date.dateWithoutTime) ?? false
        
        cell.configure(with: tracker, timesCompleted: count, isCompleted: isCompleted)
        cell.setDelegate(delegate: self)
        return cell
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategorySupplementaryView.identifier,
            for: indexPath
        ) as? TrackerCategorySupplementaryView else {
            print("[TrackerViewController viewForSupplementaryElementOfKind]: typecastError - Unable to dequeue view as TrackerCategorySupplementaryView")
            return UICollectionReusableView()
        }
        
        let category = filteredCategories[indexPath.section]
        view.setHeaderLabel(to: category.categoryName)
        
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        
        let cellWidth = (collectionView.frame.width - 40) / CGFloat(2)
        let cellHeight = CGFloat(148)
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return CGFloat(0)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        
        return CGFloat(8)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        
        guard let trackersInCategory = filteredCategories[section].trackersInCategory, !trackersInCategory.isEmpty
        else {
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
    func didCreateTracker() {
        categories = trackerCategoryStore.readTrackerCategories()
    }
}

// MARK: - TrackerCellDelegate
extension TrackerViewController: TrackerCellDelegate {
    func didTapPlusButton(in cell: TrackerCell) {
        let today = Date().dateWithoutTime
        if selectedDate > today {
            return
        }
        
        guard let indexPath = trackerCollectionView.indexPath(for: cell),
              let tracker = filteredCategories[indexPath.section].trackersInCategory?[indexPath.item]
        else { return }
        
        let day = selectedDate
        let record = TrackerRecord(trackerID: tracker.habitID, completionDate: day)
        
        if let trackerExists = trackerRecordStore.readContainsTrackerRecord(record), trackerExists {
            trackerRecordStore.deleteTrackerRecord(record)
        } else {
            trackerRecordStore.createTrackerRecord(record)
        }

        let count = trackerRecordStore.readTrackerRecordCount(record.trackerID)
        let isCompleted = trackerRecordStore.readTrackerRecordIsCompleted(record.trackerID, for: datePicker.date.dateWithoutTime) ?? false
        
        if let cellToUpdate = trackerCollectionView.cellForItem(at: indexPath) as? TrackerCell {
            cellToUpdate.configure(completed: count, isCompleted: isCompleted)
        }
    }
}

// MARK: - UIConfigurationProtocol
extension TrackerViewController: UIConfigurationProtocol {
    func configureUI() {
        view.backgroundColor = .ypMain
        
        configureNavigationBar()
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(trackerCollectionView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}
