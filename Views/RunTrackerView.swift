import SwiftUI
import Combine

struct RunTrackerView: View {
    @StateObject private var runData = RunDataManager.shared
    @StateObject private var stepCounter = StepCounterManager.shared // ✅ Observe StepCounterManager

    @State private var showPermissionAlert = false
    @State private var showSummaryModal = false
    @State private var runSummary: RunSession?
    @Environment(\.dismiss) var dismiss

    var isIndoorRun: Bool  // ✅ Determines if run is indoor or outdoor

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                MetricView(label: "Distance", value: formattedDistance())
                MetricView(label: "Time", value: "\(runData.duration.formatted()) seconds")

                StopButton(action: stopRun)
            }
            .padding()
            .onAppear(perform: checkPermissions)
            .alert("Permission Required", isPresented: $showPermissionAlert) {
                Button("Settings") {
                    guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(url)
                }
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $showSummaryModal, onDismiss: { dismiss() }) {
                if let summary = runSummary {
                    RunSummaryView(summary: summary) {
                        showSummaryModal = false
                        dismiss()
                    }
                }
            }
        }
    }

    // ✅ Fix: Display correct distance based on mode
    private func formattedDistance() -> String {
        if isIndoorRun {
            return "\(stepCounter.distance.formatted()) meters" // ✅ Show indoor step distance
        } else {
            return "\(runData.totalDistance.formatted()) meters" // ✅ Show GPS distance
        }
    }

    private func checkPermissions() {
        if isIndoorRun {
            // ✅ Indoor Run - Check Motion Permissions
            let motionStatus = StepCounterManager.shared.permissionStatus
            if motionStatus == .notDetermined {
                StepCounterManager.shared.requestPermission()
            } else if motionStatus == .denied {
                showPermissionAlert = true
            } else {
                runData.startRun(isIndoorRun: true) // ✅ Start Step Counter
            }
        } else {
            // ✅ Outdoor Run - Check Location Permissions
            let locationStatus = LocationManager.shared.currentPermissionStatus()
            if locationStatus == .notDetermined {
                LocationManager.shared.requestPermission()
            } else if locationStatus == .denied || locationStatus == .restricted {
                showPermissionAlert = true
            } else {
                runData.startRun(isIndoorRun: false) // ✅ Start GPS Tracking
            }
        }
    }

    private func stopRun() {
        runData.stopRun()
        runSummary = runData.generateRunSummary()
        showSummaryModal = true
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
