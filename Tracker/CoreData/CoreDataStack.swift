import CoreData

final class CoreDataStack {

    private enum Constants {
        static let modelName = "Tracker"
    }

    let persistentContainer: NSPersistentContainer

    init(inMemory: Bool = false) {
        let container = NSPersistentContainer(name: Constants.modelName)
        if inMemory {
            container.persistentStoreDescriptions.first?.type = NSInMemoryStoreType
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved Core Data error \(error), \(error.userInfo)")
            }
        }
        persistentContainer = container
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext

        guard context.hasChanges else { return }

        do {
            try context.save()
        } catch {
            let error = error as NSError
            print("Failed to save Core Data context: \(error), \(error.userInfo)")
        }
    }
}
