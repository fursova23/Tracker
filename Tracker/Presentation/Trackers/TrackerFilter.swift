enum TrackerFilter: CaseIterable {
    case all
    case today
    case completed
    case incomplete

    var title: String {
        switch self {
        case .all:
            return L10n.Filters.all
        case .today:
            return L10n.Filters.today
        case .completed:
            return L10n.Filters.completed
        case .incomplete:
            return L10n.Filters.incomplete
        }
    }

    var isActive: Bool {
        self == .completed || self == .incomplete
    }
}
