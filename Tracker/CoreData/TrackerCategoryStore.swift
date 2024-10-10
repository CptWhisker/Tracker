import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        
        return fetchedResultsController
    }()
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience override init() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        
        self.init(context: context)
    }
    
    // MARK: - CREATE
    func createTrackerCategory(_ category: TrackerCategory) {
        let newTrackerCategoryEntry = TrackerCategoryCoreData(context: context)
        
        newTrackerCategoryEntry.categoryName = category.categoryName
        
        do {
            try context.save()
        } catch {
            print("[TrackerCategoryStore addNewTrackerCategory]: CoreDataError - Failed to save TrackerCategory")
        }
    }
    
    // MARK: - READ
    func readTrackerCategories() -> [TrackerCategory] {
        var fetchedCategories: [TrackerCategory] = []
        
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            for categoryCoreData in categories {
                var trackers: [Tracker] = []
                
                if let coreDataTrackers = categoryCoreData.trackersInCategory?.allObjects as? [TrackerCoreData] {
                    trackers = coreDataTrackers.map { trackerCoreData in
                        return Tracker(
                            habitID: trackerCoreData.habitID ?? UUID(),
                            habitName: trackerCoreData.habitName ?? "default",
                            habitColor: trackerCoreData.habitColor as? UIColor ?? .white,
                            habitEmoji: trackerCoreData.habitEmoji ?? "🫥",
                            habitSchedule: trackerCoreData.habitSchedule as? [WeekDays],
                            isPinned: trackerCoreData.isPinned,
                            originalCategory: trackerCoreData.originalCategory ?? "default"
                        )
                    }
                }
                
                let category = TrackerCategory(
                    categoryName: categoryCoreData.categoryName ?? "default",
                    trackersInCategory: trackers
                )
                
                fetchedCategories.append(category)
            }
        } catch {
            print("[TrackerCategoryStore readTrackerCategories]: CoreDataError - Failed to fetch [TrackerCategory]")
        }
        
        return fetchedCategories
    }
    
    // MARK: - UPDATE
    func updateTrackerCategoryName(from oldName: String, to newName: String) {
        let fetchRequest: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "categoryName == %@", oldName)
        
        do {
            let categories = try context.fetch(fetchRequest)
            
            guard let categoryToUpdate = categories.first else {
                print("[TrackerCategoryStore updateTrackerCategoryName]: No category found with name \(oldName)")
                return
            }
            
            categoryToUpdate.categoryName = newName

            try context.save()
            print("[TrackerCategoryStore updateTrackerCategoryName]: Successfully updated category name from \(oldName) to \(newName)")
        } catch {
            print("[TrackerCategoryStore updateTrackerCategoryName]: CoreDataError - Failed to update TrackerCategory with name \(oldName)")
        }
    }
}


extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}
