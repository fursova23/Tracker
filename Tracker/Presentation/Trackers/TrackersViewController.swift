import UIKit

final class TrackersViewController: UIViewController {

    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private let analyticsService: AnalyticsServiceProtocol
    private let datePickerLocale: Locale?

    private var categories: [TrackerCategory] = []
    private var completedTrackers: [TrackerRecord] = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    private var selectedFilter: TrackerFilter = .all

    private let searchTextField: UISearchTextField = {
        let textField = UISearchTextField()
        textField.placeholder = L10n.Trackers.searchPlaceholder
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 10
        textField.clipsToBounds = true
        textField.returnKeyType = .search
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.tintColor = UIColor(resource: .ypBlueIOS)
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.alwaysBounceVertical = true
        collectionView.register(
            TrackerCollectionViewCell.self,
            forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier
        )
        collectionView.register(
            TrackerSectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let placeholderView = TrackersPlaceholderView()

    private lazy var filterButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Filters.button, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.backgroundColor = UIColor(resource: .ypBlueIOS)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        button.accessibilityIdentifier = "filtersButton"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(
        trackerCategoryStore: TrackerCategoryStore,
        trackerRecordStore: TrackerRecordStore,
        analyticsService: AnalyticsServiceProtocol = AnalyticsService.shared,
        currentDate: Date = Date(),
        datePickerLocale: Locale? = nil
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        self.analyticsService = analyticsService
        self.currentDate = currentDate
        self.datePickerLocale = datePickerLocale
        super.init(nibName: nil, bundle: nil)

        self.trackerCategoryStore.delegate = self
        self.trackerRecordStore.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        configureNavigationBar()
        configureSearchTextField()
        configureCollectionView()
        configureEmptyState()
        configureFilterButton()
        loadData()
        updateVisibleTrackers()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: .open)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: .close)
    }

    private func configureNavigationBar() {
        navigationItem.title = L10n.Trackers.title
        navigationItem.largeTitleDisplayMode = .always

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(addTrackerButtonTapped)
        )
        addButton.tintColor = .label
        addButton.accessibilityLabel = L10n.Trackers.addAccessibility
        navigationItem.leftBarButtonItem = addButton

        NSLayoutConstraint.activate([
            datePicker.widthAnchor.constraint(equalToConstant: 100)
        ])
        datePicker.locale = datePickerLocale
        datePicker.date = currentDate
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset.bottom = 82
        collectionView.verticalScrollIndicatorInsets.bottom = 82

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: searchTextField.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func configureSearchTextField() {
        view.addSubview(searchTextField)
        searchTextField.addTarget(self, action: #selector(searchTextChanged), for: .editingChanged)

        NSLayoutConstraint.activate([
            searchTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchTextField.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    private func configureEmptyState() {
        view.addSubview(placeholderView)

        NSLayoutConstraint.activate([
            placeholderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor, constant: -20),
            placeholderView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            placeholderView.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    private func configureFilterButton() {
        view.addSubview(filterButton)

        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func addTrackerButtonTapped() {
        analyticsService.report(event: .click, item: .addTrack)
        let newHabitViewController = NewHabitViewController(trackerCategoryStore: trackerCategoryStore)
        newHabitViewController.delegate = self

        let navigationController = UINavigationController(rootViewController: newHabitViewController)
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    @objc private func searchTextChanged() {
        updateVisibleTrackers()
    }

    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        updateVisibleTrackers()
    }

    @objc private func filterButtonTapped() {
        analyticsService.report(event: .click, item: .filter)
        let filtersViewController = FiltersViewController(selectedFilter: selectedFilter)
        filtersViewController.onFilterSelected = { [weak self] filter in
            self?.apply(filter)
        }

        let navigationController = UINavigationController(rootViewController: filtersViewController)
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    private func loadData() {
        do {
            categories = try trackerCategoryStore.fetchCategories()
            completedTrackers = try trackerRecordStore.fetchRecords()
        } catch {
            assertionFailure("Failed to load trackers: \(error)")
        }
    }

    private func updateVisibleTrackers() {
        let searchText = searchTextField.text?
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let weekday = weekday(for: currentDate)

        let scheduledCategories = categories.compactMap { category -> TrackerCategory? in
            let trackers = category.trackers.filter { $0.schedule.contains(weekday) }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }

        visibleCategories = scheduledCategories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                let matchesSearch = searchText.isEmpty || tracker.name.localizedCaseInsensitiveContains(searchText)
                let isCompleted = isTrackerCompleted(tracker.id, on: currentDate)

                switch selectedFilter {
                case .completed:
                    return matchesSearch && isCompleted
                case .incomplete:
                    return matchesSearch && !isCompleted
                case .all, .today:
                    return matchesSearch
                }
            }

            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }

        collectionView.reloadData()
        placeholderView.isHidden = !visibleCategories.isEmpty
        filterButton.isHidden = scheduledCategories.isEmpty
        filterButton.setTitleColor(selectedFilter.isActive ? .systemRed : .white, for: .normal)
        let containsTrackers = categories.contains { !$0.trackers.isEmpty }
        placeholderView.setText(
            containsTrackers
                ? L10n.Trackers.searchEmptyPlaceholder
                : L10n.Trackers.emptyPlaceholder
        )
    }

    private func apply(_ filter: TrackerFilter) {
        switch filter {
        case .today:
            currentDate = Date()
            datePicker.setDate(currentDate, animated: true)
            selectedFilter = .all
        case .all:
            selectedFilter = .all
        case .completed, .incomplete:
            selectedFilter = filter
        }

        updateVisibleTrackers()
    }

    private func weekday(for date: Date) -> Weekday {
        let calendarWeekday = Calendar.current.component(.weekday, from: date)
        return Weekday(rawValue: calendarWeekday) ?? .monday
    }

    private func isTrackerCompleted(_ trackerID: UUID, on date: Date) -> Bool {
        completedTrackers.contains { record in
            record.id == trackerID && Calendar.current.isDate(record.date, inSameDayAs: date)
        }
    }

    private func completedDaysCount(for trackerID: UUID) -> Int {
        completedTrackers.filter { $0.id == trackerID }.count
    }

    private func updateVisibleCellsCompletionState() {
        collectionView.visibleCells.forEach { visibleCell in
            guard let indexPath = collectionView.indexPath(for: visibleCell),
                  let cell = visibleCell as? TrackerCollectionViewCell else {
                return
            }

            let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
            cell.updateCompletionState(
                isCompleted: isTrackerCompleted(tracker.id, on: currentDate),
                completedDays: completedDaysCount(for: tracker.id)
            )
        }
    }

    private func presentEditor(for tracker: Tracker, categoryTitle: String) {
        let viewController = NewHabitViewController(
            trackerCategoryStore: trackerCategoryStore,
            tracker: tracker,
            categoryTitle: categoryTitle
        )
        viewController.delegate = self

        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.navigationBar.prefersLargeTitles = false
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }

    private func presentDeleteConfirmation(for trackerID: UUID) {
        let alert = UIAlertController(
            title: nil,
            message: L10n.Trackers.Delete.message,
            preferredStyle: .actionSheet
        )
        alert.addAction(UIAlertAction(title: L10n.Trackers.Delete.confirm, style: .destructive) { [weak self] _ in
            self?.deleteTracker(withID: trackerID)
        })
        alert.addAction(UIAlertAction(title: L10n.Trackers.Delete.cancel, style: .cancel))
        present(alert, animated: true)
    }

    private func deleteTracker(withID id: UUID) {
        do {
            try trackerCategoryStore.deleteTracker(withID: id)
        } catch {
            assertionFailure("Failed to delete tracker: \(error)")
        }
    }

}

extension TrackersViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCollectionViewCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.delegate = self
        cell.configure(
            with: tracker,
            completedDays: completedDaysCount(for: tracker.id),
            isCompleted: isTrackerCompleted(tracker.id, on: currentDate)
        )
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerSectionHeaderView.reuseIdentifier,
                for: indexPath
              ) as? TrackerSectionHeaderView else {
            return UICollectionReusableView()
        }

        header.configure(with: visibleCategories[indexPath.section].title)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        analyticsService.report(event: .click, item: .track)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        let category = visibleCategories[indexPath.section]
        let tracker = category.trackers[indexPath.item]

        return UIContextMenuConfiguration(identifier: tracker.id as NSCopying, previewProvider: nil) { [weak self] _ in
            let editAction = UIAction(
                title: L10n.Trackers.ContextMenu.edit,
                image: UIImage(systemName: "pencil")
            ) { _ in
                self?.analyticsService.report(event: .click, item: .edit)
                self?.presentEditor(for: tracker, categoryTitle: category.title)
            }
            let deleteAction = UIAction(
                title: L10n.Trackers.ContextMenu.delete,
                image: UIImage(systemName: "trash"),
                attributes: .destructive
            ) { _ in
                self?.analyticsService.report(event: .click, item: .delete)
                self?.presentDeleteConfirmation(for: tracker.id)
            }

            return UIMenu(children: [editAction, deleteAction])
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let horizontalInsets: CGFloat = 32
        let spacing: CGFloat = 9
        let width = floor((collectionView.bounds.width - horizontalInsets - spacing) / 2)
        return CGSize(width: width, height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackersViewController: TrackerCollectionViewCellDelegate {

    func trackerCell(_ cell: TrackerCollectionViewCell, didTapButtonFor trackerID: UUID) {
        analyticsService.report(event: .click, item: .track)
        let calendar = Calendar.current
        let selectedDate = calendar.startOfDay(for: currentDate)
        let today = calendar.startOfDay(for: Date())
        guard selectedDate <= today else { return }

        let wasCompleted = isTrackerCompleted(trackerID, on: selectedDate)

        do {
            if wasCompleted {
                try trackerRecordStore.deleteRecord(for: trackerID, on: selectedDate)
            } else {
                try trackerRecordStore.addRecord(for: trackerID, on: selectedDate)
            }
        } catch {
            assertionFailure("Failed to update tracker record: \(error)")
            return
        }
    }
}

extension TrackersViewController: NewHabitViewControllerDelegate {

    func newHabitViewController(
        _ viewController: NewHabitViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    ) {
        do {
            try trackerCategoryStore.add(tracker, toCategoryWithTitle: categoryTitle)
        } catch {
            assertionFailure("Failed to save tracker: \(error)")
        }
    }

    func newHabitViewController(
        _ viewController: NewHabitViewController,
        didUpdate tracker: Tracker,
        categoryTitle: String
    ) {
        do {
            try trackerCategoryStore.update(tracker, categoryTitle: categoryTitle)
        } catch {
            assertionFailure("Failed to update tracker: \(error)")
        }
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {

    func trackerCategoryStore(_ store: TrackerCategoryStore, didUpdate categories: [TrackerCategory]) {
        self.categories = categories
        updateVisibleTrackers()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {

    func trackerRecordStore(_ store: TrackerRecordStore, didUpdate records: [TrackerRecord]) {
        completedTrackers = records
        if selectedFilter.isActive {
            updateVisibleTrackers()
        } else {
            updateVisibleCellsCompletionState()
        }
    }
}
