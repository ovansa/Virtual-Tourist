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
    @IBAction func deleteLocation(_ sender: Any) {
        Requests.shared.deleteLocationData()
    }
    
    let defaults = UserDefaults.standard
    var previousLocation: CLLocation?
    let imageSegueIdentifier = "imageViewSegue"
    var centerOfMapView: CLLocationCoordinate2D!
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        
        configureNavBar()
        addPinOnMapGesture()
        
        previousLocation = getCenterLocation(for: mapView)
        
        let centerLocationIsAvailable = defaults.object(forKey: "centeredLatitude") != nil && defaults.object(forKey: "centeredLatitude") != nil
        displaySavedLocations(centerLocationIsAvailable)
        
        //                let centerLocation = CLLocation(latitude: 6.621190, longitude: 3.284210
        //                )
        //                self.centerViewOnLocation(location: centerLocation)
        //                let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
        //                self.mapView.setCameraZoomRange(zoomRange, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.mapView.delegate = self
        self.mapView.mapType = .standard
        
        configureNavBar()
        addPinOnMapGesture()
        
        previousLocation = getCenterLocation(for: mapView)
        
        let centerLocationIsAvailable = defaults.object(forKey: "centeredLatitude") != nil && defaults.object(forKey: "centeredLatitude") != nil
        displaySavedLocations(centerLocationIsAvailable)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let annotation = sender as! MKAnnotationView
        
        if segue.identifier == imageSegueIdentifier {
            if let vc = segue.destination as? PhotoAlbum {
                vc.annotationSegue = annotation
            }
        }
    }
    
    fileprivate func addPinOnMapGesture() {
        let longPresGestureRecog = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotation(press:)))
        longPresGestureRecog.minimumPressDuration = 2.0
        self.mapView.addGestureRecognizer(longPresGestureRecog)
    }
    
    func configureNavBar() {
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        self.navigationController?.navigationBar.tintColor = .white
        let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    fileprivate func displaySavedLocations(_ centerLocationIsAvailable: Bool) {
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
    
    func saveLocation(latitude: Double, longitude: Double) {
        let location = Locations(context: Persistence.context)
        location.longLat = String(latitude) + String(longitude)
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
//            print(savedLocations)
        } catch{}
    }
    
    @objc func addAnnotation(press: UILongPressGestureRecognizer) {
        if press.state == .began {
            let location = press.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            //            print(annotation.coordinate.latitude)
            //            print(annotation.coordinate.longitude)
            mapView.addAnnotation(annotation)
            saveLocation(latitude: annotation.coordinate.latitude, longitude: annotation.coordinate.longitude)
        }
    }
    
    func centerViewOnUserLocation() {
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: 5000, longitudinalMeters: 100)
            mapView.setRegion(region, animated: true)
        }
    }
    
    func centerViewOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 50000, longitudinalMeters: 50000
        )
        
        //        let sm = MKCoordinateRegion(center: location, span: <#T##MKCoordinateSpan#>)
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
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
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
        //        let some = mapView.region.span.latitudeDelt
        defaults.set(centerOfMapView.latitude, forKey: "centeredLatitude")
        defaults.set(centerOfMapView.longitude, forKey: "centeredLongitude")
        
        let center = getCenterLocation(for: mapView)
        let geoCoder = CLGeocoder()
        
        guard let previousLocation = previousLocation else { return }
        
        guard center.distance(from: previousLocation) > 50 else { return }
        
        geoCoder.reverseGeocodeLocation(center) { (placemarks, error) in
            guard let placemarks = placemarks?.first else {
                return
            }
            
            guard let name = placemarks.country else {return}
            guard let name2 = placemarks.locality else {return}
            guard let name3 = placemarks.name else {return}
            
            DispatchQueue.main.async {
                print("\(name) ----- \(name2) ------- \(name3)")
            }
        }
    }
}
