import SwiftUI
import Combine

@main
struct ZellijApp: App {
    var body: some Scene {
        WindowGroup {
            ConstructionCircleView(store: ConstructionCircleStore(timer: ZellijApp.animationTimer))
                .frame(width: 400, height: 400)
                .background(Color.blueprint)
                .padding()
        }
    }
}

extension ZellijApp {
    static var animationTimer: Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer
            .publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
    }
}
