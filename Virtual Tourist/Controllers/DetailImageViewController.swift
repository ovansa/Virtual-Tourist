//
//  DetailImageViewController.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 01/09/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit

class DetailImageViewController: UIViewController {
    @IBOutlet weak var theImage: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deletePictureButton: UIButton!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
        print("Back is pressed")
    }
    @IBAction func deleteImagePressed(_ sender: UIButton) {
    }
    
    var imageName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        deletePictureButton.layer.cornerRadius = deletePictureButton.frame.size.height / 2
        
        print(imageName)
        
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = document.appendingPathComponent(imageName)
        print(type(of: imagePath))
        print(type(of: imagePath.path))
        
        self.theImage.image = UIImage(contentsOfFile: imagePath.path)
    }
    
}
