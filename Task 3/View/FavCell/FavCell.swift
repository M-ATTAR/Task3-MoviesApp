//
//  FavCell.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit

class FavCell: UICollectionViewCell {

    @IBOutlet weak var movieImage: UIImageView!
    let baseURL = "https://image.tmdb.org/t/p/w500"
    var interactor: FavoriteSceneInteractorProtocol?
    
    // Sets the favorite movie image once the variable has been set.
    var movie: FavMovie! {
        didSet {
            if let poster = movie.posterImage {
                movieImage.downloadImage(from: baseURL + poster)
            } else {
                movieImage.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        movieImage.layer.cornerRadius = 15
        movieImage.clipsToBounds = true
    }
    @IBAction func deleteTapped(_ sender: UIButton) {
        interactor?.deleteMovieFromFav(movieName: movie.movieName)
    }
    
}
