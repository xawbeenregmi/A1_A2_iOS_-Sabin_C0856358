//
//  ViewController.swift
//  A1_A2_iOS_ Sabin_C0856358
//
//  Created by Sabin Regmi on 24/05/2022.
//

import UIKit
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {

    
    @IBOutlet weak var mapView: MKMapView!
    
    // create location manager
    var locationMnager = CLLocationManager()
    
    // defining user location
    var userLat:CLLocationDegrees = 0;
    var userLong:CLLocationDegrees = 0;
    
    // create the places array
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        mapView.isZoomEnabled = false
        mapView.showsUserLocation = true
        
        // giving the delegate of MKMapViewDelegate to this class
        mapView.delegate = self
        
        // assigning the delegate property of the location manager to be this class
        locationMnager.delegate = self
        
        // defining the accuracy of the location
        locationMnager.desiredAccuracy = kCLLocationAccuracyBest
        
        // requesting the permission for location
        locationMnager.requestWhenInUseAuthorization()
        
        // start updating the location
        locationMnager.startUpdatingLocation()
        
        // Creating a double tap gesture recognizer and placing addDoubleTapAnnotattion function as an action
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(addDoubleTapAnnotattion))
        
        // setting no of taps required as 2
        doubleTap.numberOfTapsRequired = 2
        
        // adding double tap gesture in mapview
        mapView.addGestureRecognizer(doubleTap)
        
    }
    
    
    // Handling did update locations function
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Getting the latest location
        let userLocation = locations[0]
        
        // Extracting latitude and longitude from the location coordinate
        let latitude = userLocation.coordinate.latitude
        let longitude = userLocation.coordinate.longitude
        
        // setting user latitude and longitude
        userLat = latitude;
        userLong = longitude;
        
        // calling displayLocation function to display the location of the user
        displayLocation(latitude: latitude, longitude: longitude, title: "My Location", subtitle: "I am here")
    }
    
    // Function to display user location in mapview
    func displayLocation(latitude: CLLocationDegrees,
                         longitude: CLLocationDegrees,
                         title: String,
                         subtitle: String) {
        
        // Defining span
        let latDelta: CLLocationDegrees = 0.05
        let lngDelta: CLLocationDegrees = 0.05
        
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lngDelta)
        
        // Defining Location
        let location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        // Defining Region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Setting up the region in the map
        mapView.setRegion(region, animated: true)
        
        // Adding annotation to the map view
        let annotation = MKPointAnnotation()
        annotation.title = title
        annotation.subtitle = subtitle
        annotation.coordinate = location
        mapView.addAnnotation(annotation)
    }
    
    // function to add annotations to the places
    func addAnnotationForPlaces(){
        
        // removing all the annotations
        mapView.removeAnnotations(mapView.annotations)
        
        // looping through places list and creating annotations and adding it to mapview
        for place in places {
            // add annotation for the coordinatet
            let annotation = MKPointAnnotation()
            annotation.title = place.title
            annotation.subtitle = place.subtitle
            annotation.coordinate = place.coordinate
            mapView.addAnnotation(annotation)
        }
    }
    
    // function to handle double tap in mapview
    @objc func addDoubleTapAnnotattion(gestureRecognizer: UIGestureRecognizer) {
        // getting the touch point
        let touchPoint = gestureRecognizer.location(in: mapView)
        
        // converting touch point to coordinate in mapview
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView)
        
        // appending it to places depending upon if its a first location or second or third
        if places.count == 0{
            places.append(Place(title: "A", subtitle: "A", coordinate: coordinate))
        } else if places.count == 1{
            places.append(Place(title: "B", subtitle: "B", coordinate: coordinate))
        } else if places.count == 2{
            places.append(Place(title: "C", subtitle: "C", coordinate: coordinate))
            
            // forcing to draw polygon when we have 3 coordinates only will create a triangle
            addPolygon()
        } else {
            // removing annotation from mapview
            mapView.removeAnnotations(mapView.annotations)
            mapView.removeOverlays(mapView.overlays)
            
            // removing places from the list
            places = [Place]()
        }
        
        // calling addAnnotationForPlaces function to add annotation for locations
        addAnnotationForPlaces()
    }
    
    // function to create a triangle (polygon with 3 coordinate will create a triangle)
    func addPolygon() {
        let coordinates = places.map {$0.coordinate}
        let polygon = MKPolygon(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polygon)
    }
    
    func calculateDistance(markerLat: CLLocationDegrees, markerLong: CLLocationDegrees) -> CLLocationDistance{
        
        // defining the user location
        let userLocation = CLLocation(latitude: userLat, longitude: userLong)
        
        // defining the marker location
        let markerLocation = CLLocation(latitude: markerLat, longitude: markerLong)
        
        // calculating the distance between marker location and user location in meters
        let distance: CLLocationDistance = markerLocation.distance(from: userLocation)
        
        // returning the distance
        return distance;
    }

}


extension ViewController: MKMapViewDelegate {
    
    //MARK: - viewFor annotation method
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        switch annotation.title {
        case "A", "B", "C":
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "droppablePin")
            annotationView.pinTintColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            annotationView.canShowCallout = true
            annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            return annotationView
        default:
            return nil
        }
    }
    
    // function to callout accessory control
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // getting latitude and longitude from annotationview
        let lat = (view.annotation?.coordinate.latitude)!;
        let long = view.annotation?.coordinate.longitude;
        
        // calling function to calculate the distance
        let distance = calculateDistance(markerLat: lat, markerLong: long!)
        
        // showing informational alert to show the distance
        let alertController = UIAlertController(title: "Distance", message: "Distance between the marker and user location is \(String(format: "%.3f", distance))} meters", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    // function to render overlay for polygon
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolygon {
            let rendrer = MKPolygonRenderer(overlay: overlay)
            rendrer.fillColor = UIColor.red.withAlphaComponent(0.5)
            rendrer.strokeColor = UIColor.green
            rendrer.lineWidth = 2
            return rendrer
        }
        return MKOverlayRenderer()
    }
}


