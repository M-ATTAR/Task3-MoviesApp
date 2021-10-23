//
//  FavoritesViewController.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit

protocol FavoritesViewProtocol {
    func reloadCollectionView()
}

class FavoritesViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var favPresenter = FavoritesPresenter() // Presenter instance.
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favPresenter.attachView(view: self) // Attaching the ViewController Protocol to the Presenter.
        
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(UINib(nibName: "FavCell", bundle: nil), forCellWithReuseIdentifier: "FavCell")
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favPresenter.updateFavs() // Updates the array holding the favorite movies from the database every time the view is displayed on the screen.
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
        
        let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(200))
        let layoutGroup = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
        return layoutSection
    }
}

extension FavoritesViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favPresenter.favs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavCell", for: indexPath) as! FavCell
        
        let favMovie = favPresenter.favs[indexPath.row]
        
        cell.movie = favMovie
        
        return cell
    }
}

extension FavoritesViewController: FavoritesViewProtocol {
    func reloadCollectionView() {
        self.collectionView.reloadData()
    }
}
