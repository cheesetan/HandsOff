//
//  PeripheralManager.swift
//  HandsOff
//
//  Created by Tristan Chay on 17/1/25.
//

import SwiftUI
import CoreBluetooth

#if os(macOS)
class BluetoothPeripheralManager: NSObject, ObservableObject {
    @Published var isAdvertising = false

    private var peripheralManager: CBPeripheralManager!
    private let serviceUUID = CBUUID(string: "C3EF2166-C690-45BA-8254-D31C1959AE91")
    private var commandCharacteristic: CBMutableCharacteristic!

    override init() {
        super.init()
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }

    func startAdvertising() {
        guard peripheralManager.state == .poweredOn else { return }

        commandCharacteristic = CBMutableCharacteristic(
            type: CBUUID(string: "C3EF2166-C690-45BA-8254-D31C1959AE91"),
            properties: [.write, .notify],
            value: nil,
            permissions: [.writeable]
        )

        // Create the service
        let service = CBMutableService(type: serviceUUID, primary: true)
        service.characteristics = [commandCharacteristic]

        // Add the service
        peripheralManager.add(service)

        // Start advertising
        peripheralManager.startAdvertising([
            CBAdvertisementDataServiceUUIDsKey: [serviceUUID],
            CBAdvertisementDataLocalNameKey: "MyMacDevice"
        ])

        isAdvertising = true
    }

    func stopAdvertising() {
        peripheralManager.stopAdvertising()
        isAdvertising = false
    }

    func lockDevice() {
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
}

extension BluetoothPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .poweredOn:
            print("Peripheral Manager is powered on")
            self.startAdvertising()
        case .poweredOff:
            print("Bluetooth is powered off")
        case .unauthorized:
            print("Bluetooth use is unauthorized")
        case .unsupported:
            print("Bluetooth is not supported")
        default:
            print("Unknown state")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for request in requests {
            if let data = request.value {
                handleCommand(data)
            }
            peripheralManager.respond(to: request, withResult: .success)
        }
    }

    private func handleCommand(_ data: Data) {
        if let command = String(data: data, encoding: .utf8) {
            if command == "lock" {
                self.lockDevice()
            } else if command == "stopAdvertising" {
                self.stopAdvertising()
            }
        }
    }
}
#endif
