# Rhythm - Loffee

Rhythm - Loffee is the iOS port-in-progress of the Android ambient sound mixer stored in `Rhythm--master`.

The goal is to recreate the core experience on iPhone and iPad:

- layer multiple relaxing sounds at the same time
- control each sound independently
- save reusable mixes
- keep the playback flow calm, quick, and reliable

## Repository Layout

- `foundation.md`: product foundation, architecture direction, roadmap, and feature scope
- `ios/Loffee/`: initial iOS source scaffold
- `Rhythm--master/`: Android reference project, ignored by the root Git repository

## Current Status

This repository now contains:

- a product foundation document
- a root `.gitignore` that excludes the Android source folder
- a SwiftUI MVP for the iOS product
- a hand-authored Xcode project structure under `ios/Loffee/Loffee.xcodeproj`
- imported Android image and audio resources under `ios/Loffee/Resources`
- real layered playback through `AVAudioEngine`
- session restore, pause and resume controls, starter mixes, and sleep timer support
- saved mix management with load, rename, duplicate, and delete flows
- a programmatically restyled visual set for the app backgrounds and sound tiles
- an expanded bundled sound library with 18 selectable sounds
- a yoga module with researched styles, goal-based recommendations, style-specific illustrated pose variants, voice guidance, audio transition cues, curated beginner/intermediate/advanced routines, daily logging, streak tracking, and milestone badges

The project can now be opened in Xcode from `ios/Loffee/Loffee.xcodeproj`.

The repository now includes native `.m4a` versions of the bundled ambient tracks alongside the original `.ogg` sources. The audio engine prefers the iOS-native files first and falls back to `.ogg` only if needed. The main remaining playback work is device validation in Xcode: loop seam checks, interruption behavior, route changes, and background playback confirmation. See `ios/Loffee/Resources/Project/AudioImportNotes.md`.

## iOS Source Structure

```text
ios/
  Loffee/
    App/
      LoffeeApp.swift
    Core/
      Audio/
        AudioEngineManager.swift
      Persistence/
        MixStore.swift
        YogaProgressStore.swift
    Domain/
      Models/
        Mix.swift
        Sound.swift
        YogaPose.swift
    Presentation/
      Home/
        HomeView.swift
        HomeViewModel.swift
      Mixes/
        MixesView.swift
      Yoga/
        YogaView.swift
        YogaViewModel.swift
```

## MVP Scope

- home sound grid
- multi-track ambient playback
- per-track volume control
- clear-all and playback controls
- starter preset mixes
- sleep timer
- saved mixes
- rename and duplicate saved mixes
- lightweight local persistence
- background playback support
- guided yoga sessions with automatic completion logging
- streak tracking and lightweight milestone gamification

## End-to-End Flow Included

The current iOS scaffold now supports this MVP loop in code:

1. choose one or more bundled sounds
2. start looping playback through `AVAudioEngine`
3. pause, resume, and clear the current playback session
4. adjust volume per active sound
5. save a mix locally with `UserDefaults`
6. rename, duplicate, delete, and reload saved mixes
7. apply a starter mix or sleep timer from the home screen
8. reopen the app and restore the last active playback selection
9. open the Yoga tab and run a guided session with automatic daily progress logging

## Next Implementation Steps

1. Convert bundled audio from `.ogg` to iOS-native formats and validate loop seams on device.
2. Move images into asset catalogs and add production app icons.
3. Add accessibility polish, haptics, and responsive iPad layout refinement.
4. Integrate Now Playing, lock screen controls, and later iCloud or widget support.

## Naming

The chosen product name is `Rhythm - Loffee`.

For code and bundle naming, `Loffee` is the recommended short form.