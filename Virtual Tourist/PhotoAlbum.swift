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
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anotation = MKPointAnnotation()
        anotation.title = "My House"
        anotation.coordinate = CLLocationCoordinate2D(latitude: 6.617186, longitude: 3.309907)
        albumMapView.addAnnotation(anotation)
        
        let myLocation = CLLocation(latitude: 6.617186, longitude: 3.309907)
        
        centerViewOnLocation(location: myLocation)
    }
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        albumMapView.setRegion(coordinateRegion, animated: true)
    }
}
