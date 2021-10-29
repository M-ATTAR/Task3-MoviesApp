//
//  HomeInteractor.swift
//  Task 3
//
//  Created by Mohamed Attar on 28/10/2021.
//

import Foundation

protocol HomeInteractorProtocol: AnyObject {
#warning("Can some functions do some operations without the need to send the presenter anything? Example: deleteAllRealmData, addMovieToFav and deleteMovieFromRealm")
    func fetchData()
    func paginate()
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
    
    func fetchData() {
        
        fetchUpcomingMovies {
            self.fetchPopularMovies {
                self.presenter?.fillCollectionView(movies: self.movies)
            }
        }
    }
    
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
    
    func deleteAllRealmData() {
        worker.deleteAllData()
        presenter?.reloadCollectionView()
    }
    
    func addMovieToFav(movieName: String, imagePath: String) {
        worker.addToFavorites(movieName: movieName, imagePath: imagePath)
        presenter?.reloadCollectionView()
    }
    func isFavourite(movieName: String) -> Bool {
        return worker.isFoundInFavorites(movieName: movieName)
    }
    func deleteMovieFromRealm(movieName: String) {
        worker.deleteMovieFromRealm(movieName: movieName)
        presenter?.reloadCollectionView()
    }
}
