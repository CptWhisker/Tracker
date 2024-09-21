import Foundation

// MARK: - Protocol
protocol NewCategoryViewModelProtocol {
    var categories: [TrackerCategory] { get }
    var selectedCategory: TrackerCategory? { get }
    var categoriesUpdated: (() -> Void)? { get set }
    var emptyStateChanged: ((Bool) -> Void)? { get set }
    func createCategory(_ category: TrackerCategory)
    func selectCategory(at index: Int)
    func setDelegate(delegate: CategorySelectionDelegate)
}

final class NewCategoryViewModel: NewCategoryViewModelProtocol {
    
    // MARK: - Properties
    private var trackerCategoryStore: TrackerCategoryStore
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
    
    // MARK: - Initialization
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        loadCategories()
    }
    
    // MARK: - Private Methods
    private func loadCategories() {
        categories = trackerCategoryStore.readTrackerCategories()
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
            delegate?.didSelectCategory(category)
        } else {
            selectedCategory = nil
        }
    }
    
    func setDelegate(delegate: CategorySelectionDelegate) {
        self.delegate = delegate
    }
}
