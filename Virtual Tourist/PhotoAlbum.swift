//
//  PhotoAlbum.swift
//  Virtual Tourist
//
//  Created by Muhammed Ibrahim on 13/08/2020.
//  Copyright © 2020 Ovansa. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbum: UIViewController {
    @IBOutlet weak var albumMapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var annotationSegue: MKAnnotationView!
    
    let locationManager = CLLocationManager()
    
    var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    let photoIdentifier = "PhotoCell"
    
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anotation = MKPointAnnotation()
        let longitude = annotationSegue.annotation!.coordinate.longitude
        let latitude = annotationSegue.annotation!.coordinate.latitude
        print(annotationSegue.annotation!.coordinate.latitude)
        
        anotation.title = "My House"
        anotation.coordinate = CLLocationCoordinate2D(latitude: 6.617186, longitude: 3.309907)
        albumMapView.addAnnotation(anotation)
        
        let myLocation = CLLocation(latitude: 6.617186, longitude: 3.309907)
        
        centerViewOnLocation(location: myLocation)
        
        setUpCollectionView()
        
        Requests.shared.getImageDataFromLocation(lat: latitude, lon: longitude) { (response) in
            self.photos = Array(response[0..<20])
            self.collectionView.reloadData()
        }
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
            let numberOfItemPerRow: CGFloat = 3
            let lineSpacing: CGFloat = 5
            let interItemSpacing: CGFloat = 5
            
            let width = (collectionView.frame.width - (numberOfItemPerRow - 1) * interItemSpacing) / numberOfItemPerRow
            let height = width
            print(width)
            
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
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: photoIdentifier, for: indexPath) as! PhotoCell
        
        cell.configure(photo: photos[indexPath.item])
        return cell
    }
}
