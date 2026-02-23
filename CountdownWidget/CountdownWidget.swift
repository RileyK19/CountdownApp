//
//  CountdownWidget.swift
//  CountdownWidget
//
//  Created by Riley Koo on 2/22/26.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entry
struct CountdownEntry: TimelineEntry {
    let date: Date
    let event: CountdownEvent?
}

// MARK: - Provider
struct CountdownProvider: TimelineProvider {
    func placeholder(in context: Context) -> CountdownEntry {
        CountdownEntry(date: Date(), event: CountdownEvent(
            name: "My Birthday",
            date: Calendar.current.date(byAdding: .day, value: 42, to: Date())!
        ))
    }
    
    func getSnapshot(in context: Context, completion: @escaping (CountdownEntry) -> Void) {
        let events = CountdownStore.shared.load()
        let next = nextEvent(from: events)
        completion(CountdownEntry(date: Date(), event: next))
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CountdownEntry>) -> Void) {
        let events = CountdownStore.shared.load()
        let next = nextEvent(from: events)
        let entry = CountdownEntry(date: Date(), event: next)
        
        // Refresh at midnight so the day count updates
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.day! += 1
        components.hour = 0
        components.minute = 0
        let midnight = Calendar.current.date(from: components) ?? Date().addingTimeInterval(86400)
        
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }
    
    private func nextEvent(from events: [CountdownEvent]) -> CountdownEvent? {
        let upcoming = events.filter { $0.daysRemaining >= 0 }.sorted { $0.date < $1.date }
        return upcoming.first ?? events.sorted { $0.date < $1.date }.last
    }
}

// MARK: - Tint color helper
private func tintColor(for event: CountdownEvent) -> Color {
    if event.daysRemaining == 0 { return .orange }
    if event.isPast { return .gray }
    if event.daysRemaining <= 7 { return .red }
    if event.daysRemaining <= 30 { return .orange }
    return .blue
}

// MARK: - Widget Views

// Home Screen: systemSmall
struct SmallWidgetView: View {
    let event: CountdownEvent?
    
    var body: some View {
        if let event {
            ZStack {
                // Frosted glass base
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                
                // Subtle colored tint based on urgency
                RoundedRectangle(cornerRadius: 22)
                    .fill(tintColor(for: event).opacity(0.15))
                
                // Inner border glow
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                
                VStack(spacing: 6) {
                    Text(event.name)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(.primary.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                    
                    Text(event.daysRemaining == 0 ? "🎉" : "\(abs(event.daysRemaining))")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(.primary)
                        .minimumScaleFactor(0.5)
                    
                    Text(event.daysRemaining == 0 ? "Today!" :
                         event.isPast ? "days ago" : "days to go")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.secondary)
                }
                .padding(12)
            }
        } else {
            emptyView
        }
    }
}

// Home Screen: systemMedium
struct MediumWidgetView: View {
    let event: CountdownEvent?
    
    var body: some View {
        if let event {
            ZStack {
                RoundedRectangle(cornerRadius: 22)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 22)
                    .fill(tintColor(for: event).opacity(0.12))
                
                RoundedRectangle(cornerRadius: 22)
                    .strokeBorder(.white.opacity(0.25), lineWidth: 1)
                
                HStack(spacing: 16) {
                    // Days circle
                    ZStack {
                        Circle()
                            .fill(tintColor(for: event).opacity(0.2))
                            .frame(width: 90, height: 90)
                        Circle()
                            .strokeBorder(tintColor(for: event).opacity(0.4), lineWidth: 1.5)
                            .frame(width: 90, height: 90)
                        VStack(spacing: 2) {
                            Text("\(abs(event.daysRemaining))")
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundStyle(.primary)
                            Text(event.isPast ? "ago" : "days")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(event.daysRemaining == 0 ? "🎉 It's Today!" : event.name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .lineLimit(2)
                        
                        Text(event.date.formatted(date: .abbreviated, time: .omitted))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        if event.daysRemaining != 0 {
                            Text(event.isPast ? "has passed" : event.formattedTimeRemaining)
                                .font(.caption.weight(.medium))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(tintColor(for: event).opacity(0.15))
                                .clipShape(Capsule())
                                .foregroundStyle(.primary.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
        } else {
            emptyView
        }
    }
}

// Lock Screen: accessoryCircular
struct LockCircularView: View {
    let event: CountdownEvent?
    
    var body: some View {
        if let event {
            ZStack {
                AccessoryWidgetBackground()
                VStack(spacing: 1) {
                    Text("\(abs(event.daysRemaining))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                    Text(event.isPast ? "ago" : "days")
                        .font(.system(size: 9, weight: .medium))
                }
            }
        } else {
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "calendar")
                    .font(.title3)
            }
        }
    }
}

// Lock Screen: accessoryRectangular
struct LockRectangularView: View {
    let event: CountdownEvent?
    
    var body: some View {
        if let event {
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(event.name)
                        .font(.system(size: 13, weight: .semibold))
                        .lineLimit(1)
                    Text(event.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                VStack(spacing: 0) {
                    Text("\(abs(event.daysRemaining))")
                        .font(.system(size: 22, weight: .black, design: .rounded))
                    Text(event.isPast ? "ago" : "days")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
        } else {
            Label("No event", systemImage: "calendar")
                .font(.subheadline)
        }
    }
}

// Lock Screen: accessoryInline
struct LockInlineView: View {
    let event: CountdownEvent?
    
    var body: some View {
        if let event {
            if event.daysRemaining == 0 {
                Label("\(event.name) — Today!", systemImage: "party.popper")
            } else {
                Label("\(event.name): \(abs(event.daysRemaining))d \(event.isPast ? "ago" : "away")", systemImage: "calendar.badge.clock")
            }
        } else {
            Label("No countdown", systemImage: "calendar")
        }
    }
}

// MARK: - Empty view
private var emptyView: some View {
    ZStack {
        RoundedRectangle(cornerRadius: 22)
            .fill(.ultraThinMaterial)
        RoundedRectangle(cornerRadius: 22)
            .strokeBorder(.white.opacity(0.2), lineWidth: 1)
        VStack(spacing: 8) {
            Image(systemName: "calendar.badge.plus")
                .font(.title2)
                .foregroundStyle(.secondary)
            Text("Add an event\nin the app")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Widget Definition
struct CountdownWidget: Widget {
    let kind: String = "CountdownWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CountdownProvider()) { entry in
            CountdownWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color.clear
                }
        }
        .configurationDisplayName("Countdown")
        .description("Shows how long until your next event.")
        .supportedFamilies([
            // Home screen
            .systemSmall,
            .systemMedium,
            // Lock screen
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Entry View (routes to correct layout)
struct CountdownWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: CountdownEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(event: entry.event)
        case .systemMedium:
            MediumWidgetView(event: entry.event)
        case .accessoryCircular:
            LockCircularView(event: entry.event)
        case .accessoryRectangular:
            LockRectangularView(event: entry.event)
        case .accessoryInline:
            LockInlineView(event: entry.event)
        default:
            SmallWidgetView(event: entry.event)
        }
    }
}
