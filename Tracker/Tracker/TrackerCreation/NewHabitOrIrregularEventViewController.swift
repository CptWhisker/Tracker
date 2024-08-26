import UIKit

final class NewHabitOrIrregularEventViewController: UIViewController {
    // MARK: - Properties
    var initializerTag: InitializerTag
    
    private var trackerTitle: String?
    private var trackerCategory: TrackerCategory?
    private var trackerWeekDays: [WeekDays]?
    private var trackerEmoji: String?
    private var trackerColor: UIColor?
    
    private lazy var newHabitOrEventCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(NameTextfieldCell.self, forCellWithReuseIdentifier: NameTextfieldCell.identifier)
        collectionView.register(CategoryAndScheduleTableViewCell.self, forCellWithReuseIdentifier: CategoryAndScheduleTableViewCell.identifier)
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.identifier)
        collectionView.register(ColorSchemeCollectionViewCell.self, forCellWithReuseIdentifier: ColorSchemeCollectionViewCell.identifier)
        collectionView.register(CancelAndCreateButtonsCell.self, forCellWithReuseIdentifier: CancelAndCreateButtonsCell.identifier)
        return collectionView
    }()
    
    // MARK: - Initializers
    init(initializerTag: InitializerTag) {
        self.initializerTag = initializerTag
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureInterface()
    }
    
    // MARK: - Interface Configuration
    private func configureInterface() {
        view.backgroundColor = .ypMain
        
        view.addSubview(newHabitOrEventCollectionView)
        
        NSLayoutConstraint.activate([
            newHabitOrEventCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            newHabitOrEventCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            newHabitOrEventCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newHabitOrEventCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])
        
        switch initializerTag {
        case .habit:
            title = "Новая привычка"
        case .event:
            title = "Новое нерегулярное событие"
        }
    }
    
    // MARK: - Private Methods
    private func setTrackerCategory(to category: TrackerCategory) {
        trackerCategory = category
    }
    
    private func setTrackerWeekDays(to weekdays: [WeekDays]) {
        trackerWeekDays = weekdays
    }
    
    private func updateCategorySelectionLabel(with category: TrackerCategory) {
        let indexPath = IndexPath(item: 1, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? CategoryAndScheduleTableViewCell {
            cell.setSelectedCategoryLabel(category: category)
        }
    }
    
    private func updateSheduleSelectionLabel(with weekdays: [WeekDays]) {
        let indexPath = IndexPath(item: 1, section: 0)
        
        if let cell = newHabitOrEventCollectionView.cellForItem(at: indexPath) as? CategoryAndScheduleTableViewCell {
            cell.setSelectedWeekDaysLabel(weekdays: weekdays)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension NewHabitOrIrregularEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.item {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NameTextfieldCell.identifier, for: indexPath) as? NameTextfieldCell else {
                print("[NewHabitOrIrregularEventViewController cellForItemAt]: typecastError - Unable to dequeue cell as NameTextfieldCell")
                return UICollectionViewCell()
            }
            
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryAndScheduleTableViewCell.identifier, for: indexPath) as? CategoryAndScheduleTableViewCell else {
                print("[NewHabitOrIrregularEventViewController cellForItemAt]: typecastError - Unable to dequeue cell as CategoryAndScheduleTableViewCell")
                return UICollectionViewCell()
            }
            
            cell.setInitializerTag(to: initializerTag)
            cell.setDelegate(delegate: self)
            return cell
            
        case 2:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.identifier, for: indexPath) as? EmojiCollectionViewCell else {
                print("[NewHabitOrIrregularEventViewController cellForItemAt]: typecastError - Unable to dequeue cell as EmojiCollectionViewCell")
                return UICollectionViewCell()
            }
            
            return cell
            
        case 3:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorSchemeCollectionViewCell.identifier, for: indexPath) as? ColorSchemeCollectionViewCell else {
                print("[NewHabitOrIrregularEventViewController cellForItemAt]: typecastError - Unable to dequeue cell as ColorSchemeCollectionViewCell")
                return UICollectionViewCell()
            }
            
            return cell
            
        case 4:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CancelAndCreateButtonsCell.identifier, for: indexPath) as? CancelAndCreateButtonsCell else {
                print("[NewHabitOrIrregularEventViewController cellForItemAt]: typecastError - Unable to dequeue cell as CancelAndCreateButtonsCell")
                return UICollectionViewCell()
            }
            
            cell.setDelegate(delegate: self)
            return cell
            
        default:
            fatalError("Unexpected index path")
        }
        
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout
extension NewHabitOrIrregularEventViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellWidth = collectionView.frame.width
        
        switch indexPath.item {
        case 0:
            let cellHeight: CGFloat = 75
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 1:
            let cellHeight: CGFloat
            
            if initializerTag == .habit {
                cellHeight = 150
            } else {
                cellHeight = 75
            }
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 2:
            // TODO: Calculate height dynamically
            let cellHeight: CGFloat = 220
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 3:
            // TODO: Calculate height dynamically
            let cellHeight: CGFloat = 220
            
            return CGSize(width: cellWidth, height: cellHeight)
            
        case 4:
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

// MARK: - CancelAndCreateButtonsCellDelegate
extension NewHabitOrIrregularEventViewController: CancelAndCreateButtonsCellDelegate {
    func didTapCancelButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapCreateButton() {
        // TODO: Implement logic and functionality
    }
}

// MARK: - NewCategoryAndScheduleTableViewDelegate
extension NewHabitOrIrregularEventViewController: NewCategoryAndScheduleTableViewDelegate {
    func didTapCategoryButton() {
        let newCategoryViewController = NewCategoryViewController()
        newCategoryViewController.setDelegate(delegate: self)
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

extension NewHabitOrIrregularEventViewController: ScheduleViewControllerDelegate {
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

extension NewHabitOrIrregularEventViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        setTrackerCategory(to: category)
        updateCategorySelectionLabel(with: category)
    }
}
