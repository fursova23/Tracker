import AppMetricaCore
import Foundation

enum AnalyticsEvent: String {
    case open
    case close
    case click
}

enum AnalyticsItem: String {
    case addTrack = "add_track"
    case track
    case filter
    case edit
    case delete
}

protocol AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent, item: AnalyticsItem?)
}

extension AnalyticsServiceProtocol {
    func report(event: AnalyticsEvent) {
        report(event: event, item: nil)
    }
}

final class AnalyticsService: AnalyticsServiceProtocol {

    static let shared = AnalyticsService()

    private enum Constants {
        static let eventName = "EVENT"
        static let mainScreen = "Main"
    }

    private var isActivated = false

    private init() {}

    func activate(apiKey: String) {
        guard !apiKey.isEmpty,
              let configuration = AppMetricaConfiguration(apiKey: apiKey) else {
            #if DEBUG
            print("AppMetrica отключена: необходимо добавить APPMETRICA_API_KEY в build setting")
            #endif
            return
        }

        AppMetrica.activate(with: configuration)
        isActivated = true
    }

    func report(event: AnalyticsEvent, item: AnalyticsItem? = nil) {
        var parameters: [String: Any] = [
            "event": event.rawValue,
            "screen": Constants.mainScreen
        ]
        if let item {
            parameters["item"] = item.rawValue
        }

        #if DEBUG
        print("AppMetrica событие: \(parameters)")
        #endif

        guard isActivated else { return }

        AppMetrica.reportEvent(
            name: Constants.eventName,
            parameters: parameters,
            onFailure: { error in
                #if DEBUG
                print("Ошибка отправки AppMetrica события: \(error)")
                #endif
            }
        )
    }
}
