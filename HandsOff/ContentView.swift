//
//  ContentView.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var model: DeviceFinderViewModel = .shared
    
    var body: some View {
        NavigationStack(path: $model.joinedPeer) {
            List {
                Section {
                    ForEach(model.peers) { peer in
                        Button {
                            model.selectedPeer = peer
                        } label: {
                            HStack {
                                Image(systemName: "iphone.gen1")
                                    .imageScale(.large)
                                    .foregroundColor(.accentColor)
                                
                                Text(peer.peerId.displayName)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.vertical, 5)
                        }
                        .buttonStyle(.plain)
                    }
                } footer: {
                    Text("Tap on any device to lock them")
                }
            }
            .navigationTitle("Nearby Devices")
            .onAppear {
                model.startBrowsing()
                model.isAdvertised = true
            }
        }
    }
}

#Preview {
    ContentView()
}
