import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory])
}

final class TrackerCategoryStore: NSObject {

    weak var delegate: TrackerCategoryStoreDelegate?

    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData> = {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        controller.delegate = self
        return controller
    }()

    init(coreDataStack: CoreDataStack, trackerStore: TrackerStore) {
        context = coreDataStack.context
        self.trackerStore = trackerStore
        super.init()

        self.trackerStore.delegate = self
        try? fetchedResultsController.performFetch()
    }

    func fetchCategories() throws -> [TrackerCategory] {
        try fetchedResultsController.performFetch()
        return categories()
    }

    func add(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        try trackerStore.add(tracker, toCategoryWithTitle: title)
    }

    func update(_ tracker: Tracker, categoryTitle: String) throws {
        try trackerStore.update(tracker, categoryTitle: categoryTitle)
    }

    func deleteTracker(withID id: UUID) throws {
        try trackerStore.deleteTracker(withID: id)
    }

    func createCategoryIfNeeded(withTitle title: String) throws {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        guard try context.fetch(request).first == nil else { return }

        let categoryObject = try context.makeObject(TrackerCategoryCoreData.self)
        categoryObject.title = title

        try context.save()
    }

    private func categories() -> [TrackerCategory] {
        let categoryObjects = fetchedResultsController.fetchedObjects ?? []

        return categoryObjects.compactMap { categoryObject in
            guard let title = categoryObject.title else { return nil }

            return TrackerCategory(
                title: title,
                trackers: trackerStore.trackers(inCategoryWithTitle: title)
            )
        }
    }

    private func notifyDelegate() {
        delegate?.trackerCategoryStore(self, didUpdate: categories())
    }
}

extension TrackerCategoryStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        notifyDelegate()
    }
}

extension TrackerCategoryStore: TrackerStoreDelegate {

    func trackerStore(_ store: TrackerStore, didUpdate trackers: [Tracker]) {
        notifyDelegate()
    }
}
