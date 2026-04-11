# Audio Import Notes

The Android project audio files have been copied into `Resources/Audio` as `.ogg` files.

The iOS playback layer will attempt to open `.ogg` files, but AVAudioEngine support for Android-style OGG assets is not reliable across Apple platforms and toolchains.

For dependable playback in Xcode builds, add converted versions of these same files in one of these formats:

- `.m4a`
- `.caf`
- `.wav`
- `.aif`
- `.mp3`

Use the same base names:

- `birds`
- `flute`
- `lounge`
- `musicbox`
- `ocean`
- `orchestral`
- `piano`
- `rain`
- `wind`

The audio manager prefers iOS-native formats before falling back to `.ogg`.