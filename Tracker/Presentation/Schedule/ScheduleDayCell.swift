import UIKit

final class ScheduleDayCell: UITableViewCell {

    static let reuseIdentifier = "ScheduleDayCell"

    private var switchValueChanged: ((Bool) -> Void)?

    private let dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.onTintColor = UIColor(resource: .ypBlueIOS)
        daySwitch.addTarget(self, action: #selector(daySwitchChanged), for: .valueChanged)
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .secondarySystemBackground
        contentView.addSubview(dayLabel)
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        switchValueChanged = nil
    }

    func configure(title: String, isOn: Bool, valueChanged: @escaping (Bool) -> Void) {
        dayLabel.text = title
        daySwitch.isOn = isOn
        switchValueChanged = valueChanged
    }

    @objc private func daySwitchChanged() {
        switchValueChanged?(daySwitch.isOn)
    }
}
