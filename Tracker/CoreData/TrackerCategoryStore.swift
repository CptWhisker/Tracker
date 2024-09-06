import UIKit
import CoreData

final class TrackerCategoryStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
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
        let initContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.init(context: initContext)
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
        
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")

        do {
            let categories = try context.fetch(fetchRequest)
            
            for categoryCoreData in categories {
                var trackers: [Tracker] = []
                
                if let coreDataTrackers = categoryCoreData.trackersInCategory?.allObjects as? [TrackerCoreData] {
                    trackers = coreDataTrackers.map { trackerCoreData in
                        return Tracker(
                            habitID: trackerCoreData.habitID!,
                            habitName: trackerCoreData.habitName!,
                            habitColor: trackerCoreData.habitColor as! UIColor,
                            habitEmoji: trackerCoreData.habitEmoji!,
                            habitSchedule: trackerCoreData.habitSchedule as? [WeekDays]
                        )
                    }
                }
                
                let category = TrackerCategory(
                    categoryName: categoryCoreData.categoryName!,
                    trackersInCategory: trackers
                )
                
                fetchedCategories.append(category)
            }
        } catch {
            print("[TrackerCategoryStore readTrackerCategories]: CoreDataError - Failed to fetch [TrackerCategory]")
        }
        
        return fetchedCategories
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {}
