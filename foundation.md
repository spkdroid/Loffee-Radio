# iOS Foundation

## Product Name

The chosen product name is `Rhythm - Loffee`.

For source code, bundle naming, and folder naming, use `Loffee` as the short technical name.

## Product Goal

Build an iOS version of the Android relaxing melody mixer found in `Rhythm--master`. The iOS app should let users:

- play multiple ambient sounds at the same time
- adjust each sound independently
- save custom mixes
- reopen saved mixes later
- keep playback simple, stable, and calm

The first iOS release should focus on feature parity before adding premium or platform-specific enhancements.

## Suggested Product Direction

### Core Experience

The app is a personal soundscape mixer for sleep, focus, meditation, and relaxation. Users tap ambient sound tiles, layer several sounds together, adjust volume for each one, and save the resulting mix.

### MVP Scope

- home screen with sound grid
- simultaneous playback of multiple looping sounds
- per-sound volume controls
- play, pause, and clear-all controls
- saved mixes screen
- create, rename, load, and delete mixes
- restore last playback state when app relaunches
- background audio playback

## iOS Technical Foundation

### Recommended Stack

- SwiftUI for UI
- AVAudioEngine for layered playback and mixing
- SwiftData or Core Data for saved mixes
- UserDefaults for lightweight preferences and current playback state
- Combine or Swift concurrency for state flow and async loading

### Architecture

Use a clean, testable structure that mirrors the Android layout:

- `App`: entry point, scene setup, app lifecycle, dependency container
- `Core`: audio engine, persistence adapters, constants, utility services
- `Data`: local storage models, repositories, mappers
- `Domain`: entities, repository protocols, use cases
- `Presentation`: SwiftUI screens, view models, UI state, components

### Android to iOS Mapping

- `PlayerManager.kt` -> `AudioEngineManager.swift`
- `AppDatabase.kt` -> `MixStore.swift` backed by SwiftData or Core Data
- repository interfaces -> Swift protocols in `Domain`
- use cases -> focused Swift services or domain actions
- viewmodels -> `ObservableObject` or `@Observable` presentation models

## Functional Breakdown

### Audio System

The audio layer is the most important technical part of the port.

Requirements:

- one player per sound source
- seamless looping for ambient tracks
- independent volume per active sound
- low-latency start and stop
- safe interruption handling for phone calls, Siri, route changes, and headphones
- background playback support

Implementation direction:

- preload sound files from the app bundle
- create one engine manager responsible for node lifecycle
- expose simple commands: `play(sound)`, `pauseAll()`, `stopAll()`, `setVolume(sound, value)`
- keep playback state centralized so UI stays deterministic

### Persistence

Persist these objects locally:

- `Sound`: id, title, asset name, category, default volume, artwork
- `Mix`: id, name, createdAt, updatedAt
- `MixItem`: mix id, sound id, volume, ordering

Also store lightweight preferences:

- currently selected sounds
- last used volumes
- whether playback was active
- last opened screen if needed

### Presentation

Initial screens:

1. Home
2. Mixer panel or bottom sheet
3. My Mixes
4. Save Mix flow

Home should prioritize fast interaction:

- large sound tiles
- clear selected state
- mini-player or control strip
- frictionless volume access

## First Delivery Plan

### Phase 1: Project Setup

- create Xcode project
- define folder structure
- add audio assets and image placeholders
- build dependency container
- establish app theme and design tokens

### Phase 2: Audio Engine Prototype

- implement multi-track looping
- verify stable playback for several simultaneous sounds
- add per-track volume control
- test interruptions and background behavior

### Phase 3: Core Screens

- implement Home screen with sound grid
- wire sound selection to audio engine
- add transport controls
- add mixer controls for active sounds

### Phase 4: Saved Mixes

- add local persistence
- create save and load flows
- support rename and delete
- restore saved mixes into active playback state

### Phase 5: Polish and Release Prep

- improve onboarding and empty states
- optimize assets and battery usage
- add analytics if required
- prepare TestFlight build

## Naming Notes

The product name has now been selected as `Rhythm - Loffee`.

The original candidate list is preserved below for reference.

### Closest to Existing Brand

- Rhythm Calm
- Rhythm Sleep
- Rhythm Mix
- Rhythm Soundscape

### Better for a Fresh iOS Launch

- Loffee
- Drift Mix
- Hushscape
- Moonlayer
- Quiet Merge
- Stillwave
- Sleep Weave

## Additional Features

### Strong Early Additions

- sleep timer with fade-out
- favorites and pinned mixes
- preset scenes for sleep, focus, rain, and meditation
- lock screen and Control Center playback controls
- home screen widgets for quick-start mixes
- iCloud sync for mixes across devices

### Strong Premium Additions

- breathing sessions over ambient audio
- adaptive scenes with changing weather intensity
- Apple Health mindfulness integration
- downloadable sound packs
- personal custom audio import
- smart routine automation by time of day

## UX Notes

- keep the interaction model calm and immediate
- avoid cluttering the main screen with deep settings
- make sound selection feel playful but not noisy
- prioritize large touch targets and low cognitive load
- preserve the relaxing visual identity, but adapt it to native iOS spacing and motion

## Repository Notes

- root `.gitignore` already excludes `/Rhythm--master/`
- the Android project remains available as the reference implementation
- the iOS app can be added at the repository root as a separate project without pulling the Android folder into version control
- Android image assets have been imported into the iOS resources folder
- Android `.ogg` audio assets have also been imported, but production playback should use converted iOS-native audio formats for reliability

## Recommended Next Build Step

Create the initial iOS project skeleton with:

- `LoffeeApp.swift`
- `AudioEngineManager.swift`
- `Sound.swift`
- `Mix.swift`
- `HomeView.swift`
- `MixesView.swift`
- `HomeViewModel.swift`
- `MixStore.swift`

That is the smallest useful foundation for moving from planning into implementation.