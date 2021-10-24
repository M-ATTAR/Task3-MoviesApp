//
//  HomePresenter.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation
import Moya
import RealmSwift

protocol HomePresenterProtocol {
    associatedtype View
    
//    var favs: Results<FavMovie> { get }
    
    func attachView(view: View)
    func fetchAll()
    func updateFavorites()
    func addToFavorites(movieName:String, imagePath: String)
    func deleteAllData()
    func deleteMovie(movieName: String)
    func isFoundInFavorites(movieName: String) -> Bool
}


class HomePresenter: HomePresenterProtocol {
    
    let localRealm = try! Realm()
    
    var favs: Results<FavMovie> = try! Realm().objects(FavMovie.self)
    
    let provider = MoyaProvider<MovieType>()
    
    typealias View = HomeViewProtocol
    var homeView: HomeViewProtocol?
    
    // Attaches the HomeViewController protocol to the presenter.
    func attachView(view: HomeViewProtocol) {
        self.homeView = view
    }
    
    // MARK: - Realm Functions
    
    // Updates the favs variable with the movies marked as favorite.
    func updateFavorites() {
        favs = localRealm.objects(FavMovie.self)
        homeView?.reloadCollectionView()
    }
    // Checks if the movie exists in the database.
    func isFoundInFavorites(movieName: String) -> Bool {
        let results = favs.filter("movieName == %@", movieName)
        
        print(results)
        
        if results.count > 0 {
            return true
        } else {
            return false
        }
    }
    
    // Adds a new movie to database.
    func addToFavorites(movieName:String, imagePath: String) {
        try! localRealm.write {
            let favMovie = FavMovie()
            favMovie.movieName = movieName
            favMovie.posterImage = imagePath
            
            localRealm.add(favMovie)
        }
        updateFavorites()
        
        print(favs)
    }
    
    // Deletes all data from database. (Debug purposes only).
    func deleteAllData() {
        try! localRealm.write {
            // Delete the LocalOnlyQsTask.
            localRealm.delete(favs)
        }
        updateFavorites()
    }
    // Deletes movie from database.
    func deleteMovie(movieName: String) {
        let toDelete = favs.filter("movieName == %@", movieName)
        try! localRealm.write {
            localRealm.delete(toDelete)
        }
        updateFavorites()
    }
    
    // MARK: - Moya Functions.
    
    // Fetches Upcoming & Popular Movies from MovieDB API.
    func fetchAll() {
        homeView?.activateLoading() // activates loading animation while fetching data.
        fetchMovies(type: .upcoming) {
            self.fetchMovies(type: .popular) {
                self.homeView?.deactivateLoading() // deactivates loading animation after fetching the data from both Upcoming and Popular movies.
            }
        }
    }
    
    // Fetches Either Upcoming or Popular Movies from MovieDB API.
    func fetchMovies(type: MovieType, completion: (() -> Void)? = nil) {
        provider.request(type) { [weak self] result in
            switch result {
            case let .success(moyaResponse):
                
                do {
                    let decoder = JSONDecoder()
                    let movies = try decoder.decode(Result.self, from: moyaResponse.data)
                    
                    self?.homeView?.reloadCollectionView(type: type, movies: movies) // Reloads collection view in the HomeViewController; it specifies which movie type has been requested to update its array and passes the data after decoding it.
                    
                } catch {
                    print("something went wrong")
                    self?.homeView?.deactivateLoading()
                }
                if let completion = completion {
                    completion() // Completion handler; its purpose is to allow for another network call or for deactivating the loading animation once the request has been done.
                }
            case let .failure(error):
                self?.homeView?.deactivateLoading()
                if error.errorCode == 6 { // Alerts the user that their internet connection is off.
                    self?.homeView?.errorAlert(title: "Something unexpected happened", message: "Internet connection seems to be off. Please try again later.")
                } else { // Alerts the user that something wrong happened while making the network call.
                    self?.homeView?.errorAlert(title: "Something unexpected happened", message: error.errorDescription!)
                }
            }
        }
    }
}
