import SwiftUI

@main
struct LoffeeApp: App {
    @StateObject private var mixStore: MixStore
    @StateObject private var homeViewModel: HomeViewModel

    init() {
        let audioEngineManager = AudioEngineManager()
        let mixStore = MixStore()
        let playbackSessionStore = PlaybackSessionStore()
        _mixStore = StateObject(wrappedValue: mixStore)
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                audioEngineManager: audioEngineManager,
                mixStore: mixStore,
                playbackSessionStore: playbackSessionStore
            )
        )
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                HomeView(viewModel: homeViewModel)
                    .tabItem {
                        Label("Home", systemImage: "waveform")
                    }

                MixesView(viewModel: homeViewModel, mixStore: mixStore)
                    .tabItem {
                        Label("My Mixes", systemImage: "square.stack.3d.up")
                    }
            }
            .tint(Color("AccentColor"))
        }
    }
}