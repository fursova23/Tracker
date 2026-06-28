import CoreData

final class TrackerCategoryStore {

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore

    init(coreDataStack: CoreDataStack, trackerStore: TrackerStore) {
        context = coreDataStack.context
        self.trackerStore = trackerStore
    }

    func fetchCategories() throws -> [TrackerCategory] {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let categoryObjects = try context.fetch(request)

        return try categoryObjects.compactMap { categoryObject in
            guard let title = categoryObject.title else { return nil }

            return TrackerCategory(
                title: title,
                trackers: try trackerStore.fetchTrackers(inCategoryWithTitle: title)
            )
        }
    }

    func add(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        try trackerStore.add(tracker, toCategoryWithTitle: title)
    }

    func createCategoryIfNeeded(withTitle title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        guard try context.fetch(request).first == nil else { return }

        let categoryObject = TrackerCategoryCoreData(context: context)
        categoryObject.title = title

        try context.save()
    }
}
