import UIKit

final class StatisticsViewController: UIViewController {

    private let trackerRecordStore: TrackerRecordStore

    private let cardView = StatisticsCardView()

    private let placeholderView: TrackersPlaceholderView = {
        let view = TrackersPlaceholderView(
            image: UIImage(resource: .emptyStatisticsIcon)
        )
        view.setText(L10n.Statistics.emptyPlaceholder)
        return view
    }()

    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
        self.trackerRecordStore.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        navigationItem.title = L10n.Statistics.title
        navigationItem.largeTitleDisplayMode = .always
        configureLayout()
        loadRecords()
    }

    private func configureLayout() {
        view.addSubview(cardView)
        view.addSubview(placeholderView)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func loadRecords() {
        do {
            update(with: try trackerRecordStore.fetchRecords())
        } catch {
            assertionFailure("Failed to load tracker statistics: \(error)")
        }
    }

    private func update(with records: [TrackerRecord]) {
        let completedCount = records.count
        cardView.update(value: completedCount)
        cardView.isHidden = completedCount == 0
        placeholderView.isHidden = completedCount > 0
    }
}

extension StatisticsViewController: TrackerRecordStoreDelegate {

    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord]) {
        update(with: records)
    }
}
