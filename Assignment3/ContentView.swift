//
//  ContentView.swift
//  Assignment3
//
//  Created by Bryan JR on 2025-11-21.
//  Student ID: 991706032
//

import SwiftUI
import CoreLocation
import MapKit

struct ContentView: View {
    @ObservedObject var locationManagerVM = MyAppLocationManagerVM()
    @State var camPosition : MapCameraPosition = .userLocation(fallback: .automatic)
    @State var firstStop = ""
    @State var secondStop = ""
    @State var finalDest = ""
    @State var routeOption = 0
    @State var route: MKRoute?
    @State var route2: MKRoute?
    @State var route3: MKRoute?
    @State var firstCoord : MKMapItem?
    @State var secondCoord : MKMapItem?
    @State var finalCoord : MKMapItem?
    @State var firstLocations: [MKMapItem] = []
    @State var secondLocations: [MKMapItem] = []
    @State var thirdLocations: [MKMapItem] = []
    var body: some View {
        VStack {
            Text("Assignment 3")
            HStack{
                TextField("First Stop", text: $firstStop).onChange(of: firstStop){
                    Task{
                        await firstLocations = updateLocations(stop: firstStop)
                    }
                }
                Menu{
                    ForEach(firstLocations, id: \.self){ item in
                        Button(item.name ?? "No Locations"){
                            firstCoord = item
                            firstStop = item.name ?? firstStop
                        }
                    }
                } label: {
                    VStack{
                        Image(systemName: "chevron.down")
                    }
                }
            }
            HStack{
                TextField("Second Stop", text: $secondStop).onChange(of: secondStop){
                    Task{
                        await secondLocations = updateLocations(stop: secondStop)
                    }
                }
                Menu{
                    ForEach(secondLocations, id: \.self){ item in
                        Button(item.name ?? "No Locations"){
                            secondCoord = item
                            secondStop = item.name ?? secondStop
                        }
                    }
                } label: {
                    VStack{
                        Image(systemName: "chevron.down")
                    }
                }
            }
            HStack{
                TextField("Final Destination", text: $finalDest).onChange(of: finalDest){
                    Task{
                        await thirdLocations = updateLocations(stop: finalDest)
                    }
                }
                Menu{
                    ForEach(thirdLocations, id: \.self){ item in
                        Button(item.name ?? "No Locations"){
                            finalCoord = item
                            finalDest = item.name ?? finalDest
                        }
                    }
                } label: {
                    VStack{
                        Image(systemName: "chevron.down")
                    }
                }
            }
            Picker("Option", selection: $routeOption){
                Text("Start -> Stop 1 -> Stop 2 -> Destination").tag(0)
                Text("Start -> Stop 1").tag(1)
                Text("Stop 1 -> Stop 2").tag(2)
            }
            Button("Search"){
                Task{
                    if(routeOption == 0){
                        await showRouteStartToDest()
                    }
                    if(routeOption == 1){
                        await showRouteToLocation()
                    }
                    if(routeOption == 2){
                        await showRouteAToB()
                    }
                }
            }
            Map(position: $camPosition){
                ForEach(locationManagerVM.mapItems, id:\.self){ item in
                    
                    Marker(item: item)
                }
                
                if let mk = route{
                    MapPolyline(mk.polyline).stroke(.blue, style: StrokeStyle(lineWidth: 5))
                    Marker(item: firstCoord!)
                }
                
                if let mk = route2{
                    MapPolyline(mk.polyline).stroke(.green, style: StrokeStyle(lineWidth: 5))
                    Marker(item: secondCoord!)
                }
                if let mk = route3{
                    MapPolyline(mk.polyline).stroke(.red, style: StrokeStyle(lineWidth: 5))
                    Marker(item: finalCoord!)
                }
            }
            
            
        }
        .padding()
        .onAppear(){
            firstLocations = locationManagerVM.mapItems
            secondLocations = locationManagerVM.mapItems
            thirdLocations = locationManagerVM.mapItems
        }
        
    }
    
    func showRouteToLocation() async{
        guard let stop1 = firstCoord, let curLocation = locationManagerVM.curLocation else{
            return
        }
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: .init(coordinate: curLocation))
        request.destination = stop1
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
    
    func showRouteAToB() async{
        guard let stop1 = firstCoord, let stop2 = secondCoord else{
            print("error")
            return
        }
        let request = MKDirections.Request()
        request.source = stop1
        request.destination = stop2
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
    
    func showRouteStartToDest() async{
        guard let stop1 = firstCoord, let stop2 = secondCoord, let stop3 = finalCoord, let curLocation = locationManagerVM.curLocation else{
            print("error")
            return
        }
        let request1 = MKDirections.Request()
        request1.source = MKMapItem(placemark: .init(coordinate: curLocation))
        request1.destination = stop1
        
        let request2 = MKDirections.Request()
        request2.source = stop1
        request2.destination = stop2
        
        let request3 = MKDirections.Request()
        request3.source = stop2
        request3.destination = stop3
        
        do{
            
            let response = try await MKDirections(request: request1).calculate()
            self.route = response.routes.first
            
            if let rect = route?.polyline.boundingMapRect{
                camPosition = .rect(rect)
            }
            let response2 = try await MKDirections(request: request2).calculate()
            self.route2 = response2.routes.first
            
            if let rect = route2?.polyline.boundingMapRect{
                camPosition = .rect(rect)
            }
            let response3 = try await MKDirections(request: request3).calculate()
            self.route3 = response3.routes.first
            
            if let rect = route3?.polyline.boundingMapRect{
                camPosition = .rect(rect)
            }
        }catch{
            print("error \(error)")
        }
        
    }
    
    func updateLocations(stop: String) async -> [MKMapItem]{
        locationManagerVM.searchLocation(name: stop)
        return locationManagerVM.mapItems
    }
    
}


#Preview {
    ContentView()
}
