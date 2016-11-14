//
//  Bid.swift
//  AuctionApp
//

import Foundation
import FirebaseDatabase

struct Bid {
    
    let ref: FIRDatabaseReference?
    let email: String
    let name: String
    let amount: Int
    var itemId: String
    
    init(email: String, name: String, amount: Int, itemId: String) {
        self.email = email
        self.name = name
        self.amount = amount
        self.itemId = itemId
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        // key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        email = snapshotValue["email"] as! String
        amount = snapshotValue["amount"] as! Int
        itemId = snapshotValue["itemId"] as! String
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name
        ]
    }
    
}

enum BidType {
    case extra(Int)
    case custom(Int)
}
