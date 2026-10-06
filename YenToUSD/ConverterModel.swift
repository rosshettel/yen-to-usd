import Foundation
import Observation

@MainActor
@Observable
final class ConverterModel {
    enum RateStatus { case loading, live, fallback }

    var yen = ""
    var split = 1
    var menuOpen = false
    var rate = RateService.fallbackRate
    var rateStatus = RateStatus.loading

    var yenValue: Int { Int(yen) ?? 0 }
    var usd: Double { Double(yenValue) / rate }
    var perPerson: Double { usd / Double(split) }

    /// `key` is "0"–"9", "000", or "back".
    func press(_ key: String) {
        menuOpen = false
        if key == "back" {
            if !yen.isEmpty { yen.removeLast() }
            return
        }
        if yen.isEmpty && (key == "0" || key == "000") { return }
        yen = String((yen + key).prefix(10))
    }

    func clear() {
        yen = ""
    }

    func refreshRate() async {
        rateStatus = .loading
        if let live = await RateService.fetchLiveRate() {
            rate = live
            rateStatus = .live
        } else {
            rate = RateService.fallbackRate
            rateStatus = .fallback
        }
    }
}

private let usLocale = Locale(identifier: "en_US")

extension Double {
    /// 1,234.56
    var money: String {
        formatted(.number.precision(.fractionLength(2)).locale(usLocale))
    }
}

extension Int {
    /// 12,500
    var grouped: String {
        formatted(.number.locale(usLocale))
    }
}
