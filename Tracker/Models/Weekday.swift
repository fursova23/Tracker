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
        case .monday: "Понедельник"
        case .tuesday: "Вторник"
        case .wednesday: "Среда"
        case .thursday: "Четверг"
        case .friday: "Пятница"
        case .saturday: "Суббота"
        case .sunday: "Воскресенье"
        }
    }
}
