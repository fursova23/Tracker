import UIKit

final class StatisticsCardView: UIView {

    private let gradientLayer = CAGradientLayer()
    private let borderMaskLayer = CAShapeLayer()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = L10n.Statistics.completed
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        gradientLayer.frame = bounds
        borderMaskLayer.path = UIBezierPath(
            roundedRect: bounds.insetBy(dx: 0.5, dy: 0.5),
            cornerRadius: 15.5
        ).cgPath
    }

    func update(value: Int) {
        valueLabel.text = String(value)
    }

    private func configureView() {
        backgroundColor = .systemBackground
        layer.cornerRadius = 16
        translatesAutoresizingMaskIntoConstraints = false

        gradientLayer.colors = [
            UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1).cgColor,
            UIColor(red: 70 / 255, green: 230 / 255, blue: 157 / 255, alpha: 1).cgColor,
            UIColor(red: 0 / 255, green: 123 / 255, blue: 250 / 255, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        borderMaskLayer.fillColor = UIColor.clear.cgColor
        borderMaskLayer.strokeColor = UIColor.black.cgColor
        borderMaskLayer.lineWidth = 1
        gradientLayer.mask = borderMaskLayer
        layer.addSublayer(gradientLayer)

        addSubview(valueLabel)
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            valueLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            valueLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            titleLabel.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 7),
            titleLabel.leadingAnchor.constraint(equalTo: valueLabel.leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12)
        ])
    }
}
