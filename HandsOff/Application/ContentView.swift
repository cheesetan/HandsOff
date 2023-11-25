//
//  ContentView.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            BluetoothConnectionView()
                .tabItem {
                    Label("Bluetooth", systemImage: "person.line.dotted.person.fill")
                }
            FirebaseConnectionView()
                .tabItem {
                    Label("Firebase", systemImage: "wifi")
                }
        }
    }
}

#Preview {
    ContentView()
}
