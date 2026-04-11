import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    private let columns = [
        GridItem(.adaptive(minimum: 104), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                scenicBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        headerCard
                        starterMixesCard
                        soundGrid
                        activeMixer
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Rhythm - Loffee")
            .navigationBarTitleDisplayMode(.inline)
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
                BundlePNGImage(name: "app_icon", contentMode: .fit)
                    .frame(width: 52, height: 52)

                VStack(alignment: .leading, spacing: 4) {
                    Text("Rhythm - Loffee")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)

                    Text("Layer ambient melodies and weather textures into one calm mix.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            HStack {
                Label(viewModel.transportTitle, systemImage: viewModel.transportSystemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color(red: 1.0, green: 0.94, blue: 0.74))

                Spacer()

                if viewModel.hasActiveMix {
                    Button(viewModel.isPaused ? "Resume" : "Pause") {
                        viewModel.togglePlayback()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.30, green: 0.52, blue: 0.67))
                }

                Button("Clear All") {
                    viewModel.clearAll()
                }
                .buttonStyle(.bordered)
                .tint(Color(red: 0.82, green: 0.88, blue: 0.95))
                .disabled(viewModel.activeSounds.isEmpty)
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.18), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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
                    viewModel.applyStarterMix(starterMix)
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

    private var soundGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.sounds) { sound in
                Button {
                    viewModel.toggleSound(sound)
                } label: {
                    VStack(spacing: 10) {
                        BundlePNGImage(
                            name: sound.isSelected ? sound.selectedArtworkName : sound.normalArtworkName,
                            contentMode: .fit
                        )
                        .frame(height: 90)

                        Text(sound.name)
                            .font(.headline)
                            .foregroundStyle(.white)

                        Text(sound.category)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.72))
                    }
                    .frame(maxWidth: .infinity, minHeight: 156)
                    .padding()
                    .background(Color.black.opacity(sound.isSelected ? 0.34 : 0.22))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(sound.isSelected ? Color(red: 0.42, green: 0.75, blue: 1.0) : Color.white.opacity(0.10), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var activeMixer: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Mix")
                .font(.title3.bold())
                .foregroundStyle(.white)

            if viewModel.activeSounds.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Label("No sounds selected", systemImage: "waveform.slash")
                        .font(.headline)
                        .foregroundStyle(.white)

                    Text("Tap a tile above or start from one of the preset mixes to begin building a session.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.72))
                }
            } else {
                HStack(spacing: 12) {
                    Button(viewModel.isPaused ? "Resume playback" : "Pause playback") {
                        viewModel.togglePlayback()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.30, green: 0.52, blue: 0.67))

                    Menu {
                        ForEach(HomeViewModel.SleepTimerOption.allCases) { option in
                            Button(option.title) {
                                viewModel.setSleepTimer(option)
                            }
                        }
                    } label: {
                        Label(viewModel.sleepTimerOption.title, systemImage: "moon.zzz.fill")
                    }
                    .buttonStyle(.bordered)
                    .tint(Color.white.opacity(0.9))
                }

                ForEach(viewModel.activeSounds) { sound in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(sound.name)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(Int(sound.volume * 100))%")
                                .foregroundStyle(.white.opacity(0.72))
                        }

                        Slider(
                            value: Binding(
                                get: { Double(sound.volume) },
                                set: { viewModel.setVolume(for: sound.id, volume: Float($0)) }
                            ),
                            in: 0...1
                        )
                    }
                }

                TextField("Mix name", text: $viewModel.mixName)
                    .textFieldStyle(.roundedBorder)

                Button("Save Mix") {
                    viewModel.saveMix()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.canSaveMix)
            }
        }
        .padding(20)
        .background(Color.black.opacity(0.28))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white.opacity(0.12), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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