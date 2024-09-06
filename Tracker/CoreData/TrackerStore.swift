import UIKit
import CoreData

final class TrackerStore {
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
    func createTracker(_ tracker: Tracker, in category: TrackerCategory) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryName), category.categoryName
        )
        
        do {
        let categories = try context.fetch(fetchRequest)
        
        if let targetCategory = categories.first {
            let newTrackerEntry = TrackerCoreData(context: context)
            newTrackerEntry.habitID = tracker.habitID
            newTrackerEntry.habitName = tracker.habitName
            newTrackerEntry.habitEmoji = tracker.habitEmoji
            newTrackerEntry.habitColor = tracker.habitColor
            newTrackerEntry.habitSchedule = tracker.habitSchedule as? NSObject
            
            newTrackerEntry.trackerCategory = targetCategory
            targetCategory.addToTrackersInCategory(newTrackerEntry)
        }
            try context.save()
        } catch {
            print("[TrackerStore addTrackerToCategory]: CoreDataError - Failed to save tracker to category")
        }
    }
}
