# ⏳ Countdown Widget

A clean SwiftUI iOS app that lets you track countdowns to upcoming events — visible right from your home screen or lock screen.

## Features

- Add named countdowns to any date
- Home screen widgets (small + medium) with a liquid glass design
- Lock screen widgets (inline, circular, rectangular)
- Color coded urgency — blue → orange → red as the date gets closer
- Automatically shows your next upcoming event
- Updates at midnight so the count is always accurate

## Widget Sizes

| Placement | Sizes |
|-----------|-------|
| Home Screen | Small, Medium |
| Lock Screen | Inline, Circular, Rectangular |

## Tech

- SwiftUI + WidgetKit
- App Groups for shared data between app and widget extension
- `FileManager` shared container for persistence
- `WidgetCenter.reloadAllTimelines()` for instant widget updates on save

## Setup

If you clone this and want to run it yourself:

1. Change the bundle ID to your own in both the app and widget targets
2. Create an App Group in your Apple Developer account (e.g. `group.com.yourname.countdownapp`)
3. Enable the App Group capability on both targets in Xcode
4. Update the `suiteName` in `CountdownEvent.swift` to match your App Group identifier
5. Build and run

## Requirements

- iOS 16+
- Xcode 14+
