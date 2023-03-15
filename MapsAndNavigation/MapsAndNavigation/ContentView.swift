//
//  ContentView.swift
//  MapsAndNavigation
//
//  Created by Brett Mulder on 17/02/2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct Annotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    @State private var searchText = ""
    @State private var searchCoordinate = CLLocationCoordinate2D()
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
    @State private var isFollowingUser = true
    
    @State private var directions: [String] = []
    @State private var showDirections = false
    
    
    var body: some View {
        //        VStack {
        //            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: isFollowingUser ? .constant(.follow) : .none, annotationItems: [Annotation(coordinate: searchCoordinate)]) { annotation in
        //                MapMarker(coordinate: annotation.coordinate)
        //            }
        //            .ignoresSafeArea(.all)
        //            .onAppear{viewModel.checkIfLocationIsEnabled()}
        //            .onAppear{
        //                region = $viewModel.region.wrappedValue
        //            }
        //            HStack{
        //                SearchBar(text: $searchText, onSearch: search)
        //                Button(action: {
        //                    isFollowingUser = true
        //
        //                }){
        //                    Image(systemName: "location.fill")
        //                }
        //            }
        //        }
        VStack {
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: isFollowingUser ? .constant(.follow) : .none, annotationItems: [Annotation(coordinate: searchCoordinate)]) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .ignoresSafeArea(.all)
            .onAppear{viewModel.checkIfLocationIsEnabled()}
            .onAppear{
                region = $viewModel.region.wrappedValue
            }
            
            HStack{
                SearchBar(text: $searchText, onSearch: search)
                Button(action: {
                    isFollowingUser = true
                    
                }){
                    Image(systemName: "location.fill")
                }
            }
            
            Button(action: {
                self.showDirections.toggle()
            }, label: {
                Text("Show directions")
            })
            .disabled(directions.isEmpty)
            .padding()
        }.sheet(isPresented: $showDirections, content: {
            VStack(spacing: 0) {
                Text("Directions")
                    .font(.largeTitle)
                    .bold()
                    .padding()
                
                Divider().background(Color(UIColor.systemBlue))
                
                List(0..<self.directions.count, id: \.self) { i in
                    Text(self.directions[i]).padding()
                }
            }
        })
    }
    
    private func search() {
        let localSearchRequest = MKLocalSearch.Request()
            localSearchRequest.naturalLanguageQuery = searchText
            let localSearch = MKLocalSearch(request: localSearchRequest)
            localSearch.start { (response, error) in
                guard let response = response else { return }
                let mapItem = response.mapItems.first
                searchCoordinate = mapItem?.placemark.coordinate ?? CLLocationCoordinate2D()
                region = MKCoordinateRegion(center: searchCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05))
                isFollowingUser = false
                
                let sourcePlacemark = MKPlacemark(coordinate: self.viewModel.locationManager?.location?.coordinate ?? CLLocationCoordinate2D())
                let destinationPlacemark = MKPlacemark(coordinate: self.searchCoordinate)
                let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
                let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
                let directionsRequest = MKDirections.Request()
                directionsRequest.source = sourceMapItem
                directionsRequest.destination = destinationMapItem
                directionsRequest.transportType = .automobile
                let directions = MKDirections(request: directionsRequest)
                directions.calculate { response, error in
                    guard let route = response?.routes.first else {
                        return
                    }
                    self.directions = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
                    self.showDirections = true
                }
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
