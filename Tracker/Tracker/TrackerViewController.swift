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
    private var currentWeekDay: Int {
        return Calendar.current.component(.weekday, from: selectedDate)
    }
    private var selectedFilter: Filters = .all
    
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
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    private lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.obscuresBackgroundDuringPresentation = false
        search.searchResultsUpdater = self
        return search
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Filters", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 16
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        updateLanguage()
        fetchCategories()
        checkTrackers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        configureCollectionViewOverscroll()
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
        
        if selectedFilter == .completed || selectedFilter == .incompleted {
            applyFilter(selectedFilter)
        }
        
        checkTrackers()
        visibleCategories = filteredCategories
        trackerCollectionView.reloadData()
    }
    
    private func applyFilter(_ filter: Filters) {
        switch filter {
        case .all, .today:
            return
        case .completed:
            filteredCategories = filteredCategories.map { category in
                let filteredTrackers = category.trackersInCategory?.filter { tracker in
                    let isCompleted = trackerRecordStore.readTrackerRecordIsCompleted(tracker.habitID, for: selectedDate) ?? false
                    return isCompleted
                } ?? []
                return TrackerCategory(categoryName: category.categoryName, trackersInCategory: filteredTrackers)
            }.filter { !($0.trackersInCategory?.isEmpty ?? true) }
        case .incompleted:
            filteredCategories = filteredCategories.map { category in
                let filteredTrackers = category.trackersInCategory?.filter { tracker in
                    let isCompleted = trackerRecordStore.readTrackerRecordIsCompleted(tracker.habitID, for: selectedDate) ?? false
                    return !isCompleted
                } ?? []
                return TrackerCategory(categoryName: category.categoryName, trackersInCategory: filteredTrackers)
            }.filter { !($0.trackersInCategory?.isEmpty ?? true) }
        }
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
    
    private func deleteTracker(_ tracker: Tracker) {
        trackerStore.deleteTracker(tracker)
        trackerRecordStore.deleteAllRecords(for: tracker)
        
        fetchCategories()
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
        
//        let calendar = Calendar.current
//        let weekday = calendar.component(.weekday, from: selectedDate)
//        
//        filterTrackersInCategoriesBy(weekday: weekday)
        
        filterTrackersInCategoriesBy(weekday: currentWeekDay)
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filterTrackersInCategoriesBy(searchText)
        }
    }
    
    @objc private func pinTracker(at indexPath: IndexPath) {
        guard let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] else { return }
        
        if tracker.isPinned {
            unpinTracker(tracker)
        } else {
            pinTracker(tracker)
        }
        
        fetchCategories()
    }
    
    @objc private func editTracker(at indexPath: IndexPath) {
        guard let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] else { return }
        
        let initializerTag: InitializerTag = tracker.habitSchedule != nil ? .habit : .event
        let count = trackerRecordStore.readTrackerRecordCount(tracker.habitID)
        let trackerEditingViewController = TrackerEditingViewController(initializerTag: initializerTag, editingTracker: tracker, daysCompleted: count)
        trackerEditingViewController.setDelegate(delegate: self)
        let trackerEditingNavigationController = UINavigationController(rootViewController: trackerEditingViewController)
        present(trackerEditingNavigationController, animated: true)
    }
    
    @objc private func deleteTracker(at indexPath: IndexPath) {
        guard let tracker = visibleCategories[indexPath.section].trackersInCategory?[indexPath.item] else { return }
        
        let title = NSLocalizedString("tracker.actionSheet.text", comment: "Title for contextual menu's 'Delete' action")
        let deleteString = NSLocalizedString("tracker.actionSheet.deleteAction", comment: "Text for Alert Controller's 'Delete' button")
        let cancelString = NSLocalizedString("tracker.actionSheet.cancelAction", comment: "Text for Alert Controller's 'Cancel' button")
        
        let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: deleteString, style: .destructive) { [weak self] _ in
            self?.deleteTracker(tracker)
        })
        alertController.addAction(UIAlertAction(title: cancelString, style: .cancel))
        
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTapped() {
        let trackerFilteringViewController = TrackerFilteringViewController(selectedFilter: selectedFilter)
        trackerFilteringViewController.setDelegate(delegate: self)
        let trackerFilteringNavigationController = UINavigationController(rootViewController: trackerFilteringViewController)
        present(trackerFilteringNavigationController, animated: true)
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
        let menuActionTitle = tracker.isPinned ? unpinString : pinString
        let menuEditTitle = NSLocalizedString("tracker.contextual.edit", comment: "Title for 'Edit' contextual menu option")
        let menuDeleteTitle = NSLocalizedString("tracker.contextual.delete", comment: "Title for 'Delete' contextual menu option")
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: menuActionTitle) { [weak self] _ in
                    self?.pinTracker(at: indexPath)
                },
                UIAction(title: menuEditTitle) { [weak self] _ in
                    self?.editTracker(at: indexPath)
                },
                UIAction(title: menuDeleteTitle, attributes: .destructive) { [weak self] _ in
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
        
        filterTrackersInCategoriesBy(weekday: currentWeekDay)
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
        view.addSubview(filterButton)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            trackerCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            trackerCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            trackerCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackerCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    func configureCollectionViewOverscroll() {
        let buttonHeight: CGFloat = filterButton.bounds.height
        let padding: CGFloat = 16
        let totalInset = buttonHeight + padding
        
        trackerCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: totalInset, right: 0)
        trackerCollectionView.scrollIndicatorInsets = trackerCollectionView.contentInset
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

// MARK: - TrackerFilteringViewControllerDelegate
extension TrackerViewController: TrackerFilteringViewControllerDelegate {
    func updateFilter(with filter: Filters) {
        selectedFilter = filter
        
        if filter == .today {
            let today = Date().dateWithoutTime
            if selectedDate != today {
                datePicker.date = today
                dateChanged(datePicker)
            }
            datePicker.isEnabled = false
        } else {
            datePicker.isEnabled = true
            filterTrackersInCategoriesBy(weekday: currentWeekDay)
        }
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filterTrackersInCategoriesBy(searchText)
        }
        
        if filter != .all {
            filterButton.layer.borderWidth = 4
        } else {
            filterButton.layer.borderWidth = 0
        }
    }
}
