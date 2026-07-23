enum Weekday: Int, CaseIterable {
    case monday = 2
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday = 1
}

extension Weekday {

    var title: String {
        switch self {
        case .monday: L10n.Weekday.monday
        case .tuesday: L10n.Weekday.tuesday
        case .wednesday: L10n.Weekday.wednesday
        case .thursday: L10n.Weekday.thursday
        case .friday: L10n.Weekday.friday
        case .saturday: L10n.Weekday.saturday
        case .sunday: L10n.Weekday.sunday
        }
    }

    var shortTitle: String {
        switch self {
        case .monday: L10n.Weekday.Short.monday
        case .tuesday: L10n.Weekday.Short.tuesday
        case .wednesday: L10n.Weekday.Short.wednesday
        case .thursday: L10n.Weekday.Short.thursday
        case .friday: L10n.Weekday.Short.friday
        case .saturday: L10n.Weekday.Short.saturday
        case .sunday: L10n.Weekday.Short.sunday
        }
    }
}
