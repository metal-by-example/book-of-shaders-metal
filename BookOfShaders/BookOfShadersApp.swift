import SwiftUI

@main
struct BookOfShadersApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ShaderEditorModel())
                .navigationTitle("Book of Shaders")
        }
        .commands {
            SidebarCommands()
        }
    }
}
