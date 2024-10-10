import UIKit

final class TrackerViewController: UIViewController {
    // MARK: - Properties
    private let pinnedCategoryIdentifier: String = NSLocalizedString("tracker.pinned", comment: "Title for pinned trackers")
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    private var categories: [TrackerCategory] = [] {
        didSet {
            let weekday = Calendar.current.component(.weekday, from: selectedDate)
            filterTrackersInCategoriesBy(weekday: weekday)
        }
    }
    private var filteredCategories: [TrackerCategory] = []
    private var visibleCategories: [TrackerCategory] = []
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
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        return search
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        updateLanguage()
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
        
        navigationItem.searchController = searchController
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        
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
        visibleCategories = filteredCategories
        trackerCollectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func updateLanguage() {
        let currentLanguageIdentifier = pinnedCategoryIdentifier
        let previousLanguageIdentifier = UserDefaults.standard.string(forKey: "currentLanguagePinnedCategoryIdentifier")
        
        guard previousLanguageIdentifier != currentLanguageIdentifier else {
            UserDefaults.standard.setValue(currentLanguageIdentifier, forKey: "currentLanguagePinnedCategoryIdentifier")
            return
        }
        
        if let previousIdentifier = previousLanguageIdentifier {
            trackerCategoryStore.updateTrackerCategoryName(from: previousIdentifier, to: currentLanguageIdentifier)
        }
        
        UserDefaults.standard.setValue(currentLanguageIdentifier, forKey: "currentLanguagePinnedCategoryIdentifier")
    }

    
    private func fetchCategories() {
        categories = trackerCategoryStore.readTrackerCategories()
        
        if !categories.contains(where: { $0.categoryName == pinnedCategoryIdentifier }) {
            let pinnedCategory = TrackerCategory(categoryName: pinnedCategoryIdentifier, trackersInCategory: [])
            trackerCategoryStore.createTrackerCategory(pinnedCategory)
            categories.insert(pinnedCategory, at: 0)
        }
    }
    
    private func pinTracker(_ tracker: Tracker) {
        var updatedTracker = tracker
        updatedTracker.isPinned = true
        
        if let pinnedCategoryIndex = categories.firstIndex(where: { $0.categoryName == pinnedCategoryIdentifier }) {
            let pinnedCategory = categories[pinnedCategoryIndex]
            trackerStore.pinTracker(updatedTracker, to: pinnedCategory)
        }
    }
    
    private func unpinTracker(_ tracker: Tracker) {
        var updatedTracker = tracker
        updatedTracker.isPinned = false

        trackerStore.unpinTracker(updatedTracker)
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
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filterTrackersInCategoriesBy(searchText)
        }
    }
    
    @objc private func pinTracker(at indexPath: IndexPath) {
        if let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] {
            if tracker.isPinned {
                unpinTracker(tracker)
            } else {
                pinTracker(tracker)
            }
            
            fetchCategories()
        }
    }
    
    @objc private func editTracker() {
        print(#function)
    }
    
    @objc private func deleteTracker(at indexPath: IndexPath) {
        if let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] {
            trackerStore.deleteTracker(tracker)
            trackerRecordStore.deleteAllRecords(for: tracker)
            
            fetchCategories()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return visibleCategories[section].trackersInCategory?.count ?? 0
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell,
              let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item]
                
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

// MARK: - UICollectionViewDelegate
extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        guard indexPaths.count > 0 else { return nil }
        
        let indexPath = indexPaths[0]
        
        guard let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] else {
            return nil
        }
        
        let pinString = NSLocalizedString("tracker.contextual.pin", comment: "Title for 'Pin' contextual menu option")
        let unpinString = NSLocalizedString("tracker.contextual.unpin", comment: "Title for 'Unpin' contextual menu option")
        let pinActionTitle = tracker.isPinned ? unpinString : pinString
        let pinEditTitle = NSLocalizedString("tracker.contextual.edit", comment: "Title for 'Edit' contextual menu option")
        let pinDeleteTitle = NSLocalizedString("tracker.contextual.delete", comment: "Title for 'Delete' contextual menu option")
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: pinActionTitle) { [weak self] _ in
                    self?.pinTracker(at: indexPath)
                },
                UIAction(title: pinEditTitle) { [weak self] _ in
                    self?.editTracker()
                },
                UIAction(title: pinDeleteTitle, attributes: .destructive) { [weak self] _ in
                    self?.deleteTracker(at: indexPath)
                },
            ])
        })
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?) {
        guard let indexPath = collectionView.indexPathsForSelectedItems?.first,
              let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        cell.layer.cornerRadius = 0
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

// MARK: - UISearchResultsUpdating
extension TrackerViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filterTrackersInCategoriesBy(searchText)
        } else {
            restoreCategories()
        }
        
        trackerCollectionView.reloadData()
    }
    
    private func filterTrackersInCategoriesBy(_ text: String) {
        visibleCategories = filteredCategories.map {category in
            let filteredTrackers = category.trackersInCategory?.filter { tracker in
                return tracker.habitName.lowercased().contains(text.lowercased())
            } ?? []
            
            return TrackerCategory(categoryName: category.categoryName, trackersInCategory: filteredTrackers)
        }.filter { !($0.trackersInCategory?.isEmpty ?? true) }
    }
    
    private func restoreCategories() {
        visibleCategories = filteredCategories
    }
}
