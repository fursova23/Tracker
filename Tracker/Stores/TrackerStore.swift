import CoreData
import UIKit

enum StoreError: Error {
    case trackerNotFound
}

final class TrackerStore {

    private let context: NSManagedObjectContext

    init(coreDataStack: CoreDataStack) {
        context = coreDataStack.context
    }

    func fetchTrackers(inCategoryWithTitle title: String) throws -> [Tracker] {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "category.title == %@", title)

        let trackerObjects = try context.fetch(request)
        return trackerObjects.compactMap { tracker(from: $0) }
    }

    func add(_ tracker: Tracker, toCategoryWithTitle title: String) throws {
        let categoryObject = try fetchOrCreateCategory(withTitle: title)
        let trackerObject = TrackerCoreData(context: context)

        trackerObject.id = tracker.id
        trackerObject.name = tracker.name
        trackerObject.colorHex = hexString(from: tracker.color)
        trackerObject.emoji = tracker.emoji
        trackerObject.schedule = scheduleString(from: tracker.schedule)
        trackerObject.category = categoryObject

        try context.save()
    }

    private func fetchOrCreateCategory(withTitle title: String) throws -> TrackerCategoryCoreData {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "title == %@", title)
        request.fetchLimit = 1

        if let categoryObject = try context.fetch(request).first {
            return categoryObject
        }

        let categoryObject = TrackerCategoryCoreData(context: context)
        categoryObject.title = title
        return categoryObject
    }

    private func tracker(from trackerObject: TrackerCoreData) -> Tracker? {
        guard let id = trackerObject.id,
              let name = trackerObject.name,
              let colorHex = trackerObject.colorHex,
              let emoji = trackerObject.emoji,
              let schedule = trackerObject.schedule else {
            return nil
        }

        return Tracker(
            id: id,
            name: name,
            color: color(from: colorHex),
            emoji: emoji,
            schedule: weekdays(from: schedule)
        )
    }

    private func scheduleString(from schedule: [Weekday]) -> String {
        schedule
            .map { String($0.rawValue) }
            .joined(separator: ",")
    }

    private func weekdays(from scheduleString: String) -> [Weekday] {
        scheduleString
            .split(separator: ",")
            .compactMap { Int($0) }
            .compactMap { Weekday(rawValue: $0) }
    }

    private func hexString(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return "#000000"
        }

        return String(
            format: "#%02X%02X%02X",
            Int(red * 255),
            Int(green * 255),
            Int(blue * 255)
        )
    }

    private func color(from hexString: String) -> UIColor {
        let hex = hexString.trimmingCharacters(in: CharacterSet(charactersIn: "#"))

        guard hex.count == 6,
              let value = Int(hex, radix: 16) else {
            return .systemBlue
        }

        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
