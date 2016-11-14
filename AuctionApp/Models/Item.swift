//
//  Item.swift
//  AuctionApp
//

import Foundation
import Firebase
import FirebaseDatabase

enum ItemWinnerType {
    case single
    case multiple
}

class Item {
    let itemRef: FIRDatabaseReference?
    //let allBidders: [String]
    //let closeTime: NSDate
    //let currentPrice: [Int]
    //let currentWinners: [String]
    //let description: String
    //let donorName: String
    //let imageUrl: String
    let name: String
    // let numberOfBids: Int
    // let openTime: NSDate
    // let price: Int
    // let priceIncrement: Int
    // let quantity: Int

    init(snapshot: FIRDataSnapshot) {
        let snapshotValue = snapshot.value as! [String: AnyObject]
        //allBidders = snapshotValue["allbidders"] as! [String]
        // closeTime = snapshotValue["closetime"] as! NSDate
        //currentPrice = snapshotValue["currentPrice"] as! [Int]
        //currentWinners = snapshotValue["currentWinners"] as! [String]
        // description = snapshotValue["longName"] as! String
        // donorName = snapshotValue["donorname"] as! String
        // imageUrl = snapshotValue["imageurl"] as! String
        name = snapshotValue["shortName"] as! String
        // numberOfBids = snapshotValue["numberOfBids"] as! Int
        // openTime = snapshotValue["opentime"] as! NSDate
        // price = snapshotValue["price"] as! Int
        // quantity = snapshotValue["qty"] as! Int
        itemRef = snapshot.ref
        //priceIncrement = 5
    }
    
}

