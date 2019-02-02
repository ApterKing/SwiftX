//
//  XBluetoothManager.swift
//  Swift-X
//
//  Created by wangcong on 2017/11/3.
//  Copyright © 2017 wangcong. All rights reserved.
//

import Foundation
import CoreBluetooth

// 用于绑定设备
@objc public protocol XBluetoothManagerDelegate: NSObjectProtocol {
    @objc optional func bluetoothWillStart(_ error: Error?)
    
    @objc optional func bluetoothShouldDelayDiscoverDevice() -> Bool
    @objc optional func bluetoothDidDiscoverDevice(_ name: String, _ identifier: String)
    @objc optional func bluetoothShouldAutoConnect() -> Bool
}

public class XBluetoothManager: NSObject {
    
    static let `default` = XBluetoothManager()
    
    private var centralManager: CBCentralManager!
    private var peripheral: CBPeripheral?
    
    var delegate: XBluetoothManagerDelegate? {
        didSet {
            shouldAutoConnect = delegate == nil
        }
    }
    var shouldAutoConnect: Bool = true
    
    private override init() {
        super.init()
    }
    
    func startup() {
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
}

extension XBluetoothManager {
    
    func start() {
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func stop() {
        centralManager.stopScan()
        if let peripheral = self.peripheral {
            centralManager.cancelPeripheralConnection(peripheral)
        }
    }
}

extension XBluetoothManager: CBCentralManagerDelegate {
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var message = ""
        switch central.state {
        case .unknown:
            message = "该设备不支持BLE蓝牙"
        case .resetting:
            message = "设备正在重置，请稍后..."
        case .unsupported:
            message = "该设备不支持BLE蓝牙"
        case .unauthorized:
            message = "设备未获得BLE蓝牙授权，请开启权限"
        case .poweredOff:
            message = "设备蓝牙未开启"
        default:
            message = "蓝牙已经成功开启"
        }
        if central.state != .poweredOn {
            _showAlert(message)
            delegate?.bluetoothWillStart?(NSError(domain: "XBluetoothManager", code: -1, userInfo: [NSLocalizedDescriptionKey: message]))
        } else {
            delegate?.bluetoothWillStart?(nil)
            
            if delegate?.bluetoothShouldDelayDiscoverDevice?() ?? false {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) { [weak self] () in
                    self?.start()
                }
            } else {
                start()
            }
        }
        NSLog("XBluttoothManager  centralManagerDidUpdateState: %d  %@", central.state.rawValue, message)
    }
    
    public func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        NSLog("XBluttoothManager  willRestoreState: %@", dict)
    }
    
    // 发现外设
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("XBluttoothManager  didDiscover: %@  advertisementData: %@   rssi: %@", peripheral, advertisementData, RSSI)
        if peripheral.name == "YunChen" && peripheral.state != .connected {
            self.peripheral = peripheral
            
            if delegate?.bluetoothShouldAutoConnect?() ?? true {
                centralManager.connect(self.peripheral!, options: nil)
            }
            delegate?.bluetoothDidDiscoverDevice?(peripheral.name ?? "", peripheral.identifier.uuidString)
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("XBluttoothManager  didConnect: %@", peripheral)
        centralManager.stopScan()
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("XBluttoothManager  didFailToConnect: %@   error: \(String(describing: error))", peripheral)
        peripheral.delegate = nil
        self.peripheral = nil
        start()
    }
    
    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        NSLog("XBluttoothManager  didDisconnectPeripheral: %@   error: \(String(describing: error))", peripheral)
        peripheral.delegate = nil
        self.peripheral = nil
        start()
    }
    
}

extension XBluetoothManager: CBPeripheralDelegate {
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        NSLog("XBluttoothManager  peripheralDidUpdateName: %@", peripheral)
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        NSLog("XBluttoothManager  peripheral: %@   didModifyServices: %@", peripheral, invalidatedServices)
    }
    
    public func peripheralDidUpdateRSSI(_ peripheral: CBPeripheral, error: Error?) {
        NSLog("XBluttoothManager  peripheralDidUpdateRSSI: %@   error: %@", peripheral, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        NSLog("XBluttoothManager  peripheral: %@   didReadRSSI: %@   error: %@", peripheral, RSSI, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("XBluttoothManager  peripheral: %@   didDiscoverServices: %@", peripheral, String(describing: error))
        if let services = peripheral.services {
            for service in services {
                peripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didDiscoverIncludedServicesFor: %@   error: %@", peripheral, service, String(describing: error))
    }
    
    // 发现设备特征值
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        NSLog("XBluttoothManager  peripheral: %@   didDiscoverCharacteristicsFor: %@   error: %@", peripheral, service.uuid, String(describing: error))
        guard service.uuid.isEqual(CBUUID(string: UUID_SERVICE)) else { return }
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid.isEqual(CBUUID(string: UUID_READ_NOTIFY)) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    //                    peripheral.readValue(for: characteristic)
                    peripheral.discoverCharacteristics(nil, for: service)
                    XBluetoothManager.send(for: peripheral, characteristic: characteristic)
                } else if characteristic.uuid.isEqual(CBUUID(string: UUID_WRITE_NOTIFY)) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    XBluetoothManager.send(for: peripheral, characteristic: characteristic)
                } else if characteristic.uuid.isEqual(CBUUID(string: UUID_WRITE_WITHOUT_NOTIFY)) {
                    peripheral.setNotifyValue(true, for: characteristic)
                    XBluetoothManager.send(for: peripheral, characteristic: characteristic)
                }
            }
        }
    }
    
    // 接收设备数据
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        NSLog("XBluttoothManager  peripheral: %@   didUpdateValueFor: %@   error: %@", peripheral, characteristic, String(describing: error))
        // 一个外设可能存在多个服务，必须满足UUID_SERVICE == "FFF0"才能够读取数据
        guard error == nil && characteristic.service.uuid.isEqual(CBUUID(string: UUID_SERVICE)) else { return }
        if characteristic.uuid.isEqual(CBUUID(string: UUID_READ_NOTIFY)) {
            if let value = characteristic.value {
                XBluetoothManager.parse(value)
            }
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didWriteValueFor: %@   error: %@", peripheral, characteristic, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didUpdateNotificationStateFor: %@   error: %@", peripheral, characteristic, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didDiscoverDescriptorsFor: %@   error: %@", peripheral, characteristic, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didUpdateValueFor: %@   error: %@", peripheral, descriptor, String(describing: error))
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor descriptor: CBDescriptor, error: Error?) {
        //        NSLog("XBluttoothManager  peripheral: %@   didWriteValueFor: %@   error: %@", peripheral, descriptor, String(describing: error))
    }
    
    public func peripheralIsReady(toSendWriteWithoutResponse peripheral: CBPeripheral) {
        //        NSLog("XBluttoothManager  toSendWriteWithoutResponse: %@", peripheral)
    }
}

