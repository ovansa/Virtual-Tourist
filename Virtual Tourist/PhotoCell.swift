//
//  PhotoCell.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 15/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import Hero

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var photoImageView: UIImageView!
    
    func configure(photo: Photo) {
        Requests.shared.downloadImage(fromLink: "https://farm\(String(photo.farm)).staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).jpg") { (image) in
            self.photoImageView.image = image
        }
    }
    
    func configures(image: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        self.photoImageView.image =  #imageLiteral(resourceName: "VirtualTourist_76.png")
        let imagePath = document.appendingPathComponent(image)
        self.photoImageView.image = UIImage(contentsOfFile: imagePath.path) ?? #imageLiteral(resourceName: "VirtualTourist_76.png")
//        self.photoImageView.heroID = String(imagePath.path)
//        print(String(self.photoImageView.heroID ?? ""))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 5.0
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.masksToBounds = true
        
//         cell shadow section
//        self.contentView.layer.cornerRadius = 15.0
//        self.contentView.layer.borderWidth = 5.0
//        self.contentView.layer.borderColor = UIColor.clear.cgColor
//        self.contentView.layer.masksToBounds = true
//        self.layer.shadowColor = UIColor.white.cgColor
//        self.layer.shadowOffset = CGSize(width: 0, height: 0.0)
//        self.layer.shadowRadius = 6.0
//        self.layer.shadowOpacity = 0.6
//        self.layer.cornerRadius = 15.0
//        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath
        
    }
    
}
