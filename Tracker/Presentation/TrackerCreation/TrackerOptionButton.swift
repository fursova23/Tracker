import UIKit

final class TrackerOptionButton: UIControl {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.isHidden = true
        return label
    }()

    private let chevronImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .systemGray2
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    init(title: String) {
        super.init(frame: .zero)
        titleLabel.text = title
        configureLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setDetail(_ text: String?) {
        detailLabel.text = text
        detailLabel.isHidden = text == nil
    }

    private func configureLayout() {
        let labelsStack = UIStackView(arrangedSubviews: [titleLabel, detailLabel])
        labelsStack.axis = .vertical
        labelsStack.spacing = 2
        labelsStack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(labelsStack)
        addSubview(chevronImageView)

        NSLayoutConstraint.activate([
            labelsStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            labelsStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            labelsStack.trailingAnchor.constraint(lessThanOrEqualTo: chevronImageView.leadingAnchor, constant: -8),

            chevronImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            chevronImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            chevronImageView.widthAnchor.constraint(equalToConstant: 24),
            chevronImageView.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
}
