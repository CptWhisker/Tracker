import Foundation

final class NewCategoryViewModel {
    private var trackerCategoryStore: TrackerCategoryStore
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
    
    init(trackerCategoryStore: TrackerCategoryStore = TrackerCategoryStore()) {
        self.trackerCategoryStore = trackerCategoryStore
        loadCategories()
    }
    
    private func loadCategories() {
        categories = trackerCategoryStore.readTrackerCategories()
        emptyStateChanged?(categories.isEmpty)
    }
    
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
    }
}
