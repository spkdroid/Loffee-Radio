import SwiftUI
import UIKit

struct MixesView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var mixStore: MixStore
    @State private var renamingMix: Mix?
    @State private var renameText = ""
    @State private var searchText = ""

    private var filteredMixes: [Mix] {
        let orderedMixes = mixStore.mixes.sorted { $0.updatedAt > $1.updatedAt }
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return orderedMixes
        }

        return orderedMixes.filter { mix in
            mix.name.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.24, blue: 0.33), Color(red: 0.05, green: 0.10, blue: 0.16)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {
                    HStack(spacing: 12) {
                        BundlePNGImage(name: "rope_normal", contentMode: .fit)
                            .frame(width: 40, height: 40)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Saved Mixes")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.white)
                            Text("Reload your favorite combinations instantly.")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.75))
                        }

                        Spacer()

                        statPill
                    }

                    if mixStore.mixes.isEmpty {
                        ContentUnavailableView(
                            "No saved mixes",
                            systemImage: "square.stack.3d.up.slash",
                            description: Text("Save a mix from the Home tab to see it here.")
                        )
                        .foregroundStyle(.white)
                    } else if filteredMixes.isEmpty {
                        ContentUnavailableView(
                            "No matching mixes",
                            systemImage: "magnifyingglass",
                            description: Text("Try a broader search term.")
                        )
                        .foregroundStyle(.white)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredMixes) { mix in
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 6) {
                                                Text(mix.name)
                                                    .font(.headline)
                                                    .foregroundStyle(.white)

                                                Text("\(mix.items.count) sounds • Updated \(mix.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.white.opacity(0.72))
                                            }

                                            Spacer()
                                        }

                                        HStack {
                                            Button("Load Mix") {
                                                MixesHaptics.notification(.success)
                                                viewModel.load(mix)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .accessibilityHint("Loads this saved mix into the current session")

                                            Button("Duplicate") {
                                                MixesHaptics.selection()
                                                mixStore.duplicateMix(id: mix.id)
                                            }
                                            .buttonStyle(.bordered)

                                            Button("Rename") {
                                                MixesHaptics.selection()
                                                beginRenaming(mix)
                                            }
                                            .buttonStyle(.bordered)

                                            Button("Delete", role: .destructive) {
                                                MixesHaptics.notification(.warning)
                                                mixStore.deleteMix(id: mix.id)
                                            }
                                            .buttonStyle(.bordered)
                                        }
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(18)
                                    .background(Color.black.opacity(0.24))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
                .padding(18)
            }
            .navigationTitle("My Mixes")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search mixes")
            .alert(
                "Rename Mix",
                isPresented: Binding(
                    get: { renamingMix != nil },
                    set: { if !$0 { renamingMix = nil } }
                )
            ) {
                TextField("Mix name", text: $renameText)

                Button("Save") {
                    if let mixID = renamingMix?.id {
                        mixStore.renameMix(id: mixID, name: renameText)
                    }
                    renamingMix = nil
                }

                Button("Cancel", role: .cancel) {
                    renamingMix = nil
                }
            } message: {
                Text("Choose a clearer name for this saved sound stack.")
            }
        }
    }

    private var statPill: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(mixStore.mixes.count)")
                .font(.headline.weight(.bold))
                .foregroundStyle(.white)
            Text(mixStore.mixes.count == 1 ? "Saved mix" : "Saved mixes")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.72))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func beginRenaming(_ mix: Mix) {
        renamingMix = mix
        renameText = mix.name
    }
}

private enum MixesHaptics {
    static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }
}

#Preview {
    MixesView(
        viewModel: HomeViewModel(
            audioEngineManager: AudioEngineManager(),
            mixStore: MixStore(),
            playbackSessionStore: PlaybackSessionStore()
        ),
        mixStore: MixStore()
    )
}