import SwiftUI
import Combine

struct RunTrackerView: View {
    @StateObject private var runData = RunDataManager.shared
    @State private var showPermissionAlert = false
    @State private var showSummaryModal = false  // ✅ Added state for modal control
    @State private var runSummary: RunSession?  // ✅ Stores the generated run summary
    @State private var cancellables = Set<AnyCancellable>()
    @Environment(\.dismiss) var dismiss  // ✅ Allows navigation back


    var body: some View {
        NavigationStack {
            
            VStack(spacing: 20) {
                MetricView(label: "Distance", value: "\(runData.totalDistance.formatted()) meters")
                MetricView(label: "Time", value: "\(runData.duration.formatted()) seconds")
                
                StopButton(action: stopRun)
            }
            .padding()
            .onAppear(perform: checkPermissions)
            .alert("Location Permission Required", isPresented: $showPermissionAlert) {
                Button("Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showSummaryModal, onDismiss: { dismiss() }) {  // ✅ Ensure dismissal works
                if let summary = runSummary {
                    RunSummaryView(summary: summary) {
                        showSummaryModal = false  // ✅ Closes the modal when user dismisses
                        dismiss()  // ✅ Ensure it navigates back
                    }
                }
            }
        }
    }
    
    private func checkPermissions() {
        let status = LocationManager.shared.currentPermissionStatus()
        if status == .notDetermined {
            LocationManager.shared.requestPermission()
        } else if status == .denied || status == .restricted {
            showPermissionAlert = true
        } else {
            runData.startRun()
        }
    }
    
    private func stopRun() {
        runData.stopRun()
        runSummary = runData.generateRunSummary()
        showSummaryModal = true  // ✅ Trigger modal when stopping run
    }
}

// MARK: - Subviews
private struct MetricView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack {
            Text(label)
                .font(.headline)
            Text(value)
                .font(.title)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

private struct StopButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("Stop Run")
                .font(.title2)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .foregroundColor(.white)
                .cornerRadius(12)
        }
    }
}
