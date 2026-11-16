import SwiftUI

/// The user's saved sleep goal and usual wake-up time, plus what follows from them.
/// Declare it in a view as `private var schedule = SleepSchedule()`; the view updates when it changes.
struct SleepSchedule: DynamicProperty {
    @AppStorage(Prefs.goalCycles) var cycles = CycleOptions.recommended
    @AppStorage(Prefs.wakeMinutes) private var wakeMinutes = 420

    var wake: Date {
        SleepMath.today(minutes: wakeMinutes)
    }

    var bedtime: Date {
        SleepMath.bedtime(wakingAt: wake, cycles: cycles)
    }

    var hoursText: String {
        SleepMath.hoursText(cycles: cycles)
    }

    var cyclesBinding: Binding<Int> {
        $cycles
    }

    var wakeBinding: Binding<Date> {
        let minutes = $wakeMinutes
        return Binding(
            get: { SleepMath.today(minutes: minutes.wrappedValue) },
            set: { minutes.wrappedValue = SleepMath.minutesSinceMidnight($0) }
        )
    }
}
