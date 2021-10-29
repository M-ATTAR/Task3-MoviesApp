//
//  Movie.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation

struct Result: Codable {
    let results: [Movie]
}

struct Movie: Codable {
    let original_title: String
    let poster_path: String?
}
