import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func scheduleViewController(_ viewController: ScheduleViewController, didSelect weekdays: [Weekday])
}

final class ScheduleViewController: UIViewController {

    weak var delegate: ScheduleViewControllerDelegate?

    private let days: [(weekday: Weekday, title: String)] = [
        (.monday, "Понедельник"),
        (.tuesday, "Вторник"),
        (.wednesday, "Среда"),
        (.thursday, "Четверг"),
        (.friday, "Пятница"),
        (.saturday, "Суббота"),
        (.sunday, "Воскресенье")
    ]
    
    private var selectedWeekdays: Set<Weekday>

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .secondarySystemBackground
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        tableView.register(ScheduleDayCell.self, forCellReuseIdentifier: ScheduleDayCell.reuseIdentifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .label
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init(selectedWeekdays: [Weekday]) {
        self.selectedWeekdays = Set(selectedWeekdays)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = "Расписание"
        navigationItem.largeTitleDisplayMode = .never

        tableView.dataSource = self
        configureLayout()
    }

    private func configureLayout() {
        view.addSubview(tableView)
        view.addSubview(doneButton)

        let tableHeight = tableView.heightAnchor.constraint(equalToConstant: 525)
        tableHeight.priority = .defaultHigh

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.topAnchor, constant: -16),
            tableHeight,

            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func doneButtonTapped() {
        let weekdays = Weekday.allCases.filter { selectedWeekdays.contains($0) }
        delegate?.scheduleViewController(self, didSelect: weekdays)
        navigationController?.popViewController(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        days.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ScheduleDayCell.reuseIdentifier,
            for: indexPath
        ) as? ScheduleDayCell else {
            return UITableViewCell()
        }

        let day = days[indexPath.row]
        cell.configure(
            title: day.title,
            isOn: selectedWeekdays.contains(day.weekday)
        ) { [weak self] isOn in
            if isOn {
                self?.selectedWeekdays.insert(day.weekday)
            } else {
                self?.selectedWeekdays.remove(day.weekday)
            }
        }
        return cell
    }
}
