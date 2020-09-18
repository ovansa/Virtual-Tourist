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
    
    func updateGallery(with name: String, images: [String]) {
            let fetchImages: NSFetchRequest<Images> = Images.fetchRequest()
            fetchImages.predicate = NSPredicate(format: "name = %@", name)
            
            do {
                let result = try Persistence.context.fetch(fetchImages)
                if result.count != 0 {
    //                print(result[0].imageList!)
                    result[0].setValue(images, forKey: "imageList")
    //                print("------- After replacing image -------")
    //                print(result[0].imageList!)
                    
                } else {
                    print("No result")
                }
            } catch { }
            
            do {
                try Persistence.context.save()
            } catch {
                print("\(error)")
            }
        }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let deleteAlert = UIAlertController(title: "Confirm delete?", message: "Location will be deleted", preferredStyle: UIAlertController.Style.alert)
        
        deleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
            let longitude = self.annotationSegue.annotation!.coordinate.longitude
            let latitude = self.annotationSegue.annotation!.coordinate.latitude
            let longLat = String(latitude) + String(longitude)
            
            let fetchPoint: NSFetchRequest<Locations> = Locations.fetchRequest()
            fetchPoint.predicate = NSPredicate(format: "longLat = %@", longLat)
            
            // Delete location from Location data
            do {
                let result = try Persistence.context.fetch(fetchPoint)
                
                Persistence.context.delete(result[0])
                do {
                    try Persistence.context.save()
                } catch {
                    print("\(error)")
                }
            } catch { }
            
            // Delete images of location from Images data
            let fetchImages: NSFetchRequest<Images> = Images.fetchRequest()
            fetchImages.predicate = NSPredicate(format: "name = %@", longLat)
            
            // Delete location from Location data
            do {
                let results = try Persistence.context.fetch(fetchImages)
                
                if results.count > 0 {
                    print(results[0].name!)
                    Persistence.context.delete(results[0])
                }
                do {
                    try Persistence.context.save()
                } catch {
                    print("\(error)")
                }
            } catch { }
            
            let vc = self.storyboard?.instantiateViewController(identifier: "MapScreen") as? MapScreen
            self.navigationController?.pushViewController(vc!, animated: true)
        }))
        
        deleteAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        present(deleteAlert, animated: true, completion: nil)
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func refreshButtonPressed(_ sender: UIButton) {
        refreshImagesForLocation()
    }
    
    fileprivate func refreshImagesForLocation() {
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        self.refreshButton.isEnabled = false
        self.deleteButton.isEnabled = false
        self.collectionView.showLoader(message: "Refreshing...")
        
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
                            self.deleteButton.isEnabled = true
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
                            self.deleteButton.isEnabled = true
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
        self.collectionView.showLoader(message: "")
        Requests.shared.getImagesFromStorage(basedOn: self.longLat) { (images) in
            self.savedImages = images
            self.refreshButton.isEnabled = true
            self.deleteButton.isEnabled = true
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
        self.deleteButton.isEnabled = true
        self.collectionView.setEmptyMessage("There is no image for this location :(")
    }
    
    fileprivate func makeFreshRequestForImages() {
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        self.collectionView.showLoader(message: "Fetching...")
        
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
                        
                        do {
                            try Persistence.context.save()
                        } catch {
                            print("\(error)")
                        }
                        
                        self.savedImages = pictures
                        self.refreshButton.isEnabled = true
                        self.deleteButton.isEnabled = true
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
                        do {
                            try Persistence.context.save()
                        } catch {
                            print("\(error)")
                        }
                        self.savedImages = pictures
                        self.refreshButton.isEnabled = true
                        self.deleteButton.isEnabled = true
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
    
    func deleteImageFromDirectory(imageName img: String) {
        let document = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let imagePath = document.appendingPathComponent(img)
        
        let fileManager = FileManager.default
        try? fileManager.removeItem(atPath: imagePath.path)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchImage()
        collectionView.reloadData()
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
        return savedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! PhotoCell
        
        cell.configures(image: savedImages[indexPath.item])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let image = savedImages[indexPath.item]
        let vc = storyboard?.instantiateViewController(identifier: "DetailImageViewController") as? DetailImageViewController

        vc?.imageName = image
        vc?.longLat = self.longLat
        vc?.index = indexPath.item

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
    
    func showLoader(message msg: String?) {
        let Indicator = MBProgressHUD.showAdded(to: self, animated: true)
        Indicator.isUserInteractionEnabled = false
        Indicator.detailsLabel.text = msg
        Indicator.show(animated: true)
    }
    
    func hideLoader() {
        MBProgressHUD.hide(for: self, animated: true)
    }
}
