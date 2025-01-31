import SwiftUI

struct RunSummaryView: View {
    let summary: RunSession
    let onDismiss: () -> Void  // ✅ Closure to handle dismissal

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("🏁 Run Summary")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 30) // ✅ Ensure visibility at top

                if summary.distance > 0 {  // ✅ Ensure values exist
                    Text("Distance: \(String(format: "%.2f", summary.distance)) meters")
                        .font(.title2)
                        .foregroundColor(.black) // ✅ Ensures text is visible
                        .padding(.top, 10)

                    Text("Duration: \(String(format: "%.2f", summary.duration)) seconds")
                        .font(.title2)
                        .foregroundColor(.black) // ✅ Ensures text is visible
                        .padding(.top, 10)
                } else {
                    Text("📌 No data available")
                        .font(.title2)
                        .foregroundColor(.gray) // ✅ Display error if data is missing
                        .padding(.top, 20)
                }

                Spacer()

                Button(action: {
                    onDismiss()  // ✅ Dismiss modal & navigate back
                }) {
                    Text("Back to Home")
                        .font(.title2)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 20)  // ✅ Ensure visibility at bottom
                }
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .edgesIgnoringSafeArea(.all) // ✅ Fix potential Safe Area issues
        }
    }
}
