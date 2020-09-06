//
//  PhotoAlbum.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 13/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import MBProgressHUD


class PhotoAlbum: UIViewController {
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNewCollection: UIButton!
    @IBOutlet weak var viewForCollectionView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    var annotationSegue: MKAnnotationView!
    let locationManager = CLLocationManager()
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    let photoIdentifier = "PhotoCell"
    var photos = [Photo]()
    var savedImages = [String]()
    var isImage: Bool = false
    var photoDirUrl = [String]()
    var longLat: String!
    
    var defaultNoOfPictures: Int = 40
    
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        print("Delete is pressed")
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
        print("Back is pressed")
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        refreshImagesForLocation()
    }
    
    fileprivate func refreshImagesForLocation() {
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        self.refreshButton.isEnabled = false
        print("Fetching new image")
        self.collectionView.showLoader()
        
        Requests.shared.getImageDataFromLocation(lat: latitude, lon: longitude) { (response) in
            if response.count == 0 {
                self.setEmptyStateForNoImage()
            } else {
                if response.count < self.defaultNoOfPictures {
                    self.photos = Array(response[0...response.count])
                    let phot = Array(response[0..<response.count])
                    self.getImagesFromUrl(from: phot) { (pictures) in
                    
                        Requests.shared.updateSavedGallery(with: self.longLat, images: pictures) { (updatedImages) in
                            self.savedImages = updatedImages
                            self.refreshButton.isEnabled = true
                            
                            print("Image have been saved to cache1")
                            print(updatedImages)
                            
                            self.collectionView.reloadData()
                            self.collectionView.hideLoader()
                        }
                    }
                } else {
                    self.photos = Array(response[0...self.defaultNoOfPictures])
                    let phot = Array(response[0...self.defaultNoOfPictures])
                    self.getImagesFromUrl(from: phot) { (pictures) in
                        
                        Requests.shared.updateSavedGallery(with: self.longLat, images: pictures) { (updatedImages) in
                            self.savedImages = updatedImages
                            self.refreshButton.isEnabled = true
                            
                            print("Image have been saved to cache1")
                            print(updatedImages)
                            self.collectionView.reloadData()
                            self.collectionView.hideLoader()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func newCollection(_ sender: Any) {
        refreshImagesForLocation()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        backButton.layer.cornerRadius = backButton.frame.size.height / 2
        refreshButton.layer.cornerRadius = refreshButton.frame.size.height / 2
        
        deleteButton.layer.cornerRadius = deleteButton.frame.size.height / 2
        
        let anotation = MKPointAnnotation()
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        let longString = String(longitude)
        let latString = String(latitude)
        
        self.longLat = longString + latString
        
        fetchImage()
        
        anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        albumMapView.addAnnotation(anotation)
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        albumMapView.mapType = .standard
        
        centerViewOnLocation(location: myLocation)
        setUpCollectionView()
        
    }
    
    fileprivate func fetchImagesFromStorage() {
        self.collectionView.showLoader()
        Requests.shared.getImagesFromStorage(basedOn: self.longLat) { (images) in
            self.savedImages = images
            self.refreshButton.isEnabled = true
            self.collectionView.hideLoader()
        }
    }
    
    fileprivate func fetchImage() {
        /**
         Checks if location images does not exists in core data, and makes a network request
         Else, location images are fetched from device storage
         */
        Requests.shared.isImageTitleEmpty(basedOn: self.longLat) { (empty) in
            if empty {
                self.isImage = empty
                self.makeFreshRequestForImages()
            } else {
                self.isImage = empty
                self.fetchImagesFromStorage()
                
            }
        }
    }
    
    fileprivate func setEmptyStateForNoImage() {
        self.refreshButton.isEnabled = true
        self.collectionView.setEmptyMessage("There is no image for this location :(")
        print("There is no image for this location")
    }
    
    fileprivate func makeFreshRequestForImages() {
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        self.collectionView.showLoader()
        
        Requests.shared.getImageDataFromLocation(lat: latitude, lon: longitude) { (response) in
            if response.count == 0 {
            
                self.setEmptyStateForNoImage()
                self.collectionView.hideLoader()
            } else {
                // Fetch Images and save images to device storage
                // Then save the image location as an array in core data
                if response.count < self.defaultNoOfPictures {
                    self.photos = Array(response[0...response.count-1])
                    let phot = Array(response[0..<response.count])
                    self.getImagesFromUrl(from: phot) { (pictures) in
                        let images = Images(context: Persistence.context)
                        images.name = self.longLat
                        images.imageList = pictures
                        Persistence.saveContext()
                        self.savedImages = pictures
                        self.refreshButton.isEnabled = true
                        
                        print("Image have been saved to cache1")
                        print(pictures)
                        self.collectionView.reloadData()
                        self.collectionView.hideLoader()
                    }
                } else {
                    self.photos = Array(response[0...self.defaultNoOfPictures])
                    let phot = Array(response[0...self.defaultNoOfPictures])
                    self.getImagesFromUrl(from: phot) { (pictures) in
                        let images = Images(context: Persistence.context)
                        images.name = self.longLat
                        images.imageList = pictures
                        Persistence.saveContext()
                        self.savedImages = pictures
                        self.refreshButton.isEnabled = true
                        
                        print("Image have been saved to cache2")
                        print(pictures)
                        self.collectionView.reloadData()
                        self.collectionView.hideLoader()
                    }
                }
            }
        }
    }
    
    func getImagesFromUrl(from arr: [Photo], photoGotten: @escaping ([String]) -> Void) {
        let group = DispatchGroup()
        
        var images = [String]()
        
        for i in arr {
            group.enter()
            Requests.shared.downloadImage(fromLink: "https://farm\(String(i.farm)).staticflickr.com/\(i.server)/\(i.id)_\(i.secret).jpg") { (image) in
                let imagePath = self.saveImageInDirectory(imageName: i.id, image: image)
                images.append(imagePath)
                group.leave()
            }
        }
        group.notify(queue: .main) {
            photoGotten(images)
        }
    }
    
    func saveImageInDirectory(imageName img: String, image: UIImage) -> String {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let imgName = img+".jpg"
        let url = document.appendingPathComponent(imgName)
        
        let theImage = image
        
        if let data = theImage.jpegData(compressionQuality: 0.0) {
            do {
                try data.write(to: url)
            } catch {
                print("Unable to Write Image Data to Disk")
            }
        }
        return imgName
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        setUpCollectionViewItemSize()
    }
    
    func setUpCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let nib = UINib(nibName: photoIdentifier, bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: photoIdentifier)
    }
    
    func setUpCollectionViewItemSize() {
        if collectionViewFlowLayout == nil {
            let _: CGFloat = 5
            let lineSpacing: CGFloat = 3
            let interItemSpacing: CGFloat = 3
            
            let itemSize = self.view.bounds.width / 4 - 6
            
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            
            collectionViewFlowLayout.itemSize = CGSize(width: itemSize, height: itemSize + 20)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        albumMapView.setRegion(coordinateRegion, animated: true)
    }
}

extension PhotoAlbum: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //        if isImage == false {
        //            return savedImages.count
        //        } else {
        //            return photos.count
        //        }
        
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! PhotoCell
        //        if isImage == false {
        //            cell.configures(image: savedImages[indexPath.item])
        //            print("Cofiguring from local storage")
        //        } else {
        //            cell.configure(photo: photos[indexPath.item])
        //            print("Cofiguring from internat image")
        //        }
        
        cell.configures(image: savedImages[indexPath.item])
        
        return cell
    }
    
    fileprivate func deleteAPicture(_ collectionView: UICollectionView, _ indexPath: IndexPath) {
        collectionView.deleteItems(at: [indexPath])
        savedImages.remove(at: indexPath.item)
        Requests.shared.updateSavedGallery(with: self.longLat, images: savedImages) { (updatedList) in
            self.savedImages = updatedList
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        deleteAPicture(collectionView, indexPath)
        
        let image = savedImages[indexPath.item]
        print(image)
        
        let vc = storyboard?.instantiateViewController(identifier: "DetailImageViewController") as? DetailImageViewController
        
        vc?.imageName = image
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
}

extension UICollectionView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .center;
        messageLabel.font = UIFont(name: "Avenir", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel;
    }
    
    func restore() {
        self.backgroundView = nil
    }
    
    func showLoader() {
        let Indicator = MBProgressHUD.showAdded(to: self, animated: true)
//        Indicator.label.text = "Indicator"
        Indicator.isUserInteractionEnabled = false
//        Indicator.detailsLabel.text = "fetching details"
        Indicator.show(animated: true)
    }
    
    func hideLoader() {
        MBProgressHUD.hide(for: self, animated: true)
    }
}