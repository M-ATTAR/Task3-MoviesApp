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
    var movies: [[Movie]] { get }
    
    func attachView(view: View)
    
    // Moya Functions
    func fetchAll()
    func paginate()
    // Realm Functions
    func addToFavorites(movieName:String, imagePath: String)
    func deleteAllData()
    func deleteMovie(movieName: String)
    func isFoundInFavorites(movieName: String) -> Bool
}


class HomePresenter: HomePresenterProtocol {
    
    var favs: Results<FavMovie> { try! Realm().objects(FavMovie.self) } // Computed Property
    var page = 1
    
    var upcomingMovies = [Movie]()
    var popularMovies = [Movie]()
    var movies: [[Movie]] = [ [], [] ]
    
    let localRealm = try! Realm()
    let provider = MoyaProvider<MovieType>()
    
    typealias View = HomeViewProtocol
    var homeView: HomeViewProtocol?
    
    // Attaches the HomeViewController protocol to the presenter.
    func attachView(view: HomeViewProtocol) {
        
        self.homeView = view
    }
    
    // MARK: - Realm Functions
    
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
        homeView?.reloadCollectionView()
        print(favs)
    }
    
    // Deletes all data from database. (Debug purposes only).
    func deleteAllData() {
        
        try! localRealm.write {
            // Delete all favorite movies.
            localRealm.delete(favs)
        }
        homeView?.reloadCollectionView()
    }
    // Deletes movie from database.
    func deleteMovie(movieName: String) {
        
        let toDelete = favs.filter("movieName == %@", movieName)
        try! localRealm.write {
            localRealm.delete(toDelete)
        }
        homeView?.reloadCollectionView()
    }
    
    // MARK: - Moya Functions.
    
    func paginate() {
        
        page += 1
        fetchMovies(type: .popular(page: page)) {
            //
        }
    }
    
    // Fetches Upcoming & Popular Movies from MovieDB API.
    func fetchAll() {
        
        homeView?.activateLoading() // activates loading animation while fetching data.
        fetchMovies(type: .upcoming) {
            self.fetchMovies(type: .popular(page: self.page) ) {
                self.homeView?.deactivateLoading() // deactivates loading animation after fetching the data from both Upcoming and Popular movies.
            }
        }
    }
    
    func fillData(type: MovieType, movies: Result) {
        
        switch type {
        case .upcoming:
            upcomingMovies = movies.results
            self.movies[0] = upcomingMovies
        case .popular(let page):
            popularMovies = movies.results
            if page == 1 {
                self.movies[1] = popularMovies
            } else {
                self.movies[1].append(contentsOf: popularMovies)
            }
        }
        homeView?.reloadCollectionView()
    }
    
    // Fetches Either Upcoming or Popular Movies from MovieDB API.
    func fetchMovies(type: MovieType, completion: (() -> Void)? = nil) {
        
        provider.request(type) { [weak self] result in
            switch result {
                
            case let .success(moyaResponse):
                do {
                    
                    let decoder = JSONDecoder()
                    let movies = try decoder.decode(Result.self, from: moyaResponse.data)
                    
                    self?.fillData(type: type, movies: movies)
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
