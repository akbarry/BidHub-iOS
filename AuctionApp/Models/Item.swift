//
//  Item.swift
//  AuctionApp
//

import UIKit

enum ItemWinnerType {
    case single
    case multiple
}

class Item: PFObject, PFSubclassing {
    
    private lazy var __once: () = {
            self.registerSubclass()
        }()
    
    @NSManaged var name:String
    @NSManaged var price:Int
    
    var priceIncrement:Int {
        get {
            if let priceIncrementUW = self["priceIncrement"] as? Int {
                return priceIncrementUW
            }else{
                return 5
            }
        }
    }
    
    var currentPrice:[Int] {
        get {
            if let array = self["currentPrice"] as? [Int] {
                return array
            }else{
                return [Int]()
            }
        }
        set {
            self["currentPrice"] = newValue
        }
    }
    
    var currentWinners:[String] {
        get {
            if let array = self["currentWinners"] as? [String] {
                return array
            }else{
                return [String]()
            }
        }
        set {
            self["currentWinners"] = newValue
        }
    }
    
    var allBidders:[String] {
        get {
            if let array = self["allBidders"] as? [String] {
                return array
            }else{
                return [String]()
            }
        }
        set {
            self["allBidders"] = newValue
        }
    }
    
    var numberOfBids:Int {
        get {
            if let numberOfBidsUW = self["numberOfBids"] as? Int {
                return numberOfBidsUW
            }else{
                return 0
            }
        }
        set {
            self["numberOfBids"] = newValue
        }
    }

    
    var donorName:String {
        get {
            if let donor =  self["donorname"] as? String{
                return donor
            }else{
                return ""
            }
        }
        set {
            self["donorname"] = newValue
        }
    }
    var imageUrl:String {
        get {
            if let imageURLString = self["imageurl"] as? String {
                return imageURLString
            }else{
                return ""
            }
        }
        set {
            self["imageurl"] = newValue
        }
    }
    

    var itemDesctiption:String {
        get {
            if let desc = self["description"] as? String{
                return desc
            }else{
                return ""
            }
        }
        set {
            self["description"] = newValue
        }
    }
    
    var quantity: Int {
        get {
            if let quantityUW =  self["qty"] as? Int{
                return quantityUW
            }else{
                return 0
            }
        }
        set {
            self["qty"] = newValue
        }
    }
    
    var openTime: Date {
        get {
            if let open =  self["opentime"] as? Date{
                return open
            }else{
                return Date()
            }
        }
    }
    
    var closeTime: Date {
        get {
            if let close =  self["closetime"] as? Date{
                return close
            }else{
                return Date()
            }
        }
    }
    
    var winnerType: ItemWinnerType {
        get {
            if quantity > 1 {
                return .multiple
            }else{
                return .single
            }
        }
    }

    var minimumBid: Int {
        get {
            if !currentPrice.isEmpty {
                return currentPrice.minElement()
            }else{
                return price
            }
        }
    }
    
    var isWinning: Bool {
        get {
            let user = PFUser.current()
            return currentWinners.contains(user.email)
        }
    }
    
    
    var hasBid: Bool {
        get {
            let user = PFUser.current()
            return allBidders.contains(user.email)
        }
    }
    
    override class func initialize() {
        var onceToken : Int = 0;
        _ = self.__once
    }
    
    class func parseClassName() -> String! {
        return "Item"
    }
}


