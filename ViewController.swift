//
//  ViewController.swift
//  
//
//  Created by IE06 on 09/11/22.
//

import CoreLocation
import UIKit
import MapKit

var values:Int = 0
protocol HandleMapSearchDelegate{
    func dropPinZoomIn(placemark:MKPlacemark)
    func zoomIn(placemark: MKPlacemark)
}

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UIGestureRecognizerDelegate, HandleMapSearchDelegate{
    
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var longPress: UILongPressGestureRecognizer!
    
    let locationManager = CLLocationManager()
    var selectedPin: MKPlacemark? = nil
    var resultSearchController: UISearchController? = nil
    var geocoder = CLGeocoder()
    
    var handleMapSearchDelegate: HandleMapSearchDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        locationManager.startUpdatingLocation()
        
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        resultSearchController?.searchBar.delegate = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.searchController = resultSearchController
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.showsSearchResultsController = true
        definesPresentationContext = true
        
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        self.mapView.addGestureRecognizer(longPressGesture)
        
        
        self.title = "MacMaps"
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else{return}
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        
        mapView.setRegion(region, animated:true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error \(error)")
    }
    
    @objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer, placemark: MKPlacemark){
        if gestureRecognizer.state != UIGestureRecognizer.State.ended{
            let touchLocation = gestureRecognizer.location(in: mapView)
            let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let lat = locationCoordinate.latitude
            let lng = locationCoordinate.longitude
            let location = CLLocation(latitude: lat, longitude: lng)
            geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
                let myPin = MKPointAnnotation()
                myPin.coordinate = locationCoordinate
                let place = placemarks?[0]
                var countryName = ""
                var cityName = ""
                var state = ""
                var name = ""
                if let countryString = place?.country,
                   let cityString = place?.locality,
                   let stateString = place?.administrativeArea,
                   let nameString = place?.name{
                    countryName = countryString
                    cityName = cityString
                    state = stateString
                    name = nameString
                    myPin.title = "\(nameString) \(cityString) \(stateString) \(countryString)"
                    self.mapView.addAnnotation(myPin)
                }
            }
            if gestureRecognizer.state != UIGestureRecognizer.State.began{
                return
            }
        }
    }
    
    func dropPinZoomIn(placemark:MKPlacemark){
        
        selectedPin = placemark
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = placemark.coordinate
        annotation.title = placemark.name
        if let city = placemark.locality,
           let state = placemark.administrativeArea {
            annotation.subtitle = "\(city) \(state)"
        }
        mapView.addAnnotation(annotation)
    }
    
    func zoomIn(placemark: MKPlacemark){
        selectedPin = placemark
        let span = MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
        let region = MKCoordinateRegion(center: placemark.coordinate, span: span)
        
        mapView.setRegion(region, animated: true)
    }
    
}


