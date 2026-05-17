import Foundation

enum AppFormatters {
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let fileSafeDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter
    }()

    static let percent: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 0
        return formatter
    }()
}

extension Date {
    var roofScanShortDate: String {
        AppFormatters.shortDate.string(from: self)
    }
}

extension Double {
    var confidenceText: String {
        AppFormatters.percent.string(from: NSNumber(value: self)) ?? "\(Int(self * 100))%"
    }
}
