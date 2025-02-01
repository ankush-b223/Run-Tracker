import CoreMotion
import Combine

class StepCounterManager: ObservableObject {
    static let shared = StepCounterManager()
    private let pedometer = CMPedometer()
    private var isTracking = false
    
    @Published var stepCount: Int = 0
    @Published var distance: Double = 0.0
    @Published var permissionStatus: CMAuthorizationStatus = CMPedometer.authorizationStatus() // ✅ Added state to track permissions

    private var cancellables = Set<AnyCancellable>()
    
    private init() {}

    // ✅ Request permission before using the pedometer
    func requestPermission() {
        if CMPedometer.authorizationStatus() == .notDetermined {
            // Apple does not provide an explicit `requestPermission` function.
            // We have to call `queryPedometerData` to trigger the system permission prompt.
            pedometer.queryPedometerData(from: Date(), to: Date()) { _, _ in
                DispatchQueue.main.async {
                    self.permissionStatus = CMPedometer.authorizationStatus() // ✅ Update status after request
                }
            }
        } else {
            // If permission is already set, update status immediately
            permissionStatus = CMPedometer.authorizationStatus()
        }
    }
    
    func startTracking() {
        guard CMPedometer.isStepCountingAvailable(), permissionStatus == .authorized, !isTracking else {
            print("❌ Motion tracking permission not granted or step counting not available")
            return
        }
        isTracking = true
        let fromDate = Date()
        
        print("✅ StepCounterManager started tracking")
        
        pedometer.startUpdates(from: fromDate) { [weak self] data, error in
            guard let self = self, let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.stepCount = data.numberOfSteps.intValue
                if let distance = data.distance?.doubleValue {
                    self.distance = distance
                    print("📊 Steps: \(self.stepCount), Distance: \(self.distance)m")

                }
            }
        }
    }
    
    func stopTracking() {
        guard isTracking else { return }
        pedometer.stopUpdates()
        isTracking = false
    }
}
