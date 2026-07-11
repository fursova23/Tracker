import UIKit

final class OnboardingViewController: UIViewController {

    // MARK: - Properties

    var completion: (() -> Void)?

    private let pages: [OnboardingPageViewController] = [
        OnboardingPageViewController(
            pageIndex: 0,
            titleText: "Отслеживайте только то, что хотите",
            backgroundImageResource: .onboardingBlue
        ),
        OnboardingPageViewController(
            pageIndex: 1,
            titleText: "Даже если это не литры воды и йога",
            backgroundImageResource: .onboardingRed
        )
    ]

    private lazy var pageViewController: UIPageViewController = {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal
        )
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()

    // MARK: - UI Elements

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.3)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()

    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupPageViewController()
    }

    // MARK: - Setup UI

    private func setupUI() {
        view.backgroundColor = .systemBackground

        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pageViewController.didMove(toParent: self)

        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        view.addSubview(pageControl)
        view.addSubview(finishButton)

        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            finishButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            finishButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            finishButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            finishButton.heightAnchor.constraint(equalToConstant: 60),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: finishButton.topAnchor, constant: -24)
        ])
    }

    private func setupPageViewController() {
        guard let firstPage = pages.first else { return }

        pageViewController.setViewControllers(
            [firstPage],
            direction: .forward,
            animated: false
        )
    }

    // MARK: - Actions

    @objc private func finishButtonTapped() {
        completion?()
    }
}

// MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? OnboardingPageViewController else { return nil }
        let previousIndex = page.pageIndex - 1

        guard pages.indices.contains(previousIndex) else { return nil }
        return pages[previousIndex]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let page = viewController as? OnboardingPageViewController else { return nil }
        let nextIndex = page.pageIndex + 1

        guard pages.indices.contains(nextIndex) else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {

    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard completed,
              let currentPage = pageViewController.viewControllers?.first as? OnboardingPageViewController else {
            return
        }

        pageControl.currentPage = currentPage.pageIndex
    }
}
