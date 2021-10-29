//
//  Movie.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation

struct Result: Codable {
    var results: [Movie]
}

struct Movie: Codable {
    var original_title: String
    var poster_path: String?
}
