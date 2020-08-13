//
//  MapScreen.swift
//  
//
//  Created by Muhammed Ibrahim on 12/08/2020.
//

import UIKit
import MapKit
import CoreLocation

class MapScreen: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let anotation1 = MKPointAnnotation()
        anotation1.title = "Some House at Adealu"
        anotation1.coordinate = CLLocationCoordinate2D(latitude: 6.615128, longitude: 3.311222)
        mapView.addAnnotation(anotation1)
        let anotation2 = MKPointAnnotation()
        anotation2.title = "My House"
        anotation2.coordinate = CLLocationCoordinate2D(latitude: 6.617186, longitude: 3.309907)
        mapView.addAnnotation(anotation2)
        
        let iyanaPaja = CLLocation(latitude: 6.617186, longitude: 3.309907)
        centerViewOnLocation(location: iyanaPaja)
        
        
        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        mapView.setCameraZoomRange(zoomRange, animated: true)
    

    }
    
    func centerViewOnUserLocation() {
            if let location = locationManager.location?.coordinate {
                let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
                mapView.setRegion(region, animated: true)
            }
        }
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
 

    
    func setUPLocationManager() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
    
        func checkLocationServices() {
            if CLLocationManager.locationServicesEnabled() {
                setUPLocationManager()
                checkLocationAuthorization()
            } else {
    
            }
        }
        func checkLocationAuthorization() {
            switch CLLocationManager.authorizationStatus() {
            case .authorizedWhenInUse:
                mapView.showsUserLocation = true
    //            centerViewOnUserLocation()
            case .denied:
                // Show alert instructing
                break
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                break
            case .authorizedAlways:
                break
            case .restricted:
                // Show alert instructions
                break
            @unknown default:
                break
            }
        }

}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 500) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}


//extension MapScreen: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//    }
//
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//    }
//}

//class MapScreen: UIViewController {
//    @IBOutlet weak var mapView: MKMapView!
//
//    let locationManager = CLLocationManager()
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        checkLocationServices()
//
//        // Do any additional setup after loading the view.
//    }
//
//    func centerViewOnUserLocation() {
//        if let location = locationManager.location?.coordinate {
//            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 10000, longitudinalMeters: 10000)
//            mapView.setRegion(region, animated: true)
//        }
//    }
//
//    func checkLocationAuthorization() {
//        switch CLLocationManager.authorizationStatus() {
//        case .authorizedWhenInUse:
//            mapView.showsUserLocation = true
////            centerViewOnUserLocation()
//        case .denied:
//            // Show alert instructing
//            break
//        case .notDetermined:
//            locationManager.requestWhenInUseAuthorization()
//            break
//        case .authorizedAlways:
//            break
//        case .restricted:
//            // Show alert instructions
//            break
//        @unknown default:
//            break
//        }
//    }
//
//    func setUPLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//    }
//
//    func checkLocationServices() {
//        if CLLocationManager.locationServicesEnabled() {
//            setUPLocationManager()
//            checkLocationAuthorization()
//        } else {
//
//        }
//    }
//}
//
extension MapScreen: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}
