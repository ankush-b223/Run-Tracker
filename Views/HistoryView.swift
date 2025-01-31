import SwiftUI

struct HistoryView: View {
    @State private var runHistory: [RunSession] = [
        RunSession(distance: 2500.0, duration: 1200.0, timestamp: Date()),
        RunSession(distance: 3200.0, duration: 1400.0, timestamp: Date().addingTimeInterval(-86400)),
        RunSession(distance: 5000.0, duration: 1800.0, timestamp: Date().addingTimeInterval(-172800))
    ]

    var body: some View {
        NavigationStack {
            List(runHistory) { run in
                NavigationLink(destination: RunDetailsView(run: run)) {
                    VStack(alignment: .leading) {
                        Text("Run: \(String(format: "%.2f m", run.distance)), \(String(format: "%.2f s", run.duration))")
                            .font(.system(size: 16))
                        Text(run.timestamp.formatted(.dateTime))
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                }
            }
            .navigationTitle("Run History")
        }
    }
}
