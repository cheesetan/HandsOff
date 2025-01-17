//
//  DeviceDiscoveryView.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import SwiftUI
import CoreBluetooth

#if os(iOS)
struct CentralView: View {
    @StateObject private var bcManager = BluetoothCentralManager()

    var body: some View {
        if !bcManager.isReady {
            NavigationStack {
                VStack {
                    List(bcManager.discoveredPeripherals, id: \.identifier) { peripheral in
                        Button(peripheral.name ?? "Unknown Device") {
                            bcManager.connect(to: peripheral)
                        }
                    }
                }
                .navigationTitle("Connect")
            }
        } else {
            CommandView()
                .environmentObject(bcManager)
        }
    }
}

struct CommandView: View {

    @EnvironmentObject private var bcManager: BluetoothCentralManager

    var body: some View {
        NavigationStack {
            VStack {
                Button {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        bcManager.sendCommand("lock")
                    }
                } label: {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(.white, .red)
                        .mask(Circle())
                }
                .buttonStyle(.plain)
            }
            .padding(30)
            .navigationTitle(bcManager.connectedPeripheral?.name ?? "")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#endif
