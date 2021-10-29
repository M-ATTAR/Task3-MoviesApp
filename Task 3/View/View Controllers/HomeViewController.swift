//
//  ViewController.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit

protocol HomeViewProtocol {
//    func reloadCollectionView(type: MovieType, movies: Result)
    func reloadCollectionView()
    func activateLoading()
    func deactivateLoading()
    func errorAlert(title: String, message: String)
}

class HomeViewController: UIViewController {
    
    var homePresenter = HomePresenter() // Presenter instance.

    let waitingAlert = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homePresenter.attachView(view: self) // Attaches the HomeViewControllerProtocol to the Presenter.
        
        collectionView.collectionViewLayout = createCompositionalLayout()
        
        collectionView.register(UINib(nibName: "MovieCell", bundle: nil), forCellWithReuseIdentifier: "MovieCell")
        
        // Registers the section header nib.
        collectionView.register(UINib(nibName: "SectionHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        homePresenter.fetchAll() // Fetches both Upcoming and Popular movies from the API.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        reloadCollectionView()
    }
    @IBAction func deleteAllData(_ sender: UIBarButtonItem) {
        
        homePresenter.deleteAllData() // Deletes all data (debugging purposes only).
    }
    
    // Creates compositional layout for UICollectionViewLayout and splits the collectionview into two sections one for the upcoming movies and one for the popular movies.
    func createCompositionalLayout() -> UICollectionViewLayout {
        
        let layout = UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            switch sectionIndex {
            case 0:
                return self.createUpcomingMoviesSection()
            default:
                return self.createPopularMoviesSection()
            }
        }
        
        let config                  = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing  = 10 // gives 10 pts space between sections.
        layout.configuration        = config
        return layout
    }
    
    // Creates the LayoutSection for the upcoming movies section
    func createUpcomingMoviesSection() -> NSCollectionLayoutSection {
        
        let itemSize                                = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.50), heightDimension: .fractionalHeight(1))
        
        let layoutItem                              = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets                    = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
        
        let layoutGroupSize                         = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(280))
        let layoutGroup                             = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection                           = NSCollectionLayoutSection(group: layoutGroup)
        layoutSection.orthogonalScrollingBehavior   = .continuousGroupLeadingBoundary
        let layoutSectionHeader                     = createSectionHeader()
        layoutSection.boundarySupplementaryItems    = [layoutSectionHeader]
        return layoutSection
    }
    
    // Creates the LayoutSection for the popular movies section
    func createPopularMoviesSection() -> NSCollectionLayoutSection {
        
        let itemSize                                = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
        
        let layoutItem                              = NSCollectionLayoutItem(layoutSize: itemSize)
        layoutItem.contentInsets                    = NSDirectionalEdgeInsets(top: 7, leading: 5, bottom: 0, trailing: 5)
        
        let layoutGroupSize                         = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(310))
        let layoutGroup                             = NSCollectionLayoutGroup.horizontal(layoutSize: layoutGroupSize, subitems: [layoutItem])
        
        let layoutSection                           = NSCollectionLayoutSection(group: layoutGroup)
        let layoutSectionHeader                     = createSectionHeader()
        layoutSection.boundarySupplementaryItems    = [layoutSectionHeader]
        return layoutSection
    }
    
    // creates the section header which displays either Upcoming Movies or Popular Movies.
    func createSectionHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        
        let layoutSectionHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.93), heightDimension: .estimated(30))
        let layoutSectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: layoutSectionHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        return layoutSectionHeader
    }
    
    
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as? SectionHeader {
            // Displays the SectionHeader label text according to the section index.
            if indexPath.section == 0 {
                sectionHeader.sectionHeader = "Upcoming Movies"
            } else {
                sectionHeader.sectionHeader = "Popular Movies"
            }
            return sectionHeader
        }
        return UICollectionReusableView()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return homePresenter.movies.count
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return homePresenter.movies[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MovieCell", for: indexPath) as! MovieCell
        
        let movie = homePresenter.movies[indexPath.section][indexPath.row]
        
        if homePresenter.isFoundInFavorites(movieName: movie.original_title) {
            cell.favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
        } else {
            cell.favButton.setImage(UIImage(systemName: "star"), for: .normal)
        }

        cell.movie = movie
        cell.homePresenter = homePresenter
        
        return cell
    }
    
    // Pagination functionality.
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height // Entire ScrollView
        let height = scrollView.frame.size.height // Height of the screen
        
        if offsetY > contentHeight - height {
            homePresenter.paginate()
        }
    }
}

extension HomeViewController: HomeViewProtocol {
    
    // Presents UIAlertController when the Presenters calls it to tell the user that something wrong happened. Dismisses the waiting alert first to not overlap.
    func errorAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            
            self.waitingAlert.dismiss(animated: true) {
                self.present(alertVC, animated: true)
            }
        }
    }
    
    // Activates the loading animation when the presenter calls it.
    func activateLoading() {
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        waitingAlert.view.addSubview(loadingIndicator)
        
        if waitingAlert.isBeingPresented { // Checks if the alert is being already displayed to not overlap.
            return
        }
        present(waitingAlert, animated: true, completion: nil)
    }
    
    // Deactivates the loading animation when the presenter calls it.
    func deactivateLoading() {
        DispatchQueue.main.async {
            self.waitingAlert.dismiss(animated: true, completion: nil)
        }
    }

    // Reloads the collection view without any data.
    func reloadCollectionView() {
        collectionView.reloadData()
    }
}
