//
//  XBluetoothManager+WB.swift
//  Witbeck
//
//  Created by wangcong on 2017/11/6.
//  Copyright © 2017 wangcong. All rights reserved.
//

import Foundation
import CoreBluetooth

let UUID_SERVICE = "FFF0"
let UUID_WRITE_NOTIFY = "FFF1"
let UUID_WRITE_WITHOUT_NOTIFY = "FFF1"
let UUID_WRITE = "FFF3"
let UUID_READ_NOTIFY = "FFF4"


/// MARK: 发送数据
extension XBluetoothManager {
    
    class public func send(for peripheral: CBPeripheral, characteristic: CBCharacteristic) {
//        let entity = WBUserEntity.current
//        let sex = (entity.isMale ? 0 : 1).toHexString()
//        let age = (entity.age == 0 ? 25 : entity.age).toHexString()
//        let height = (entity.height == 0 ? 175: Int(entity.height)).toHexString()
//        let waistline = (entity.waistline == 0 ? 80 : Int(entity.waistline)).toHexString()
//        let hipline = (entity.hipline == 0 ? 90 : Int(entity.hipline)).toHexString()
//        let verify = "A5".XORString(with: sex)
//            .XORString(with: age)
//            .XORString(with: height)
//            .XORString(with: waistline)
//            .XORString(with: hipline)
//
//        let dataString = "A5\(sex)\(age)\(height)\(waistline)\(hipline)\(verify)"
//
//        NSLog("send: \(dataString)     default: A50019AF505A19")
//        if let characteristics = characteristic.service.characteristics {
//            for achar in characteristics {
//                if achar.uuid.isEqual(CBUUID(string: UUID_WRITE_NOTIFY)) || achar.uuid.isEqual(CBUUID(string: UUID_WRITE_WITHOUT_NOTIFY)) {
//                    if let data = dataString.hexadecimal() {
//                        peripheral.writeValue(data, for: characteristic, type: .withResponse)
//                        if peripheral.canSendWriteWithoutResponse {
//                            peripheral.writeValue(data, for: characteristic, type: .withoutResponse)
//                        }
//                    }
//                }
//            }
//        }
    }
    
}

extension Int {
    func toHexString() -> String {
        let hex = String(self, radix: 16)
        return (hex.count <= 1 ? "0" + hex : hex).uppercased()
    }
}

extension String {
    
    func XORString(with string: String) -> String {
        let selfHex = self.withCString { strtol($0, nil, 16) }
        let stringHex = string.withCString { strtol($0, nil, 16) }
        
        let xor = String(format: "%lX", selfHex^stringHex)
        return (xor.count <= 1 ? "0" + xor : xor).uppercased()
    }
    
    func hexadecimal() -> Data? {
        var data = Data(capacity: count / 2)
        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, options: .anchored, range: NSMakeRange(0, utf16.count)) { (match, flags, stop) in
            let byteString = (self as NSString).substring(with: match!.range)
            var num = UInt8(byteString, radix: 16)!
            data.append(&num, count: 1)
        }
        guard data.count > 0 else { return nil }
        return data
    }
}

/// MARK: 解析数据
extension XBluetoothManager {
    static var kUID = "kUID_XBluetoothManager"
    
    // 每次正确称量的唯一标识
    static var uid: Int? {
        get {
            return objc_getAssociatedObject(self, &kUID) as? Int
        }
        set {
            objc_setAssociatedObject(self, &kUID, newValue, .OBJC_ASSOCIATION_COPY)
        }
    }
    
    class public func parse(_ data: Data) {
        
//        var dataString = String(format: "%@", data as CVarArg)
//        dataString = dataString.replacingOccurrences(of: ">", with: "")
//            .replacingOccurrences(of: "<", with: "")
//            .replacingOccurrences(of: " ", with: "")
//        print("parse  \(dataString)")
//
//        // 设备型号 0 2
//        let deviceType = dataString[safe: 0...1]
//        let verify = dataString[safe: dataString.count - 2...dataString.count - 1]
//        guard deviceType != verify else { return }
//
//        // //状态 2 2 (00 动态， 01 静态）
//        let deviceState = dataString[safe: 2...3]
//
//        if deviceState == "00" && dataString.count >= 38 {  // 此处最正确的数据还未读取，不作存储
//            uid = nil
//        } else if deviceState == "01" && dataString.count >= 38 {
//            let entity = WBMeasureEntity()
//            let user = WBUserEntity.current
//
//            if uid == nil {
//                uid = Int(Date().timestamp)
//            }
//            entity.id = XBluetoothManager.uid!
//            entity.measureAt = entity.id
//            entity.height = user.height
//
//            //体重4 4   / 100
//            if let weight = dataString[safe: 4...7] {
//                entity.weight = Double(weight.withCString({ strtol($0, nil, 16) })) / 100.0
//            }
//            let fHeight = user.height != 0 ? Double(user.height) / 100 : 1.7
//            entity.bmi = entity.weight / (fHeight * fHeight)
//
//            //脂肪含量 8 4  /10
//            if let fat = dataString[safe: 8...11] {
//                entity.fat =  Double(fat.withCString({ strtol($0, nil, 16) })) / 10.0
//            }
//
//            // 缺省 12 4
//
//            //水分含量 16 4  /10
//            if let water = dataString[safe: 16...19] {
//                entity.water =  Double(water.withCString({ strtol($0, nil, 16) })) / 10.0
//            }
//
//            //肌肉 20 4  /10
//            if let muscle = dataString[safe: 20...23] {
//                entity.muscle =  Double(muscle.withCString({ strtol($0, nil, 16) })) / 10.0
//            }
//
//            //骨骼重量 24 4  /10
//            if let bone = dataString[safe: 24...27] {
//                entity.bone =  Double(bone.withCString({ strtol($0, nil, 16) })) / 10.0
//            }
//
//            //基础代谢 28 4
//            if let bmr = dataString[safe: 28...31] {
//                entity.bmr =  Double(bmr.withCString({ strtol($0, nil, 16) }))
//            }
//
//            //内脏脂肪 32 2   / 10
//            if let visceralFat = dataString[safe: 32...33] {
//                entity.visceralFat =  Double(visceralFat.withCString({ strtol($0, nil, 16) })) / 10
//            }
//
//            //身体年龄 34 2
//            if let bodyage = dataString[safe: 34...35] {
//                var ibodyage =  bodyage.withCString({ strtol($0, nil, 16) })
//                if ibodyage <= 0 {
//                    let age = user.age != 0 ? user.age : 25
//                    let height = user.height != 0 ? user.height : 170
//                    if user.isMale {
//                        ibodyage = Int(entity.weight / (Double(height * height) * 10000 * Double(age))  / 23.0)
//                    } else {
//                        ibodyage = Int(entity.weight / (Double(height * height) * 10000 * Double(age))  / 21.5)
//                    }
//                }
//                if ibodyage <= 0 {
//                    ibodyage = 1
//                }
//                entity.bodyAge = ibodyage
//            }
//
//            // 缺省 36 2
//            // 校验 38 2
//
//            // save前将体重换算成 g (服务器存储的是g为单位）
//            let weight = entity.weight * 1000
//            entity.weight = weight
//            if XRealmManager.default.objects(WBMeasureEntity.self)?.filter("id = %@", entity.id).first == nil {
//                entity.save()
//
//                // 自动弹出健康报告
//                let healthyReportVC = WBHealthyReportViewController()
//                UIApplication.shared.keyWindow?.rootViewController?.present(healthyReportVC, animated: true, completion: nil)
//            }
//        }
    }
    
}

extension XBluetoothManager {
    func _showAlert(_ message: String) {
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
        alertController.show((UIApplication.shared.keyWindow?.rootViewController)!, sender: nil)
    }
}
