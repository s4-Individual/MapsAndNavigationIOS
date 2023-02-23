//
//  Searchbar.swift
//  MapsAndNavigation
//
//  Created by Brett Mulder on 17/02/2023.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search", text: $text, onCommit: onSearch)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            Button(action: onSearch) {
                Text("Search")
            }
            .padding(.trailing, 10)
        }
    }
}

struct Searchbar_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
