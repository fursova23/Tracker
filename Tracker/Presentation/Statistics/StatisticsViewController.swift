import UIKit

final class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = L10n.Statistics.title
        navigationItem.largeTitleDisplayMode = .always
    }
}
