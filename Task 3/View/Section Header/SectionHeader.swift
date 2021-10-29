//
//  SectionHeader.swift
//  Task 3
//
//  Created by Mohamed Attar on 22/10/2021.
//

import UIKit

class SectionHeader: UICollectionReusableView {

    @IBOutlet weak var sectionLabel: UILabel!
    
    var sectionHeader: String! {
        didSet {
            sectionLabel.text = sectionHeader
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
}
