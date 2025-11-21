//
//  MyAppLocationVM.swift
//  Assignment3
//
//  Created by Bryan JR on 2025-11-21.
//

import Foundation
import CoreLocation
import MapKit

class MyAppLocationManagerVM : NSObject, CLLocationManagerDelegate, ObservableObject{
    
    let locationManage = CLLocationManager()
    
    @Published var curLocation : CLLocationCoordinate2D?
    
    @Published var mapItems : [MKMapItem] = []
    
    override init(){
        super.init()
        
        locationManage.delegate = self
        locationManage.requestWhenInUseAuthorization()
        locationManage.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last{
            curLocation = location.coordinate
        }
    }
    
    func searchLocation(name: String?){
        guard let name = name, let curLocation = curLocation else{
            print("Invalid Name")
            return
        }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = name
        request.region.center = curLocation
        
        let search = MKLocalSearch(request: request)
        
        search.start{ response, error in
            guard let res = response else{
                print("Location not found")
                return
            }
            self.mapItems = res.mapItems
        }
    }
}
