//
//  SearchRequest.swift
//  Places
//
//  Created by Edward Siu on 4/22/18.
//  Copyright © 2018 asm. All rights reserved.
//

import Foundation

struct SearchRequest: Codable {
    let keyword: String
    let lat: Double
    let lon: Double
    let radius: Double
    let category: String
}

struct DetailRequest: Codable {
    let placeid: String
}
