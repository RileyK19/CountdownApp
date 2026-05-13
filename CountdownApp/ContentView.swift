//
//  ContentView.swift
//  CountdownApp
//
//  Created by Riley Koo on 2/22/26.
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var events: [CountdownEvent] = []
    @State private var showingAddSheet = false
    @State private var selectedEvent: CountdownEvent? = nil
    
    var body: some View {
        NavigationStack {
            Group {
                if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .navigationTitle("Countdowns")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                AddEventView { newEvent in
                    var event = newEvent
                    event.sortOrder = events.count
                    events.append(event)
                    save()
                }
            }
            .onAppear { load() }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 64))
                .foregroundStyle(.blue.opacity(0.7))
            Text("No Countdowns Yet")
                .font(.title2.bold())
            Text("Tap + to add an event and it'll show up on your widget.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 40)
            Button("Add Event") {
                showingAddSheet = true
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var eventList: some View {
        List {
            ForEach(events.sorted { $0.sortOrder < $1.sortOrder }) { event in
                EventRow(event: event)
                    .onTapGesture {
                        selectedEvent = event
                    }
            }
            .onDelete { indexSet in
                let sorted = events.sorted { $0.sortOrder < $1.sortOrder }
                for index in indexSet {
                    let toRemove = sorted[index]
                    events.removeAll { $0.id == toRemove.id }
                }
                save()
            }
            .onMove { from, to in
                events.move(fromOffsets: from, toOffset: to)
                for (i, var event) in events.enumerated() {
                    event.sortOrder = i
                    events[i] = event
                }
                save()
            }
        }
        .listStyle(.insetGrouped)
        .sheet(item: $selectedEvent) { event in
            AddEventView(existing: event) { newEvent in
                if let index = events.firstIndex(where: { $0.id == event.id }) {
                    events[index] = newEvent
                }
                save()
            }
        }
    }
    
    private func save() {
        CountdownStore.shared.save(events)
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func load() {
        events = CountdownStore.shared.load()
    }
}

// MARK: - Event Row
struct EventRow: View {
    let event: CountdownEvent
    
    var body: some View {
        HStack(spacing: 16) {
            // Day count bubble
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(bubbleColor.gradient)
                    .frame(width: 64, height: 64)
                VStack(spacing: 2) {
                    Text(dayText)
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(dayLabel)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(event.name)
                    .font(.headline)
                Text(event.date.formatted(date: .long, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(event.formattedTimeRemaining)
                    .font(.subheadline)
                    .foregroundStyle(event.isPast ? .red : .blue)
            }
        }
        .padding(.vertical, 4)
    }
    
    var dayText: String {
        let days = abs(event.daysRemaining)
        if event.daysRemaining == 0 { return "🎉" }
        return "\(days)"
    }
    
    var dayLabel: String {
        if event.daysRemaining == 0 { return "today" }
        return event.isPast ? "days ago" : "days"
    }
    
    var bubbleColor: Color {
        if event.daysRemaining == 0 { return .orange }
        if event.isPast { return .gray }
        if event.daysRemaining <= 7 { return .red }
        if event.daysRemaining <= 30 { return .orange }
        return .blue
    }
}

// MARK: - Add Event Sheet
struct AddEventView: View {
    var existing: CountdownEvent? = nil
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var date = Date()
    
    var onAdd: (CountdownEvent) -> Void
    
    init(existing: CountdownEvent? = nil, onAdd: @escaping (CountdownEvent) -> Void) {
        self.existing = existing
        self.onAdd = onAdd
        _name = State(initialValue: existing?.name ?? "")
        _date = State(initialValue: existing?.date ?? Date())
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Event Details") {
                    TextField("Event name (e.g. Christmas, Birthday)", text: $name)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                if !name.isEmpty {
                    Section("Preview") {
                        EventRow(event: CountdownEvent(name: name, date: date))
                    }
                }
            }
            .navigationTitle("New Countdown")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let event = CountdownEvent(name: name, date: date)
                        onAdd(event)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
