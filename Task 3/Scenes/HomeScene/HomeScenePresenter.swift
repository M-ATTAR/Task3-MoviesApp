//
//  HomeScenePresenter.swift
//  Task 3
//
//  Created by Mohamed Attar on 28/10/2021.
//

import Foundation
import Moya

protocol HomeScenePresenterProtocol: AnyObject {
    func showError(error: MoyaError)
    func fillCollectionView(movies: [[Movie]])
    func reloadCollectionView()
}

class HomeScenePresenter: HomeScenePresenterProtocol {
    
    weak var viewController: HomeViewProtocol?
    
    // Displays an Alert Controller with the error message.
    func showError(error: MoyaError) {
        viewController?.errorAlert(title: "Something wrong happened", message: error.localizedDescription)
    }
    
    // Fills the collection view with data passed from the Interactor and deactivates loading animation.
    func fillCollectionView(movies: [[Movie]]) {
        // call viewcontroller to fill movies
        viewController?.fillCollectionView(movies: movies)
        viewController?.deactivateLoading()
    }
    
    // Reloads the collection view.
    func reloadCollectionView() {
        viewController?.reloadCollectionView()
    }
}
