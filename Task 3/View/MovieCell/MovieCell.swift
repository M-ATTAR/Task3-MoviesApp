//
//  MovieCell.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit

class MovieCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var movieLabel: UILabel!
    
    let baseURL = "https://image.tmdb.org/t/p/w500"
    var interactor: HomeInteractorProtocol?
    
    // Sets the movie label text and image view once the movie variable has been set also checks for whether the movie is marked as favorite or not and sets the button's image accordingly.
    var movie: Movie! {
        didSet {
            movieLabel.text = movie.original_title
            if let poster = movie.poster_path {
                imageView.downloadImage(from: baseURL + poster)
            } else {
                imageView.image = UIImage(named: "placeholder")
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        imageView.layer.cornerRadius = 15
        imageView.clipsToBounds = true
        
        favButton.setImage(UIImage(systemName: "star"), for: .normal)
        
        // Adds the button functionality. Mark the movie as favorite or unmark it.
        favButton.addAction(UIAction(handler: { [weak self] _ in
            if self?.favButton.currentImage == UIImage(systemName: "star.fill") {
                self?.interactor?.deleteMovieFromRealm(movieName: self?.movie.original_title ?? "ERROR")
                self?.favButton.setImage(UIImage(systemName: "star"), for: .normal)
            } else {
                self?.interactor?.addMovieToFav(movieName: self?.movie.original_title ?? "ERROR", imagePath: self?.movie.poster_path ?? "placeholder")
                self?.favButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            }
        }), for: .touchUpInside)
    }

}
