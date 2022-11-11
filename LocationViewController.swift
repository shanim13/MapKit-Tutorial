//
//  LocationViewController.swift
//  macMaps
//
//  Created by IE06 on 09/11/22.
//


import UIKit
import MapKit

class LocationViewController : UITableViewController{
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    var handleMapSearchDelegate: HandleMapSearchDelegate? = nil
    
    
    var searchingList: [MKMapItem] = []
    
    func parseAddress(selectedItem:MKPlacemark) -> String {
        let firstSpace = (selectedItem.subThoroughfare != nil && selectedItem.thoroughfare != nil) ? " " : ""
        let comma = (selectedItem.subThoroughfare != nil || selectedItem.thoroughfare != nil) && (selectedItem.subAdministrativeArea != nil || selectedItem.administrativeArea != nil) ? ", " : ""
        let secondSpace = (selectedItem.subAdministrativeArea != nil && selectedItem.administrativeArea != nil) ? " " : ""
        let addressLine = String(
            format:"%@%@%@%@%@%@%@",
            selectedItem.subThoroughfare ?? "",
            firstSpace,
            selectedItem.thoroughfare ?? "",
            comma,
            selectedItem.locality ?? "",
            secondSpace,
            selectedItem.administrativeArea ?? ""
        )
        return addressLine
    }
}
extension LocationViewController : UISearchResultsUpdating, UISearchBarDelegate{
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let mapView = mapView,
              let searchBarText = searchController.searchBar.text else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBarText
        request.region = mapView.region
        request.resultTypes = [.pointOfInterest, .address]
        let search = MKLocalSearch(request: request)
        search.start { [self] response, _ in
            guard let response = response else {
                return
            }
            
            for mapItem in response.mapItems{
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.phoneNumber
                
                self.mapView!.addAnnotation(annotation)
            }
            
            self.matchingItems = response.mapItems
            self.tableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        //delegate
        
        searchBar.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView!.region
        request.resultTypes = [.pointOfInterest, .address]
        let search = MKLocalSearch(request: request)
        search.start { [self] response, _ in
            guard let response = response else {
                return
            }
            self.searchingList = response.mapItems
            for mapItem in response.mapItems{
                let annotation = MKPointAnnotation()
                annotation.coordinate = mapItem.placemark.coordinate
                annotation.title = mapItem.name
                annotation.subtitle = mapItem.phoneNumber
                
                self.mapView!.addAnnotation(annotation)
                
            }
            self.mapView!.setRegion(response.boundingRegion, animated: true)
            
        }
    }
}


extension LocationViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        let selectedItem = matchingItems[indexPath.row].placemark
        cell.detailTextLabel?.text = parseAddress(selectedItem: selectedItem)
        cell.textLabel?.text = selectedItem.name
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedItem = matchingItems[indexPath.row].placemark
        handleMapSearchDelegate?.dropPinZoomIn(placemark: selectedItem)
        handleMapSearchDelegate?.zoomIn(placemark: selectedItem)
        dismiss(animated: true, completion: nil)
        
    }
    
}
