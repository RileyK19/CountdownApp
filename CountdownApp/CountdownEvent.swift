//
//  CountdownEvent.swift
//  CountdownApp
//
//  Created by Riley Koo on 2/22/26.
//


import Foundation

// MARK: - Shared Model
// Store in App Groups so both app and widget can access

public struct CountdownEvent: Codable, Identifiable {
    public var id: UUID
    public var name: String
    public var date: Date
    public var sortOrder: Int
    public static var nextOrder: Int = 0
    
    public init(id: UUID = UUID(), name: String, date: Date) {
        self.id = id
        self.name = name
        self.date = date
        self.sortOrder = CountdownEvent.nextOrder
        CountdownEvent.nextOrder += 1
    }
    
    public var daysRemaining: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let target = calendar.startOfDay(for: date)
        let components = calendar.dateComponents([.day], from: today, to: target)
        return components.day ?? 0
    }
    
    public var isPast: Bool {
        return date < Date()
    }
    
    public var formattedTimeRemaining: String {
        let days = abs(daysRemaining)
        if daysRemaining == 0 {
            return "Today! 🎉"
        } else if daysRemaining > 0 {
            if days == 1 { return "Tomorrow" }
            if days < 7 { return "\(days) days" }
            let weeks = days / 7
            let remaining = days % 7
            if weeks == 1 && remaining == 0 { return "1 week" }
            if remaining == 0 { return "\(weeks) weeks" }
            return "\(days) days"
        } else {
            return "\(days) days ago"
        }
    }
}

// MARK: - Persistence
public class CountdownStore {
    public static let shared = CountdownStore()
    private let key = "countdown_events"
    
    // Use a shared container via file system instead of UserDefaults suite
    private var sharedURL: URL? {
        FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.rileykoo.countdownapp"
        )?.appendingPathComponent("events.json")
    }
    
    private init() {}
    
    public func save(_ events: [CountdownEvent]) {
        guard let url = sharedURL else {
            print("❌ App Group container not found - check entitlements")
            return
        }
        if let data = try? JSONEncoder().encode(events) {
            try? data.write(to: url)
            print("✅ Saved \(events.count) events to \(url)")
        }
    }
    
    public func load() -> [CountdownEvent] {
        guard let url = sharedURL else {
            print("❌ App Group container not found")
            return []
        }
        guard let data = try? Data(contentsOf: url) else {
            print("⚠️ No data file yet at \(url)")
            return []
        }
        let events = (try? JSONDecoder().decode([CountdownEvent].self, from: data)) ?? []
        print("✅ Loaded \(events.count) events")
        return events
    }
}
