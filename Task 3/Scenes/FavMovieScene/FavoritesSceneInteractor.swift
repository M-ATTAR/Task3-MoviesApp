//
//  FavoritesSceneInteractor.swift
//  Task 3
//
//  Created by Mohamed Attar on 29/10/2021.
//

import Foundation


protocol FavoriteSceneInteractorProtocol {
    func fetchFav()
    func deleteMovieFromFav(movieName: String)
}

class FavoriteSceneInteractor: FavoriteSceneInteractorProtocol {
    
    var worker = FavoriteSceneWorker()
    var presenter: FavoriteScenePresenterProtocol?
    
    func fetchFav() {
        worker.fetchFav { fav in
            self.presenter?.loadFavorites(favorites: fav)
        }
    }
    
    func deleteMovieFromFav(movieName: String) {
        worker.deleteFav(movieName: movieName)
        fetchFav()
    }
}
