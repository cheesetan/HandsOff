//
//  CentralManager.swift
//  HandsOff
//
//  Created by Tristan Chay on 24/11/23.
//

import CoreBluetooth
import SwiftUI

#if os(macOS)
#else
class BluetoothCentralManager: NSObject, ObservableObject {
    @Published var discoveredPeripherals: [CBPeripheral] = []
    @Published var isScanning = false
    @Published var connectedPeripheral: CBPeripheral?
    @Published var isReady = false

    private var centralManager: CBCentralManager!
    private let serviceUUID = CBUUID(string: "C3EF2166-C690-45BA-8254-D31C1959AE91")
    private let characteristicUUID = CBUUID(string: "C3EF2166-C690-45BA-8254-D31C1959AE91")

    // Store discovered characteristic
    private var commandCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    // Method to send commands using the stored characteristic
    func sendCommand(_ command: String) {
        guard let characteristic = commandCharacteristic,
              let data = command.data(using: .utf8) else {
            print("Cannot send command - characteristic not found or invalid data")
            return
        }

        connectedPeripheral?.writeValue(data, for: characteristic, type: .withResponse)
    }

    func startScanning() {
        guard centralManager.state == .poweredOn else { return }
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
        isScanning = true
    }

    func stopScanning() {
        centralManager.stopScan()
        isScanning = false
    }

    func connect(to peripheral: CBPeripheral) {
        centralManager.connect(peripheral, options: nil)
    }

    func disconnect() {
        if let peripheral = connectedPeripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

extension BluetoothCentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Central Manager is powered on")
            self.startScanning()
        case .poweredOff:
            print("Bluetooth is powered off")
            isReady = false
        case .unauthorized:
            print("Bluetooth use is unauthorized")
            isReady = false
        case .unsupported:
            print("Bluetooth is not supported")
            isReady = false
        default:
            print("Unknown state")
            isReady = false
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(peripheral) {
            discoveredPeripherals.append(peripheral)
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        peripheral.delegate = self

        peripheral.discoverServices([serviceUUID])
//        self.sendCommand("stopAdvertising")
        self.stopScanning()
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        connectedPeripheral = nil
        commandCharacteristic = nil
        isReady = false
        self.startScanning()
    }
}

extension BluetoothCentralManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard error == nil else {
            print("Error discovering services: \(error!.localizedDescription)")
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            // Discover characteristics for our service
            peripheral.discoverCharacteristics([characteristicUUID], for: service)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard error == nil else {
            print("Error discovering characteristics: \(error!.localizedDescription)")
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            if characteristic.uuid == characteristicUUID {
                // Store the characteristic for later use
                commandCharacteristic = characteristic

                // Enable notifications if the characteristic supports it
                if characteristic.properties.contains(.notify) {
                    peripheral.setNotifyValue(true, for: characteristic)
                }

                // Mark the manager as ready to send commands
                isReady = true
            }
        }
    }

    // Handle incoming notifications from the peripheral
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil else {
            print("Error receiving notification: \(error!.localizedDescription)")
            return
        }

        if let data = characteristic.value,
           let response = String(data: data, encoding: .utf8) {
            print("Received response: \(response)")
        }
    }
}
#endif
