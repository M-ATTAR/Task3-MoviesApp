//
//  HomeInteractor.swift
//  Task 3
//
//  Created by Mohamed Attar on 28/10/2021.
//

import Foundation

protocol HomeInteractorProtocol: AnyObject {
#warning("Can some functions do some operations without the need to send the presenter anything? Example: deleteAllRealmData, addMovieToFav and deleteMovieFromRealm")
    
    // Moya Functions
    func fetchData()
    func paginate()
    
    // Realm Functions
    func deleteAllRealmData()
    func addMovieToFav(movieName: String, imagePath: String)
    func isFavourite(movieName: String) -> Bool
    func deleteMovieFromRealm(movieName: String)
}

class HomeSceneInteractor: HomeInteractorProtocol {

    var worker = HomeSceneWorker()
    var presenter: HomeScenePresenterProtocol?

    var movies: [[Movie]] = [ [], [] ]
    
    var page = 1
    
    // MARK: - Moya Functions
    
    // Fetches the data from Moya using worker functions.
    func fetchData() {
        
        fetchUpcomingMovies {
            self.fetchPopularMovies {
                self.presenter?.fillCollectionView(movies: self.movies)
            }
        }
    }
    
    // Fetches Upcoming movies and add them to the array.
    func fetchUpcomingMovies(completion: @escaping () -> Void) {
        worker.fetchMovies(type: .upcoming) { movies, error in
            guard let movies = movies else {
                self.presenter?.showError(error: error!)
                return
            }
            self.movies[0] = movies
            completion()
        }
    }
    
    // Fetches the first page of the Popular movies and adds them to the array.
    func fetchPopularMovies(completion: @escaping () -> Void) {
        worker.fetchMovies(type: .popular(page: 1)) { movies, error in
            guard let movies = movies else {
                self.presenter?.showError(error: error!)
                return
            }
            self.movies[1] = movies
            completion()
        }
    }
    
    // Fetches pages beyond the first page with every pagination call and appends them to the array.
    func paginate() {
        page += 1
        worker.fetchMovies(type: .popular(page: page), completion: { movies, error in
            guard let movies = movies else {
                self.presenter?.showError(error: error!)
                return
            }
            self.movies[1].append(contentsOf: movies)
            self.presenter?.fillCollectionView(movies: self.movies)
        })
    }
    
    // MARK: - Realm Functions
    
    // Deletes all realm data. (For debugging purposes only).
    func deleteAllRealmData() {
        worker.deleteAllData()
        presenter?.reloadCollectionView()
    }
    
    // Adds movie to favorites using worker functions
    func addMovieToFav(movieName: String, imagePath: String) {
        worker.addToFavorites(movieName: movieName, imagePath: imagePath)
        presenter?.reloadCollectionView()
    }
    // Checks whether passed movie is marked as favorite or not.
    func isFavourite(movieName: String) -> Bool {
        return worker.isFoundInFavorites(movieName: movieName)
    }
    // Deletes the passed movie from realm database.
    func deleteMovieFromRealm(movieName: String) {
        worker.deleteMovieFromRealm(movieName: movieName)
        presenter?.reloadCollectionView()
    }
}
