import UIKit
import CoreData

final class TrackerStore: NSObject {
    // MARK: - Properties
    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "habitName", ascending: true)]
        
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
    func createTracker(_ tracker: Tracker, in category: TrackerCategory) {
        let fetchRequest = TrackerCategoryCoreData.fetchRequest()
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

extension TrackerStore: NSFetchedResultsControllerDelegate {}
