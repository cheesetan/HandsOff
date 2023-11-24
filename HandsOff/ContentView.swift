//
//  ContentView.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var model = DeviceFinderViewModel()

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
            .onChange(of: model.lockRequest) { oldValue, newValue in
                let script = "tell application \"System Events\" to sleep"
                guard let appleScript = NSAppleScript(source: script) else { return }
                var error: NSDictionary?
                appleScript.executeAndReturnError(&error)
                if let error = error {
                    print(error[NSAppleScript.errorAppName] as! String)
                    print(error[NSAppleScript.errorBriefMessage] as! String)
                    print(error[NSAppleScript.errorMessage] as! String)
                    print(error[NSAppleScript.errorNumber] as! NSNumber)
                    print(error[NSAppleScript.errorRange] as! NSRange)
                }
            }
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
