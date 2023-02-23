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

    
    var body: some View {
        VStack {
            HStack{
                SearchBar(text: $searchText, onSearch: search)
                Button(action: {
                    isFollowingUser = true
        
                }){
                    Image(systemName: "location")
                }
            }
            
            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: isFollowingUser ? .constant(.follow) : .none, annotationItems: [Annotation(coordinate: searchCoordinate)]) { annotation in
                MapMarker(coordinate: annotation.coordinate)
            }
            .ignoresSafeArea(.all)
            .onAppear{viewModel.checkIfLocationIsEnabled()}
            .onAppear{
                region = $viewModel.region.wrappedValue
            }
        }
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
        }
    }
    
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
