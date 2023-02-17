//
//  ContentView.swift
//  MapsAndNavigation
//
//  Created by Brett Mulder on 17/02/2023.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        Map(coordinateRegion: $viewModel.region, showsUserLocation: true)
            .ignoresSafeArea(.all)
            .onAppear{viewModel.checkIfLocationIsEnabled()}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
