//
//  DetailImageViewController.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 01/09/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import CoreData

class DetailImageViewController: UIViewController {
    @IBOutlet weak var theImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var deletePictureButton: UIButton!
    
    var imageName = ""
    var longLat = ""
    var index = 0
    var savedImages: [String]!
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    @IBAction func deleteImagePressed(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Confirm delete?", message: "Image will be lost", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            self.deleteImage()
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showSelectedImage()
        createRoundButtonStyle()
    }
    
    fileprivate func showSelectedImage() {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imagePath = document.appendingPathComponent(imageName)
        
        self.theImage.image = UIImage(contentsOfFile: imagePath.path)
    }
    
    fileprivate func createRoundButtonStyle() {
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        deletePictureButton.layer.cornerRadius = deletePictureButton.frame.size.height / 2
    }
    
    private func fetchImagesFromStorage() {
        Requests.shared.getImagesFromStorage(basedOn: self.longLat) { (images) in
            self.savedImages = images
            self.savedImages.remove(at: self.index)
            Requests.shared.updateGallery(with: self.longLat, images: self.savedImages)
        }
    }
    
    func deleteImage() {
        Requests.shared.getImagesFromStorage(basedOn: self.longLat) { (images) in
            self.savedImages = images
            print(self.savedImages.count)
            print(self.savedImages!)
            self.savedImages.remove(at: self.index)
            print(self.savedImages.count)
            print(self.savedImages!)
            Requests.shared.updateGallery(with: self.longLat, images: self.savedImages)
            
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}
