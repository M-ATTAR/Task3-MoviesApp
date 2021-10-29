//
//  FavoriteSceneWorker.swift
//  Task 3
//
//  Created by Mohamed Attar on 29/10/2021.
//

import Foundation
import RealmSwift

class FavoriteSceneWorker {
    
    private let localRealm = try! Realm()
    private var favs: Results<FavMovie> { try! Realm().objects(FavMovie.self) } // Computed Property
    
    // Deletes favorite movie from realm database.
    func deleteFav(movieName: String) {
        let toDelete = favs.filter("movieName == %@", movieName)
        try! localRealm.write {
            localRealm.delete(toDelete)
        }
    }
    
    // Fetches favorite movies and pass them using closures.
    func fetchFav(completion: @escaping (Results<FavMovie>) -> Void) {
        completion(favs)
    }
    
}