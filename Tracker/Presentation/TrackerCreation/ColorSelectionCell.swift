import UIKit

final class ColorSelectionCell: UICollectionViewCell {

    static let reuseIdentifier = "ColorSelectionCell"

    private let selectionView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    override var isSelected: Bool {
        didSet {
            selectionView.layer.borderWidth = isSelected ? 3 : 0
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(selectionView)
        selectionView.addSubview(colorView)

        NSLayoutConstraint.activate([
            selectionView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            selectionView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            selectionView.widthAnchor.constraint(equalToConstant: 48),
            selectionView.heightAnchor.constraint(equalToConstant: 48),

            colorView.centerXAnchor.constraint(equalTo: selectionView.centerXAnchor),
            colorView.centerYAnchor.constraint(equalTo: selectionView.centerYAnchor),
            colorView.widthAnchor.constraint(equalToConstant: 40),
            colorView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with color: UIColor) {
        colorView.backgroundColor = color
        selectionView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
}
