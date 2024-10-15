import UIKit

final class TrackerEditingViewController: UIViewController {
    // MARK: - Properties
    private let initializerTag: InitializerTag
    private let editingTracker: Tracker
    private let daysCompleted: Int
    private var trackerCategoryStore = TrackerCategoryStore()
    private var trackerStore = TrackerStore()
    private weak var delegate: NewHabitOrIrregularEventDelegate?
    private var trackerTitle: String? {
        didSet { updateCreateButtonState() }
    }
    private var trackerCategory: TrackerCategory? {
        didSet { updateCreateButtonState() }
    }
    private var trackerWeekDays: [WeekDays]? {
        didSet { updateCreateButtonState() }
    }
    private var trackerEmoji: String? {
        didSet { updateCreateButtonState() }
    }
    private var trackerColor: UIColor? {
        didSet { updateCreateButtonState() }
    }
    
    // MARK: - UI Elements
    private lazy var newHabitOrEventCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(ProgressLabelCell.self, forCellWithReuseIdentifier: ProgressLabelCell.identifier)
        collectionView.register(NameTextfieldCell.self, forCellWithReuseIdentifier: NameTextfieldCell.identifier)
        collectionView.register(CategoryAndScheduleTableViewCell.self, forCellWithReuseIdentifier: CategoryAndScheduleTableViewCell.identifier)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.register(ColorSchemeCollectionViewCell.self, forCellWithReuseIdentifier: ColorSchemeCollectionViewCell.identifier)
        collectionView.register(CancelAndSaveButtonsCell.self, forCellWithReuseIdentifier: CancelAndCreateButtonsCell.identifier)
        return collectionView
    }()
    
    // MARK: - Initializers
    init(initializerTag: InitializerTag, editingTracker: Tracker, daysCompleted: Int) {
        self.initializerTag = initializerTag
        self.editingTracker = editingTracker
        self.daysCompleted = daysCompleted
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        addTapGestureToHideKeyboard()
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            
            self.configureWithTracker(self.editingTracker)
        }
    }
    
    // MARK: - Private Methods
    private func configureWithTracker(_ tracker: Tracker) {
        trackerTitle = tracker.habitName
        updateTrackerTitle(with: tracker.habitName)
        
        let category = TrackerCategory(categoryName: tracker.originalCategory)
        setTrackerCategory(to: category)
        updateCategorySelectionLabel(with: category)
        
        if let weekdays = tracker.habitSchedule {
            setTrackerWeekDays(to: weekdays)
            updateSheduleSelectionLabel(with: weekdays)
        }
        
        trackerEmoji = tracker.habitEmoji
        updateEmojiSelectionLabel(with: tracker.habitEmoji)
        
        trackerColor = tracker.habitColor
        updateColorSelectionLabel(with: tracker.habitColor)
    }
    
    private func setTrackerCategory(to category: TrackerCategory?) {
        trackerCategory = category
    }
    
    private func setTrackerWeekDays(to weekdays: [WeekDays]) {
        trackerWeekDays = weekdays
    }
    
    private func updateTrackerTitle(with title: String) {
        let indexPath = IndexPath(item: 1, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? NameTextfieldCell {
            cell.setTitle(title)
        }
    }
    
    private func updateCategorySelectionLabel(with category: TrackerCategory?) {
        let indexPath = IndexPath(item: 2, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? CategoryAndScheduleTableViewCell {
            cell.setSelectedCategoryLabel(category: category)
        }
    }
    
    private func updateSheduleSelectionLabel(with weekdays: [WeekDays]) {
        let indexPath = IndexPath(item: 2, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? CategoryAndScheduleTableViewCell {
            cell.setSelectedWeekDaysLabel(weekdays: weekdays)
        }
    }
    
    private func updateEmojiSelectionLabel(with emoji: String) {
        let indexPath = IndexPath(item: 3, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell {
            cell.selectEmoji(withEmoji: emoji)
        }
    }
    
    private func updateColorSelectionLabel(with color: UIColor) {
        let indexPath = IndexPath(item: 4, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? ColorSchemeCollectionViewCell {
            cell.selectCell(withColor: color)
        }
    }
    
    private func updateCreateButtonState() {
        let allFieldsFilled: Bool = checkIfAllFilled()
        let indexPath = IndexPath(item: 5, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? CancelAndSaveButtonsCell {
            cell.setSaveButtonState(isEnabled: allFieldsFilled)
        }
    }
    
    private func checkIfAllFilled() -> Bool {
        switch initializerTag {
        case .habit:
            return (trackerTitle != nil) && (trackerCategory != nil) && (trackerEmoji != nil) && (trackerColor != nil) && (trackerWeekDays != nil)
        case .event:
            return (trackerTitle != nil) && (trackerCategory != nil) && (trackerEmoji != nil) && (trackerColor != nil)
        }
    }
    
    // MARK: - Public Methods
    func setDelegate(delegate: NewHabitOrIrregularEventDelegate) {
        self.delegate = delegate
    }
}

// MARK: - UICollectionViewDataSource
extension TrackerEditingViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProgressLabelCell.identifier, for: indexPath) as? ProgressLabelCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as ProgressLabelCell")
                return UICollectionViewCell()
            }
            
            cell.setProgress(to: daysCompleted)
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameTextfieldCell.identifier, for: indexPath) as? NameTextfieldCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as NameTextfieldCell")
                return UICollectionViewCell()
            }
            
            cell.setDelegate(delegate: self)
            
            return cell
            
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryAndScheduleTableViewCell.identifier, for: indexPath) as? CategoryAndScheduleTableViewCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as CategoryAndScheduleTableViewCell")
                return UICollectionViewCell()
            }
            
            cell.setInitializerTag(to: initializerTag)
            cell.setDelegate(delegate: self)
            
            return cell
            
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as EmojiCollectionViewCell")
                return UICollectionViewCell()
            }
            
            cell.setDelegate(delegate: self)
            
            return cell
            
        case 4:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorSchemeCollectionViewCell.identifier, for: indexPath) as? ColorSchemeCollectionViewCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as ColorSchemeCollectionViewCell")
                return UICollectionViewCell()
            }
            
            cell.setDelegate(delegate: self)
            
            return cell
            
        case 5:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CancelAndSaveButtonsCell.identifier, for: indexPath) as? CancelAndSaveButtonsCell else {
                print("[TrackerEditingViewController cellForItemAt]: typecastError - Unable to dequeue cell as CancelAndCreateButtonsCell")
                return UICollectionViewCell()
            }
            
            cell.setDelegate(delegate: self)
            cell.setSaveButtonState(isEnabled: checkIfAllFilled())
            
            return cell
            
        default:
            fatalError("Unexpected index path")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackerEditingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        
        switch indexPath.item {
        case 0:
            let cellHeight: CGFloat = 40
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 1:
            let cellHeight: CGFloat = 75
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 2:
            let cellHeight: CGFloat
            
            if initializerTag == .habit {
                cellHeight = 150
            } else {
                cellHeight = 75
            }
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 3:
            // TODO: Calculate height dynamically
            let cellHeight: CGFloat = 220
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 4:
            // TODO: Calculate height dynamically
            let cellHeight: CGFloat = 220
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 5:
            let cellHeight: CGFloat = 60
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        default:
            fatalError("Unexpected index path")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }
}

// MARK: - NameTextfieldCellDelegate
extension TrackerEditingViewController: NameTextfieldCellDelegate {
    func didTypeText(_ text: String) {
        trackerTitle = text
    }
}

// MARK: - CancelAndSaveButtonsCellDelegate
extension TrackerEditingViewController: CancelAndSaveButtonsCellDelegate {
    func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapSaveButton() {
        let tracker: Tracker
        
        guard let title = trackerTitle,
              let emoji = trackerEmoji,
              let color = trackerColor,
              let category = trackerCategory else {
            print("[TrackerEditingViewController didTapCreateButton]: trackerError - Missong required properties")
            return
        }
        
        if initializerTag == .habit {
            guard let schedule = trackerWeekDays else {
                print("[TrackerEditingViewController didTapCreateButton]: trackerError - Missong required properties")
                return
            }
            
            tracker = Tracker(habitID: editingTracker.habitID, habitName: title, habitColor: color, habitEmoji: emoji, habitSchedule: schedule, isPinned: editingTracker.isPinned, originalCategory: category.categoryName)
        } else {
            tracker = Tracker(habitID: editingTracker.habitID, habitName: title, habitColor: color, habitEmoji: emoji, habitSchedule: nil, isPinned: editingTracker.isPinned, originalCategory: category.categoryName)
        }
        
        dismiss(animated: true) { [weak self, weak delegate] in
            self?.trackerStore.updateTracker(tracker: tracker)
            delegate?.didCreateTracker()
        }
    }
}

// MARK: - NewCategoryAndScheduleTableViewDelegate
extension TrackerEditingViewController: NewCategoryAndScheduleTableViewDelegate {
    func didTapCategoryButton() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.setDelegate(delegate: self)
        newCategoryViewController.setSelectedCategory(category: trackerCategory)
        let newCategoryNavigationController = UINavigationController(rootViewController: newCategoryViewController)
        present(newCategoryNavigationController, animated: true, completion: nil)
    }
    
    func didTapScheduleButton() {
        let scheduleViewController = ScheduleViewController()
        scheduleViewController.setDelegate(delegate: self)
        let scheduleNavigationController = UINavigationController(rootViewController: scheduleViewController)
        present(scheduleNavigationController, animated: true, completion: nil)
    }
}

// MARK: - ScheduleViewControllerDelegate
extension TrackerEditingViewController: ScheduleViewControllerDelegate {
    func didSelectWeekDays(weekdays: [WeekDays]) {
        let sortedWeekDays = weekdays.sorted {
            if let index1 = WeekDays.allCases.firstIndex(of: $0),
               let index2 = WeekDays.allCases.firstIndex(of: $1) {
                return index1 < index2
            }
            return false
        }
        
        setTrackerWeekDays(to: sortedWeekDays)
        updateSheduleSelectionLabel(with: sortedWeekDays)
    }
}

// MARK: - CategorySelectionDelegate
extension TrackerEditingViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory?) {
        setTrackerCategory(to: category)
        updateCategorySelectionLabel(with: category)
    }
}

// MARK: - EmojiCollectionViewCellDelegate
extension TrackerEditingViewController: EmojiCollectionViewCellDelegate {
    func didSelectEmoji(_ emoji: String) {
        trackerEmoji = emoji
    }
}

// MARK: - ColorSchemeCollectionViewDelegate
extension TrackerEditingViewController: ColorSchemeCollectionViewCellDelegate {
    func didSelectColor(_ color: UIColor) {
        trackerColor = color
    }
}

// MARK: - UIConfigurationProtocol
extension TrackerEditingViewController: UIConfigurationProtocol {
    func configureUI() {
        view.backgroundColor = .ypMain
        
        title = NSLocalizedString("trackerEditing.title", comment: "Title for tracker editing screen")
        
        addSubviews()
        addConstraints()
    }
    
    func addSubviews() {
        view.addSubview(newHabitOrEventCollectionView)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            newHabitOrEventCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            newHabitOrEventCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            newHabitOrEventCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newHabitOrEventCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
    }
}

