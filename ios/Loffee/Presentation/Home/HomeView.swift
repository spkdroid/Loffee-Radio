import SwiftUI
import UIKit

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @AppStorage("com.loffee.has-seen-onboarding") private var hasSeenOnboarding = false
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @ScaledMetric(relativeTo: .title2) private var heroIconSize = 52
    @State private var isMixerPresented = false

    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: horizontalSizeClass == .regular ? 164 : 112), spacing: 14)]
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                scenicBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerCard
                        if !hasSeenOnboarding {
                            onboardingCard
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        starterMixesCard
                        soundLibrarySection
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 120)
                }
            }
            .navigationTitle("Rhythm - Loffee")
            .navigationBarTitleDisplayMode(.inline)
            .safeAreaInset(edge: .bottom) {
                bottomControlBar
                    .padding(.horizontal, 14)
                    .padding(.bottom, 8)
            }
            .sheet(isPresented: $isMixerPresented) {
                mixerSheet
            }
            .alert(
                "Audio Issue",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.dismissError() } }
                ),
                actions: {
                    Button("OK") {
                        viewModel.dismissError()
                    }
                },
                message: {
                    Text(viewModel.errorMessage ?? "Unknown audio error")
                }
            )
            .animation(.spring(response: 0.34, dampingFraction: 0.84), value: viewModel.activeSounds)
            .animation(.easeInOut(duration: 0.24), value: hasSeenOnboarding)
        }
    }

    private var scenicBackground: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [Color(red: 0.16, green: 0.33, blue: 0.43), Color(red: 0.08, green: 0.16, blue: 0.22)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: -24) {
                ZStack(alignment: .top) {
                    BundlePNGImage(name: "bg_main", contentMode: .fit)
                    VStack(spacing: -4) {
                        BundlePNGImage(name: "bg_moon", contentMode: .fit)
                            .frame(maxWidth: 220)
                            .padding(.top, 28)
                        BundlePNGImage(name: "bg_mountains", contentMode: .fit)
                    }
                }

                Spacer()

                BundlePNGImage(name: "bg_lake", contentMode: .fit)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                BundlePNGImage(name: "rope_normal", contentMode: .fit)
                    .frame(width: heroIconSize, height: heroIconSize)
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Rhythm - Loffee")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Layer ambient melodies and weather textures into one calm mix.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer(minLength: 12)
            }

            HStack {
                Label(viewModel.transportTitle, systemImage: viewModel.transportSystemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.94, blue: 0.74))

                Spacer()

                if viewModel.hasActiveMix {
                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        HomeHaptics.impact(.light)
                        viewModel.togglePlayback()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.30, green: 0.52, blue: 0.67))
                    .accessibilityHint("Toggles playback for the current mix")
                }

                Button("Clear All") {
                    HomeHaptics.notification(.warning)
                    viewModel.clearAll()
                }
                .buttonStyle(.bordered)
                .tint(Color(red: 0.82, green: 0.88, blue: 0.95))
                .disabled(viewModel.activeSounds.isEmpty)
                .accessibilityHint("Stops playback and removes all active sounds")
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .accessibilityElement(children: .combine)
    }

    private var onboardingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("First launch tips", systemImage: "sparkles")
                .font(.headline)
                .foregroundStyle(.white)

            Text("Start with a preset, tap any sound tile to layer it in, then open the mixer bar at the bottom to tune levels and save the result.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.78))

            HStack(spacing: 12) {
                featureChip(title: "Preset scenes", systemImage: "wand.and.rays")
                featureChip(title: "Mixer panel", systemImage: "slider.horizontal.3")
                featureChip(title: "Sleep timer", systemImage: "moon.zzz")
            }

            Button("Hide tips") {
                HomeHaptics.selection()
                hasSeenOnboarding = true
            }
            .buttonStyle(.bordered)
            .tint(.white)
            .accessibilityHint("Dismisses first launch guidance")
        }
        .padding(20)
        .background(Color.black.opacity(0.24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func featureChip(title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption.weight(.semibold))
            .foregroundStyle(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.white.opacity(0.08))
            .clipShape(Capsule())
    }

    private var starterMixesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Starter mixes")
                .font(.title3.bold())
                .foregroundStyle(.white)

            Text("Use a preset combination as a starting point, then fine tune the levels below.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.76))

            ForEach(viewModel.starterMixes) { starterMix in
                Button {
                    HomeHaptics.impact(.medium)
                    viewModel.applyStarterMix(starterMix)
                    isMixerPresented = true
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(starterMix.title)
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text(starterMix.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.70))
                        }

                        Spacer()

                        Image(systemName: "arrow.up.right.circle.fill")
                            .foregroundStyle(Color(red: 0.80, green: 0.90, blue: 1.0))
                    }
                    .padding(16)
                    .background(Color.white.opacity(0.06))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Starter mix \(starterMix.title)")
                .accessibilityHint("Loads \(starterMix.subtitle)")
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.10), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var soundLibrarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sound library")
                        .font(.title3.bold())
                        .foregroundStyle(.white)

                    Text(viewModel.hasActiveMix ? viewModel.miniPlayerSubtitle : "Choose textures and melodies to build your own scene.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.76))
                }

                Spacer()

                if viewModel.hasActiveMix {
                    Button {
                        HomeHaptics.impact(.light)
                        isMixerPresented = true
                    } label: {
                        Label("Mixer", systemImage: "slider.horizontal.3")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.32, green: 0.57, blue: 0.72))
                    .accessibilityHint("Opens the dedicated mixer panel")
                }
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.sounds) { sound in
                    Button {
                        HomeHaptics.selection()
                        viewModel.toggleSound(sound)
                    } label: {
                        VStack(spacing: 10) {
                            BundlePNGImage(
                                name: sound.isSelected ? sound.selectedArtworkName : sound.normalArtworkName,
                                contentMode: .fit
                            )
                            .frame(height: horizontalSizeClass == .regular ? 104 : 90)
                            .accessibilityHidden(true)

                            Text(sound.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            Text(sound.category)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))

                            Label(sound.isSelected ? "Selected" : "Ready", systemImage: sound.isSelected ? "waveform.circle.fill" : "plus.circle")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(sound.isSelected ? Color(red: 0.76, green: 0.91, blue: 1.0) : .white.opacity(0.7))
                        }
                        .frame(maxWidth: .infinity, minHeight: horizontalSizeClass == .regular ? 184 : 160)
                        .padding()
                        .background(Color.black.opacity(sound.isSelected ? 0.34 : 0.22))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(sound.isSelected ? Color(red: 0.42, green: 0.75, blue: 1.0) : Color.white.opacity(0.10), lineWidth: 1.5)
                        )
                        .shadow(color: sound.isSelected ? Color(red: 0.42, green: 0.75, blue: 1.0).opacity(0.18) : .clear, radius: 18, y: 10)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("\(sound.name), \(sound.category)")
                    .accessibilityValue(sound.isSelected ? "Selected at \(Int(sound.volume * 100)) percent volume" : "Not selected")
                    .accessibilityHint(sound.isSelected ? "Double tap to remove from the mix" : "Double tap to add to the mix")
                }
            }
        }
    }

    private var bottomControlBar: some View {
        VStack(spacing: 0) {
            if viewModel.hasActiveMix {
                HStack(spacing: 14) {
                    Button {
                        HomeHaptics.impact(.light)
                        isMixerPresented = true
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(viewModel.miniPlayerTitle)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)

                            Text(viewModel.miniPlayerSubtitle)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(viewModel.miniPlayerTitle)
                    .accessibilityValue(viewModel.miniPlayerSubtitle)
                    .accessibilityHint("Opens the mixer panel")

                    Button {
                        HomeHaptics.impact(.medium)
                        viewModel.togglePlayback()
                    } label: {
                        Image(systemName: viewModel.isPaused ? "play.fill" : "pause.fill")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.12))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(viewModel.isPaused ? "Resume playback" : "Pause playback")
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                )
            } else {
                Button {
                    HomeHaptics.selection()
                    hasSeenOnboarding = false
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.tap.fill")
                            .foregroundStyle(Color(red: 0.99, green: 0.92, blue: 0.72))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("No active mix")
                                .font(.headline)
                                .foregroundStyle(.white)

                            Text("Tap a sound tile to begin, or reopen tips for a quick tour.")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Spacer()

                        Text("Tips")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 18)
                    .padding(.vertical, 16)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var mixerSheet: some View {
        MixerPanelSheet(viewModel: viewModel)
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.thinMaterial)
    }
}

private struct MixerPanelSheet: View {
    @ObservedObject var viewModel: HomeViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Mixer")
                        .font(.largeTitle.bold())

                    Text("Fine tune active sounds, set a sleep timer, and save the current scene.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    if viewModel.activeSounds.isEmpty {
                        ContentUnavailableView(
                            "Nothing is playing yet",
                            systemImage: "waveform.slash",
                            description: Text("Return to the home screen and tap a sound tile or starter mix.")
                        )
                    } else {
                        HStack(spacing: 12) {
                            Button(viewModel.isPaused ? "Resume playback" : "Pause playback") {
                                HomeHaptics.impact(.medium)
                                viewModel.togglePlayback()
                            }
                            .buttonStyle(.borderedProminent)

                            Menu {
                                ForEach(HomeViewModel.SleepTimerOption.allCases) { option in
                                    Button(option.title) {
                                        HomeHaptics.selection()
                                        viewModel.setSleepTimer(option)
                                    }
                                }
                            } label: {
                                Label(viewModel.sleepTimerOption.title, systemImage: "moon.zzz.fill")
                            }
                            .buttonStyle(.bordered)

                            Button("Clear") {
                                HomeHaptics.notification(.warning)
                                viewModel.clearAll()
                            }
                            .buttonStyle(.bordered)
                        }

                        ForEach(viewModel.activeSounds) { sound in
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(sound.name)
                                            .font(.headline)

                                        Text(sound.category)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text("\(Int(sound.volume * 100))%")
                                        .font(.subheadline.monospacedDigit())
                                        .foregroundStyle(.secondary)
                                }

                                Slider(
                                    value: Binding(
                                        get: { Double(sound.volume) },
                                        set: { viewModel.setVolume(for: sound.id, volume: Float($0)) }
                                    ),
                                    in: 0...1
                                )
                                .accessibilityLabel("\(sound.name) volume")
                                .accessibilityValue("\(Int(sound.volume * 100)) percent")
                            }
                            .padding(16)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("Save this mix")
                                .font(.headline)

                            TextField("Mix name", text: $viewModel.mixName)
                                .textFieldStyle(.roundedBorder)
                                .accessibilityLabel("Mix name")

                            Button("Save Mix") {
                                HomeHaptics.notification(.success)
                                viewModel.saveMix()
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(!viewModel.canSaveMix)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Active Mix")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

private enum HomeHaptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

#Preview {
    HomeView(
        viewModel: HomeViewModel(
            audioEngineManager: AudioEngineManager(),
            mixStore: MixStore(),
            playbackSessionStore: PlaybackSessionStore()
        )
    )
}