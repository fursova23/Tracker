import Foundation

final class UserDefaultsService {

    static let shared = UserDefaultsService()

    private enum Key {
        static let hasSeenOnboarding = "hasSeenOnboarding"
    }

    private let defaults = UserDefaults.standard

    var hasSeenOnboarding: Bool {
        get {
            defaults.bool(forKey: Key.hasSeenOnboarding)
        }
        set {
            defaults.set(newValue, forKey: Key.hasSeenOnboarding)
        }
    }

    private init() {}
}
