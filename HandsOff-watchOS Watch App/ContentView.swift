//
//  ContentView.swift
//  HandsOff-watchOS Watch App
//
//  Created by Tristan Chay on 17/1/25.
//

import SwiftUI
import CoreBluetooth

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
                    bcManager.sendCommand("lock")
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

#Preview {
    CentralView()
}
