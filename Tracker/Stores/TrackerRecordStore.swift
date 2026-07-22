import CoreData

protocol TrackerRecordStoreDelegate: AnyObject {
    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord])
}

final class TrackerRecordStore: NSObject {

    weak var delegate: TrackerRecordStoreDelegate?

    private let context: NSManagedObjectContext
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData> = {
        let request = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "date", ascending: true)
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

    init(coreDataStack: CoreDataStack) {
        context = coreDataStack.context
        super.init()

        try? fetchedResultsController.performFetch()
    }

    func fetchRecords() throws -> [TrackerRecord] {
        try fetchedResultsController.performFetch()
        return records()
    }

    func addRecord(for trackerID: UUID, on date: Date) throws {
        guard try fetchRecordObject(for: trackerID, on: date) == nil else { return }

        guard let trackerObject = try fetchTrackerObject(with: trackerID) else {
            throw StoreError.trackerNotFound
        }

        let recordObject = try context.makeObject(TrackerRecordCoreData.self)
        recordObject.date = Calendar.current.startOfDay(for: date)
        recordObject.tracker = trackerObject

        try context.save()
    }

    func deleteRecord(for trackerID: UUID, on date: Date) throws {
        guard let recordObject = try fetchRecordObject(for: trackerID, on: date) else { return }

        context.delete(recordObject)
        try context.save()
    }

    private func fetchTrackerObject(with id: UUID) throws -> TrackerCoreData? {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    private func fetchRecordObject(for trackerID: UUID, on date: Date) throws -> TrackerRecordCoreData? {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let nextDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "tracker.id == %@ AND date >= %@ AND date < %@",
            trackerID as CVarArg,
            startOfDay as NSDate,
            nextDay as NSDate
        )
        request.fetchLimit = 1

        return try context.fetch(request).first
    }

    private func records() -> [TrackerRecord] {
        let recordObjects = fetchedResultsController.fetchedObjects ?? []

        return recordObjects.compactMap { recordObject in
            guard let trackerID = recordObject.tracker?.id,
                  let date = recordObject.date else {
                return nil
            }

            return TrackerRecord(id: trackerID, date: date)
        }
    }
}

extension TrackerRecordStore: NSFetchedResultsControllerDelegate {

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<any NSFetchRequestResult>) {
        delegate?.trackerRecordStore(self, didUpdate: records())
    }
}
