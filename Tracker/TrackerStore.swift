import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let initContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.init(context: initContext)
    }
    
    func addNewTracker(_ tracker: Tracker) {
        let newTrackerEntry = TrackerCoreData(context: context)
        
        newTrackerEntry.habitID = tracker.habitID
        newTrackerEntry.habitName = tracker.habitName
        newTrackerEntry.habitEmoji = tracker.habitEmoji
        newTrackerEntry.habitColor = tracker.habitColor
        newTrackerEntry.habitSchedule = tracker.habitSchedule as? NSObject
        
        do {
            try context.save()
        } catch {
            print("[TrackerStore addNewTracker]: CoreDataError - Failed to save Tracker as TrackerCoreData")
        }
    }
}
