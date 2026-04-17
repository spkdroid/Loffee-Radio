# Audio Import Notes

The Android project audio files have been copied into `Resources/Audio` as `.ogg` files.

The iOS playback layer will attempt to open `.ogg` files, but AVAudioEngine support for Android-style OGG assets is not reliable across Apple platforms and toolchains.

For dependable playback in Xcode builds, use converted versions of these same files in one of these formats:

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

## Conversion Status In This Repository

This workspace now contains `.m4a` conversions for each bundled sound alongside the original `.ogg` source files.

The current `.m4a` files were generated with `ffmpeg` using AAC at 192 kbps and keep the same base names as the original assets.

Example `ffmpeg` conversion command for one file:

```text
ffmpeg -i rain.ogg -c:a aac -b:a 192k rain.m4a
```

Example batch approach after `ffmpeg` is installed:

```text
for %f in (*.ogg) do ffmpeg -i "%f" -c:a aac -b:a 192k "%~nf.m4a"
```

The remaining work is validation rather than conversion: test each loop on Apple hardware or the iOS simulator and confirm that interruptions, route changes, background playback, and lock screen controls behave correctly.