import Foundation

final class CategoryViewModel {

    // MARK: - Bindings

    var onCategoriesChanged: (() -> Void)?
    var onSelectedCategoryChanged: ((String) -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Properties

    private let categoryStore: TrackerCategoryStore
    private var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesChanged?()
        }
    }
    private var selectedCategoryTitle: String?

    var categoriesAmount: Int {
        categories.count
    }

    var isEmpty: Bool {
        categories.isEmpty
    }

    // MARK: - Lifecycle

    init(categoryStore: TrackerCategoryStore, selectedCategoryTitle: String?) {
        self.categoryStore = categoryStore
        self.selectedCategoryTitle = selectedCategoryTitle
    }

    // MARK: - Data

    func loadCategories() {
        do {
            categories = try categoryStore.fetchCategories()
        } catch {
            onError?("Не удалось загрузить категории")
        }
    }

    func createCategory(title: String) {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }

        do {
            try categoryStore.createCategoryIfNeeded(withTitle: trimmedTitle)
            loadCategories()
        } catch {
            onError?("Не удалось сохранить категорию")
        }
    }

    func categoryTitle(at row: Int) -> String {
        categories[row].title
    }

    func isCategorySelected(at row: Int) -> Bool {
        categoryTitle(at: row) == selectedCategoryTitle
    }

    func selectCategory(at row: Int) {
        let title = categoryTitle(at: row)
        selectedCategoryTitle = title
        onSelectedCategoryChanged?(title)
    }
}
