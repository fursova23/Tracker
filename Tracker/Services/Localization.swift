import Foundation

enum Localization {

    private static var bundleOverride: Bundle?

    static func localizedString(
        _ key: String,
        _ table: String,
        _ fallback: String
    ) -> String {
        (bundleOverride ?? .main).localizedString(
            forKey: key,
            value: fallback,
            table: table
        )
    }

    #if DEBUG
    static func setLanguageForTesting(_ languageCode: String?) {
        guard let languageCode else {
            bundleOverride = nil
            return
        }

        guard let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            assertionFailure("Bundle локализации не найден: \(languageCode)")
            return
        }

        bundleOverride = bundle
    }
    #endif
}
