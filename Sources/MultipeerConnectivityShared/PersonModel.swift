//
//  File.swift
//  
//
//  Created by Miguel Costa on 04.07.23.
//

import Foundation

public struct Person: Identifiable, Codable, Equatable {
    public var id = UUID()
    public let name: String
    public let age: Int

    public init(name: String, age: Int) {
        self.name = name
        self.age = age
    }
}


