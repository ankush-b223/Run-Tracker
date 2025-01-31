// RunDataManager.swift
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
    
    private let minDistanceThreshold: Double = 2.0
    private let maxGPSDriftThreshold: Double = 50.0

    init() {
        setupLocationSubscription()
    }
    
    private func setupLocationSubscription() {
        LocationManager.shared.$location
            .receive(on: DispatchQueue.global(qos: .userInitiated))
            .sink { [weak self] newLocation in
                guard let self = self, let location = newLocation else { return }
                self.processLocation(location)
            }
            .store(in: &cancellables)
    }

    func startRun() {
        resetRunData()
        startTimer()
        LocationManager.shared.startTracking()
    }
    
    func stopRun() {
        endTime = Date()
        timer?.cancel()
        LocationManager.shared.stopTracking()
    }
    
    private func processLocation(_ location: CLLocation) {
        guard let last = lastRecordedLocation else {
            updateLocation(location, distance: 0)
            return
        }
        
        let distance = location.distance(from: last)
        
        guard distance >= minDistanceThreshold else {
            print("Ignoring small movement: \(distance)m")
            return
        }
        
        guard distance <= maxGPSDriftThreshold else {
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
