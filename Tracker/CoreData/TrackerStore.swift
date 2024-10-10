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
            newTrackerEntry.isPinned = tracker.isPinned
            newTrackerEntry.originalCategory = tracker.originalCategory
            
            newTrackerEntry.trackerCategory = targetCategory
            targetCategory.addToTrackersInCategory(newTrackerEntry)
        }
            try context.save()
        } catch {
            print("[TrackerStore addTrackerToCategory]: CoreDataError - Failed to save tracker to category")
        }
    }
    
    func pinTracker(_ tracker: Tracker, to pinnedCategory: TrackerCategory) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.habitID), tracker.habitID as CVarArg)
        
        do {
            let trackerResults = try context.fetch(fetchRequest)
            
            guard let pinnedTracker = trackerResults.first else { return }
            
            let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
            categoryFetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryName), pinnedCategory.categoryName)
                        
            let categories = try context.fetch(categoryFetchRequest)
            
            guard let pinnedCategory = categories.first else { return }
            
            if let oldCategory = pinnedTracker.trackerCategory {
                oldCategory.removeFromTrackersInCategory(pinnedTracker)
            }
            
            pinnedTracker.trackerCategory = pinnedCategory
            pinnedCategory.addToTrackersInCategory(pinnedTracker)
            
            pinnedTracker.isPinned = tracker.isPinned
            
            try context.save()
        } catch {
            print("[pinTracker]: Failed to update tracker category: \(error)")
        }
    }
    
    func unpinTracker(_ tracker: Tracker) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.habitID), tracker.habitID as CVarArg)
        
        do {
            let trackerResults = try context.fetch(fetchRequest)
            
            guard let unpinnedTracker = trackerResults.first else {
                print("[moveTrackerToOriginalCategory]: Tracker not found.")
                return
            }
            
            let categoryFetchRequest = TrackerCategoryCoreData.fetchRequest()
            categoryFetchRequest.predicate = NSPredicate(
                format: "%K == %@", #keyPath(TrackerCategoryCoreData.categoryName), tracker.originalCategory
            )
            
            let categories = try context.fetch(categoryFetchRequest)
            
            guard let originalCategory = categories.first else {
                print("[moveTrackerToOriginalCategory]: Original category not found.")
                return
            }
            
            if let pinnedCategory = unpinnedTracker.trackerCategory {
                pinnedCategory.removeFromTrackersInCategory(unpinnedTracker)
            }
            
            unpinnedTracker.trackerCategory = originalCategory
            originalCategory.addToTrackersInCategory(unpinnedTracker)
            
            unpinnedTracker.isPinned = tracker.isPinned
            
            try context.save()
        } catch {
            print("[moveTrackerToOriginalCategory]: Failed to move tracker to original category: \(error)")
        }
    }



}

extension TrackerStore: NSFetchedResultsControllerDelegate {}
