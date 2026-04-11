# Rhythm - Loffee Roadmap

This roadmap starts from the current MVP foundation and breaks the next work into practical improvement phases.

The goal is to move from a working prototype into a stable, polished, and differentiated iOS relaxation product.

## Current MVP Baseline

The current MVP direction covers:

- layered ambient playback
- per-sound volume control
- saved mixes
- rename and duplicate saved mixes
- restore last session
- pause, resume, and clear-all transport controls
- starter preset mixes
- sleep timer
- background playback support
- early SwiftUI UI and Xcode project structure

Before scaling features, the first priority should be reliability, audio quality, and basic UX completeness.

## Phase 1: Stabilize The MVP

### Goal

Make the current product dependable enough for real daily use.

### Improvements

- replace imported `.ogg` files with iOS-native audio formats such as `.m4a`, `.caf`, or `.wav`
- validate seamless loop behavior for every sound
- add true play, pause, resume, and clear-all behavior across the full app state
- improve interruption handling for calls, Siri, headphones, Bluetooth, and route changes
- confirm background audio behavior on device
- remove any mismatch between saved mixes, restored sessions, and active engine state
- add basic error states for missing assets or failed playback

### Deliverables

- stable playback engine
- deterministic session restore
- reliable mix save and load behavior
- device-tested MVP build

## Phase 2: Complete The Core User Experience

### Goal

Finish the essential interactions that make the app feel complete instead of technical.

### Improvements

- add a polished mini-player or bottom control bar
- add a dedicated mixer panel for active sounds
- support rename mix flow directly in the saved mixes screen
- support duplicate mix flow for quick experimentation
- add empty states for no saved mixes and no active sounds
- improve visual feedback for selected sounds, active playback, and paused state
- add onboarding hints for first launch
- refine spacing, typography, and motion to feel intentionally native on iPhone and iPad

### Deliverables

- complete home-to-mix workflow
- improved clarity of playback state
- more usable saved-mix management

## Phase 3: Native iOS Product Polish

### Goal

Make the app feel like a real iOS product rather than a port.

### Improvements

- move image resources into proper asset catalogs
- add production app icons, launch treatment, and adaptive sizing assets
- add lock screen and Control Center playback controls
- support Now Playing metadata for active mixes
- add haptics in key interaction points where appropriate
- optimize layout for iPad and larger iPhones
- improve accessibility with VoiceOver labels, Dynamic Type support, and contrast checks
- reduce energy usage and optimize audio/resource loading

### Deliverables

- App Store-quality visual baseline
- better platform integration
- improved accessibility and battery behavior

## Phase 4: Content And Retention Features

### Goal

Increase repeat usage and make the app more useful across different calming routines.

### Improvements

- add curated preset scenes such as sleep, rain, focus, meditation, and ocean night
- add favorites and pinned mixes
- add a sleep timer with fade-out options
- add categories or tags for sounds and mixes
- add quick-start suggestions based on recent usage
- add richer sound library organization and artwork polish
- add streak-free retention features that stay calm and non-gamified

### Deliverables

- better repeat engagement
- faster path to useful soundscapes
- stronger content depth without adding complexity

## Phase 5: Data, Sync, And Cross-Device Convenience

### Goal

Make user data resilient and portable.

### Improvements

- migrate saved mixes from pure `UserDefaults` to SwiftData or Core Data
- add iCloud sync for mixes and preferences
- add backup-safe persistence and migration paths
- support widgets for launching favorite mixes
- support Shortcuts and simple automation triggers
- add import and export for mixes if needed

### Deliverables

- stronger persistence model
- cross-device continuity
- better ecosystem integration

## Phase 6: Premium Differentiators

### Goal

Expand beyond parity and create a stronger product position.

### Improvements

- add breathing sessions layered over ambient audio
- add adaptive soundscapes with changing intensity over time
- add guided relaxation or focus sessions
- add downloadable sound packs
- add custom user-imported audio where licensing and file management allow
- add Apple Health mindfulness session integration where appropriate

### Deliverables

- clearer premium upgrade path
- broader use cases beyond basic sound mixing
- stronger long-term product identity

## Recommended Delivery Order

If the goal is fastest path to a credible first release, the order should be:

1. Phase 1: Stabilize The MVP
2. Phase 2: Complete The Core User Experience
3. Phase 3: Native iOS Product Polish
4. Small beta or TestFlight release
5. Phase 4 and Phase 5 based on user feedback
6. Phase 6 when the core loop is proven

## Suggested Release Milestones

### Milestone A: Functional Beta

- stable playback
- complete mix save and restore
- working transport controls
- real device testing complete

### Milestone B: Public MVP

- polished home and mixes flow
- accessibility baseline complete
- lock screen playback support
- refined visuals and assets

### Milestone C: Growth Release

- presets
- sleep timer
- favorites
- iCloud sync or widgets

### Milestone D: Premium Expansion

- advanced routines
- premium sound packs
- differentiated wellness features

## Immediate Recommendation

The best next improvement phase is now Phase 3.

The current iOS scaffold has already covered most of the code-only parts of Phase 1 and Phase 2 that fit inside this workspace. The next highest-value work is Apple-platform validation and polish: converting audio assets to iOS-native formats, testing route and interruption behavior on device, moving resources into asset catalogs, improving accessibility, and integrating system playback surfaces such as Now Playing and lock screen controls.