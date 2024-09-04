import UIKit
import CoreData

final class TrackerCategoryStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let initContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.init(context: initContext)
    }
    
    func addNewTrackerCategory(_ category: TrackerCategory) {
        let newTrackerCategoryEntry = TrackerCategoryCoreData(context: context)
        
        newTrackerCategoryEntry.categoryName = category.categoryName
        
        if let trackers = category.trackersInCategory {
            for tracker in trackers {
                let newTrackerEntry = TrackerCoreData(context: context)
                newTrackerEntry.habitID = tracker.habitID
                newTrackerEntry.habitName = tracker.habitName
                newTrackerEntry.habitEmoji = tracker.habitEmoji
                newTrackerEntry.habitColor = tracker.habitColor
                newTrackerEntry.habitSchedule = tracker.habitSchedule as? NSObject
                
                newTrackerEntry.trackerCategory = newTrackerCategoryEntry
                newTrackerCategoryEntry.addToTrackersInCategory(newTrackerEntry)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("[TrackerCategoryStore addNewTrackerCategory]: CoreDataError - Failed to save TrackerCategory as TrackerCategoryCoreData")
        }
    }
}
