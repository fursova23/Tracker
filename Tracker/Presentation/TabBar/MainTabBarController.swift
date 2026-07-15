import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - Properties

    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore

    // MARK: - UI Elements

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

    init(coreDataStack: CoreDataStack) {
        let trackerStore = TrackerStore(coreDataStack: coreDataStack)
        trackerCategoryStore = TrackerCategoryStore(
            coreDataStack: coreDataStack,
            trackerStore: trackerStore
        )
        trackerRecordStore = TrackerRecordStore(coreDataStack: coreDataStack)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewControllers()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground
        configureTabBar()
    }

    private func setupViewControllers() {
        let trackersController = makeNavigationController(
            rootViewController: TrackersViewController(
                trackerCategoryStore: trackerCategoryStore,
                trackerRecordStore: trackerRecordStore
            ),
            title: L10n.Tab.trackers,
            image: UIImage(resource: .trackersTabIcon),
            tag: 0
        )
        let statisticsController = makeNavigationController(
            rootViewController: StatisticsViewController(),
            title: L10n.Tab.statistics,
            image: UIImage(resource: .statisticsTabIcon),
            tag: 1
        )

        setViewControllers(
            [trackersController, statisticsController],
            animated: false
        )
    }

    private func configureTabBar() {
        tabBar.tintColor = UIColor(resource: .ypBlueIOS)
        tabBar.unselectedItemTintColor = .secondaryLabel
        tabBar.addSubview(separatorView)

        NSLayoutConstraint.activate([
            separatorView.topAnchor.constraint(equalTo: tabBar.topAnchor),
            separatorView.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1 / UIScreen.main.scale)
        ])
    }

    // MARK: - Factory Methods

    private func makeNavigationController(
        rootViewController: UIViewController,
        title: String,
        image: UIImage,
        tag: Int
    ) -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .label
        navigationController.tabBarItem = UITabBarItem(
            title: title,
            image: image,
            tag: tag
        )

        return navigationController
    }
}
