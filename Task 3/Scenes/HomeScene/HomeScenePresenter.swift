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
    
    func showError(error: MoyaError) {
        // Call ViewController for error
        viewController?.errorAlert(title: "Something wrong happened", message: error.localizedDescription)
    }
    
    func fillCollectionView(movies: [[Movie]]) {
        // call viewcontroller to fill movies
        viewController?.fillCollectionView(movies: movies)
        viewController?.deactivateLoading()
    }
    
    func reloadCollectionView() {
        viewController?.reloadCollectionView()
    }
}
