import SwiftUI

@main
struct YenToUSDApp: App {
    @State private var model = ConverterModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView(model: model)
                .preferredColorScheme(.dark)
        }
        .onChange(of: scenePhase) { _, phase in
            // Fires on launch and whenever the app comes back to the foreground.
            if phase == .active {
                Task { await model.refreshRate() }
            }
        }
    }
}
