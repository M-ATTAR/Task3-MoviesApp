//
//  FavMovie.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation
import RealmSwift

class FavMovie: Object {
    
    @Persisted var movieName: String
    @Persisted var posterImage: String?
    
    convenience init(name: String, posterImage: String?) {
        self.init()
        self.movieName = name
        self.posterImage = posterImage
    }
}

