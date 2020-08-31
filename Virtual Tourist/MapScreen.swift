//
//  MapScreen.swift
//  
//
//  Created by Muhammed Ibrahim on 12/08/2020.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapScreen: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let defaults = UserDefaults.standard
    
    @IBAction func deleteLocation(_ sender: Any) {
        Requests.shared.deleteLocationData()
    }
    let imageSegueIdentifier = "imageViewSegue"
    
    var centerOfMapView: CLLocationCoordinate2D!
    
    let locationManager = CLLocationManager()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.mapType = .hybrid
        
        let longPresGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPresGestureRecog.minimumPressDuration = 2.0
        self.mapView.addGestureRecognizer(longPresGestureRecog)
        
        let centerLocationIsAvailable = defaults.object(forKey: "centeredLatitude") != nil && defaults.object(forKey: "centeredLatitude") != nil
//
//        let centerLocation = CLLocation(latitude: 6.621190, longitude: 3.284210
//        )
//        self.centerViewOnLocation(location: centerLocation)
//        let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
//        self.mapView.setCameraZoomRange(zoomRange, animated: true)
        
        getLocations { (locations) in
            if locations.isEmpty {
                let anotation1 = MKPointAnnotation()
                anotation1.title = "Eiffel Tower"
                anotation1.coordinate = CLLocationCoordinate2D(latitude: 48.858372, longitude: 2.294481)

                self.mapView.addAnnotation(anotation1)
                let anotation2 = MKPointAnnotation()
                anotation2.title = "Kilimanjaro"
                anotation2.coordinate = CLLocationCoordinate2D(latitude: 27.175014, longitude: 78.042152)
                self.mapView.addAnnotation(anotation2)

                if centerLocationIsAvailable {
                    let centerLocation = CLLocation(latitude: self.defaults.double(forKey: "centeredLatitude"), longitude: self.defaults.double(forKey: "centeredLongitude"))
                    self.saveLocation(latitude: self.defaults.double(forKey: "centeredLatitude"), longitude: self.defaults.double(forKey: "centeredLongitude")
                    )
                    self.centerViewOnLocation(location: centerLocation)
                } else {
                    let centerLocation = CLLocation(latitude: 48.858372, longitude: 2.294481)
                    self.saveLocation(latitude: self.defaults.double(forKey: "centeredLatitude"), longitude: self.defaults.double(forKey: "centeredLongitude")
                    )
                    self.centerViewOnLocation(location: centerLocation)
                }


                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
                self.mapView.setCameraZoomRange(zoomRange, animated: true)

            } else {
                for location in locations {
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
                    self.mapView.addAnnotation(annotation)
                }
                let centerLocation = CLLocation(latitude: self.defaults.double(forKey: "centeredLatitude"), longitude: self.defaults.double(forKey: "centeredLongitude"))
                self.centerViewOnLocation(location: centerLocation)

                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
                self.mapView.setCameraZoomRange(zoomRange, animated: true)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let annotation = sender as! MKAnnotationView
        
        if segue.identifier == imageSegueIdentifier {
            if let vc = segue.destination as? PhotoAlbum {
                vc.annotationSegue = annotation
            }
        }
    }
    
    
    
    func saveLocation(latitude: Double, longitude: Double) {
        let location = Locations(context: Persistence.context)
        location.latitude = latitude
        location.longitude = longitude
        Persistence.saveContext()
    }
    
    func getLocations(locations: @escaping ([Locations]) -> Void) {
        let savedLocationData: NSFetchRequest<Locations> = Locations.fetchRequest()
        var savedLocations = [Locations]()
        
        do {
            let saved = try Persistence.context.fetch(savedLocationData)
            savedLocations = saved
            locations(savedLocations)
        } catch{}
    }
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            print(annotation.coordinate.latitude)
            print(annotation.coordinate.longitude)
            mapView.addAnnotation(annotation)
            saveLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 400, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000
        )
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

extension MapScreen: CLLocationManagerDelegate, MKMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        performSegue(withIdentifier: imageSegueIdentifier, sender: view)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        centerOfMapView = mapView.centerCoordinate
        
        defaults.set(centerOfMapView.latitude, forKey: "centeredLatitude")
        defaults.set(centerOfMapView.longitude, forKey: "centeredLongitude")
        
        print(centerOfMapView.latitude)
        print(defaults.double(forKey: "centeredLatitude"))
        print(centerOfMapView.longitude)
        print(defaults.double(forKey: "centeredLongitude"))
        print("\n")
    }
}
