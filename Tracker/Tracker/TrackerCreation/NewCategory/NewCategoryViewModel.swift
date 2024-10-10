import Foundation

// MARK: - Protocol
protocol NewCategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get }
    var categoriesUpdated: (() -> Void)? { get set }
    var emptyStateChanged: ((Bool) -> Void)? { get set }
    var categorySelected: (() -> Void)? { get set }
    func loadCategories()
    func createCategory(_ category: TrackerCategory)
    func selectCategory(at index: Int)
    func setDelegate(delegate: CategorySelectionDelegate)
    func setSelectedCategory(category: TrackerCategory?)
}

final class NewCategoryViewModel: NewCategoryViewModelProtocol {
    
    // MARK: - Properties
    private let trackerCategoryStore: TrackerCategoryStore
    private weak var delegate: CategorySelectionDelegate?
    private(set) var categories: [TrackerCategory] = [] {
        didSet {
            categoriesUpdated?()
        }
    }
    
    var selectedCategory: TrackerCategory? {
        didSet {
            categoriesUpdated?()
        }
    }
    
    var categoriesUpdated: (() -> Void)?
    var emptyStateChanged: ((Bool) -> Void)?
    var categorySelected: (() -> Void)?
    
    // MARK: - Initialization
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
    }
    
    // MARK: - Public Methods
    func loadCategories() {
        categories = trackerCategoryStore.readTrackerCategories()
        let systemCategoryName = NSLocalizedString("newCategoryViewModel.hiddenSystemCategory", comment: "Name for system category 'Pinned'")

        categories = categories.filter { $0.categoryName.lowercased() != systemCategoryName.lowercased() }

        emptyStateChanged?(categories.isEmpty)
    }
    
    // MARK: - Protocol Implementation
    func createCategory(_ category: TrackerCategory) {
        trackerCategoryStore.createTrackerCategory(category)
        categories.append(category)
        emptyStateChanged?(categories.isEmpty)
    }
    
    func selectCategory(at index: Int) {
        let category = categories[index]
        if category.categoryName != selectedCategory?.categoryName {
            selectedCategory = category
        } else {
            selectedCategory = nil
        }
        
        delegate?.didSelectCategory(selectedCategory)
        categorySelected?()
    }
    
    func setDelegate(delegate: CategorySelectionDelegate) {
        self.delegate = delegate
    }
    
    func setSelectedCategory(category: TrackerCategory?) {
        if let category {
            selectedCategory = category
        }
    }
}
