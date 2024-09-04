import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    convenience init() {
        let initContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.init(context: initContext)
    }
    
    func addNewTrackerRecord(_ record: TrackerRecord, to tracker: TrackerCoreData) {
        let newTrackerRecordEntry = TrackerRecordCoreData(context: context)
        
        newTrackerRecordEntry.trackerID = record.trackerID
        newTrackerRecordEntry.completionDate = record.completionDate
        
        newTrackerRecordEntry.tracker = tracker
        tracker.addToTrackerRecords(newTrackerRecordEntry)
        
        do {
            try context.save()
        } catch {
            print("[TrackerRecordStore addNewTrackerRecord]: CoreDataError - Failed to save TrackerRecord as TrackerRecordCoreData")
        }
    }
}
