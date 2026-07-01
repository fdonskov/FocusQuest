<h1 align="center">FocusQuest</h1>

<p align="center"><sub><a href="README.md">English</a> · <a href="README.ru.md">Русский</a></sub></p>

<p align="center">
  <img src="https://img.shields.io/badge/iOS-17%2B-7C4CFF?logo=apple&logoColor=white" alt="iOS 17+">
  <img src="https://img.shields.io/badge/macOS-14%2B-7C4CFF?logo=apple&logoColor=white" alt="macOS 14+">
  <img src="https://img.shields.io/badge/Swift-5.9%2B-9B6BFF?logo=swift&logoColor=white" alt="Swift 5.9+">
  <img src="https://img.shields.io/badge/Built%20with-SwiftUI-46E6FF" alt="Built with SwiftUI">
  <img src="https://img.shields.io/badge/status-MVP-8B81AD" alt="Status: MVP">
</p>

<p align="center">
A Pomodoro timer with RPG progression, wrapped in a dark-fantasy theme.<br>
Finished focus sessions level up your character, unlock locations, and drop
loot and achievements. A lofi ambient track plays while you focus.
</p>

<p align="center">
<img src="docs/screenshots/demo.gif" width="280" alt="App in motion"><br>
<sub>In motion</sub>
</p>

## Screens

<table>
  <tr>
    <td align="center"><img src="docs/screenshots/timer.png" width="220"><br><sub>Timer</sub></td>
    <td align="center"><img src="docs/screenshots/map.png" width="220"><br><sub>Wanderer's Map</sub></td>
    <td align="center"><img src="docs/screenshots/inventory.png" width="220"><br><sub>Inventory</sub></td>
  </tr>
  <tr>
    <td align="center"><img src="docs/screenshots/achievements.png" width="220"><br><sub>Achievements</sub></td>
    <td align="center"><img src="docs/screenshots/settings.png" width="220"><br><sub>Settings</sub></td>
    <td align="center"><img src="docs/screenshots/reward.png" width="220"><br><sub>Session reward</sub></td>
  </tr>
</table>

<!-- Screenshots and demo.gif go into docs/screenshots/ (see .gitkeep there). -->

## What it is

An app for running focus sessions (the Pomodoro technique) with RPG elements.
The idea is simple: turn the routine of concentration into a small adventure —
every finished session moves your character forward, opens new places and drops loot.

Platforms: iOS 17+, macOS 14+. No external dependencies.

## What's inside

- The timer counts down from an absolute `Date` instead of accumulating ticks, so it
  survives backgrounding, screen lock and returning to the app.
- Progression: XP per session (with a bonus for no pauses), levels, six locations
  unlocked by level, loot in four rarities, seven achievements.
- Dark-fantasy UI: full-screen location scenes, glows, a pulsing timer ring, and
  per-location particles (fireflies, snow, embers, leaves).
- Lofi focus music — tracks rotate from one session to the next.
- RU/EN localization with instant switching in settings.
- A statistics screen with a weekly focus-time chart.
- Live Activity and Dynamic Island countdown (optional, a separate Widget Extension).
- Respects system Reduce Motion and Dynamic Type.

## Architecture

MVVM with Observation (`@Observable`), SwiftData for storage (models designed for
future CloudKit sync). Business logic lives in dedicated services: `TimerEngine`,
`Progression`, `LootService`, `LocationService`, `AchievementService`,
`StatsCalculator`, `AudioService`, `NotificationService`. The SwiftUI layer sits on
top of them and shares a common theme and design tokens.

## Build

Open the project in Xcode and run the target you need (iPhone simulator or macOS).
No external dependencies.

## Status

In development, MVP.

## Assets and licenses

- Lofi music — CC0 1.0 (public domain).
- Location art — placeholder illustrations, swappable for final art.
- Fonts — Space Grotesk and Manrope (OFL); system fonts are used if they are absent.
