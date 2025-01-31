import SwiftUI

struct RunDetailsView: View {
    let run: RunSession

    var body: some View {
        VStack(spacing: 20) {
            // Distance
            Text("Distance: \(String(format: "%.2f", run.distance)) meters")
                .font(.system(size: 20))

            // Duration
            Text("Duration: \(String(format: "%.2f", run.duration)) seconds")
                .font(.system(size: 20))

            // Average Speed
            Text("Avg Speed: \(String(format: "%.2f", run.distance / run.duration)) m/s")
                .font(.system(size: 20))

            // Timestamp
            Text("Date: \(run.timestamp.formatted(.dateTime))")
                .font(.system(size: 18))
                .foregroundColor(.gray)

            Spacer()
        }
        .padding()
        .navigationTitle("Run Details")
    }
}
