//
//  ViewController.swift
//  Za Hunter
//
//  Created by Jacob Smith on 4/3/19.
//  Copyright © 2019 John Hersey High School. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var pizza: [MKMapItem] = []
    
    var initialRegion: MKCoordinateRegion!
    var isInitialRegion = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        mapView.delegate = self
        
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        if isInitialRegion {
            initialRegion = MKCoordinateRegion(center: mapView.centerCoordinate, span: mapView.region.span)
            isInitialRegion = false
        }
    }

    @IBAction func whenPizzaSearchButtonPressed(_ sender: Any) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Pizza"
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        request.region = MKCoordinateRegion(center: currentLocation.coordinate, span: span)
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            guard let response = response else { return }
            for mapItem in response.mapItems {
                self.pizza.append(mapItem)
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                self.mapView.addAnnotation(annotation)
            }
        }
    }
    
    @IBAction func whenZoomButtonPressed(_ sender: Any) {
        let center = currentLocation.coordinate
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(mapView.userLocation) {
            return nil
        }
        let pin = MKAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.image = UIImage(named: "Pizza")
        pin.canShowCallout = true
        let button = UIButton(type: .detailDisclosure)
        pin.rightCalloutAccessoryView = button
        let secondButton = UIButton(type: .contactAdd)
        pin.leftCalloutAccessoryView = secondButton
        return pin
    }
}

