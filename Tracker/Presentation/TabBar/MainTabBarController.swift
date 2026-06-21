import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureTabBar()
        setViewControllers([
            makeNavigationController(
                rootViewController: TrackersViewController(),
                title: "Трекеры",
                image: UIImage(resource: .trackersTabIcon),
                tag: 0
            ),
            makeNavigationController(
                rootViewController: StatisticsViewController(),
                title: "Статистика",
                image: UIImage(resource: .statisticsTabIcon),
                tag: 1
            )
        ], animated: false)
    }

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

    private func configureTabBar() {
        tabBar.tintColor = UIColor(resource: .ypBlueIOS)
        tabBar.unselectedItemTintColor = .secondaryLabel
    }
}
