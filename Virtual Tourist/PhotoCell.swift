//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 15/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configure(photo: Photo) {
        Requests.shared.downloadImage(fromLink: "https://farm\(String(photo.farm)).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg") { (image) in
            self.photoImageView.image = image
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
