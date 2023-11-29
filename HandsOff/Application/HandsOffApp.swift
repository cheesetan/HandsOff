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
            Button("Lock Macbook") {
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
            .keyboardShortcut("l")
            Divider()
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
