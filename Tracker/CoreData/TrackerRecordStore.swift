import UIKit
import CoreData

final class TrackerRecordStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "trackerID", ascending: true)]
        
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
    func createTrackerRecord(_ record: TrackerRecord) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@", #keyPath(TrackerCoreData.habitID), record.trackerID as CVarArg
        )
        
        do {
            let trackers = try context.fetch(fetchRequest)
            if let targetTracker = trackers.first {
                let newTrackerRecordEntry = TrackerRecordCoreData(context: context)
                newTrackerRecordEntry.trackerID = record.trackerID
                newTrackerRecordEntry.completionDate = record.completionDate
                
                newTrackerRecordEntry.tracker = targetTracker
                targetTracker.addToTrackerRecords(newTrackerRecordEntry)
                
                try context.save()
            }
        } catch {
            print("[TrackerRecordStore createTrackerRecords]: CoreDataError - Failed to create TrackerRecord")
        }
    }
    
    // MARK: - READ
    func readContainsTrackerRecord(_ record: TrackerRecord) -> Bool? {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), record.trackerID as CVarArg,
            #keyPath(TrackerRecordCoreData.completionDate), record.completionDate as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            
            return records.isEmpty ? false : true
        } catch {
            print("[TrackerRecordStore readTrackerRecords]: CoreDataError - Failed to read TrackerRecord's existence")
        }
        
        return nil
    }
    
    func readTrackerRecordCount(_ recordID: UUID) -> Int {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), recordID as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            
            return records.count
        } catch {
            print("[TrackerRecordStore readTrackerRecordCount]: CoreDataError - Failed to read TrackerRecords' count")
        }
        
        return 0
    }
    
    func readTrackerRecordIsCompleted(_ recordID: UUID, for date: Date) -> Bool? {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), recordID as CVarArg,
            #keyPath(TrackerRecordCoreData.completionDate), date as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            
            return records.isEmpty ? false : true
        } catch {
            print("[TrackerRecordStore readTrackerRecordIsCompleted]: CoreDataError - Failed to read TrackerRecord's completion status")
        }
        
        return nil
    }
    
    // MARK: - DELETE
    func deleteTrackerRecord(_ record: TrackerRecord) {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: "%K == %@ AND %K == %@",
            #keyPath(TrackerRecordCoreData.trackerID), record.trackerID as CVarArg,
            #keyPath(TrackerRecordCoreData.completionDate), record.completionDate as CVarArg
        )
        
        do {
            let records = try context.fetch(fetchRequest)
            if let recordToDelete = records.first {
                context.delete(recordToDelete)
                try context.save()
            }
            
        } catch {
            print("[TrackerRecordStore deleteTrackerRecords]: CoreDataError - Failed to delete TrackerRecord")
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {}
