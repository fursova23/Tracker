import UIKit

protocol NewHabitViewControllerDelegate: AnyObject {
    func newHabitViewController(_ viewController: NewHabitViewController, didCreate tracker: Tracker)
}

final class NewHabitViewController: UIViewController {

    weak var delegate: NewHabitViewControllerDelegate?

    private var selectedSchedule: [Weekday] = []

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
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

    private let optionsContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let categoryButton = TrackerOptionButton(title: "Категория")
    private let scheduleButton = TrackerOptionButton(title: "Расписание")

    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .separator
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отменить", for: .normal)
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
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Новая привычка"
        navigationItem.largeTitleDisplayMode = .never

        configureActions()
        configureLayout()
        updateCreateButton()
    }

    private func configureActions() {
        nameTextField.addTarget(self, action: #selector(nameTextChanged), for: .editingChanged)
        nameTextField.addTarget(self, action: #selector(nameEditingDidEndOnExit), for: .editingDidEndOnExit)
        categoryButton.addTarget(self, action: #selector(categoryButtonTapped), for: .touchUpInside)
        scheduleButton.addTarget(self, action: #selector(scheduleButtonTapped), for: .touchUpInside)
    }

    private func configureLayout() {
        categoryButton.translatesAutoresizingMaskIntoConstraints = false
        scheduleButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nameTextField)
        view.addSubview(optionsContainer)
        optionsContainer.addSubview(categoryButton)
        optionsContainer.addSubview(separatorView)
        optionsContainer.addSubview(scheduleButton)
        view.addSubview(cancelButton)
        view.addSubview(createButton)

        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsContainer.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            optionsContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            optionsContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
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
        let canCreate = !name.isEmpty && !selectedSchedule.isEmpty
        createButton.isEnabled = canCreate
        createButton.backgroundColor = canCreate ? .label : .systemGray2
    }

    private func scheduleText() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == Weekday.allCases.count {
            return "Каждый день"
        }

        let shortTitles: [Weekday: String] = [
            .monday: "Пн", .tuesday: "Вт", .wednesday: "Ср", .thursday: "Чт",
            .friday: "Пт", .saturday: "Сб", .sunday: "Вс"
        ]
        return Weekday.allCases
            .filter { selectedSchedule.contains($0) }
            .compactMap { shortTitles[$0] }
            .joined(separator: ", ")
    }

    @objc private func nameTextChanged() {
        updateCreateButton()
    }

    @objc private func nameEditingDidEndOnExit() {
        nameTextField.resignFirstResponder()
    }

    @objc private func categoryButtonTapped() {}

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
              !selectedSchedule.isEmpty else {
            return
        }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: UIColor(red: 0.20, green: 0.78, blue: 0.35, alpha: 1),
            emoji: "🎨",
            schedule: selectedSchedule
        )
        delegate?.newHabitViewController(self, didCreate: tracker)
        dismiss(animated: true)
    }
}

extension NewHabitViewController: ScheduleViewControllerDelegate {

    func scheduleViewController(_ viewController: ScheduleViewController, didSelect weekdays: [Weekday]) {
        selectedSchedule = weekdays
        scheduleButton.setDetail(scheduleText())
        updateCreateButton()
    }
}
