import SnapshotTesting
import UIKit
import XCTest
@testable import Tracker

@MainActor
final class TrackerSnapshotTests: XCTestCase {

    override func setUp() {
        super.setUp()
        Localization.setLanguageForTesting("en")
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        Localization.setLanguageForTesting(nil)
        super.tearDown()
    }

    func testMainScreenLightTheme() throws {
        let viewController = try makeMainViewController(style: .light)
        let image = try captureImage(of: viewController, style: .light)

        assertSnapshot(
            of: image,
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                scale: 3
            )
        )
    }

    func testMainScreenDarkTheme() throws {
        let viewController = try makeMainViewController(style: .dark)
        let image = try captureImage(of: viewController, style: .dark)

        assertSnapshot(
            of: image,
            as: .image(
                precision: 0.99,
                perceptualPrecision: 0.98,
                scale: 3
            )
        )
    }

    private func makeMainViewController(style: UIUserInterfaceStyle) throws -> UIViewController {
        let coreDataStack = CoreDataStack(inMemory: true)
        let trackerStore = TrackerStore(coreDataStack: coreDataStack)
        let categoryStore = TrackerCategoryStore(
            coreDataStack: coreDataStack,
            trackerStore: trackerStore
        )
        let trackerID = try XCTUnwrap(
            UUID(uuidString: "9F29D786-1027-4E8A-8A39-8A8FD1803670")
        )
        let tracker = Tracker(
            id: trackerID,
            name: "Read for 30 minutes",
            color: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1),
            emoji: "📚",
            schedule: Weekday.allCases
        )
        try categoryStore.add(tracker, toCategoryWithTitle: "Useful habits")

        let date = Calendar(identifier: .gregorian).date(
            from: DateComponents(year: 2024, month: 1, day: 1)
        )!
        let viewController = MainTabBarController(
            coreDataStack: coreDataStack,
            analyticsService: AnalyticsServiceStub(),
            currentDate: date,
            datePickerLocale: Locale(identifier: "en_US")
        )
        viewController.overrideUserInterfaceStyle = style
        return viewController
    }

    private func captureImage(
        of viewController: UIViewController,
        style: UIUserInterfaceStyle
    ) throws -> UIImage {
        guard let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else {
            throw SnapshotTestError.windowSceneUnavailable
        }

        let bounds = windowScene.coordinateSpace.bounds
        let previousKeyWindow = windowScene.windows.first(where: \.isKeyWindow)
        let window = UIWindow(windowScene: windowScene)
        window.frame = bounds
        window.overrideUserInterfaceStyle = style
        window.rootViewController = viewController
        window.makeKeyAndVisible()
        defer {
            window.isHidden = true
            previousKeyWindow?.makeKeyAndVisible()
        }
        prepareForSnapshot(window)
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.5))
        prepareForSnapshot(window)
        CATransaction.flush()

        let format = UIGraphicsImageRendererFormat()
        format.scale = 3
        format.opaque = true
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(bounds: bounds, format: format).image { _ in
            window.drawHierarchy(in: bounds, afterScreenUpdates: false)
        }
    }

    private func prepareForSnapshot(_ view: UIView) {
        view.setNeedsLayout()
        view.layoutIfNeeded()
        view.setNeedsDisplay()
        view.layer.setNeedsDisplay()
        view.layer.displayIfNeeded()
        view.subviews.forEach(prepareForSnapshot)
    }

}

private enum SnapshotTestError: Error {
    case windowSceneUnavailable
}

private struct AnalyticsServiceStub: AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, item: AnalyticsItem?) {}
}
