//
//  HandsOffApp.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI

@main
struct HandsOffApp: App {
    
    @ObservedObject var model: DeviceFinderViewModel = .shared
    
    init() {
        model.startBrowsing()
        model.isAdvertised = true
    }
    
    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("HandsOff", systemImage: "lock.square") {
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
        #else
        WindowGroup {
            ContentView()
        }
        #endif
    }
}
