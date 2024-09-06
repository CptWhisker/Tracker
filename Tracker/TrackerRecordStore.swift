import UIKit
import CoreData

final class TrackerRecordStore {
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
    func createTrackerRecord(_ record: TrackerRecord, to tracker: TrackerCoreData) {
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
    
    // MARK: - READ
    func readTrackerRecord(trackerID: UUID, completionDate: Date) -> Bool {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), trackerID as CVarArg,
            #keyPath(TrackerRecordCoreData.completionDate), completionDate as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            
            return records.isEmpty ? false : true
        } catch {
            print("[TrackerRecordStore readTrackerRecords]: CoreDataError - Failed to read TrackerRecord")
        }
        
        return false
    }
    
    // MARK: - DELETE
    func deleteTrackerRecord(trackerID: UUID, completionDate: Date) {
        let fetchRequest = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), trackerID as CVarArg,
            #keyPath(TrackerRecordCoreData.completionDate), completionDate as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            let record = records.first!
            
            context.delete(record)
        } catch {
            print("[TrackerRecordStore readTrackerRecords]: CoreDataError - Failed to read TrackerRecord")
        }
    }
}
