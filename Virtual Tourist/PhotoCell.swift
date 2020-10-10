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
    
    func configures(image: String) {
        self.photoImageView.image =  #imageLiteral(resourceName: "VirtualTourist_76.png")
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(image)
        self.photoImageView.image = UIImage(contentsOfFile: imagePath.path)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImageView.image = #imageLiteral(resourceName: "VirtualTourist_120")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
    }
    
}
