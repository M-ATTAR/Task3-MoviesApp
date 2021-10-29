//
//  FavoritesScenePresenter.swift
//  Task 3
//
//  Created by Mohamed Attar on 29/10/2021.
//

import Foundation
import RealmSwift

protocol FavoriteScenePresenterProtocol {
    func loadFavorites(favorites: Results<FavMovie>)
}

class FavoriteScenePresenter: FavoriteScenePresenterProtocol {
    
    weak var viewController: FavoritesViewProtocol?
    
    // Loads favorite movies passed by the interactor to the viewcontroller.
    func loadFavorites(favorites: Results<FavMovie>) {
        viewController?.loadFavorites(favorites: favorites)
    }
}
