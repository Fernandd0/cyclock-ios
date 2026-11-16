import Foundation

/// Pure sleep-cycle arithmetic: 90-minute cycles plus 14 minutes to fall asleep.
nonisolated enum SleepMath {
    static let cycleMinutes = 90
    static let fallAsleepMinutes = 14
    static let napPrepMinutes = 5

    /// When to wake up if you go to bed at `bedtime` and sleep `cycles` full cycles.
    static func wakeTime(sleepingAt bedtime: Date, cycles: Int) -> Date {
        bedtime.addingTimeInterval(TimeInterval((fallAsleepMinutes + cycles * cycleMinutes) * 60))
    }

    /// When to go to bed to wake at `wake` after `cycles` full cycles.
    static func bedtime(wakingAt wake: Date, cycles: Int) -> Date {
        wake.addingTimeInterval(TimeInterval(-(fallAsleepMinutes + cycles * cycleMinutes) * 60))
    }

    /// When a nap of `minutes` ends if you lie down at `start`.
    static func napEnd(from start: Date, minutes: Int) -> Date {
        start.addingTimeInterval(TimeInterval((napPrepMinutes + minutes) * 60))
    }

    static func hours(cycles: Int) -> Double {
        Double(cycles * cycleMinutes) / 60
    }

    static func hoursText(cycles: Int) -> String {
        hours(cycles: cycles).formatted(.number.precision(.fractionLength(1)))
    }

    /// Today at the given minutes since midnight.
    static func today(minutes: Int, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: minutes / 60, minute: minutes % 60, second: 0, of: .now) ?? .now
    }

    static func minutesSinceMidnight(_ date: Date, calendar: Calendar = .current) -> Int {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        return (parts.hour ?? 0) * 60 + (parts.minute ?? 0)
    }

    /// The next moment in the future with the same hour and minute as `date`.
    static func nextOccurrence(of date: Date, after now: Date = .now, calendar: Calendar = .current) -> Date {
        var parts = calendar.dateComponents([.hour, .minute], from: date)
        parts.second = 0
        return calendar.nextDate(after: now, matching: parts, matchingPolicy: .nextTime) ?? date
    }

    /// True when the next occurrence of `date` falls on a later day than today.
    static func isTomorrow(_ date: Date, calendar: Calendar = .current) -> Bool {
        !calendar.isDateInToday(nextOccurrence(of: date, calendar: calendar))
    }
}

nonisolated extension Date {
    /// Localized short time, e.g. "7:30 AM" or "07:30" depending on the device settings.
    var clock: String {
        formatted(date: .omitted, time: .shortened)
    }
}
