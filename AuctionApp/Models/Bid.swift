//
//  Bid.swift
//  AuctionApp
//

import UIKit

class Bid: PFObject, PFSubclassing {
    
    private lazy var __once: () = {
            self.registerSubclass()
        }()
    
    @NSManaged var email: String
    @NSManaged var name: String
    
    var amount: Int {
        get {
            return self["amt"] as! Int
        }
        set {
            self["amt"] = newValue
        }
    }
    
    var itemId: String {
        get {
            return self["item"] as! String
        }
        set {
            self["item"] = newValue
        }
    }
    
    //Needed
    override init(){
        super.init()
    }
    
    init(email: String, name: String, amount: Int, itemId: String) {
        super.init()
        self.email = email
        self.name = name
        self.amount = amount
        self.itemId = itemId
    }
    
    override class func initialize() {
        var onceToken : Int = 0;
        _ = self.__once
    }
    
    class func parseClassName() -> String! {
        return "NewBid"
    }
}

enum BidType {
    case extra(Int)
    case custom(Int)
}
