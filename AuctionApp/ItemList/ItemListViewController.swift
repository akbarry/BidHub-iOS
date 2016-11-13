//
//  ItemListViewController.swift
//  AuctionApp
//

import UIKit

extension String {
    subscript (i: Int) -> String {
        return String(Array(self)[i])
    }
}

class ItemListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate,ItemTableViewCellDelegate, BiddingViewControllerDelegate {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var segmentControl: UISegmentedControl!
    @IBOutlet var tableView: UITableView!
    var refreshControl: UIRefreshControl = UIRefreshControl()
    var items:[Item] = [Item]()
    var timer:Timer?
    var filterType: FilterType = .all
    var sizingCell: ItemTableViewCell?
    var bottomContraint:NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        SVProgressHUD.setForegroundColor(UIColor(red: 157/225, green: 19/225, blue: 43/225, alpha: 1.0))
        SVProgressHUD.setRingThickness(2.0)
        
        
        let colorView:UIView = UIView(frame: CGRect(x: 0, y: -1000, width: view.frame.size.width, height: 1000))
        colorView.backgroundColor = UIColor.white
        tableView.addSubview(colorView)

        //Refresh Control
        let refreshView = UIView(frame: CGRect(x: 0, y: 10, width: 0, height: 0))
        tableView.insertSubview(refreshView, aboveSubview: colorView)

        refreshControl.tintColor = UIColor(red: 157/225, green: 19/225, blue: 43/225, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(ItemListViewController.reloadItems), for: .valueChanged)
        refreshView.addSubview(refreshControl)
        
        
        sizingCell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell") as? ItemTableViewCell

        if iOS8 {
            tableView.estimatedRowHeight = 392
            tableView.rowHeight = UITableViewAutomaticDimension
        }
        self.tableView.alpha = 0.0
        reloadData(false, initialLoad: true)

        let user = PFUser.current()
        println("Logged in as: \(user.email)")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(ItemListViewController.pushRecieved(_:)), name: NSNotification.Name(rawValue: "pushRecieved"), object: nil)
        timer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(ItemListViewController.reloadItems), userInfo: nil, repeats: true)
        timer?.tolerance = 10.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
        timer?.invalidate()
    }
    
    
    func pushRecieved(_ notification: Notification){
        
        if let aps = notification.object?["aps"] as? [AnyHashable: Any]{
            if let alert = aps["alert"] as? String {
                CSNotificationView.show(in: self, tintColor: UIColor.white, font: UIFont(name: "Avenir-Light", size: 14)!, textAlignment: .center, image: nil, message: alert, duration: 5.0)
                
            }
        }
        reloadData()
        
        
    }
    
    //Hack for selectors and default parameters
    func reloadItems(){
        reloadData()
    }
    
    func reloadData(_ silent: Bool = true, initialLoad: Bool = false) {
        if initialLoad {
            SVProgressHUD.show()
        }
        DataManager().sharedInstance.getItems{ (items, error) in
        
            if error != nil {
                //Error Case
                if !silent {
                    self.showError("Error getting Items")
                }
                println("Error getting items")
                
            }else{
                self.items = items
                self.filterTable(self.filterType)
            }
            self.refreshControl.endRefreshing()
            
            if initialLoad {
                SVProgressHUD.dismiss()
                UIView.animate(withDuration: 1.0, animations: { () -> Void in
                    self.tableView.alpha = 1.0
                })
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if iOS8 {
            return UITableViewAutomaticDimension
        }else{

            if let cell = sizingCell {
                
                let padding = 353
                let minHeightText: NSString = "\n\n"
                let font = UIFont(name: "Avenir Light", size: 15.0)!
                let attributes =  [NSFontAttributeName: font] as NSDictionary
                let item = items[indexPath.row]
                
                let minSize = minHeightText.boundingRectWithSize(CGSize(width: (view.frame.size.width - 40), height: 1000), options: .UsesLineFragmentOrigin, attributes: attributes as! [AnyHashable : Any] as [AnyHashable: Any], context: nil).height
                
                let maxSize = item.itemDesctiption.boundingRectWithSize(CGSize(width: (view.frame.size.width - 40), height: 1000), options: .UsesLineFragmentOrigin, attributes: attributes as! [AnyHashable : Any] as [AnyHashable: Any], context: nil).height + 50
                
                return (max(minSize, maxSize) + CGFloat(padding))

            }else{
                return 392
            }
            
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemTableViewCell", for: indexPath) as! ItemTableViewCell
        
        return configureCellForIndexPath(cell, indexPath: indexPath)
    }
    
    func configureCellForIndexPath(_ cell: ItemTableViewCell, indexPath: IndexPath) -> ItemTableViewCell {
        let item = items[indexPath.row]
        
        cell.itemImageView.image = nil
        var url:URL = URL(string: item.imageUrl)!
        cell.itemImageView.setImageWith(url)
        

        let fullNameArr = item.donorName.components(separatedBy: " ")
        cell.donorAvatar.image = nil;
        if fullNameArr.count > 1{
            var firstName: String = fullNameArr[0]
            var lastName: String = fullNameArr[1]
            var inital: String = firstName[0]
            var donorAvatarStringUrl = "https://api.hubapi.com/socialintel/v1/avatars?email=\(inital)\(lastName)@hubspot.com"

            var donorAvatarUrl:URL = URL(string: donorAvatarStringUrl)!
            
            cell.donorAvatar.setImageWith(URLRequest(url: donorAvatarUrl), placeholderImage: nil, success: { (urlRequest: URLRequest!, response: URLResponse!, image: UIImage!) -> Void in
                cell.donorAvatar.image = image.resizedImage(to: cell.donorAvatar.bounds.size)
                
            }, failure: { (urlRequest: URLRequest!, response: URLResponse!, error: NSError!) -> Void in
                println("error occured: \(error)")
            })
        }
        
        cell.itemDonorLabel.text = item.donorName
        cell.itemTitleLabel.text = item.name
        cell.itemDescriptionLabel.text = item.itemDesctiption
        
        if item.quantity > 1 {
            var bidsString = ", ".join(item.currentPrice.map({bidPrice in "$\(bidPrice)"}))
            if count(bidsString) == 0 {
                bidsString = "(none yet)"
            }
            
            cell.itemDescriptionLabel.text =
                "\(item.quantity) available! Highest \(item.quantity) bidders win. Current highest bids are \(bidsString)" +
                "\n\n" + cell.itemDescriptionLabel.text!
        }
        cell.delegate = self;
        cell.item = item
        
        var price: Int?
        var lowPrice: Int?

        switch (item.winnerType) {
        case .single:
            price = item.currentPrice.first
            cell.availLabel.text = "1 Available"
        case .multiple:
            price = item.currentPrice.first
            lowPrice = item.currentPrice.last
            cell.availLabel.text = "\(item.quantity) Available"
        }
        
        let bidString = (item.numberOfBids == 1) ? "Bid":"Bids"
        cell.numberOfBidsLabel.text = "\(item.numberOfBids) \(bidString)"
        
        if let topBid = price {
            if let lowBid = lowPrice{
                if item.numberOfBids > 1{
                    cell.currentBidLabel.text = "$\(lowBid)-\(topBid)"
                }else{
                    cell.currentBidLabel.text = "$\(topBid)"
                }
            }else{
                cell.currentBidLabel.text = "$\(topBid)"
            }
        }else{
            cell.currentBidLabel.text = "$\(item.price)"
        }
        
        if !item.currentWinners.isEmpty && item.hasBid{
            if item.isWinning{
                cell.setWinning()
            }else{
                cell.setOutbid()
            }
        }else{
            cell.setDefault()
        }
        
        if(item.closeTime.timeIntervalSinceNow < 0.0){
            cell.dateLabel.text = "Sorry, bidding has closed"
            cell.bidNowButton.isHidden = true
        }else{
            if(item.openTime.timeIntervalSinceNow < 0.0){
                //open
                cell.dateLabel.text = "Bidding closes \((item.closeTime as NSDate).relativeTime().lowercased())."
                cell.bidNowButton.isHidden = false
            }else{
                cell.dateLabel.text = "Bidding opens \((item.openTime as NSDate).relativeTime().lowercased())."
                cell.bidNowButton.isHidden = true
            }
        }
        
        return cell
    }
    
    //Cell Delegate
    func cellDidPressBid(_ item: Item) {
        
        
        let bidVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "BiddingViewController") as? BiddingViewController
        if let biddingVC = bidVC {
            biddingVC.delegate = self
            biddingVC.item = item
            addChildViewController(biddingVC)
            view.addSubview(biddingVC.view)
            biddingVC.didMove(toParentViewController: self)
        }
    }
        
    @IBAction func logoutPressed(_ sender: AnyObject) {
        PFUser.logOut()
        performSegue(withIdentifier: "logoutSegue", sender: nil)
    }
    
    @IBAction func segmentBarValueChanged(_ sender: AnyObject) {
        searchBar.resignFirstResponder()
        searchBar.text = ""
        let segment = sender as! UISegmentedControl
        switch(segment.selectedSegmentIndex) {
        case 0:
          filterTable(.all)
        case 1:
            filterTable(.noBids)
        case 2:
            filterTable(.myItems)
        default:
            filterTable(.all)
        }
    }
    
    func filterTable(_ filter: FilterType) {
        filterType = filter
        self.items = DataManager().sharedInstance.applyFilter(filter)
        self.tableView.reloadData()
    }
    
    func bidOnItem(_ item: Item, amount: Int) {
        
        SVProgressHUD.show()
        
        DataManager().sharedInstance.bidOn(item, amount: amount) { (success, errorString) -> () in
            if success {
                println("Wohooo")
                self.items = DataManager().sharedInstance.allItems
                self.reloadData()
                SVProgressHUD.dismiss()
            }else{
                self.showError(errorString)
                self.reloadData()
                SVProgressHUD.dismiss()
            }
        }
    }
    
    
    func showError(_ errorString: String) {
        
        if let gotModernAlert: AnyClass = NSClassFromString("UIAlertController") {
            
            
            //make and use a UIAlertController
            let alertView = UIAlertController(title: "Error", message: errorString, preferredStyle: .alert)

            let okAction = UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
                println("Ok Pressed")
            })
            
            alertView.addAction(okAction)
            self.present(alertView, animated: true, completion: nil)
        }
        else {
            
            //make and use a UIAlertView
            
            let alertView = UIAlertView(title: "Error", message: errorString, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "Ok")
            alertView.show()
        }
    }
    
    
    
    ///Search Bar
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filterTable(.all)
        }else{
            filterTable(.search(searchTerm:searchText))
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.segmentBarValueChanged(segmentControl)
        searchBar.resignFirstResponder()
    }
    
    ///Bidding VC
    
    func biddingViewControllerDidBid(_ viewController: BiddingViewController, onItem: Item, amount: Int){
        viewController.view.removeFromSuperview()
        bidOnItem(onItem, amount: amount)
    }
    
    func biddingViewControllerDidCancel(_ viewController: BiddingViewController){
        viewController.view.removeFromSuperview()
    }
}

