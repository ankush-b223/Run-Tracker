//
//  User.swift
//  WhizRun
//
//  Created by GRC on 2025/1/27.
//

import Foundation

struct User: Identifiable, Codable {
    let id: Int
    let name: String
    let email: String
}
