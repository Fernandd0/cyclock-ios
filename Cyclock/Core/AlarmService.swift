import AlarmKit
import SwiftUI

nonisolated struct CyclockAlarmMetadata: AlarmMetadata {}

/// What an alarm is for; shown in the alarm list and used as the alert title.
nonisolated enum AlarmKind: String {
    case wake, bedtime, nap

    var label: LocalizedStringKey {
        switch self {
        case .wake: "despertar"
        case .bedtime: "dormir"
        case .nap: "siesta"
        }
    }

    var alertTitle: LocalizedStringResource {
        switch self {
        case .wake: "Hora de despertar"
        case .bedtime: "Hora de dormir"
        case .nap: "Fin de la siesta"
        }
    }
}

/// Schedules real system alarms through AlarmKit (they ring even in silent mode / Focus).
@Observable
final class AlarmService {
    struct Scheduled: Identifiable {
        let id: UUID
        let date: Date
        let kind: AlarmKind?
    }

    /// The last change the user made, so other views (the mascot) can react to it.
    struct Event: Equatable {
        var id: Int
        var added: Bool
    }

    /// Fire date -> alarm id, for the alarms this app has scheduled.
    private(set) var scheduled: [Date: UUID] = [:]
    /// What each alarm is for. AlarmKit does not hand this back, so it is kept in UserDefaults.
    private var kinds: [String: String]
    private(set) var event: Event?

    var errorMessage: String?
    /// True when the last error was the user denying alarm access (the alert then offers Settings).
    private(set) var permissionDenied = false

    private static let kindsKey = "alarmKinds"
    private var manager: AlarmManager { .shared }

    init() {
        kinds = UserDefaults.standard.dictionary(forKey: Self.kindsKey) as? [String: String] ?? [:]
    }

    /// Pending alarms, soonest first.
    var upcoming: [Scheduled] {
        scheduled
            .sorted { $0.key < $1.key }
            .map { Scheduled(id: $0.value, date: $0.key, kind: kinds[$0.value.uuidString].flatMap(AlarmKind.init)) }
    }

    func isSet(_ date: Date) -> Bool {
        scheduled[SleepMath.nextOccurrence(of: date)] != nil
    }

    /// Re-reads the alarms the system still holds, so the UI survives relaunches and fired alarms.
    func refresh() {
        guard let alarms = try? manager.alarms else { return }
        var map: [Date: UUID] = [:]
        for alarm in alarms {
            if case .fixed(let date)? = alarm.schedule {
                map[date] = alarm.id
            }
        }
        scheduled = map
        let alive = Set(map.values.map(\.uuidString))
        setKinds(kinds.filter { alive.contains($0.key) })
    }

    func cancel(_ fireDate: Date) {
        guard let id = scheduled[fireDate] else { return }
        try? manager.cancel(id: id)
        forget(fireDate, id: id)
    }

    func toggle(at date: Date, kind: AlarmKind) async {
        let fireDate = SleepMath.nextOccurrence(of: date)

        if let id = scheduled[fireDate] {
            try? manager.cancel(id: id)
            forget(fireDate, id: id)
            return
        }

        permissionDenied = false
        do {
            guard let id = try await Self.schedule(at: fireDate, title: kind.alertTitle) else {
                permissionDenied = true
                errorMessage = String(localized: "Cyclock no tiene permiso para crear alarmas. Actívalo en Ajustes.")
                return
            }
            scheduled[fireDate] = id
            var updated = kinds
            updated[id.uuidString] = kind.rawValue
            setKinds(updated)
            record(added: true)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func forget(_ fireDate: Date, id: UUID) {
        scheduled[fireDate] = nil
        var updated = kinds
        updated[id.uuidString] = nil
        setKinds(updated)
        record(added: false)
    }

    private func setKinds(_ newValue: [String: String]) {
        guard newValue != kinds else { return }
        kinds = newValue
        UserDefaults.standard.set(newValue, forKey: Self.kindsKey)
    }

    private func record(added: Bool) {
        event = Event(id: (event?.id ?? 0) + 1, added: added)
    }

    /// Asks for permission if needed and schedules the alarm. Returns nil when the user denied access.
    @concurrent
    private nonisolated static func schedule(at fireDate: Date, title: LocalizedStringResource) async throws -> UUID? {
        let manager = AlarmManager.shared
        guard try await manager.requestAuthorization() == .authorized else { return nil }
        let attributes = AlarmAttributes<CyclockAlarmMetadata>(
            presentation: AlarmPresentation(alert: .init(title: title)),
            tintColor: AppStyle.current.tint
        )
        let id = UUID()
        _ = try await manager.schedule(
            id: id,
            configuration: .alarm(schedule: .fixed(fireDate), attributes: attributes)
        )
        return id
    }
}
