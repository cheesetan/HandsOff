//
//  HandsOffApp.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI

@main
struct HandsOffApp: App {

    #if os(macOS)
    @StateObject private var bpManager = BluetoothPeripheralManager()
    #endif

    var body: some Scene {
        #if os(macOS)
        MenuBarExtra("HandsOff", systemImage: "lock.square") {
            Text(bpManager.isAdvertising ? "Status: Advertising" : "Status: Not Advertising")
            Button("Lock Device") {
                bpManager.lockDevice()
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
            CentralView()
        }
        #endif
    }
}
