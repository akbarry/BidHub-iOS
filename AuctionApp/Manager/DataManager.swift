//
//  ItemManager.swift
//  AuctionApp
//

import UIKit


class DataManager: NSObject {
 
    var allItems: [Item] = [Item]()

    var timer:Timer?
    
    var sharedInstance : DataManager {
        struct Static {
            static let instance : DataManager = DataManager()
        }
        
        return Static.instance
    }
    
    
    func getItems(_ completion: @escaping ([Item], NSError?) -> ()){
        let query = Item.query()
        query?.limit = 1000
        query?.addAscendingOrder("closetime")
        query?.addAscendingOrder("name")
        query?.findObjectsInBackground { (results, error) -> Void in
            if error != nil{
                println("Error!! \(error)")
                completion([Item](), error as NSError?)
            }else{
                if let itemsUW = results as? [Item] {
                    self.allItems = itemsUW
                    completion(itemsUW, nil)
                }
            }
        }
    }
    
    func searchForQuery(_ query: String) -> ([Item]) {
        return applyFilter(.search(searchTerm: query))
    }
    
    func applyFilter(_ filter: FilterType) -> ([Item]) {
        return allItems.filter({ (item) -> Bool in
            return filter.predicate.evaluate(with: item)
        })
    }
    
    func bidOn(_ item:Item, amount: Int, completion: @escaping (Bool, _ errorCode: String) -> ()){
        
        let user = PFUser.current()
        
        Bid(email: (user?.email)!, name: (user?.username)!, amount: amount, itemId: item.objectId)
        .saveInBackground { (success, error) -> Void in
            
            if error != nil {
                
                if let errorString:String = error.userInfo?["error"] as? String{
                    completion(false, errorString)
                }else{
                    completion(false, "")
                }
                return
            }
            
            let newItemQuery: PFQuery = Item.query()
            newItemQuery.whereKey("objectId", equalTo: item.objectId)
            newItemQuery.getFirstObjectInBackground({ (item, error) -> Void in
                
                if let itemUW = item as? Item {
                    self.replaceItem(itemUW)
                }
                completion(true, "")
            })
            
            let channel = "a\(item.objectId)"
            PFPush.subscribeToChannel(inBackground: channel, block: { (success, error) -> Void in
                
            })
        }
    }
    
    func replaceItem(_ item: Item) {
        allItems = allItems.map { (oldItem) -> Item in
            if oldItem.objectId == item.objectId {
                return item
            }
            return oldItem
        }
    }
}


enum FilterType: CustomStringConvertible {
    case all
    case noBids
    case myItems
    case search(searchTerm: String)
    
    var description: String {
        switch self{
        case .all:
            return "All"
        case .noBids:
            return "NoBids"
        case .myItems:
            return "My Items"
        case .search:
            return "Searching"
        }
    }
    
    var predicate: NSPredicate {
        switch self {
        case .all:
            return NSPredicate(value: true)
        case .noBids:
            return NSPredicate(block: { (object, bindings) -> Bool in
                if let item = object as? Item {
                    return item.numberOfBids == 0
                }
                return false
            })
        case .myItems:
            return NSPredicate(block: { (object, bindings) -> Bool in
                if let item = object as? Item {
                    return item.hasBid
                }
                return false
            })

        case .search(let searchTerm):
            return NSPredicate(format: "(donorName CONTAINS[c] %@) OR (name CONTAINS[c] %@) OR (itemDesctiption CONTAINS[c] %@)", searchTerm)
        default:
            return NSPredicate(value: true)
        }
    }
}
