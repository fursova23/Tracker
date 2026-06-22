import UIKit

final class MainTabBarController: UITabBarController {

    // MARK: - UI Elements

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Lifecycle

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
            rootViewController: TrackersViewController(),
            title: "Трекеры",
            image: UIImage(resource: .trackersTabIcon),
            tag: 0
        )
        let statisticsController = makeNavigationController(
            rootViewController: StatisticsViewController(),
            title: "Статистика",
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
