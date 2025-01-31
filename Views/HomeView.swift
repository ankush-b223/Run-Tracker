import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Title
                Text("WhizRun!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black) // ✅ Ensures text visibility
                    .padding(.top, 40)

                // Start Run Button
                NavigationLink(destination: RunTrackerView()) {
                    Text("Start Run")
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                // View History Button
                NavigationLink(destination: HistoryView()) {
                    Text("View History")
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding()
            .background(Color.white) // ✅ Fixes black screen issue
        }
    }
}

#Preview {
    HomeView()
}
