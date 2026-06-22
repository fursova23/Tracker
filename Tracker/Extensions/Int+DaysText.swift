extension Int {

    var daysText: String {
        let lastTwoDigits = self % 100
        let lastDigit = self % 10
        let word: String

        if (11...14).contains(lastTwoDigits) {
            word = "дней"
        } else if lastDigit == 1 {
            word = "день"
        } else if (2...4).contains(lastDigit) {
            word = "дня"
        } else {
            word = "дней"
        }

        return "\(self) \(word)"
    }
}
