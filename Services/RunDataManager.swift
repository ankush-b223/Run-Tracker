import Foundation
import CoreLocation
import Combine

@MainActor
class RunDataManager: ObservableObject {
    static let shared = RunDataManager()

    @Published var locations: [CLLocation] = []
    @Published var startTime: Date?
    @Published var endTime: Date?
    @Published var totalDistance: Double = 0.0
    @Published var duration: TimeInterval = 0.0
    private var cancellables = Set<AnyCancellable>()

    private var lastRecordedLocation: CLLocation?
    private var timer: AnyCancellable?
    private var isIndoorRun = false  // ✅ Track run type

    init() {
        setupSubscriptions()
    }
    
    private func setupSubscriptions() {
        // ✅ Subscribe to location updates (GPS)
        LocationManager.shared.$location
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] newLocation in
                guard let self = self, let location = newLocation, !self.isIndoorRun else { return }
                self.processLocation(location)
            }
            .store(in: &cancellables)

        // ✅ Subscribe to step counter updates (Indoor tracking)
        StepCounterManager.shared.$distance
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newDistance in
                guard let self = self, self.isIndoorRun else { return }
                self.totalDistance = newDistance
            }
            .store(in: &cancellables)
    }

    func startRun(isIndoorRun: Bool) {
        self.isIndoorRun = isIndoorRun
        resetRunData()
        startTimer()
        
        if isIndoorRun {
            StepCounterManager.shared.startTracking()
        } else {
            LocationManager.shared.startTracking()
        }
    }

    func stopRun() {
        endTime = Date()
        timer?.cancel()
        
        if isIndoorRun {
            StepCounterManager.shared.stopTracking()
        } else {
            LocationManager.shared.stopTracking()
        }
    }

    private func processLocation(_ location: CLLocation) {
        guard let last = lastRecordedLocation else {
            updateLocation(location, distance: 0)
            return
        }
        
        let distance = location.distance(from: last)

        guard distance >= 2.0 else {
            print("Ignoring small movement: \(distance)m")
            return
        }

        guard distance <= 50.0 else {
            print("Ignoring GPS drift: \(distance)m")
            return
        }

        updateLocation(location, distance: distance)
    }

    private func updateLocation(_ location: CLLocation, distance: Double) {
        Task { @MainActor in
            locations.append(location)
            lastRecordedLocation = location
            totalDistance += distance
            print("Added location: \(location.coordinate) Δ\(distance)m")
        }
    }

    private func resetRunData() {
        locations.removeAll()
        startTime = Date()
        endTime = nil
        totalDistance = 0.0
        duration = 0.0
        lastRecordedLocation = nil
    }

    private func startTimer() {
        timer = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateDuration()
            }
    }

    private func updateDuration() {
        guard let start = startTime else { return }
        duration = Date().timeIntervalSince(start)
    }

    func generateRunSummary() -> RunSession? {
        guard let start = startTime else { return nil }
        return RunSession(
            distance: totalDistance,
            duration: duration,
            timestamp: start
        )
    }
}
