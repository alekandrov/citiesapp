import SwiftUI

@main
struct CitiesApp: App {
    @StateObject private var appVM = AppViewModel()
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appVM)
                .preferredColorScheme(appVM.appliedScheme())
        }
    }
}

struct RootView: View {
    @State private var showSplash = true

    var body: some View {
        Group {
            if showSplash {
                SplashView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                showSplash = false
                            }
                        }
                    }
            } else {
                CityListView()
            }
        }
    }
}

struct SplashView: View {
    var body: some View {
        ZStack {
            Color("LaunchBackground").ignoresSafeArea()
            VStack(spacing: 12) {
                Image(systemName: "map")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120)
                Text("CitiesApp")
                    .font(.title2).bold()
                    .opacity(0.85)
            }
        }
    }
}
