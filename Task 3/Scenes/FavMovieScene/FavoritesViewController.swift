//
//  FavoritesViewController.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit
import RealmSwift

protocol FavoritesViewProtocol: AnyObject {
    func loadFavorites(favorites: Results<FavMovie>)
}

class FavoritesViewController: UIViewController {

    @IBOutlet weak var noMoviesLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var interactor: FavoriteSceneInteractorProtocol?
    var favorites: Results<FavMovie>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(UINib(nibName: "FavCell", bundle: nil), forCellWithReuseIdentifier: "FavCell")
        
        interactor?.fetchFav()
    }
    
    func setup() {
        let viewController = self
        let interactor = FavoriteSceneInteractor()
        let presenter = FavoriteScenePresenter()
        
        interactor.presenter = presenter
        presenter.viewController = viewController
        viewController.interactor = interactor
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadCollectionView()
        if favorites.isEmpty {
            collectionView.isHidden = true
            noMoviesLabel.isHidden = false
        } else {
            collectionView.isHidden = false
            noMoviesLabel.isHidden = true
        }
    }
    
    // Creates a UICollectionViewLayout using UICompositionalLayout
    func createCompositionalLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            return self.createFavoriteMoviesSection()
        }
        return layout
    }
    
    // Creates the section holding the Cells and specifies the layout.
    func createFavoriteMoviesSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.333333), heightDimension: .fractionalHeight(1)) // Row holds 3 cells
        
        let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 5)
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(0.333))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        return layoutSection
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavCell", for: indexPath) as! FavCell
        
        let favMovie = favorites[indexPath.row]
        
        cell.movie = favMovie
        cell.interactor = interactor
        
        return cell
    }
}

extension FavoritesViewController: FavoritesViewProtocol {
    func loadFavorites(favorites: Results<FavMovie>) {
        self.favorites = favorites
        reloadCollectionView()
    }
    
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
}
