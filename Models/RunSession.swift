//
//  RunSession.swift
//  WhizRun
//
//  Created by GRC on 2025/1/27.
//

import Foundation

struct RunSession: Identifiable, Codable {
    let id: UUID
    let distance: Double
    let duration: TimeInterval
    let timestamp: Date

    init(id: UUID = UUID(), distance: Double, duration: TimeInterval, timestamp: Date) {
        self.id = id
        self.distance = distance
        self.duration = duration
        self.timestamp = timestamp
    }
}
