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

class PhotoAlbum: UIViewController {
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnNewCollection: UIButton!
    @IBAction func newCollection(_ sender: Any) {
        print("--------------------------------------------")
    }
    
    
    var annotationSegue: MKAnnotationView!
    
    let locationManager = CLLocationManager()
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    let photoIdentifier = "PhotoCell"
    
    var photos = [Photo]()
    
    var savedImages = [String]()
    //    var savedIms: [String] = ["50250867232.jpg", "50250024693.jpg", "50250673466.jpg", "50250678002.jpg", "50250675036.jpg"]
    
    var isImage: Bool = false
    
    var photoDirUrl = [String]()
    
    var longLat: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anotation = MKPointAnnotation()
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        
        let longString = String(longitude)
        let latString = String(latitude)
        
        self.longLat = longString + latString
        //        print(annotationSegue.annotation!.coordinate.latitude)
        btnNewCollection.isEnabled = false
        
        Requests.shared.isImageTitleEmpty(basedOn: self.longLat) { (empty) in
            if empty {
                self.isImage = empty
                Requests.shared.getImageDataFromLocation(lat: latitude, lon: longitude) { (response) in
                    self.photos = Array(response[0..<5])
                    self.getImagesFromUrl(from: self.photos) { (pictures) in
                        let images = Images(context: Persistence.context)
                        images.name = self.longLat
                        images.imageList = pictures
                        Persistence.saveContext()
                        self.btnNewCollection.isEnabled = true
                    }
                    
                    self.collectionView.reloadData()
                }
            } else {
                self.isImage = empty
                Requests.shared.getImagesFromStorage(basedOn: self.longLat) { (images) in
                    self.savedImages = images
                    print(self.savedImages)
                    self.btnNewCollection.isEnabled = true
                }
                
            }
        }
        
        anotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        albumMapView.addAnnotation(anotation)
        
        let myLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        centerViewOnLocation(location: myLocation)
        
        setUpCollectionView()
        
        
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
    
    func getASavedImage() {
        let savedImageData: NSFetchRequest<Images> = Images.fetchRequest()
        var theSavedImages = [Images]()
        do {
            let saved = try Persistence.context.fetch(savedImageData)
            theSavedImages = saved
            print(theSavedImages[0].imageList!)
        } catch {}
    }
    
    func saveImageInDirectory(imageName img: String, image: UIImage) -> String {
        // Get the location of the document directory
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
            let numberOfItemPerRow: CGFloat = 4
            let lineSpacing: CGFloat = 5
            let interItemSpacing: CGFloat = 5
            
            let width = (collectionView.frame.width - (numberOfItemPerRow - 1
                ) * interItemSpacing) / numberOfItemPerRow
            let height = width
            collectionViewFlowLayout = UICollectionViewFlowLayout()
            collectionViewFlowLayout.itemSize = CGSize(width: width, height: height)
            collectionViewFlowLayout.sectionInset = UIEdgeInsets.zero
            collectionViewFlowLayout.scrollDirection = .vertical
            collectionViewFlowLayout.minimumLineSpacing = lineSpacing
            collectionViewFlowLayout.minimumInteritemSpacing = interItemSpacing
            
            collectionView.setCollectionViewLayout(collectionViewFlowLayout, animated: true)
        }
    }
    
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        albumMapView.setRegion(coordinateRegion, animated: true)
    }
}

extension PhotoAlbum: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isImage == false {
            return savedImages.count
        } else {
            return photos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! PhotoCell
        if isImage == false{
            cell.configures(image: savedImages[indexPath.item])
            print("Cofiguring from local storage")
        } else {
            cell.configure(photo: photos[indexPath.item])
            print("Cofiguring from internat image")
        }
        return cell
    }
}
