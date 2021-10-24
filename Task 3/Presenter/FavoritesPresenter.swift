//
//  FavoritesPresenter.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import Foundation
import RealmSwift

protocol FavoritePresenterProtocol {
    associatedtype View
    
    var favs: Results<FavMovie> { get }
    
    func attachView(view: View)
    func updateFavs()
    func deleteFav(movieName: String)
}


class FavoritesPresenter: FavoritePresenterProtocol {
   
    let localRealm = try! Realm()
    
    var favs: Results<FavMovie> = try! Realm().objects(FavMovie.self)
    
    typealias View = FavoritesViewProtocol
    var favView: FavoritesViewProtocol?
    
    func attachView(view: FavoritesViewProtocol) {
        self.favView = view
    }
    func updateFavs() {
        favs = localRealm.objects(FavMovie.self)
        favView?.reloadCollectionView()
    }
    func deleteFav(movieName: String) {
        let toDelete = favs.filter("movieName == %@", movieName)
        try! localRealm.write {
            localRealm.delete(toDelete)
        }
        updateFavs()
    }
}
