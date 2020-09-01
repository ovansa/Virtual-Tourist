//
//  DetailImageViewController.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 01/09/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import Hero

class DetailImageViewController: UIViewController {
    @IBOutlet weak var theImage: UIImageView!
    
    var imageName = ""
    var heroID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(imageName)
        
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = document.appendingPathComponent(imageName)
        print(type(of: imagePath))
        print(type(of: imagePath.path))
        
        self.theImage.image = UIImage(contentsOfFile: imagePath.path)
        self.theImage.heroID = imagePath.path
        print(self.theImage.heroID)
    }
    
}
