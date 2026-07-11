import UIKit

final class OnboardingPageViewController: UIViewController {

    // MARK: - Properties

    let pageIndex: Int

    private let titleText: String
    private let backgroundImageResource: ImageResource

    // MARK: - UI Elements

    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    // MARK: - Lifecycle

    init(
        pageIndex: Int,
        titleText: String,
        backgroundImageResource: ImageResource
    ) {
        self.pageIndex = pageIndex
        self.titleText = titleText
        self.backgroundImageResource = backgroundImageResource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    // MARK: - Setup UI

    private func setupUI() {
        backgroundImageView.image = UIImage(resource: backgroundImageResource)
        titleLabel.text = titleText

        view.addSubview(backgroundImageView)
        view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 80)
        ])
    }
}
