import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(
        _ viewController: NewHabitViewController,
        didCreate tracker: Tracker,
        categoryTitle: String
    )

    func newHabitViewController(
        _ viewController: NewHabitViewController,
        didUpdate tracker: Tracker,
        categoryTitle: String
    )
}

final class NewHabitViewController: UIViewController {

    private enum Constants {
        static let maxNameLength = 38
        static let nameLimitMessage = L10n.Tracker.Creation.nameLimit
        static let emojis = [
            "🙂", "😻", "🌺", "🐶", "❤️", "😱",
            "😇", "😡", "🥶", "🤔", "🙌", "🍔",
            "🥦", "🏓", "🥇", "🎸", "🏝", "😪"
        ]
        static let colors: [UIColor] = [
            UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 136 / 255, blue: 30 / 255, alpha: 1),
            UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1),
            UIColor(red: 110 / 255, green: 68 / 255, blue: 254 / 255, alpha: 1),
            UIColor(red: 51 / 255, green: 207 / 255, blue: 105 / 255, alpha: 1),
            UIColor(red: 230 / 255, green: 109 / 255, blue: 212 / 255, alpha: 1),
            UIColor(red: 249 / 255, green: 212 / 255, blue: 212 / 255, alpha: 1),
            UIColor(red: 52 / 255, green: 167 / 255, blue: 254 / 255, alpha: 1),
            UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1),
            UIColor(red: 53 / 255, green: 52 / 255, blue: 124 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 103 / 255, blue: 77 / 255, alpha: 1),
            UIColor(red: 255 / 255, green: 153 / 255, blue: 204 / 255, alpha: 1),
            UIColor(red: 246 / 255, green: 196 / 255, blue: 139 / 255, alpha: 1),
            UIColor(red: 121 / 255, green: 148 / 255, blue: 245 / 255, alpha: 1),
            UIColor(red: 131 / 255, green: 44 / 255, blue: 241 / 255, alpha: 1),
            UIColor(red: 173 / 255, green: 86 / 255, blue: 218 / 255, alpha: 1),
            UIColor(red: 141 / 255, green: 114 / 255, blue: 230 / 255, alpha: 1),
            UIColor(red: 47 / 255, green: 208 / 255, blue: 88 / 255, alpha: 1)
        ]
    }

    weak var delegate: NewHabitViewControllerDelegate?

    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerToEdit: Tracker?
    private var selectedSchedule: Set<Weekday> = []
    private var selectedCategoryTitle: String?
    private var selectedEmoji: String?
    private var selectedColor: UIColor?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = L10n.Tracker.Creation.namePlaceholder
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 16
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
        textField.leftViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let nameLimitLabel: UILabel = {
        let label = UILabel()
        label.text = Constants.nameLimitMessage
        label.font = .systemFont(ofSize: 17)
        label.textColor = .systemRed
        label.textAlignment = .center
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let optionsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let categoryButton = TrackerOptionButton(
        title: L10n.Tracker.Creation.category
    )
    private let scheduleButton = TrackerOptionButton(
        title: L10n.Tracker.Creation.schedule
    )

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Tracker.Creation.emoji
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let emojiCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(
            EmojiSelectionCell.self,
            forCellWithReuseIdentifier: EmojiSelectionCell.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private let colorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Tracker.Creation.color
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let colorCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 52, height: 52)
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 3, bottom: 0, right: 3)

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.allowsMultipleSelection = false
        collectionView.register(
            ColorSelectionCell.self,
            forCellWithReuseIdentifier: ColorSelectionCell.reuseIdentifier
        )
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()

    private lazy var optionsTopConstraint = optionsContainer.topAnchor.constraint(
        equalTo: nameTextField.bottomAnchor,
        constant: 24
    )

    private lazy var optionsTopWithErrorConstraint = optionsContainer.topAnchor.constraint(
        equalTo: nameLimitLabel.bottomAnchor,
        constant: 32
    )

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Tracker.Creation.cancel, for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(L10n.Tracker.Creation.create, for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.setTitleColor(.white, for: .disabled)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(trackerCategoryStore: TrackerCategoryStore) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerToEdit = nil
        super.init(nibName: nil, bundle: nil)
    }

    init(
        trackerCategoryStore: TrackerCategoryStore,
        tracker: Tracker,
        categoryTitle: String
    ) {
        self.trackerCategoryStore = trackerCategoryStore
        trackerToEdit = tracker
        selectedSchedule = Set(tracker.schedule)
        selectedCategoryTitle = categoryTitle
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = trackerToEdit == nil
            ? L10n.Tracker.Creation.title
            : L10n.Tracker.Creation.editTitle
        navigationItem.largeTitleDisplayMode = .never

        configureActions()
        configureLayout()
        configureEditingState()
        updateCreateButton()
    }

    private func configureActions() {
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameEditingDidEndOnExit), for: .editingDidEndOnExit)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
        emojiCollectionView.dataSource = self
        emojiCollectionView.delegate = self
        colorCollectionView.dataSource = self
        colorCollectionView.delegate = self
    }

    private func configureLayout() {
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(nameLimitLabel)
        contentView.addSubview(optionsContainer)
        optionsContainer.addSubview(categoryButton)
        optionsContainer.addSubview(separatorView)
        optionsContainer.addSubview(scheduleButton)
        contentView.addSubview(emojiTitleLabel)
        contentView.addSubview(emojiCollectionView)
        contentView.addSubview(colorTitleLabel)
        contentView.addSubview(colorCollectionView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cancelButton.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            nameLimitLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            nameLimitLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLimitLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            optionsTopConstraint,
            optionsContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            optionsContainer.heightAnchor.constraint(equalToConstant: 150),

            categoryButton.topAnchor.constraint(equalTo: optionsContainer.topAnchor),
            categoryButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            categoryButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            categoryButton.heightAnchor.constraint(equalToConstant: 75),

            separatorView.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor, constant: -16),
            separatorView.centerYAnchor.constraint(equalTo: optionsContainer.centerYAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),

            scheduleButton.bottomAnchor.constraint(equalTo: optionsContainer.bottomAnchor),
            scheduleButton.leadingAnchor.constraint(equalTo: optionsContainer.leadingAnchor),
            scheduleButton.trailingAnchor.constraint(equalTo: optionsContainer.trailingAnchor),
            scheduleButton.heightAnchor.constraint(equalToConstant: 75),

            emojiTitleLabel.topAnchor.constraint(equalTo: optionsContainer.bottomAnchor, constant: 32),
            emojiTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            emojiTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            emojiCollectionView.topAnchor.constraint(equalTo: emojiTitleLabel.bottomAnchor, constant: 12),
            emojiCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            emojiCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            emojiCollectionView.heightAnchor.constraint(equalToConstant: 156),

            colorTitleLabel.topAnchor.constraint(equalTo: emojiCollectionView.bottomAnchor, constant: 32),
            colorTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            colorTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),

            colorCollectionView.topAnchor.constraint(equalTo: colorTitleLabel.bottomAnchor, constant: 12),
            colorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            colorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 156),
            contentView.bottomAnchor.constraint(equalTo: colorCollectionView.bottomAnchor, constant: 24),

            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),

            createButton.leadingAnchor.constraint(equalTo: cancelButton.trailingAnchor, constant: 8),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.bottomAnchor.constraint(equalTo: cancelButton.bottomAnchor),
            createButton.widthAnchor.constraint(equalTo: cancelButton.widthAnchor),
            createButton.heightAnchor.constraint(equalTo: cancelButton.heightAnchor)
        ])
    }

    private func updateCreateButton() {
        let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let canCreate = !name.isEmpty
            && selectedCategoryTitle != nil
            && !selectedSchedule.isEmpty
            && selectedEmoji != nil
            && selectedColor != nil
        createButton.isEnabled = canCreate
        createButton.backgroundColor = canCreate ? .label : .systemGray2
    }

    private func configureEditingState() {
        guard let trackerToEdit else { return }

        nameTextField.text = trackerToEdit.name
        categoryButton.setDetail(selectedCategoryTitle)
        scheduleButton.setDetail(scheduleText())
        createButton.setTitle(L10n.Tracker.Creation.save, for: .normal)

        if let emojiIndex = Constants.emojis.firstIndex(of: trackerToEdit.emoji) {
            emojiCollectionView.selectItem(
                at: IndexPath(item: emojiIndex, section: 0),
                animated: false,
                scrollPosition: []
            )
        }

        if let colorIndex = Constants.colors.firstIndex(where: { $0.isEqual(trackerToEdit.color) }) {
            colorCollectionView.selectItem(
                at: IndexPath(item: colorIndex, section: 0),
                animated: false,
                scrollPosition: []
            )
        }
    }

    private func setNameLimitErrorVisible(_ isVisible: Bool) {
        guard nameLimitLabel.isHidden == isVisible else { return }

        if isVisible {
            optionsTopConstraint.isActive = false
            nameLimitLabel.isHidden = false
            optionsTopWithErrorConstraint.isActive = true
        } else {
            optionsTopWithErrorConstraint.isActive = false
            nameLimitLabel.isHidden = true
            optionsTopConstraint.isActive = true
        }

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }

    private func scheduleText() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == Weekday.allCases.count {
            return L10n.Tracker.Creation.everyDay
        }

        return Weekday.allCases
            .filter { selectedSchedule.contains($0) }
            .map(\.shortTitle)
            .joined(separator: ", ")
    }

    @objc private func nameTextChanged() {
        updateCreateButton()
    }

    @objc private func nameEditingDidEndOnExit() {
        nameTextField.resignFirstResponder()
    }

    @objc private func categoryButtonTapped() {
        view.endEditing(true)

        let viewModel = CategoryViewModel(
            categoryStore: trackerCategoryStore,
            selectedCategoryTitle: selectedCategoryTitle
        )
        let categoryViewController = CategoryViewController(viewModel: viewModel)
        categoryViewController.onCategorySelected = { [weak self] title in
            self?.selectedCategoryTitle = title
            self?.categoryButton.setDetail(title)
            self?.updateCreateButton()
        }
        navigationController?.pushViewController(categoryViewController, animated: true)
    }

    @objc private func scheduleButtonTapped() {
        view.endEditing(true)
        let scheduleViewController = ScheduleViewController(selectedWeekdays: selectedSchedule)
        scheduleViewController.delegate = self
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }

    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func createButtonTapped() {
        guard let name = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !name.isEmpty,
              let selectedCategoryTitle,
              !selectedSchedule.isEmpty,
              let selectedEmoji,
              let selectedColor else {
            return
        }

        let tracker = Tracker(
            id: trackerToEdit?.id ?? UUID(),
            name: name,
            color: selectedColor,
            emoji: selectedEmoji,
            schedule: Weekday.allCases.filter { selectedSchedule.contains($0) }
        )

        if trackerToEdit == nil {
            delegate?.newHabitViewController(self, didCreate: tracker, categoryTitle: selectedCategoryTitle)
        } else {
            delegate?.newHabitViewController(self, didUpdate: tracker, categoryTitle: selectedCategoryTitle)
        }
        dismiss(animated: true)
    }
}

extension NewHabitViewController: UITextFieldDelegate {

    func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        guard textField === nameTextField,
              let currentText = textField.text,
              let textRange = Range(range, in: currentText) else {
            return true
        }

        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        let isWithinLimit = updatedText.count <= Constants.maxNameLength
        setNameLimitErrorVisible(!isWithinLimit)
        return isWithinLimit
    }
}

extension NewHabitViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        collectionView === emojiCollectionView
            ? Constants.emojis.count
            : Constants.colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView === emojiCollectionView {
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: EmojiSelectionCell.reuseIdentifier,
                for: indexPath
            ) as? EmojiSelectionCell else {
                return UICollectionViewCell()
            }

            cell.configure(with: Constants.emojis[indexPath.item])
            return cell
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ColorSelectionCell.reuseIdentifier,
            for: indexPath
        ) as? ColorSelectionCell else {
            return UICollectionViewCell()
        }

        cell.configure(with: Constants.colors[indexPath.item])
        return cell
    }
}

extension NewHabitViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView === emojiCollectionView {
            selectedEmoji = Constants.emojis[indexPath.item]
        } else {
            selectedColor = Constants.colors[indexPath.item]
        }

        updateCreateButton()
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {

    func scheduleViewController(_ viewController: ScheduleViewController, didSelect weekdays: Set<Weekday>) {
        selectedSchedule = weekdays
        scheduleButton.setDetail(scheduleText())
        updateCreateButton()
    }
}
