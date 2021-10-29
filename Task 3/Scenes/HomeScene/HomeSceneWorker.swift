//
//  HomeSceneWorker.swift
//  Task 3
//
//  Created by Mohamed Attar on 28/10/2021.
//

import Foundation
import Moya
import RealmSwift

class HomeSceneWorker {
    
    private let provider = MoyaProvider<MovieType>()
    private let localRealm = try! Realm()
    private var favs: Results<FavMovie> { try! Realm().objects(FavMovie.self) }
    
    // MARK: - Moya Functions
    
    // Fetches Either Upcoming or Popular Movies from MovieDB API.
    func fetchMovies(type: MovieType, completion: @escaping (( [Movie]?, MoyaError? ) -> Void)) {
        
        provider.request(type) { result in
            switch result {
                
            case let .success(moyaResponse):
                do {
                    
                    let decoder = JSONDecoder()
                    let movies = try decoder.decode(Result.self, from: moyaResponse.data)
                    
                    completion(movies.results, nil)
                } catch {
                    print("something went wrong")
                }
            case let .failure(error):
                completion(nil, error)
            }
        }
    }
    
    // MARK: - Realm Functions
    
    // Adds movie to favorites.
    func addToFavorites(movieName:String, imagePath: String) {
        try! localRealm.write {
            let favMovie = FavMovie()
            favMovie.movieName = movieName
            favMovie.posterImage = imagePath
            
            localRealm.add(favMovie)
        }
    }
    
    // Deletes all data from realm. Debugging purposes only.
    func deleteAllData() {
        for fav in favs {
            print(fav.movieName)
        }
        
        try! localRealm.write {
            // Delete all favorite movies.
            localRealm.delete(favs)
        }
    }
    
    // Checks whether passed movie is in Realm database or not.
    func isFoundInFavorites(movieName: String) -> Bool {
        let results = favs.filter("movieName == %@", movieName)
        
        print(results)
        
        if results.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Deletes passed movie from realm.
    func deleteMovieFromRealm(movieName: String) {
        let toDelete = favs.filter("movieName == %@", movieName)
        try! localRealm.write {
            localRealm.delete(toDelete)
        }
    }
    
}
