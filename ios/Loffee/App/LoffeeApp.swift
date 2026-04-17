import SwiftUI

@main
struct LoffeeApp: App {
    @StateObject private var mixStore: MixStore
    @StateObject private var homeViewModel: HomeViewModel
    @StateObject private var yogaViewModel: YogaViewModel

    init() {
        let audioEngineManager = AudioEngineManager()
        let mixStore = MixStore()
        let playbackSessionStore = PlaybackSessionStore()
        let yogaProgressStore = YogaProgressStore()
        _mixStore = StateObject(wrappedValue: mixStore)
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                audioEngineManager: audioEngineManager,
                mixStore: mixStore,
                playbackSessionStore: playbackSessionStore
            )
        )
        _yogaViewModel = StateObject(wrappedValue: YogaViewModel(progressStore: yogaProgressStore))
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

                YogaView(viewModel: yogaViewModel)
                    .tabItem {
                        Label("Yoga", systemImage: "figure.mind.and.body")
                    }
            }
            .tint(Color("AccentColor"))
        }
    }
}