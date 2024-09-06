import UIKit
import CoreData

final class TrackerCategoryStore {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
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
            
            categories.forEach { categoryCoreData in
                var trackers: [Tracker] = []
                
                if let trackerSet = categoryCoreData.trackersInCategory as? Set<TrackerCoreData> {
                    trackers.forEach { trackerCoreData in
                        let tracker = Tracker(
                            habitID: trackerCoreData.habitID,
                            habitName: trackerCoreData.habitName,
                            habitColor: trackerCoreData.habitColor ,
                            habitEmoji: trackerCoreData.habitEmoji,
                            habitSchedule: trackerCoreData.habitSchedule
                        )
                        
                        trackers.append(tracker)
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
