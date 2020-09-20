//
//  OrderDetailsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/11/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import SummerSlider
import GoogleMaps
import MBProgressHUD
import Toaster
import Cosmos
import Lottie
import MapKit

class UserOrderDetailsVC: UIViewController , Dimmable {
  
    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var loadingScreenView: UIView!
    @IBOutlet weak var menuOptions: UIBarButtonItem!
    @IBOutlet weak var transparentView: UIView!
    @IBOutlet weak var mapOnlyIcon: UIBarButtonItem!

    //order  info
    @IBOutlet weak var orderInfoView: UIView!
    @IBOutlet weak var orderNumView: UIView!
    @IBOutlet weak var orderNumLbl: UILabel!
    @IBOutlet weak var orderDeliveryDurationLbl: UILabel!
    @IBOutlet weak var orderStatusLbl: UILabel!
    @IBOutlet weak var orderStatusLblWidth: NSLayoutConstraint!
    @IBOutlet weak var orderDestinationLbl: UILabel!
    @IBOutlet weak var orderSourceLbl: UILabel!
    @IBOutlet weak var orderDateLbl: UILabel!
    @IBOutlet weak var orderDotsHeight: NSLayoutConstraint!
    @IBOutlet weak var orderDotsImg: UIImageView!
    @IBOutlet weak var orderNewDistanceFullView: UIView!
    @IBOutlet weak var orderNewDistanceBgView: UIView!
    @IBOutlet weak var orderNewDistanceCirlcleView: UIView!
    @IBOutlet weak var orderNewDistanceLbl: UILabel!
    @IBOutlet weak var orderPickupImg: UIImageView!
    @IBOutlet weak var pickupPinTop: NSLayoutConstraint!
    // full distance view
    @IBOutlet weak var orderDistanceFullView: UIView!
    @IBOutlet weak var orderFromDistanceBgView: UIView!
    @IBOutlet weak var orderFromDistanceCirlcleView: UIView!
    @IBOutlet weak var orderFromDistanceLbl: UILabel!
    @IBOutlet weak var orderToDistanceBgView: UIView!
    @IBOutlet weak var orderToDistanceCirlcleView: UIView!
    @IBOutlet weak var orderToDistanceLbl: UILabel!
    
    //order details
    @IBOutlet weak var orderDetailsView: UIView!
    @IBOutlet weak var orderDetailsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderDetailsFullView: UIView!
    @IBOutlet weak var orderDetailsTitleLbl: UILabel!
    @IBOutlet weak var orderDetailsArrowImg: UIImageView!
    @IBOutlet weak var orderDetailsDescLbl: UILabel!
    @IBOutlet weak var orderDetailsCancellationLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var playRecordIcon : UIImageView!
    @IBOutlet weak var recordSlider:SummerSlider!
    @IBOutlet weak var playingTimerLbl : UILabel!
    @IBOutlet weak var recordTimeLbl : UILabel!
    @IBOutlet weak var recordHeight: NSLayoutConstraint!
    @IBOutlet weak var recordView: UIView!

    //order offers
    @IBOutlet weak var orderOffersView: UIView!
    @IBOutlet weak var orderOffersLoadingView: UIView!
    @IBOutlet weak var orderOffersViewHeight: NSLayoutConstraint!
    @IBOutlet weak var orderOffersTitleLbl: UILabel!
    @IBOutlet weak var orderOffersArrowImg: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    //waiting offers
    @IBOutlet weak var waitingOffersView: UIView!
    @IBOutlet weak var waitingOffersTitleLbl: UILabel!
    @IBOutlet weak var waitingOffersTimeLbl: UILabel!
    @IBOutlet weak var cancelLbl: UILabel!
    @IBOutlet weak var cancelView: UIView!
    
    //refresh search
    @IBOutlet weak var refreshSerarchView: UIView!
    @IBOutlet weak var refreshSerarchTitleLbl: UILabel!
    @IBOutlet weak var refreshSerarchTitleTop: NSLayoutConstraint!
    @IBOutlet weak var refreshSerarchLbl: UILabel!
    @IBOutlet weak var refreshCancelLbl: UILabel!
    @IBOutlet weak var refreshCancelView: UIView!
    
    //accepted offer view
    @IBOutlet weak var acceptedOfferView: UIView!
    @IBOutlet weak var acceptedOfferGrayView: UIView!
    @IBOutlet weak var delegateProfileImg: UIImageView!
    @IBOutlet weak var delegateNameLbl: UILabel!
    @IBOutlet weak var acceptedTotalTitleLbl: UILabel!
    @IBOutlet weak var acceptedTotalTitleWidth: NSLayoutConstraint!
    @IBOutlet weak var acceptedTotalLbl: UILabel!
    @IBOutlet weak var shippingCostTitleLbl: UILabel!
    @IBOutlet weak var shippingCostValueLbl: UILabel!
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var vatValueLbl: UILabel!
    @IBOutlet weak var itemPriceTitleLbl: UILabel!
    @IBOutlet weak var itemPriceValueLbl: UILabel!
    @IBOutlet weak var itemPriceView: UIView!
    @IBOutlet weak var addedToWalletTitleLbl: UILabel!
    @IBOutlet weak var addedToWalletLbl: UILabel!
    @IBOutlet weak var addedToWalletView: UIView!
    @IBOutlet weak var addedToWalletTop: NSLayoutConstraint!
    @IBOutlet weak var addedToWalletBottom: NSLayoutConstraint!
    @IBOutlet weak var discountTitleLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var acceptedOfferViewTop: NSLayoutConstraint!
    @IBOutlet weak var addRateLbl: UILabel!
    @IBOutlet weak var addRateView: UIView!
    @IBOutlet weak var starRateView: CosmosView!
    @IBOutlet weak var callLbl: UILabel!

    //reorder view in invoice
    @IBOutlet weak var acceptedReorderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var acceptedReorderLbl: UILabel!
    @IBOutlet weak var acceptedReorderView: UIView!
    
    //reorder sperated view
    @IBOutlet weak var reorderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var reorderLbl: UILabel!
    @IBOutlet weak var reorderView: UIView!
    
    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var orderImages = [DelegateImageData]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let orderDetailsManager = OrderDetailsManager()
    var loadingView: MBProgressHUD!
    var orderDetailsPresenter : UserOrderDetailsPresenter!
    var orderID = 0
    var order = Order()
    var offers = [Offer]()
    var pickupLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var mapPoints = [CLLocationCoordinate2D]()
    let WEB_API_KEY = AppKeys.WEB_API_KEY
    var selectedImage = Image()
    var needToClearMap = false
    var isFromPushNotifications = false
    var alertManager = AlertManager()
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    private var boatAnimation: LOTAnimationView?

    // if isFromChat so we render order details page .. else check the status to know if we should navigate to chat or render order details page
    var isFromChat = false
    var isNeedToBackToOrders = false
    var orderTimer = Timer()
    var isNeedToRefreshDelegates = false
    var needCheckTimer = true

    //tracking variables
    var carMarker : GMSMarker!
    let trackingManager = TrackingManager()
    var distanceToPickup = 0.0
    var distanceToDestination = 0.0
    var delegateLocation = CLLocation()
    var isDelegateRouteDrawed = false
    var isPickupRouteDrawed = false
    var delegatePolyline = GMSPolyline()
    var deliveryPolyline = GMSPolyline()
    
    //0 .. for new without delegate  1.. before pickup item   2 .. after pickup   3.. after end the ride
    var orderRouteStatus = 0
    //update distance
    var delegateDistance = 0.0
    var delegateOldLocation = CLLocation()
    var delegateCurrentLocation = CLLocation()
    
    var areaManager = AreaManager()
    var selectedDelegateID = 0
    var showCancelOrder = false
    
    var isMapShowedOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderDetailsPresenter = UserOrderDetailsPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        orderDetailsPresenter.setView(view: self)
        orderDetailsPresenter.getCustomerOrderDetails(id: orderID)
        mapView.delegate = self
        setUI()
        setFonts()
        setGestures()
        setLocalization()
    }
  
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if needToClearMap{
            if mapView != nil{
                mapView.clear()
                mapView.stopRendering()
                mapView.removeFromSuperview()
                mapView = nil
            }
        }
    }
    
    func setUI(){
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "my_order".localized()

        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        recordView.isHidden = true
        noNetworkView.isHidden = true
        refreshSerarchView.isHidden = true
        acceptedOfferView.isHidden = true
        
        orderNewDistanceLbl.text = ""
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")            
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
        
        orderDetailsManager.setCornerRadius(selectedView: orderInfoView, radius: 12)
        orderDetailsManager.setShadow(selectedView: orderInfoView)
        orderDetailsManager.setCornerRadius(selectedView: orderNumView, radius: 10)
        orderDetailsManager.setCornerRadius(selectedView: waitingOffersView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: refreshSerarchView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: cancelView, radius: 6)
        orderDetailsManager.setCornerRadius(selectedView: refreshCancelView, radius: 6)
        orderDetailsManager.setShadow(selectedView: cancelView)
        orderDetailsManager.setShadow(selectedView: refreshCancelView)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceCirlcleView, radius: 3.5)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceFullView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: acceptedOfferView, radius: 12)
        orderDetailsManager.setShadow(selectedView: acceptedOfferView)
        orderDetailsManager.setCornerRadius(selectedView: acceptedOfferGrayView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: delegateProfileImg, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: reorderView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: acceptedReorderView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: orderDistanceFullView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: orderFromDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderFromDistanceCirlcleView, radius: 3.5)
        orderDetailsManager.setCornerRadius(selectedView: orderToDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderToDistanceCirlcleView, radius: 3.5)

        orderFromDistanceLbl.text = ""
        orderToDistanceLbl.text = ""
        collapseOrderDetails()
        collapseOffers()
        setMapStyle()
        
        //hide menu options
        self.menuOptions.tintColor = UIColor.clear
        self.menuOptions.isEnabled = false
        
        //hide vat
        vatTitleLbl.text = ""
        vatValueLbl.text = ""
        vatTitleLbl.isHidden = true
        vatValueLbl.isHidden = true
    }
    
    func setFonts(){
        orderNumLbl.font = Utils.customDefaultFont(orderNumLbl.font.pointSize)
        orderDeliveryDurationLbl.font = Utils.customDefaultFont(orderDeliveryDurationLbl.font.pointSize)
        orderStatusLbl.font = Utils.customBoldFont(orderStatusLbl.font.pointSize)
        orderDestinationLbl.font = Utils.customDefaultFont(orderDestinationLbl.font.pointSize)
        orderSourceLbl.font = Utils.customDefaultFont(orderSourceLbl.font.pointSize)
        orderDateLbl.font = Utils.customDefaultFont(orderDateLbl.font.pointSize)
        orderNewDistanceLbl.font = Utils.customDefaultFont(orderNewDistanceLbl.font.pointSize)
        orderFromDistanceLbl.font = Utils.customDefaultFont(orderFromDistanceLbl.font.pointSize)
        orderToDistanceLbl.font = Utils.customDefaultFont(orderToDistanceLbl.font.pointSize)
        
        orderDetailsTitleLbl.font = Utils.customBoldFont(orderDetailsTitleLbl.font.pointSize)
        orderDetailsDescLbl.font = Utils.customDefaultFont(orderDetailsDescLbl.font.pointSize)
        orderDetailsCancellationLbl.font = Utils.customDefaultFont(orderDetailsCancellationLbl.font.pointSize)
        
        waitingOffersTimeLbl.font = Utils.customDefaultFont(waitingOffersTimeLbl.font.pointSize)
        waitingOffersTitleLbl.font = Utils.customDefaultFont(waitingOffersTitleLbl.font.pointSize)
        cancelLbl.font = Utils.customDefaultFont(cancelLbl.font.pointSize)
        
        refreshSerarchTitleLbl.font = Utils.customDefaultFont(refreshSerarchTitleLbl.font.pointSize)
        refreshSerarchLbl.font = Utils.customDefaultFont(refreshSerarchLbl.font.pointSize)
        refreshCancelLbl.font = Utils.customDefaultFont(refreshCancelLbl.font.pointSize)

        orderOffersTitleLbl.font = Utils.customBoldFont(orderOffersTitleLbl.font.pointSize)
        
        shippingCostTitleLbl.font = Utils.customDefaultFont(shippingCostTitleLbl.font.pointSize)
        vatTitleLbl.font = Utils.customDefaultFont(vatTitleLbl.font.pointSize)
        acceptedTotalTitleLbl.font = Utils.customDefaultFont(acceptedTotalTitleLbl.font.pointSize)
        delegateNameLbl.font = Utils.customDefaultFont(delegateNameLbl.font.pointSize)
        acceptedTotalLbl.font = Utils.customBoldFont(acceptedTotalLbl.font.pointSize)
        shippingCostValueLbl.font = Utils.customBoldFont(shippingCostValueLbl.font.pointSize)
        vatValueLbl.font = Utils.customBoldFont(vatValueLbl.font.pointSize)
        itemPriceTitleLbl.font = Utils.customDefaultFont(itemPriceTitleLbl.font.pointSize)
        addedToWalletTitleLbl.font = Utils.customDefaultFont(addedToWalletTitleLbl.font.pointSize)
        addedToWalletLbl.font = Utils.customBoldFont(addedToWalletLbl.font.pointSize)
        discountTitleLbl.font = Utils.customDefaultFont(discountTitleLbl.font.pointSize)
        discountLbl.font = Utils.customBoldFont(discountLbl.font.pointSize)
        itemPriceValueLbl.font = Utils.customBoldFont(itemPriceValueLbl.font.pointSize)
        addRateLbl.font = Utils.customDefaultFont(addRateLbl.font.pointSize)
        reorderLbl.font = Utils.customDefaultFont(reorderLbl.font.pointSize)
        acceptedReorderLbl.font = Utils.customDefaultFont(acceptedReorderLbl.font.pointSize)
        callLbl.font = Utils.customDefaultFont(callLbl.font.pointSize)

        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    func setGestures(){
        let orderTab = UITapGestureRecognizer(target: self, action: #selector(self.orderDetailsPressed))
        orderTab.cancelsTouchesInView = false
        orderDetailsFullView.addGestureRecognizer(orderTab)
        
        let orderImagesTab = UITapGestureRecognizer(target: self, action: #selector(self.orderCollectionPressed))
        orderImagesTab.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(orderImagesTab)
        
        let offersTab = UITapGestureRecognizer(target: self, action: #selector(self.offersPressed))
        orderOffersView.addGestureRecognizer(offersTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
        
        let refreshTap = UITapGestureRecognizer(target: self, action: #selector(refreshDelegateAction))
        refreshSerarchLbl.addGestureRecognizer(refreshTap)
        
        let cancelLabelTap = UITapGestureRecognizer(target: self, action: #selector(cancelOrder))
        cancelLbl.addGestureRecognizer(cancelLabelTap)
        
        let cancelViewTap = UITapGestureRecognizer(target: self, action: #selector(cancelOrder))
        cancelView.addGestureRecognizer(cancelViewTap)
        
        let refreshCancelViewTap = UITapGestureRecognizer(target: self, action: #selector(cancelOrder))
        refreshCancelView.addGestureRecognizer(refreshCancelViewTap)
        
        let refreshCancelLabelTap = UITapGestureRecognizer(target: self, action: #selector(cancelOrder))
        refreshCancelLbl.addGestureRecognizer(refreshCancelLabelTap)
//        let gesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged))
//        orderOffersView.addGestureRecognizer(gesture)
//        orderOffersView.isUserInteractionEnabled = true
        
        let addRateTap = UITapGestureRecognizer(target: self, action: #selector(showRate))
        addRateLbl.addGestureRecognizer(addRateTap)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        
        cancelLbl.text = "editCancel".localized()
        orderDetailsTitleLbl.text = "my_order_items".localized()
        waitingOffersTitleLbl.text = "waiting_for_delegates".localized()
        orderOffersTitleLbl.text = "offers".localized()
        
        shippingCostTitleLbl.text = "Shipping_cost".localized()
//        vatTitleLbl.text = "VAT".localized()
        acceptedTotalTitleLbl.text = "totalOffer".localized()
        acceptedTotalTitleWidth.constant = acceptedTotalTitleLbl.intrinsicContentSize.width
        itemPriceTitleLbl.text = "item_price".localized()
        addedToWalletTitleLbl.text = "added_to_wallet".localized()
        addRateLbl.text = "add_rate".localized()
        discountTitleLbl.text = "discount".localized()

        refreshSerarchLbl.text = "no_deleagte_refresh".localized()
        refreshSerarchTitleLbl.text = "no_delegates".localized()
        refreshCancelLbl.text = "editCancel".localized()
        callLbl.text = "call".localized()
        
        reorderLbl.text = "reorder".localized()
        acceptedReorderLbl.text = "reorder".localized()
    }
    
    func setMapStyle(){
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                if mapView != nil{
                    mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                }
                
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    
  
    @objc func cancelOrder(){
//        self.view.isUserInteractionEnabled = true
//
//        let alert = UIAlertController(title: "", message:"cancelOrderAlert".localized(), preferredStyle: UIAlertController.Style.alert)
//        alert.setValue(NSAttributedString(string: "cancelOrderAlert".localized(), attributes: [NSAttributedString.Key.font : Utils.customDefaultFont(15.0)
//            , NSAttributedString.Key.foregroundColor : Colors.hexStringToUIColor(hex: "e84450")]), forKey: "attributedMessage")
//
//        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
//            print("user choose to cancel order")
//            if self.order.id != nil{
//                self.orderDetailsPresenter.cancelOrder(id: self.order.id!, reason: 0)
//            }
//
//        }))
//        //change text color of alert view buttons
//        alert.view.tintColor = Colors.hexStringToUIColor(hex: "212121")
//        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
//        topMostController().present(alert, animated: true, completion: nil)
        
        showCancelOrder = true
        self.performSegue(withIdentifier: "menuOptions", sender: self)
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    @objc func setOrderTimer(){
        if needCheckTimer{
            refreshSerarchView.isHidden = true
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            dateFormatter.locale = Locale(identifier: "en_US_POSIX")
            dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
            var startDateStr = ""
            if order.search_delegates_started_at != nil{
                startDateStr = order.search_delegates_started_at!
            }else  if order.created_at != nil{
                startDateStr = order.created_at!
            }
            if startDateStr != ""{
                let startDate = dateFormatter.date(from: startDateStr)
                let endDate = Date()
                if startDate != nil{
                    if !isNeedToRefreshDelegates{
                        let interval = endDate.timeIntervalSince(startDate!)
                        if orderDetailsManager.isSearchForDelagtesValid(time: interval){
                            //valid so view timer
                            refreshSerarchView.isHidden = true
                            waitingOffersTimeLbl.text = orderDetailsManager.getCountDownString(time: interval)
                        }else{
                            // not valid so view refresh fo delegates
                            if !isMapShowedOnly{ //view order normaly
                                refreshSerarchView.isHidden = false
                            }
//                            refreshSerarchTitleLbl.text = "search_timeout".localized()
                            refreshSerarchTitleLbl.text = ""
                            waitingOffersView.isHidden = true
                            refreshSerarchTitleTop.constant = 6
//                            orderTimer.invalidate()
                        }
                    }else{
//                        refreshSerarchTitleLbl.text = "search_timeout".localized()
                        refreshSerarchTitleLbl.text = ""
                        if !isMapShowedOnly{ //view order normaly
                            refreshSerarchView.isHidden = false
                        }
                        refreshSerarchTitleLbl.text = "no_delegates".localized()
                        refreshSerarchTitleTop.constant = 12
                        if order.status != nil{
                            if order.status == "pending"{
                                if !isMapShowedOnly{ //view order normaly
                                    refreshSerarchView.isHidden = false
                                }
                                refreshSerarchTitleLbl.text = "no_more_delegates".localized()
                                refreshSerarchTitleTop.constant = 12
                                isNeedToRefreshDelegates = true
                                orderTimer.invalidate()
                            }
                        }
                    }
                    
                    //                if orderDetailsManager.daysBetweenDates(startDate: startDate!, endDate: endDate) == 0{ //get days
                    //                    let interval = endDate.timeIntervalSince(startDate!)
                    //                    print("get passed minutes \(orderDetailsManager.getMinutesPassed(time: interval))")
                    ////                    print(orderDetailsManager.getCountDownString(time: interval))
                    //                    waitingOffersTimeLbl.text = orderDetailsManager.prodTimeString(time: interval)
                    //
                    //                }else if orderDetailsManager.daysBetweenDates(startDate: startDate!, endDate: endDate) == 1{ // only one day
                    //                    waitingOffersTimeLbl.text = "\(orderDetailsManager.daysBetweenDates(startDate: startDate!, endDate: endDate)) \("day".localized())"
                    //                }else{ // more than one day
                    //                    waitingOffersTimeLbl.text = "\(orderDetailsManager.daysBetweenDates(startDate: startDate!, endDate: endDate)) \("days".localized())"
                    //                }
                }else{
                    refreshSerarchView.isHidden = true
                }
            }
        }else{
            refreshSerarchView.isHidden = true
        }
    }
    
    
    
    @objc func orderCollectionPressed(){
        print("orderCollectionPressed")
    }
    
//    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
//        if gestureRecognizer.state == UIGestureRecognizer.State.began || gestureRecognizer.state == UIGestureRecognizer.State.changed {
//            //if we want to drag we yt7rek kda fe ay 7etah
//            //let point = gestureRecognizer.location(in: mySuperView)
//            //whiteView.center = point
//            let screenHeight = self.view.frame.height
//            let distanceFromBottom = screenHeight - gestureRecognizer.view!.center.y - 60
//            print(distanceFromBottom)
//            let translation = gestureRecognizer.translation(in: self.view)
//            print("translation: \(translation.y)")
//            print("gestureRecognizer: \(gestureRecognizer.view!.center.y)")
//            print("sum : \(gestureRecognizer.view!.center.y + translation.y)")
//            //if gestureRecognizer.view!.center.y <
//            if gestureRecognizer.view!.center.y > (gestureRecognizer.view!.center.y + translation.y) {
//                gestureRecognizer.view!.center = CGPoint(x: gestureRecognizer.view!.center.x, y: gestureRecognizer.view!.center.y + translation.y)
//                gestureRecognizer.setTranslation(CGPoint(x: 0, y: 0), in: self.view)
//            }
//        }
//    }
    
    @objc func offersPressed(){
        if tableViewHeight.constant == 0{
            collapseOrderDetails()
            expandOffers()
//        }else{
//            collapseOffers()
        }
    }
    
    func collapseOffers(){
        orderOffersArrowImg.image = UIImage(named: "anchor_upward")
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.tableViewHeight.constant = 0
            self.orderOffersViewHeight.constant = 45
            self.view.layoutIfNeeded()
        }, completion: { (result) in
        })
    }
    
    func expandOffers(){
        orderOffersArrowImg.image = UIImage(named: "anchor_downward")
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            if self.offers.count == 1{
                var cellHeight : CGFloat = 0.0
                let indexPath = IndexPath(row: 0, section: 0)
                let frame = self.tableView.rectForRow(at: indexPath)
                cellHeight = cellHeight + frame.height
                self.tableViewHeight.constant = cellHeight
                self.orderOffersViewHeight.constant = cellHeight + 60

//                self.tableViewHeight.constant = 130
//                self.orderOffersViewHeight.constant = 200
            }else{
                self.tableViewHeight.constant = 225
                self.orderOffersViewHeight.constant = 270
            }
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func orderDetailsPressed(){
        if orderDetailsViewHeight.constant == 0 {
            collapseOffers()
            expandOrderDetails()
        }else{
            expandOffers()
            collapseOrderDetails()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.needToClearMap = true
        if trackingManager.databaseRef != nil{
            trackingManager.removeObservers()
        }
        if isFromPushNotifications{
            performSegue(withIdentifier: "toNotifications", sender: self)
        }else if isNeedToBackToOrders{
            performSegue(withIdentifier: "toMyOrders", sender: self)
        }else{
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @IBAction func reorderAction(_ sender: Any) {
       print("reorder action")
        showReOrderAlert()
    }
    
    @IBAction func mapFilterAction(_ sender: Any) {
        print("mapFilterAction")
        if isMapShowedOnly{
            changeOrderView(isHidden: false)
            setData(order: order)
        }else{
            changeOrderView(isHidden: true)
        }
        self.isMapShowedOnly = !isMapShowedOnly
        if(isMapShowedOnly){
            mapOnlyIcon.image = UIImage(named: "close_map")
        }else{
            mapOnlyIcon.image = UIImage(named: "open_map")
        }
    }
    
    func changeOrderView(isHidden: Bool){
        transparentView.isHidden = isHidden
        orderInfoView.isHidden = isHidden
        orderOffersView.isHidden = isHidden
        waitingOffersView.isHidden = isHidden
        refreshSerarchView.isHidden = isHidden
        reorderView.isHidden = isHidden
        acceptedOfferView.isHidden = isHidden
    }
    
    func showReOrderAlert(){
        // create the alert
        let msg = "reorder_msg".localized()
        let alert = UIAlertController(title: "", message:msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            if self.order.from_lat != nil && self.order.from_lng != nil && self.order.to_lng != nil && self.order.to_lat != nil{
                if !self.areaManager.isSelectedPointInBlockedArea(latitude: self.order.from_lat, longitude: self.order.from_lng) && !self.areaManager.isSelectedPointInBlockedArea(latitude: self.order.to_lat, longitude: self.order.to_lng){
                    self.createReorderRequest()
                }else{
                    Toast.init(text: "blockedAreaToast".localized()).show()
                }
            }else{
                self.createReorderRequest()
            }
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func createReorderRequest(){
        var fromType = 0
        if order.fromType != nil{
            fromType = order.fromType!
        }
        var descStr = ""
        if order.desc != nil{
            descStr = order.desc!
        }
        
        var fromLat = 0.0
        var fromLng = 0.0
        var fromAddress = ""
        if order.from_lat != nil{
            fromLat = order.from_lat!
        }
        if order.from_lng != nil{
            fromLng = order.from_lng!
        }
        if order.from_address != nil{
            fromAddress = order.from_address!
        }
        var storeName = ""
        if order.store_name != nil{
            storeName = order.store_name!
        }
        
        var toLat = 0.0
        var toLng = 0.0
        var toAddress = ""
        if order.to_lat != nil{
            toLat = order.to_lat!
        }
        if order.to_lng != nil{
            toLng = order.to_lng!
        }
        if order.to_address != nil{
            toAddress = order.to_address!
        }
        
        var delivery_duration = 0
        if order.delivery_duration != nil{
            delivery_duration = order.delivery_duration!
        }
        
        orderDetailsPresenter.reOrder(desc: descStr, fromType: fromType, fromLat: fromLat, fromLng: fromLng, toLat: toLat, toLng: toLng, fromAddress: fromAddress, toAddress: toAddress, storeName: storeName, images: getImagesId(), voicenoteId: 0, deliveryDuration: delivery_duration)
    }
    
    func getImagesId() -> String{
        var imagesIds = ""
        var imagesCount = 0
        var images = [DelegateImageData]()
        if order.images != nil{
            images = order.images!
        }
        if images.count > 0{
            //            imagesIds = "["
            for image in images{
                if image.id != nil{
                    imagesIds += "\(String(describing: image.id!))"
                }
                imagesCount += 1
                if imagesCount != images.count{
                    imagesIds += ","
                }
            }
            //            imagesIds += "]"
        }
        return imagesIds
    }
    func reloadOrderData(){
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reloadAction), userInfo: nil, repeats: false)
    }
    
    @objc func reloadAction(){
        self.view.isUserInteractionEnabled = true
        orderDetailsPresenter.getCustomerOrderDetails(id: orderID)
        changeOrderView(isHidden: false)
        isMapShowedOnly = false
        mapOnlyIcon.image = UIImage(named: "open_map")
    }
    
    @objc func refreshDelegateAction(){
        orderDetailsPresenter.refreshDelegates(id: orderID)
    }
    
    @objc func showRate() {
        performSegue(withIdentifier: "toRate", sender: self)
    }
    
    @IBAction func openMenuOptions(_ sender: Any) {
        showCancelOrder = false
        self.performSegue(withIdentifier: "menuOptions", sender: self)
    }
    
    @IBAction func unwindFromMenuOptions(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
    }
    
    @IBAction func unwindFromRate(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: dimSpeed)
    }
    
    @IBAction func unwindToCanelOrder(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
        self.view.isUserInteractionEnabled = false
       Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(self.cancelOrder), userInfo: nil, repeats: false);
    }
    
    @IBAction func unwindToSubmitComplain(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
        self.view.isUserInteractionEnabled = false
        Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(self.submitComplaint), userInfo: nil, repeats: false);
    }
    
    @IBAction func unwindAfterCancelOrder(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
        self.view.isUserInteractionEnabled = false
        Timer.scheduledTimer(timeInterval: 0.55, target: self, selector: #selector(self.reloadAction), userInfo: nil, repeats: false);
    }
    
    @objc func submitComplaint(){
        print("submitComplaint")
        self.view.isUserInteractionEnabled = true
    }
    
    func collapseOrderDetails(){
//        orderDetailsCancellationLbl.isHidden = false
        orderDetailsArrowImg.image = UIImage(named: "anchor_upward")
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            self.collectionViewHeight.constant = 70
            self.recordHeight.constant = 0
            self.orderDetailsViewHeight.constant = 0
            self.orderDetailsCancellationLbl.isHidden = true
            self.view.layoutIfNeeded()
        }, completion: { (result) in
            self.orderDetailsView.isHidden = true
        })
    }
    
    func expandOrderDetails(){
        orderDetailsView.isHidden = false
        orderDetailsCancellationLbl.isHidden = true
        orderDetailsArrowImg.image = UIImage(named: "anchor_downward")
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width
        var totalHeight : CGFloat = 0
        if order.desc != nil{
            totalHeight += orderDetailsManager.heightForLable(text: order.desc!, width: screenWidth - 30 ) + 10
        }
        
        if order.cancel_reason != nil{
            if order.cancel_reason?.title != nil{
                totalHeight += orderDetailsManager.heightForLable(text: "\("cancellation_reason".localized()) \(String(describing: (order.cancel_reason?.title!)!))", width: screenWidth - 30 ) + 10
                orderDetailsCancellationLbl.isHidden = false
            }
        }

        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.5, animations: {
            if self.order.images != nil{
                if self.order.images?.count != 0{
                    self.collectionViewHeight.constant = 70
                    totalHeight += 70
                }else{
                    self.collectionViewHeight.constant = 0
                }
            }else{
                self.collectionViewHeight.constant = 0
            }
            self.collectionView.reloadData()
            self.recordHeight.constant = 0
            self.orderDetailsViewHeight.constant = totalHeight + 10
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func setOrderStatus(){
        waitingOffersView.isHidden = true
        self.menuOptions.tintColor = UIColor.white
        self.menuOptions.isEnabled = true
        acceptedOfferView.isHidden = true
        refreshSerarchView.isHidden = true
        transparentView.isHidden = true
        needCheckTimer = true
        // hide offers view
//        orderOffersView.isHidden = true
//        tableViewHeight.constant = 0
//        orderOffersViewHeight.constant = 0
        
        if order.status != nil{
            if order.status! == "new"{
                orderStatusLbl.text = "newStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "498BCA")
                // check if need to refresh search
                checkRefreshSearch(status: order.status!)
                
                // set order waiting timer
                waitingOffersView.isHidden = false
                needCheckTimer = true
                transparentView.isHidden = false
                orderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(setOrderTimer)), userInfo: nil, repeats: true)
            }else if order.status! == "delivery_in_progress"{
                orderStatusLbl.text = "beignDeliveredStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "5CACF9")
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
                setOrderAcceptedOffer()
                needCheckTimer = false
            }else if order.status! == "cancelled"{
                orderStatusLbl.text = "CancelledStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "E84450")
                setOrderAcceptedOffer()
                needCheckTimer = false
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
            }else if order.status! == "pending"{
                // set order waiting timer
                waitingOffersView.isHidden = false
                transparentView.isHidden = false
//                needCheckTimer = true
//                orderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(setOrderTimer)), userInfo: nil, repeats: true)
                orderStatusLbl.text = "pendingStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "A5AAB2")
                orderRouteStatus = 0
                checkRefreshSearch(status: order.status!)
            }else if order.status! == "assigned"{
                orderStatusLbl.text = "assignedStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "FF9F3E")
                needCheckTimer = false
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
                setOrderAcceptedOffer()
            }else if order.status! == "in_progress"{
                orderStatusLbl.text = "inProgressStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "d8ca72")
                needCheckTimer = false
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
                
                setOrderAcceptedOffer()
            }else if order.status! == "delivered"{
                orderStatusLbl.text = "DeliveredStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "4DD552")
                needCheckTimer = false
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false

                setOrderAcceptedOffer()
            }
        }else{
            orderStatusLbl.text = ""
        }
        orderStatusLblWidth.constant = orderStatusLbl.intrinsicContentSize.width
    }
    
    func setOrderDate(){
        if order.created_at != nil{
            orderDateLbl.text = orderDetailsManager.getFormattedDate(dateTxt: order.created_at!)
        }else{
            orderDateLbl.text = ""
        }
    }
    
    func setOrderOffers(){
        orderOffersView.isHidden = true
        if boatAnimation != nil {
            boatAnimation?.stop()
        }
        if order.offers != nil{
            if (order.offers?.count)! > 0{
                self.offers = order.offers!
                waitingOffersView.isHidden = true
                orderOffersView.isHidden = false
                needCheckTimer = false
                refreshSerarchView.isHidden = true
                transparentView.isHidden = true
                tableView.reloadData()
                initAnimation()
                beginAnimation()
                expandOffers()
//                collapseOffers()
            }
        }
    }
    
    
    func setOrderAcceptedOffer(){
        
        acceptedOfferView.isHidden = false

        var totalValue = 0.0
        var changes = 0.0
        
        if order.delivery_price != nil{
            shippingCostValueLbl.text = getPrice(price: order.delivery_price!)
            totalValue = order.delivery_price!
        }else{
            //no offer
            shippingCostValueLbl.text = ""
            acceptedOfferView.isHidden = true
        }
        
//        if order.vat != nil{
//            vatValueLbl.text = getPrice(price: order.vat!)
//            totalValue += order.vat!
//        }else{
//            vatValueLbl.text = "-"
//        }
        
        if order.discount != nil{
            if order.discount != 0{
                discountLbl.text = "-\(getPrice(price: order.discount!))"
                totalValue -= order.discount!
                discountLbl.isHidden = false
                discountTitleLbl.isHidden = false
                discountView.isHidden = false
            }else{
                hideDiscountView()
            }
        }else{
            hideDiscountView()
        }
        
        if order.item_price != nil{
            // view item price
            itemPriceValueLbl.text = getPrice(price: order.item_price!)
            totalValue += order.item_price!
            itemPriceTitleLbl.isHidden = false
            itemPriceValueLbl.isHidden = false
            itemPriceView.isHidden = false
            if appDelegate.isRTL{
                acceptedOfferViewTop.constant = 45
            }else{
                acceptedOfferViewTop.constant = 40
            }
        }else{
            //hide item price
            itemPriceTitleLbl.isHidden = true
            itemPriceValueLbl.isHidden = true
            itemPriceView.isHidden = true
            if appDelegate.isRTL{
                acceptedOfferViewTop.constant = 10
            }else{
                acceptedOfferViewTop.constant = 15
            }
        }
        
        if order.actual_paid != nil && order.total_price != nil{
            changes = order.actual_paid! - order.total_price!
            if order.actual_paid! > order.total_price!{
                addedToWalletLbl.text = "+\(getPrice(price: changes))"
                totalValue += changes
            }else if order.actual_paid! < order.total_price!{
                addedToWalletLbl.text = "\(getPrice(price: changes))"
                totalValue -= changes
            }else{
               hideAddedToWalletView()
            }
        }else{
            hideAddedToWalletView()
        }
        
        if order.actual_paid != nil{
            acceptedTotalLbl.text = getPrice(price: order.actual_paid!)
        }else{
            if totalValue < 0{
                acceptedTotalLbl.text = getPrice(price: totalValue)
            }else{
                acceptedTotalLbl.text = getPrice(price: totalValue)
            }
        }
        setDelegateData()
        setAddRateView()
    }
    
    func hideAddedToWalletView(){
        //no changes actual price equal total price
        addedToWalletLbl.isHidden = true
        addedToWalletTitleLbl.isHidden = true
        addedToWalletView.isHidden = true
        addedToWalletLbl.text = ""
        addedToWalletTitleLbl.text = ""
        addedToWalletTop.constant = 0
        addedToWalletBottom.constant = 0
    }
    
    func hideDiscountView(){
        discountLbl.isHidden = true
        discountTitleLbl.isHidden = true
        discountView.isHidden = true
        discountLbl.text = ""
        discountTitleLbl.text = ""
    }
    
    func setAddRateView(){
        addRateLbl.isHidden = true
        addRateView.isHidden = true
        starRateView.isHidden = false
        if order.status != nil{
            if order.status == "delivered"{
                if order.is_rated != nil{
                    if !order.is_rated!{ //order deliverd and not rated yet so show rating
                        addRateLbl.isHidden = false
                        addRateView.isHidden = false
                        starRateView.isHidden = true
                    }
                }
            }
        }
    }
    
    func setReorderView(){
        // initial hide all reorder view
        reorderLbl.isHidden = true
        reorderView.isHidden = true
        reorderViewHeight.constant = 0
        
        acceptedReorderLbl.isHidden = true
        acceptedReorderView.isHidden = true
        acceptedReorderViewHeight.constant = 0
        
        if order.status != nil{
            if order.status == "delivered" || order.status == "cancelled"{
                if order.delivery_price != nil{ // order has accepted invoice so hide seperated reorder view and show the reorder view in accepted invoice view
                    
                    acceptedReorderLbl.isHidden = false
                    acceptedReorderView.isHidden = false
                    acceptedReorderViewHeight.constant = 40

                }else{
                    reorderLbl.isHidden = false
                    reorderView.isHidden = false
                    reorderViewHeight.constant = 45
                }
            }
        }
    }
    
    func setDelegateData(){
        var delegateData = DelegateData()
        
        if order.delegate != nil{
            delegateData = order.delegate!
        }
        
        if delegateData.id != nil{
            if trackingManager.databaseRef == nil{
                trackingManager.initRefernces(delegateID: delegateData.id!, viewContoller: self, pickupLocation: self.pickupLocation, destinationLocation: destinationLocation)
            }else{
                //drawed before
                delegatePolyline.map = nil
                //        delegatePolyline = deliveryPolyline
                deliveryPolyline.map = nil
                
                if carMarker != nil{
                    carMarker.map = nil
                    carMarker = nil
                }
            }
            if orderRouteStatus == 1{ //order with delegate route before pickup item
                trackingManager.setDeliveryStatus(isBeforePickup: true)
            }else if orderRouteStatus == 2{ //order with delegate route after pickup item
                trackingManager.setDeliveryStatus(isBeforePickup: false)
            }
//            trackingManager.getDelegateCurrentLocation(delegateID: delegateData.id!, viewContoller: self)
            trackingManager.getUpdatedOnDelegateLocation()
        }
        
        if delegateData.name != nil{
            delegateNameLbl.text = delegateData.name
        }else{
            delegateNameLbl.text = ""
        }
        
        delegateProfileImg.image = UIImage(named: "avatar")
        if delegateData.image != nil{
            if delegateData.image?.medium != nil{
                let url = URL(string: (delegateData.image?.medium)!)
                print("url \(String(describing: url))")
                self.delegateProfileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        
        if delegateData.delegate_rating != nil{
            setDelegateRate(rate: delegateData.delegate_rating!)
        }else{
            setDelegateRate(rate: 5)
        }
    }
    
    func setDelegateRate(rate: Double){
        starRateView.update()
        starRateView.settings.updateOnTouch = false
        starRateView.rating = rate
    }
    
    func getPrice(price: Double) -> String{
//        if price.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(price)) \("sar".localized())"
//        }else{
            let priceStr = String(format: "%.2f", price)
            return "\(priceStr) \("sar".localized())"
//        }
    }
    
    func checkRefreshSearch(status: String){
        refreshSerarchView.isHidden = true
        isNeedToRefreshDelegates = false
        if order.search_delegates_result != nil{
            if order.search_delegates_result == 0{
                if status == "new"{
                    refreshSerarchView.isHidden = false
                    refreshSerarchTitleLbl.text = "no_delegates".localized()
                    refreshSerarchTitleTop.constant = 12
                    isNeedToRefreshDelegates = true
                }else if status == "pending"{
                    refreshSerarchView.isHidden = false
                    refreshSerarchTitleLbl.text = "no_more_delegates".localized()
                    refreshSerarchTitleTop.constant = 12
                    isNeedToRefreshDelegates = true
                    orderTimer.invalidate()
                }
            }else{
                if status == "pending"{
                    needCheckTimer = true
                    orderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(setOrderTimer)), userInfo: nil, repeats: true)
                }
            }
        }else{
            if status == "pending"{
                needCheckTimer = true
                orderTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: (#selector(setOrderTimer)), userInfo: nil, repeats: true)
            }
        }
    }
    
    func setOrderData(){
        if order.id != nil{
            orderNumLbl.text = "\(String(describing: order.id!))"
        }else{
            orderNumLbl.text = ""
        }
        
        if order.delivery_duration != nil {
            orderDeliveryDurationLbl.text = "\(order.delivery_duration!) \("hr".localized())"
        }else{
            orderDeliveryDurationLbl.text = ""
        }
        
        if order.store_name != nil{
            orderSourceLbl.text = order.store_name!
        }else if order.from_address != nil{
            orderSourceLbl.text = order.from_address!
        }
        
        if order.to_address != nil{
            orderDestinationLbl.text =  order.to_address!
        }else{
            orderDestinationLbl.text = ""
        }
        
        if order.desc != nil{
            orderDetailsDescLbl.text = order.desc
        }else{
            orderDetailsDescLbl.text = ""
        }
        
        if order.cancel_reason != nil{
            if order.cancel_reason?.title != nil{
                orderDetailsCancellationLbl.text = "\("cancellation_reason".localized()) \(String(describing: (order.cancel_reason?.title!)!))"
                orderDetailsCancellationLbl.isHidden = false
            }else{
                orderDetailsCancellationLbl.text = ""
                orderDetailsCancellationLbl.isHidden = true
            }
        }else{
            orderDetailsCancellationLbl.text = ""
            orderDetailsCancellationLbl.isHidden = true
        }
        
        setOrderRouteStatus()
        
        if order.from_lat != nil && order.from_lng != nil && order.to_lat != nil && order.to_lng != nil{
//            if !isPickupRouteDrawed{
                setMap()
//            }
            //            orderNewDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: order.from_lat!, fromLocationLng: order.from_lng!, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
        }else{
            orderNewDistanceLbl.text = ""
        }
        
        expandOrderDetails()
        collapseOrderDetails()
        setOrderStatus()
        setOrderDate()
        setOrderTimer()
        setOrderOffers()
        setReorderView()
        
        if orderDotsImg.frame.height > 40{
            orderDotsImg.image = UIImage(named: "line")
            if appDelegate.isRTL{
                pickupPinTop.constant = 15
            }
        }else{
            orderDotsImg.image = UIImage(named: "line_small")
        }
        print("height: \(orderDotsImg.frame.height)")
        
        noNetworkView.isHidden = true
        loadingScreenView.isHidden = true
        
//        trackingManager.createDummyTimer()
    }
    
    func checkScreenNavigation(){
        if order.status != nil{
            if order.status! == "assigned" || order.status! == "in_progress" || order.status! == "delivery_in_progress"{
                self.needToClearMap = true
                performSegue(withIdentifier: "toChat", sender: self)
            }else if order.status! == "delivered"{
                setOrderData()
                if order.is_rated != nil{
                    if !order.is_rated!{ //order deliverd and not rated yet so show rating
                        
                        performSegue(withIdentifier: "toRate", sender: self)
                    }
                }
            }else{
                setOrderData()
            }
        }else{
            setOrderData()
        }
    }
    
    func checkRateNavigation(){
        if order.status != nil{
           if order.status! == "delivered"{
                if order.is_rated != nil{
                    if !order.is_rated!{ //order deliverd and not rated yet so show rating
                        performSegue(withIdentifier: "toRate", sender: self)
                    }
                }
            }
        }
    }
    
    func initAnimation(){
        if appDelegate.isRTL{
            boatAnimation = LOTAnimationView(name: "offers_loader_ar")
        }else{
            boatAnimation = LOTAnimationView(name: "offers_loader")
        }
        // Set view to full screen, aspectFill
//        boatAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        boatAnimation!.contentMode = .scaleAspectFit
        boatAnimation!.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        print("midX: \(orderOffersLoadingView.frame.midX)  midY: \(orderOffersLoadingView.frame.midY)")
        boatAnimation?.loopAnimation = true
    }
    
    @objc func beginAnimation() {
        // Add the Animation
        orderOffersLoadingView.addSubview(boatAnimation!)
        self.boatAnimation?.play()
        print("offers loader: \( Double((self.boatAnimation?.animationDuration)!))")
    }
    
    @IBAction func acceptedOfferDeleagteAction(){
        if order.delegate != nil{
            if order.delegate?.id != nil{
                self.selectedDelegateID = (order.delegate?.id)!
                performSegue(withIdentifier: "toProfile", sender: self)
            }
        }
    }
    
    @IBAction func callDeleagteAction(){
        if order.delegate != nil{
            if order.delegate?.mobile != nil{
                callDeleagte(phone: (order.delegate?.mobile)!)
            }
        }
    }
    
    func callDeleagte(phone: String) {
        let formattedString = phone.replacingOccurrences(of: " ", with: "")
        //        let trimmedString = self.phones[indexPath.row].removeWhitespace()
        if let url = URL(string: "tel://\(String(describing: formattedString))"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toFullImage"{
            let vc = segue.destination as! ViewFullImageVC
            vc.image = selectedImage
        }else if segue.identifier == "toChat"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ChatVC
            vc.isFromMyOrders = true
            vc.isDelegateOfOrder = false
            vc.order = order
            vc.isFromPushNotifications = self.isFromPushNotifications
        }else if segue.identifier == "toNotifications"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 0
        }else if segue.identifier == "menuOptions"{
            let vc = segue.destination as! MenuOptions
            vc.order = order
            vc.showCancelOrder = showCancelOrder
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "toRate"{
            let vc = segue.destination as! RateVC
            vc.order = order
            vc.isUserRateDelegate = true
            vc.rateOrderDelegate = self
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "toProfile"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ProfileVC
            vc.isUser = false
            vc.userId = selectedDelegateID
        }else if segue.identifier == "toMyOrders"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 1
        }
    }
}

extension UserOrderDetailsVC: GMSMapViewDelegate{ //map functions
    
    func setMap(){
        // set map
        if mapView != nil{
            let pickupLat = CLLocationDegrees(exactly: order.from_lat!)
            let pickupLng = CLLocationDegrees(exactly: order.from_lng!)
            let camera = GMSCameraPosition.camera(withLatitude: pickupLat!, longitude: pickupLng!, zoom: 16.0)
            if mapView != nil{
                mapView.camera = camera
            }
//            if appDelegate.isRTL{
//                setMarkerOnMap(latitude: pickupLat!, longitude: pickupLng!, imageName: "btn_red_ar")
//            }else{
//                setMarkerOnMap(latitude: pickupLat!, longitude: pickupLng!, imageName: "btn_red_en")
//            }
            setMarkerOnMap(latitude: pickupLat!, longitude: pickupLng!, imageName: "store_pin_map")
            
            let destinationLat = CLLocationDegrees(exactly: order.to_lat!)
            let destinationLng = CLLocationDegrees(exactly: order.to_lng!)
//            if appDelegate.isRTL{
//                setMarkerOnMap(latitude: destinationLat!, longitude: destinationLng!, imageName: "btn_blue_ar")
//            }else{
//                setMarkerOnMap(latitude: destinationLat!, longitude: destinationLng!, imageName: "btn_blue_en")
//            }
            setMarkerOnMap(latitude: destinationLat!, longitude: destinationLng!, imageName: "destination_pin_map")
            
            pickupLocation = CLLocationCoordinate2D(latitude: pickupLat!, longitude: pickupLng!)
            destinationLocation = CLLocationCoordinate2D(latitude: destinationLat!, longitude: destinationLng!)
            
//            getPolylineRoute(from: pickupLocation, to: destinationLocation)

            if orderRouteStatus == 0 || orderRouteStatus == 1 || orderRouteStatus == 3{
                // if before pickup need to draw the pickup destination route or ended trip
                orderDetailsPresenter.getPolylineRoute(from: pickupLocation, to: destinationLocation, isDelegatePath: false, orderStatus: order.status ?? "")
            }

            Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showAllMarkers), userInfo: nil, repeats: false)
        }
    }

    
    func setMarkerOnMap(latitude: CLLocationDegrees, longitude: CLLocationDegrees, imageName: String){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let image = UIImage(named: imageName)
        marker.icon = image
        if mapView != nil{
            marker.map = mapView
        }
    }

    @objc func showAllMarkers(){
        if mapView != nil{
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            //        let bounds = GMSCoordinateBounds()
            //        bounds.includingCoordinate(pickupLocation)
            //        bounds.includingCoordinate(destinationLocation)
            //        bounds.includingCoordinate(currentLocation)
            let path = GMSMutablePath()
            path.add(pickupLocation)
            path.add(destinationLocation)
            if delegateLocation.coordinate.latitude != 0.0 && delegateLocation.coordinate.longitude != 0.0{
                path.add(delegateLocation.coordinate)
            }
            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 130.0)
            if mapView != nil{
                mapView.animate(with: update)
            }
            CATransaction.commit()
            if mapView != nil{
                mapView.isMyLocationEnabled = true
            }
        }
    }
    
    func calculateDistance(distanceInMeters : Double) -> String{
        if Int(distanceInMeters) > 1000{
            let distance = distanceInMeters/1000
            if distance.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(distanceInMeters/1000)) \("Km".localized())"
            }else{
                return "\(String(format: "%.1f", distanceInMeters/1000)) \("Km".localized())"
            }
        }else{
            if distanceInMeters.truncatingRemainder(dividingBy: 1) == 0 {
                return "\(Int(distanceInMeters)) \("M".localized())"
            }else{
                return "\(String(format: "%.1f", distanceInMeters)) \("M".localized())"
            }
        }
    }
    
    func setDistance(distanceValue: Double){
        orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
    }
    
    
    func setDistance(isDelegatePath: Bool, distanceValue: Double){
        if isDelegatePath{
            self.distanceToPickup = distanceValue/1000
            delegateDistance = distanceValue
            if Int(distanceValue) > 1000 {
                if orderRouteStatus == 2{ // delegate destination view
                    if orderNewDistanceLbl != nil{
                        self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }else{ //delegate pickup destination view
                    if orderToDistanceLbl != nil{
                        self.orderToDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }
            }else{
                if orderRouteStatus == 2{ // delegate destination view
                    if orderNewDistanceLbl != nil{
                        self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }else{
                    if orderToDistanceLbl != nil{
                        self.orderToDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }
            }
        }else{
            self.distanceToDestination = distanceValue/1000
            if Int(distanceValue) > 1000{
                if orderFromDistanceLbl != nil{
                    self.orderFromDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                }
            }else{
                if orderFromDistanceLbl != nil{
                    self.orderFromDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                }
            }
        }
    
    }
    
    func showPath(polyStr :String, isDelegatePath: Bool){
       
        if  order.status! == "new" || order.status! == "pending"{ //modified condition
            let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 2.5
            if isDelegatePath{
                //after pick up line item to destination
                if orderRouteStatus == 2{
                    polyline.strokeColor = Colors.hexStringToUIColor(hex: "#498bca")
                }else{
                    //before pick up item line to pickup
                    polyline.strokeColor = Colors.hexStringToUIColor(hex: "#e84450")
                }
                isDelegateRouteDrawed = true
                self.delegatePolyline = polyline
                if mapView != nil{
                    delegatePolyline.map = mapView // Your map view
                }
                
            }else{
                polyline.strokeColor = Colors.hexStringToUIColor(hex: "#498bca")
                self.deliveryPolyline = polyline
                isPickupRouteDrawed = true
                if mapView != nil{
                    deliveryPolyline.map = mapView // Your map view
                }
            }
        }
        
    }
    
    func getFromPickupToDistinationDistance(){
        if order.from_lat != nil && order.from_lng != nil && order.to_lat != nil && order.to_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: order.from_lat!, fromLocationLng: order.from_lng!, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            setDistance(isDelegatePath: false, distanceValue: distance)
        }
    }
    
    func getFromDelegateToPickupDistance(){
        if delegateLocation.coordinate.latitude != 0.0 && delegateLocation.coordinate.longitude != 0.0 && order.from_lat != nil && order.from_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: delegateLocation.coordinate.latitude, fromLocationLng: delegateLocation.coordinate.longitude, toLocationLat: order.from_lat!, toLocationLng: order.from_lng!)
            setDistance(isDelegatePath: true, distanceValue: distance)
        }
    }
    
    func getFromDelegateToDestinationDistance(){
        if delegateLocation.coordinate.latitude != 0.0 && delegateLocation.coordinate.longitude != 0.0 && order.from_lat != nil && order.from_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: delegateLocation.coordinate.latitude, fromLocationLng: delegateLocation.coordinate.longitude, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            setDistance(isDelegatePath: true, distanceValue: distance)
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
//        if marker.icon == UIImage(named: "destination_pin_map"){
//            print("destination_pin_map")
//            redirectToMaps(latitude: order.to_lat!, longitude: order.to_lng!)
//        }else if marker.icon == UIImage(named: "store_pin_map"){
//            print("store_pin_map")
//            redirectToMaps(latitude: order.from_lat!, longitude: order.from_lng!)
//        }else {
//            print("car_vertical")
//            redirectToMaps(latitude: delegateLocation.coordinate.latitude, longitude: delegateLocation.coordinate.longitude)
//        }
        return true
    }
    
    func redirectToMaps(latitude: Double, longitude: Double){
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            //            UIApplication.shared.open(URL(string:"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
            print("open action sheet")
            openMapsSheet(latitude: latitude, longitude: longitude)
        } else {
            openAppleMapForPlace(latitude: latitude, longitude: longitude)
        }
    }
    
    func openAppleMapForPlace(latitude: Double, longitude: Double) {
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = ""
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openMapsSheet(latitude: Double, longitude: Double){
        let alert:UIAlertController=UIAlertController(title: "open_in_maps".localized(), message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let gooleAction = UIAlertAction(title:"googleMap".localized(), style:
            .default)
        {
            UIAlertAction in
            UIApplication.shared.open(URL(string:"comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&q=\(latitude),\(longitude)")!, options: [:], completionHandler: nil)
        }
        let appleAction = UIAlertAction(title: "appleMap".localized(), style: UIAlertAction.Style.default)
        {
            UIAlertAction in
            self.openAppleMapForPlace(latitude: latitude, longitude: longitude)
        }
        let cancelAction = UIAlertAction(title: "cancel".localized(), style: UIAlertAction.Style.cancel)
        {
            UIAlertAction in
        }
        
        // Add the actions
        alert.addAction(appleAction)
        alert.addAction(gooleAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}

extension UserOrderDetailsVC: AcceptOfferDelegate{
   
    func acceptOffer(offerID: Int, offerPrice: String){
        print("acceptOffer")
        showAcceptOfferAlert(offerID: offerID, offerPrice: offerPrice)
    }
    
    func showAcceptOfferAlert(offerID: Int, offerPrice: String){
        // create the alert
        let msg = "accept_offer_alert".localized() + " " + offerPrice
        let alert = UIAlertController(title: "", message:msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            self.confirmAcceptOfferAction(offerID: offerID)
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmAcceptOfferAction(offerID: Int){
        orderDetailsPresenter.acceptOffer(id: offerID)
    }
    
    func rejectOffer(offerID: Int, offerPrice: String){
        print("rejectOffer")
        showRejectOfferAlert(offerID: offerID, offerPrice: offerPrice)
    }
    
    func showRejectOfferAlert(offerID: Int, offerPrice: String){
        // create the alert
        let msg = "reject_offer_alert".localized() + " "
        let alert = UIAlertController(title: "", message:msg, preferredStyle: UIAlertController.Style.alert)
        
        // add an action (button)
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            self.confirmRejectOfferAction(offerID: offerID)
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmRejectOfferAction(offerID: Int){
        orderDetailsPresenter.rejectOffer(id: offerID)
    }
    
    func delegateProfilePressed(delegateId: Int) {
        self.selectedDelegateID = delegateId
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
}

extension UserOrderDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count = 0
        if order.images != nil{
            count = Int((order.images?.count)!)
        }
        print(count)
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath)
        let imageView = cell.contentView.viewWithTag(1) as? UIImageView
        orderDetailsManager.setCornerRadius(selectedView: imageView!, radius: 10)
        imageView!.image = UIImage(named: "default")
        if order.images![indexPath.row].image != nil{
            if order.images![indexPath.row].image!.small != nil{
                let url = URL(string: (order.images![indexPath.row].image!.small)!)
                print("url \(String(describing: url))")
                imageView!.kf.setImage(with: url, placeholder: UIImage(named: "default"))
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if order.images![indexPath.row].image != nil{
            self.selectedImage = order.images![indexPath.row].image!
            performSegue(withIdentifier: "toFullImage", sender: self)
        }
    }
}

extension UserOrderDetailsVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return offers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderOfferCell
        var deliveryDuration = 0
        if order.delivery_duration != nil{
            deliveryDuration = order.delivery_duration!
        }
        cell.setCell(offer: offers[indexPath.row], delegate: self, deliveryDuration: deliveryDuration)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension UserOrderDetailsVC: UserOrderDetailsView{
    
    func showloading(isFromAccept: Bool) {
        if !isFromAccept{
            loadingScreenView.isHidden = false
        }
        
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
    }
    
    func cancelOrderSuccessfully(){
        print("cancelOrderSuccessfully")
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        self.reloadAction()
    }
    
    func showNetworkError() {
        self.noNetworkView.isHidden = false
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg: String) {
        Toast.init(text:msg).show()
    }
    
    func setData(order: Order) {
        self.order = order
        if order.id != nil{
            self.orderID = order.id!
        }
        if isFromChat{ // render order details
            setOrderData()
            checkRateNavigation()
        }else{ // check on status if render order details or navigate to chat page
            checkScreenNavigation()
        }

    }
    
    func showSuccess(order: Order){
        self.order = order
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        self.needToClearMap = true
        performSegue(withIdentifier: "toChat", sender: self)
    }
    
    func rejectOfferSuccessfully(order: Order){
        self.order = order
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        setData(order: order)
    }
    
    func showNetworkToast(){
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showBlockedAreaError(){
        Toast.init(text: "blockedAreaToast".localized()).show()
    }

}

extension UserOrderDetailsVC: RateOrderDelegate{
    
    func rateOrderSuccessfully(order: Order) {
        setData(order: order)
    }
    
}

// TRAKING
extension UserOrderDetailsVC{
    
    
    func getDelegateRoute(location: CLLocation){
        print("getDelegateRoute in user details")
        self.delegateLocation = location
//        if !isDelegateRouteDrawed {
        if orderRouteStatus == 1{
            //delegate on his way to pickup
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }else if orderRouteStatus == 2{
            //delegate on his way to destination
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: destinationLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }
//        }
        showAllMarkers()
    }
    
    func updateCarOnMAp(location: CLLocation){
        var oldLocation = CLLocation()
        if orderRouteStatus != 3{ // ended trip so we don't need to delegate on map or location
            if carMarker == nil{
                //for first time put marker on map and draw the route
                carMarker = GMSMarker()
                carMarker.position = location.coordinate
                carMarker.rotation = GMSGeometryHeading(oldLocation.coordinate, location.coordinate)
                let image = UIImage(named:"car_vertical")
                carMarker.icon = image
                carMarker.map = mapView
                carMarker.appearAnimation = .pop
                carMarker.rotation = GMSGeometryHeading(oldLocation.coordinate, location.coordinate)
                getDelegateRoute(location: location)
                delegateCurrentLocation = location
            }else{
              //  checkDelegateRoute(location: location) //modified comment this line
               // calculateDrivenDistance(location: location) //modified
                delegateLocation = location

                if let orderStatus = order.status{
                    if orderStatus == "delivery_in_progress"{
                        self.getFromDelegateToDestinationDistance()
                    }else{
                        self.getFromDelegateToPickupDistance()
                    }
                }
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                carMarker.position = location.coordinate
                carMarker.rotation = GMSGeometryHeading(oldLocation.coordinate, location.coordinate)
                CATransaction.commit()
            }
            oldLocation = location
        }else{
            if carMarker != nil{
                carMarker.map = nil
            }
        }
    }
    
    // TO CHECK IF DELEGATE NEW LOCATION ON THE DRAWED ROUTE OR NOT
    func checkDelegateRoute(location: CLLocation){
        if delegatePolyline.path != nil{
            let path = delegatePolyline.path
            let result = GMSGeometryIsLocationOnPathTolerance(location.coordinate, path!, true, 10)
            if result{ //on same route
                print("removed the drived path")
                let str = trackingManager.removeDrivedRoute(polylineStr: (path?.encodedPath())!, delegateLocation: location)
                delegatePolyline.map = nil
                showPath(polyStr: str, isDelegatePath: true)
                calculateDrivenDistance(location: location)
            }else{ // change route
                print("remove the past path and create new one")
                delegateCurrentLocation = location
                removePath(location: location)
            }
        }else{ // change route
            print("remove the past path and create new one")
            delegateCurrentLocation = location
            removePath(location: location)
        }
    }
    
    func removePath(location: CLLocation){
        delegatePolyline.map = nil
        if orderRouteStatus == 1{
            //delegate on his way to pickup
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }else if orderRouteStatus == 2{
            //delegate on his way to destination
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: destinationLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }
    }
    
    
    func setAfterPickupDelegateLocation(location: CLLocation){
        self.orderRouteStatus = 1
        delegatePolyline.map = nil
//        delegatePolyline = deliveryPolyline
        deliveryPolyline.map = nil
        carMarker.map = nil
        carMarker = nil
        updateCarOnMAp(location: location)
    }
    
    func setOrderRouteStatus(){
        if order.status != nil{
            if order.status! == "new" || order.status! == "pending"{
                //no delegate yet
                orderRouteStatus = 0
                orderDistanceFullView.isHidden = true
                orderNewDistanceFullView.isHidden = false
                orderPickupImg.image = UIImage(named: "shop_ic")
            }else if order.status! == "assigned" || order.status! == "in_progress"{
                //delegate and before pickup item
                orderRouteStatus = 1
                orderDistanceFullView.isHidden = false
                orderNewDistanceFullView.isHidden = true
                orderPickupImg.image = UIImage(named: "shop_ic")
            }else if order.status! == "delivery_in_progress"{
                //delegate and after pickup item
                orderRouteStatus = 2
                orderDistanceFullView.isHidden = true
                orderNewDistanceFullView.isHidden = false
                orderPickupImg.image = UIImage(named: "car_ic")
            }else if order.status! == "cancelled" || order.status! == "delivered"{
                //order ended
                orderRouteStatus = 3
                orderDistanceFullView.isHidden = true
                orderNewDistanceFullView.isHidden = false
                orderPickupImg.image = UIImage(named: "shop_ic")
                
            }
        }
    }
    
    func calculateDrivenDistance(location: CLLocation){
       // delegateCurrentLocation = location
        self.delegateOldLocation = delegateCurrentLocation
        let disntance = GMSGeometryDistance(delegateOldLocation.coordinate, location.coordinate)
        delegateDistance -= disntance
        if orderRouteStatus == 2{ // delegate destination view
            if orderNewDistanceLbl != nil{
                self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: delegateDistance)
            }
        }else{ //delegate pickup destination view
            if orderToDistanceLbl != nil{
                self.orderToDistanceLbl.text = calculateDistance(distanceInMeters: delegateDistance)
            }
        }
        self.delegateCurrentLocation = location
    }
    
    func getHeadingForDirection(fromCoordinate fromLoc: CLLocationCoordinate2D, toCoordinate toLoc: CLLocationCoordinate2D) -> Float {
        
        let fLat: Float = Float((fromLoc.latitude).degreesToRadians)
        let fLng: Float = Float((fromLoc.longitude).degreesToRadians)
        let tLat: Float = Float((toLoc.latitude).degreesToRadians)
        let tLng: Float = Float((toLoc.longitude).degreesToRadians)
        let degree: Float = (atan2(sin(tLng - fLng) * cos(tLat), cos(fLat) * sin(tLat) - sin(fLat) * cos(tLat) * cos(tLng - fLng))).radiansToDegrees
        if degree >= 0 {
            return degree
        }
        else {
            return 360 + degree
        }
    }
    
}
extension Int {
    var degreesToRadians: Double { return Double(self) * .pi / 180 }
}
extension FloatingPoint {
    var degreesToRadians: Self { return self * .pi / 180 }
    var radiansToDegrees: Self { return self * 180 / .pi }
}
