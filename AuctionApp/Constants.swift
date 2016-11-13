//
//  Constants.swift
//  AuctionApp
//

import UIKit

let Device = UIDevice.current

private let iosVersion = NSString(string: Device.systemVersion).doubleValue

let iOS10 = iosVersion >= 10
let iOS9 = iosVersion >= 9 && iosVersion < 10
let iOS8 = iosVersion >= 8 && iosVersion < 9
let iOS7 = iosVersion >= 7 && iosVersion < 8
