import SwiftUI

struct HomeView: View {
    @State private var isIndoorRun = false  // ✅ Toggle for indoor/outdoor mode

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("WhizRun!")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.top, 40)

                Toggle("Indoor Run", isOn: $isIndoorRun)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)

                NavigationLink(destination: RunTrackerView(isIndoorRun: isIndoorRun)) {
                    Text("Start Run")
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isIndoorRun ? Color.green : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: HistoryView()) {
                                    Text("View History")
                                        .font(.system(size: 20))
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.gray)
                                        .foregroundColor(.white)
                                        .cornerRadius(10)
                                }


                Spacer()
            }
            .padding()
            .background(Color.white)
        }
    }
}
