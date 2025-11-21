//
//  ContentView.swift
//  Assignment3
//
//  Created by Bryan JR on 2025-11-21.
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @ObservedObject var locationManagerVM = MyAppLocationManagerVM()
    @State var camPosition : MapCameraPosition = .userLocation(fallback: .automatic)
    @State var locationName = ""
    @State var selection : MKMapItem?
    @State var route: MKRoute?
    var body: some View {
        VStack {
            Text("Location Service Example")
            
            Text("Current Location: \(locationManagerVM.curLocation?.latitude), \(locationManagerVM.curLocation?.longitude)")
            TextField("First Stop", text: $locationName)
            TextField("Second Stop", text: $locationName)
            TextField("Final Destination", text: $locationName)
            Button("Search"){
                locationManagerVM.searchLocation(name: locationName)
            }
            Map(position: $camPosition, selection: $selection){
                ForEach(locationManagerVM.mapItems, id:\.self){ item in
                    
                    Marker(item: item)
                }
                
                if let mk = route{
                    MapPolyline(mk.polyline).stroke(.blue, style: StrokeStyle(lineWidth: 5))
                }
            }.task(id: selection){
                await showRouteToLocation()
            }
            
            
        }
        .padding()
        
    }
    func showRouteToLocation() async{
        guard let selection = selection, let curLocation = locationManagerVM.curLocation else{
            return
        }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: curLocation))
        request.destination = selection
        do{
            let response = try await MKDirections(request: request).calculate()
            self.route = response.routes.first
            
            if let rect = route?.polyline.boundingMapRect{
                camPosition = .rect(rect)
            }
        }catch{
            print("error \(error)")
        }
        
    }
    
}


#Preview {
    ContentView()
}
