import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func trackerCell(_ cell: TrackerCollectionViewCell, didTapButtonFor trackerID: UUID)
}

final class TrackerCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = "TrackerCollectionViewCell"

    weak var delegate: TrackerCollectionViewCellDelegate?

    private var trackerID: UUID?

    private let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let daysLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var completeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.tintColor = .white
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        trackerID = nil
        delegate = nil
    }

    func configure(with tracker: Tracker, completedDays: Int, isCompleted: Bool) {
        trackerID = tracker.id
        cardView.backgroundColor = tracker.color
        emojiLabel.text = tracker.emoji
        nameLabel.text = tracker.name
        daysLabel.text = daysText(for: completedDays)

        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        )
        completeButton.setImage(image, for: .normal)
        completeButton.backgroundColor = isCompleted
            ? tracker.color.withAlphaComponent(0.3)
            : tracker.color
    }

    private func configureLayout() {
        contentView.addSubview(cardView)
        cardView.addSubview(emojiBackgroundView)
        emojiBackgroundView.addSubview(emojiLabel)
        cardView.addSubview(nameLabel)
        contentView.addSubview(daysLabel)
        contentView.addSubview(completeButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),

            emojiBackgroundView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiBackgroundView.widthAnchor.constraint(equalToConstant: 24),
            emojiBackgroundView.heightAnchor.constraint(equalToConstant: 24),

            emojiLabel.centerXAnchor.constraint(equalTo: emojiBackgroundView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiBackgroundView.centerYAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            nameLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),

            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            daysLabel.centerYAnchor.constraint(equalTo: completeButton.centerYAnchor),

            completeButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            completeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            completeButton.widthAnchor.constraint(equalToConstant: 34),
            completeButton.heightAnchor.constraint(equalToConstant: 34)
        ])
    }

    private func daysText(for count: Int) -> String {
        let lastTwoDigits = count % 100
        let lastDigit = count % 10
        let word: String

        if (11...14).contains(lastTwoDigits) {
            word = "дней"
        } else if lastDigit == 1 {
            word = "день"
        } else if (2...4).contains(lastDigit) {
            word = "дня"
        } else {
            word = "дней"
        }

        return "\(count) \(word)"
    }

    @objc private func completeButtonTapped() {
        guard let trackerID else { return }
        delegate?.trackerCell(self, didTapButtonFor: trackerID)
    }
}
