//
//  DelegateOrderDetailsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import SummerSlider
import GoogleMaps
import MBProgressHUD
import Toaster
import Cosmos
import MapKit

class DelegateOrderDetailsVC: UIViewController, Dimmable {

    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var loadingScreenView: UIView!
    @IBOutlet weak var menuOptions: UIBarButtonItem!
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
    @IBOutlet weak var orderDistanceFullView: UIView!
    @IBOutlet weak var orderFromDistanceBgView: UIView!
    @IBOutlet weak var orderFromDistanceCirlcleView: UIView!
    @IBOutlet weak var orderFromDistanceLbl: UILabel!
    @IBOutlet weak var orderToDistanceBgView: UIView!
    @IBOutlet weak var orderToDistanceCirlcleView: UIView!
    @IBOutlet weak var orderToDistanceLbl: UILabel!
    @IBOutlet weak var pickupPinTop: NSLayoutConstraint!

    @IBOutlet weak var orderNewDistanceFullView: UIView!
    @IBOutlet weak var orderNewDistanceBgView: UIView!
    @IBOutlet weak var orderNewDistanceCirlcleView: UIView!
    @IBOutlet weak var orderNewDistanceLbl: UILabel!
    @IBOutlet weak var orderPickupImg: UIImageView!
    
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
    
    //new offer
    @IBOutlet weak var newOfferView: UIView!
    @IBOutlet weak var newOfferTitleLbl: UILabel!
    @IBOutlet weak var newOfferLbl: UILabel!
    @IBOutlet weak var newOfferRejectImg: UIImageView!
    @IBOutlet weak var newOfferAcceptImg: UIImageView!

    //my offer view
    @IBOutlet weak var myOfferView: UIView!
    @IBOutlet weak var myOfferViewHeight: NSLayoutConstraint!
    @IBOutlet weak var myOfferProfileImg: UIImageView!
    @IBOutlet weak var myOfferNameLbl: UILabel!
    @IBOutlet weak var myOfferTotalTitleLbl: UILabel!
    @IBOutlet weak var myOfferTotalTitleWidth: NSLayoutConstraint!
    @IBOutlet weak var myOfferTotalLbl: UILabel!
    @IBOutlet weak var myOfferCallLbl: UILabel!
    @IBOutlet weak var myOfferCallView: UIView!
    @IBOutlet weak var shippingCostTitleLbl: UILabel!
    @IBOutlet weak var shippingCostValueLbl: UILabel!
    @IBOutlet weak var comissionTitleLbl: UILabel!
    @IBOutlet weak var comissionValueLbl: UILabel!
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var vatValueLbl: UILabel!
    @IBOutlet weak var totalReceivedTitleLbl: UILabel!
    @IBOutlet weak var totalReceivedValueLbl: UILabel!
    @IBOutlet weak var cancelOfferLbl: UILabel!
    @IBOutlet weak var cancelOfferView: UIView!
    @IBOutlet weak var cancelOfferViewHeight: NSLayoutConstraint!
    @IBOutlet weak var itemPriceTitleLbl: UILabel!
    @IBOutlet weak var itemPriceValueLbl: UILabel!
    @IBOutlet weak var itemPriceView: UIView!
    @IBOutlet weak var addRateLbl: UILabel!
    @IBOutlet weak var addRateView: UIView!
    @IBOutlet weak var acceptedOfferViewTop: NSLayoutConstraint!
    @IBOutlet weak var starRateView: CosmosView!
    @IBOutlet weak var addedToWalletTitleLbl: UILabel!
    @IBOutlet weak var addedToWalletLbl: UILabel!
    @IBOutlet weak var addedToWalletView: UIView!
    @IBOutlet weak var discountTitleLbl: UILabel!
    @IBOutlet weak var discountLbl: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountTop: NSLayoutConstraint!
    @IBOutlet weak var discountBottom: NSLayoutConstraint!

    //no network
    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    //not available order
    @IBOutlet weak var notAvailableOrderView: UIView!
    @IBOutlet weak var notAvailableOrderLbl: UILabel!
    @IBOutlet weak var notAvailableOrderBtnView: UIView!

    
    var orderImages = [DelegateImageData]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let orderDetailsManager = OrderDetailsManager()
    let locationManager = LocationManager()
    var userDefault = UserDefault()
    var loadingView: MBProgressHUD!
    var orderDetailsPresenter : DelegateOrderDetailsPresenter!
    var orderID = 0
    var order = Order()
    var pickupLocation = CLLocationCoordinate2D()
    var destinationLocation = CLLocationCoordinate2D()
    var currentLocation = CLLocationCoordinate2D()
    var mapPoints = [CLLocationCoordinate2D]()
    var distanceToPickup = 0.0
    var distanceToDestination = 0.0
    var selectedImage = Image()
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    var needToClearMap = false
    var isCurrentRouteDrawed = false
    var isFromPushNotifications = false
    var isFromDeliverOrder = false
    // if isFromChat so we render order details page .. else check the status to know if we should navigate to chat or render order details page
    var isFromChat = false
    
    
    //tracking variables
    var carMarker : GMSMarker!
    let trackingManager = TrackingManager()
    var delegateLocation = CLLocation()
    var isDelegateRouteDrawed = false
    var isPickupRouteDrawed = false
    var delegatePolyline = GMSPolyline()
    //0 .. before pickup item   1 .. after pickup   2.. after end the ride
    var orderRouteStatus = 0
    //update distance
    var delegateDistance = 0.0
    var delegateOldLocation = CLLocation()
    var delegateCurrentLocation = CLLocation()
    var isFreeCommission = false
    
    var selectedProfileID = 0
    var isMapShowedOnly = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderDetailsPresenter = DelegateOrderDetailsPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository(), delegateRepository: Injection.provideDelegateRepository())
        orderDetailsPresenter.setView(view: self)
        orderDetailsPresenter.getDelegateOrderDetails(id: orderID, isFromReload: false)
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
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
        self.navigationItem.title = "delegate_order".localized()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        recordView.isHidden = true
        noNetworkView.isHidden = true
        orderNewDistanceLbl.text = ""
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
//            myOfferViewHeight.constant = 270
        }else{
            backIcon.image = UIImage(named: "back_ic")
//            myOfferViewHeight.constant = 230
        }
        
        orderDetailsManager.setCornerRadius(selectedView: orderInfoView, radius: 12)
        orderDetailsManager.setShadow(selectedView: orderInfoView)
        orderDetailsManager.setCornerRadius(selectedView: orderNumView, radius: 10)
        orderDetailsManager.setCornerRadius(selectedView: newOfferView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: orderFromDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderFromDistanceCirlcleView, radius: 3.5)
        orderDetailsManager.setCornerRadius(selectedView: orderToDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderToDistanceCirlcleView, radius: 3.5)
        orderDetailsManager.setCornerRadius(selectedView: orderDistanceFullView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: myOfferView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: cancelOfferView, radius: 10)
        orderDetailsManager.setCornerRadius(selectedView: myOfferProfileImg, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceBgView, radius: 5)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceCirlcleView, radius: 3.5)
        orderDetailsManager.setCornerRadius(selectedView: orderNewDistanceFullView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: notAvailableOrderBtnView, radius: 12)

        collapseOrderDetails()
        orderFromDistanceLbl.text = ""
        orderToDistanceLbl.text = ""
        newOfferView.isHidden = true
        myOfferView.isHidden = true
        myOfferCallView.isHidden = true
        notAvailableOrderView.isHidden = true
        setMapStyle()
        
        //hide menu options
        self.menuOptions.tintColor = UIColor.clear
        self.menuOptions.isEnabled = false
        self.mapOnlyIcon.tintColor = UIColor.clear
        self.mapOnlyIcon.isEnabled = false
        
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
        orderFromDistanceLbl.font = Utils.customDefaultFont(orderFromDistanceLbl.font.pointSize)
        orderToDistanceLbl.font = Utils.customDefaultFont(orderToDistanceLbl.font.pointSize)
        orderNewDistanceLbl.font = Utils.customDefaultFont(orderNewDistanceLbl.font.pointSize)

        orderDetailsTitleLbl.font = Utils.customBoldFont(orderDetailsTitleLbl.font.pointSize)
        orderDetailsDescLbl.font = Utils.customDefaultFont(orderDetailsDescLbl.font.pointSize)
        orderDetailsCancellationLbl.font = Utils.customDefaultFont(orderDetailsCancellationLbl.font.pointSize)

        newOfferTitleLbl.font = Utils.customDefaultFont(newOfferTitleLbl.font.pointSize)
        newOfferLbl.font = Utils.customDefaultFont(newOfferLbl.font.pointSize)
        
        shippingCostTitleLbl.font = Utils.customDefaultFont(shippingCostTitleLbl.font.pointSize)
        comissionTitleLbl.font = Utils.customDefaultFont(comissionTitleLbl.font.pointSize)
        vatTitleLbl.font = Utils.customDefaultFont(vatTitleLbl.font.pointSize)
        cancelOfferLbl.font = Utils.customDefaultFont(cancelOfferLbl.font.pointSize)
        totalReceivedTitleLbl.font = Utils.customDefaultFont(totalReceivedTitleLbl.font.pointSize)
        myOfferNameLbl.font = Utils.customDefaultFont(myOfferNameLbl.font.pointSize)
        myOfferTotalTitleLbl.font = Utils.customDefaultFont(myOfferTotalTitleLbl.font.pointSize)
        itemPriceTitleLbl.font = Utils.customDefaultFont(itemPriceTitleLbl.font.pointSize)
        addRateLbl.font = Utils.customDefaultFont(addRateLbl.font.pointSize)
        addedToWalletTitleLbl.font = Utils.customDefaultFont(addedToWalletTitleLbl.font.pointSize)
        addedToWalletLbl.font = Utils.customBoldFont(addedToWalletLbl.font.pointSize)
        discountTitleLbl.font = Utils.customDefaultFont(discountTitleLbl.font.pointSize)
        discountLbl.font = Utils.customBoldFont(discountLbl.font.pointSize)
        
        comissionValueLbl.font = Utils.customBoldFont(comissionValueLbl.font.pointSize)
        vatValueLbl.font = Utils.customBoldFont(vatValueLbl.font.pointSize)
        shippingCostValueLbl.font = Utils.customBoldFont(shippingCostValueLbl.font!.pointSize)
        totalReceivedValueLbl.font = Utils.customBoldFont(totalReceivedValueLbl.font!.pointSize)
        myOfferTotalLbl.font = Utils.customBoldFont(myOfferTotalLbl.font!.pointSize)
        itemPriceValueLbl.font = Utils.customBoldFont(itemPriceValueLbl.font.pointSize)
        myOfferCallLbl.font = Utils.customDefaultFont(myOfferCallLbl.font.pointSize)

        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        notAvailableOrderLbl.font = Utils.customBoldFont(notAvailableOrderLbl.font.pointSize)
    }
    
    func setGestures(){
        let orderTab = UITapGestureRecognizer(target: self, action: #selector(self.orderDetailsPressed))
        orderTab.cancelsTouchesInView = false
        orderDetailsFullView.addGestureRecognizer(orderTab)
        
        let orderImagesTab = UITapGestureRecognizer(target: self, action: #selector(self.orderCollectionPressed))
        orderImagesTab.cancelsTouchesInView = false
        collectionView.addGestureRecognizer(orderImagesTab)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
        
        let setOfferTap = UITapGestureRecognizer(target: self, action: #selector(setOfferAction))
        newOfferAcceptImg.addGestureRecognizer(setOfferTap)
        
        let rejectOfferTap = UITapGestureRecognizer(target: self, action: #selector(rejectOfferAction))
        newOfferRejectImg.addGestureRecognizer(rejectOfferTap)
        
        let cancelOfferTap = UITapGestureRecognizer(target: self, action: #selector(cancelOfferAction))
        cancelOfferView.addGestureRecognizer(cancelOfferTap)
        
        let cancelOfferLblTap = UITapGestureRecognizer(target: self, action: #selector(cancelOfferAction))
        cancelOfferLbl.addGestureRecognizer(cancelOfferLblTap)
        
        let addRateTap = UITapGestureRecognizer(target: self, action: #selector(showRate))
        addRateLbl.addGestureRecognizer(addRateTap)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        orderDetailsTitleLbl.text = "my_order_items".localized()
        
        newOfferLbl.text = "newOfferTitle".localized()
        comissionTitleLbl.text = "offer_Comission".localized()
        shippingCostTitleLbl.text = "Shipping_cost".localized()
//        vatTitleLbl.text = "VAT".localized()
        totalReceivedTitleLbl.text = "willReceive".localized()
        newOfferTitleLbl.text = "newOrder".localized()
        myOfferTotalTitleLbl.text = "totalOffer".localized()
        myOfferTotalTitleWidth.constant = myOfferTotalTitleLbl.intrinsicContentSize.width
        itemPriceTitleLbl.text = "item_price".localized()
        cancelOfferLbl.text = "cancel_offer".localized()
        addRateLbl.text = "add_rate".localized()
        addedToWalletTitleLbl.text = "added_to_wallet".localized()
        discountTitleLbl.text = "discount".localized()
        myOfferCallLbl.text = "call".localized()
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
    
    @objc func getUserLocation()
    {
        if locationManager.locationStatus == "denied" || locationManager.locationStatus == ""{
            Toast(text: "permissionDenied".localized()).show()
            
            //no location set last known location
            if userDefault.getLastKnownLocation().lat != nil && userDefault.getLastKnownLocation().lng != nil{
                
                self.currentLocation = CLLocationCoordinate2D(latitude: userDefault.getLastKnownLocation().lat!, longitude: userDefault.getLastKnownLocation().lng!)
                if order.from_lat != nil && order.from_lng != nil{
                    if order.from_lat != 0.0 && order.from_lng != 0.0{
                        self.updateCarOnMAp(location: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                    }
                }
                
            }
        }else{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
            self.currentLocation = locationManager.location.coordinate
            if order.from_lat != nil && order.from_lng != nil{
//                orderToDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: currentLocation.latitude, fromLocationLng: currentLocation.longitude, toLocationLat: order.from_lat!, toLocationLng: order.from_lng!)
//                setMarkerOnMap(latitude: currentLocation.latitude, longitude: currentLocation.longitude, imageName: "car_purple")
//                if !isCurrentRouteDrawed{
//                    print("not isCurrentRouteDrawed")
//                    orderDetailsPresenter.getPolylineRoute(from: currentLocation, to: pickupLocation, isDelegatePath: true)
//                    isCurrentRouteDrawed = true
//                }
                if order.from_lat != 0.0 && order.from_lng != 0.0{
                    self.updateCarOnMAp(location: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
                }
//                showAllMarkers()
            }
        }
        if mapView != nil{
            mapView.isMyLocationEnabled = true
        }
    }
    
    @objc func orderCollectionPressed(){
        print("orderCollectionPressed")
    }
    
    @objc func setOfferAction(){
        if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0{
            performSegue(withIdentifier: "toSetOffer", sender: self)
        }else{
            Toast(text: "permissionDenied".localized()).show()
        }
    }
    
    @IBAction func showMenuOptions(_ sender: Any) {
        if mapOnlyIcon.isEnabled{
            self.performSegue(withIdentifier: "menuOptions", sender: self)
        }else{
            mapFilterAction(sender)
        }
    }
    
    @objc func cancelOfferAction(){
        showCancelOfferAlert()
    }
    
    @objc func showRate() {
        performSegue(withIdentifier: "toRate", sender: self)
    }
    
    @IBAction func mapFilterAction(_ sender: Any) {
        print("mapFilterAction")
        self.isMapShowedOnly = !isMapShowedOnly
        if(isMapShowedOnly){
            if mapOnlyIcon.isEnabled{
                mapOnlyIcon.image = UIImage(named: "close_map")
            }else{
                menuOptions.image = UIImage(named: "close_map")
            }
        }else{
            if mapOnlyIcon.isEnabled{
                mapOnlyIcon.image = UIImage(named: "open_map")
            }else{
                menuOptions.image = UIImage(named: "open_map")
            }
        }
        if !isMapShowedOnly{
            changeOrderView(isHidden: false)
            setData(order: order)
        }else{
            changeOrderView(isHidden: true)
        }
    }
    
    func changeOrderView(isHidden: Bool){
        orderDetailsView.isHidden = isHidden
        orderInfoView.isHidden = isHidden
        newOfferView.isHidden = isHidden
        myOfferView.isHidden = isHidden
    }
    func showCancelOfferAlert(){
        
        var alert : UIAlertController!
        alert = UIAlertController(title: "", message: "cancel_offer_alert".localized(), preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            if self.order.offers != nil{
                if self.order.offers!.count > 0 {
                    if self.order.offers![0].id != nil{
                        self.orderDetailsPresenter.cancelOffer(id : self.order.offers![0].id!)
                        //self.cancelOfferSuccessfully()
                    }
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func rejectOfferAction(){
        print("reject offer")
        showIgnoreOrderAlert()
    }
    
    func showIgnoreOrderAlert(){
        
        var alert : UIAlertController!
        alert = UIAlertController(title: "", message: "ignore_order_alert".localized(), preferredStyle: UIAlertController.Style.alert)
        
        alert.setValue(NSAttributedString(string: "ignore_order_alert".localized(), attributes: [NSAttributedString.Key.font : Utils.customDefaultFont(13.0)]), forKey: "attributedMessage")
        
        alert.addAction(UIAlertAction(title: "yes".localized(), style: UIAlertAction.Style.default, handler: { (action) in
            self.orderDetailsPresenter.ignoreOrder(id: self.orderID)
        }))
        alert.addAction(UIAlertAction(title: "no".localized(), style: UIAlertAction.Style.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
        
    }
    @objc func orderDetailsPressed(){
        if orderDetailsViewHeight.constant == 0 {
            expandOrderDetails()
        }else{
            collapseOrderDetails()
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.needToClearMap = true
        if isFromPushNotifications{
            performSegue(withIdentifier: "toNotifications", sender: self)
        }else if isFromDeliverOrder{
            performSegue(withIdentifier: "home", sender: self)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    func reloadOrderData(){
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.reloadAction), userInfo: nil, repeats: false)
    }
    
    @objc func reloadAction(){
        self.view.isUserInteractionEnabled = true
        orderDetailsPresenter.getDelegateOrderDetails(id: orderID, isFromReload: false)
        changeOrderView(isHidden: false)
        isMapShowedOnly = false
        mapOnlyIcon.image = UIImage(named: "open_map")
    }
    
    func collapseOrderDetails(){
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
        newOfferView.isHidden = true
        self.menuOptions.tintColor = UIColor.white
        self.menuOptions.isEnabled = true
        self.mapOnlyIcon.tintColor = UIColor.white
        self.mapOnlyIcon.isEnabled = true
        menuOptions.image = UIImage(named: "more_actions_ic")
        
        self.mapOnlyIcon.tintColor = UIColor.white
        self.mapOnlyIcon.isEnabled = true
        
        if order.status != nil{
            if order.status! == "new"{
                orderStatusLbl.text = "newStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "498BCA")
                // set order waiting timer
                newOfferView.isHidden = false
                //hide menu options and show only map
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
                self.mapOnlyIcon.tintColor = UIColor.clear
                self.mapOnlyIcon.isEnabled = false
                if(isMapShowedOnly){
                    menuOptions.image = UIImage(named: "close_map")
                }else{
                    menuOptions.image = UIImage(named: "open_map")
                }
            }else if order.status! == "delivery_in_progress"{
                orderStatusLbl.text = "beignDeliveredStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "5CACF9")
                setOrderAcceptedOffer()
            }else if order.status! == "cancelled"{
                orderStatusLbl.text = "CancelledStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "E84450")
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
                setOrderAcceptedOffer()
            }else if order.status! == "pending"{
                orderStatusLbl.text = "pendingStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "A5AAB2")
                newOfferView.isHidden = false
                //hide menu options and show only map
                //                self.menuOptions.tintColor = UIColor.clear
                //                self.menuOptions.isEnabled = false
                self.mapOnlyIcon.tintColor = UIColor.clear
                self.mapOnlyIcon.isEnabled = false
                if(isMapShowedOnly){
                    menuOptions.image = UIImage(named: "close_map")
                }else{
                    menuOptions.image = UIImage(named: "open_map")
                }
            }else if order.status! == "assigned"{
                orderStatusLbl.text = "assignedStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "FF9F3E")
                setOrderAcceptedOffer()
            }else if order.status! == "in_progress"{
                orderStatusLbl.text = "inProgressStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "d8ca72")
                setOrderAcceptedOffer()
            }else if order.status! == "delivered"{
                orderStatusLbl.text = "DeliveredStatus".localized()
                orderStatusLbl.textColor = Colors.hexStringToUIColor(hex: "4DD552")
                setOrderAcceptedOffer()
                //hide menu options
//                self.menuOptions.tintColor = UIColor.clear
//                self.menuOptions.isEnabled = false
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
    
    func checkScreenNavigation(){
        if order.status != nil{
            if order.status! == "assigned" || order.status! == "in_progress" || order.status! == "delivery_in_progress"{
                self.needToClearMap = true
                performSegue(withIdentifier: "toChat", sender: self)
            }else if order.status! == "delivered"{
                setOrderData()
                if order.is_rated != nil{
                    if !order.is_rated!{ //order deliverd and not rated yet so show rating
                        if ((topMostController() as? RateVC) != nil){
                            print("rate already viewed")
                        }else{
                            performSegue(withIdentifier: "toRate", sender: self)
                        }
                    }
                }
            }else{
                setOrderData()
            }
        }else{
            setOrderData()
        }
    }
    
    func setOrderData(){
    
        // for testing
//        let databaseManager = DatabaseManager()
//        databaseManager.initRefernces(delegateID: userDefault.getUserData().id!)
//        databaseManager.getUpdatedOnDelegateLocation()
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
            setMap()
            //            orderFromDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: order.from_lat!, fromLocationLng: order.from_lng!, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            //            if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0{
            //                orderToDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: currentLocation.latitude, fromLocationLng: currentLocation.longitude, toLocationLat: order.from_lat!, toLocationLng: order.from_lng!)
            //            }else{
            //                orderToDistanceLbl.text = ""
            //            }
        }else{
            orderFromDistanceLbl.text = ""
            orderToDistanceLbl.text = ""
        }
    
        parseMyOffersData()
        expandOrderDetails()
        collapseOrderDetails()
        setOrderStatus()
        // set view hidden until get distance
        newOfferView.isHidden = true
        setOrderDate()
        
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
    }
    
    @IBAction func unwindFromSetOffer(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: dimSpeed)
    }
    
    @IBAction func unwindFromMenuOptions(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
    }
    
    @IBAction func unwindFromRate(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: dimSpeed)
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
    
    @IBAction func acceptedOfferProfileAction(){
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @objc func submitComplaint(){
        print("submitComplaint")
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func callUserAction(){
        if order.user != nil{
            if order.user?.mobile != nil{
                callUser(phone: (order.user?.mobile)!)
            }
        }
    }
    
    func callUser(phone: String) {
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
        }else if segue.identifier == "toSetOffer"{
            let vc = segue.destination as! DelegateSetOfferVC
            vc.order = self.order
            vc.currentLocation = self.currentLocation
            vc.distanceToPickup = self.distanceToPickup
            vc.distanceToDestination = self.distanceToDestination
            vc.setOfferDelegate = self
            vc.isFreeCommission = self.isFreeCommission
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "toNotifications"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 0
        }else if segue.identifier == "home"{
            let tabBarView = segue.destination as! UserTabBar
            tabBarView.selectedIndex = 1
            let nav = tabBarView.viewControllers![1] as! UINavigationController
            let vc = nav.topViewController as! MyOrdersVC
            vc.isUser = false
        }else if segue.identifier == "toChat"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ChatVC
            vc.isFromMyOrders = true
            vc.isDelegateOfOrder = true
            
            vc.order = order
            vc.isFromPushNotifications = self.isFromPushNotifications
        }else if segue.identifier == "toProfile"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ProfileVC
            vc.isUser = true
            vc.userId = selectedProfileID
        }else if segue.identifier == "toRate"{
            let vc = segue.destination as! RateVC
            vc.order = order
            vc.isUserRateDelegate = false
            vc.rateOrderDelegate = self
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "menuOptions"{
            let vc = segue.destination as! MenuOptions
            vc.isDelegate = true
            vc.order = self.order
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }
    }
}

extension DelegateOrderDetailsVC: GMSMapViewDelegate{ //map functions
    
    func setMap(){
        // set map
        if mapView != nil{
            let pickupLat = CLLocationDegrees(exactly: order.from_lat!)
            let pickupLng = CLLocationDegrees(exactly: order.from_lng!)
            let camera = GMSCameraPosition.camera(withLatitude: pickupLat!, longitude: pickupLng!, zoom: 16.0)
            if mapView != nil{
                mapView.camera = camera
            }
            
            if appDelegate.isRTL{
                setMarkerOnMap(latitude: pickupLat!, longitude: pickupLng!, imageName: "btn_red_ar")
            }else{
                setMarkerOnMap(latitude: pickupLat!, longitude: pickupLng!, imageName: "btn_red_en")
            }
            
            let destinationLat = CLLocationDegrees(exactly: order.to_lat!)
            let destinationLng = CLLocationDegrees(exactly: order.to_lng!)
            if appDelegate.isRTL{
                setMarkerOnMap(latitude: destinationLat!, longitude: destinationLng!, imageName: "btn_blue_ar")
            }else{
                setMarkerOnMap(latitude: destinationLat!, longitude: destinationLng!, imageName: "btn_blue_en")
            }
//            if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0{
//                setMarkerOnMap(latitude: currentLocation.latitude, longitude: currentLocation.longitude, imageName: "car_purple")
//            }
            
            pickupLocation = CLLocationCoordinate2D(latitude: pickupLat!, longitude: pickupLng!)
            destinationLocation = CLLocationCoordinate2D(latitude: destinationLat!, longitude: destinationLng!)
            
            if orderRouteStatus == 0 || orderRouteStatus == 2{
                // if before pickup need to draw the pickup destination route
                orderDetailsPresenter.getPolylineRoute(from: pickupLocation, to: destinationLocation, isDelegatePath: false , orderStatus: order.status ?? "")
            }

//            orderDetailsPresenter.getPolylineRoute(from: currentLocation, to: pickupLocation, isDelegatePath: true)
            if orderRouteStatus != 2{ // ended order no need to delegate location
                self.updateCarOnMAp(location: CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude))
            }else if mapView != nil && carMarker != nil{
                delegatePolyline.map = nil
                carMarker.map = nil
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
            if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0{
                path.add(currentLocation)
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
    
    func setDistance(isDelegatePath: Bool, distanceValue: Double){
        if isDelegatePath{
            self.distanceToPickup = distanceValue/1000
            delegateDistance = distanceValue
            if Int(distanceValue) > 1000 {
                if orderRouteStatus == 1{
                    if orderNewDistanceLbl != nil{
                        self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }else{
                    if orderToDistanceLbl != nil{
                        self.orderToDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }
            }else{
                if orderRouteStatus == 1{
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
                if orderRouteStatus == 2{ //ended order
                    if orderNewDistanceLbl != nil{
                        self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }else{
                    if orderFromDistanceLbl != nil{
                        self.orderFromDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }
                
            }else{
                if orderRouteStatus == 2{ //ended order
                    if orderNewDistanceLbl != nil{
                        self.orderNewDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }else{
                    if orderFromDistanceLbl != nil{
                        self.orderFromDistanceLbl.text = calculateDistance(distanceInMeters: distanceValue)
                    }
                }
            }
        }
        
        if orderFromDistanceLbl.text != "" && orderToDistanceLbl.text != ""{
            newOfferView.isHidden = false
            setOrderStatus()
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
    
    func showPath(polyStr :String, isDelegatePath: Bool){
        if   order.status! == "pending"{ //modified condition
            if orderFromDistanceLbl.text != "" && orderToDistanceLbl.text != ""{
                newOfferView.isHidden = false
                setOrderStatus()
            }
            let path = GMSPath(fromEncodedPath: polyStr)
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 2.5
            if isDelegatePath{
                //after pick up line item to destination
                if orderRouteStatus == 1{
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
                isPickupRouteDrawed = true
                if mapView != nil{
                    polyline.map = mapView // Your map view
                }
            }
        }
    }
    
    func getAllDistance(){
        newOfferView.isHidden = false
        setOrderStatus()
        isCurrentRouteDrawed = false
        if order.from_lat != nil && order.from_lng != nil && order.to_lat != nil && order.to_lng != nil{
            orderFromDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: order.from_lat!, fromLocationLng: order.from_lng!, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0{
                orderToDistanceLbl.text = orderDetailsManager.getDistance(fromLocationLat: currentLocation.latitude, fromLocationLng: currentLocation.longitude, toLocationLat: order.from_lat!, toLocationLng: order.from_lng!)
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
        
        if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0 && order.from_lat != nil && order.from_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: currentLocation.latitude, fromLocationLng: currentLocation.longitude, toLocationLat: order.from_lat!, toLocationLng: order.from_lng!)
            setDistance(isDelegatePath: true, distanceValue: distance)
        }
    }
    
    
    func getFromDelegateToDestinationDistance(){
        
        if currentLocation.latitude != 0.0 && currentLocation.longitude != 0.0 && order.to_lat != nil && order.to_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: currentLocation.latitude, fromLocationLng: currentLocation.longitude, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            setDistance(isDelegatePath: true, distanceValue: distance)
        }
    }
    
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.icon == UIImage(named: "btn_blue_ar") || marker.icon == UIImage(named: "btn_blue_en"){
            print("destination_pin_map")
            redirectToMaps(latitude: order.to_lat!, longitude: order.to_lng!)
        }else if marker.icon == UIImage(named: "btn_red_en") || marker.icon == UIImage(named: "btn_red_ar"){
            print("store_pin_map")
            redirectToMaps(latitude: order.from_lat!, longitude: order.from_lng!)
        }else {
            print("car_vertical")
//            redirectToMaps(latitude: delegateLocation.coordinate.latitude, longitude: delegateLocation.coordinate.longitude)
        }
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

extension DelegateOrderDetailsVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
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

extension DelegateOrderDetailsVC: DelegateOrderDetailsView{
    
    func showloading(isFromCancel: Bool) {
        if !isFromCancel{
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
        
        if isFromChat{ // reder order details
            setOrderData()
        }else{ // check on status if render order details or navigate to chat page
            checkScreenNavigation()
        }        
        
    }
    
    func setFreeCommission(isFreeCommission: Bool) {
        self.isFreeCommission = isFreeCommission
    }
    
    func cancelOfferSuccessfully(){
        print("cancelOfferSuccessfully")
//        if isFromPushNotifications{
//            performSegue(withIdentifier: "home", sender: self)
//        }else{
//            //get selected tab bar index to my orders , delibvery request tab
//            if let tabBarView = self.presentingViewController as? UserTabBar{
//                tabBarView.selectedIndex = 1
//                let nav = tabBarView.viewControllers![1] as! UINavigationController
//                let vc = nav.topViewController as! MyOrdersVC
//                vc.isUser = false
//            }
//
//            self.dismiss(animated: true, completion: nil)
//        }
        hideMyOfferView()
    }
    
    func ignoreOrderSuccessfully() {
        self.needToClearMap = true
        if isFromPushNotifications{
            performSegue(withIdentifier: "toNotifications", sender: self)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    func showNotAvailabeOrder(msg : String){
        notAvailableOrderView.isHidden = false
        notAvailableOrderLbl.text = msg
    }
    
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
}
extension DelegateOrderDetailsVC: SetOfferDelegate{
    
    func setOfferSuccessfully(shippingCost: Double, Commission: Double, VAT: Double, totalRecieve: Double){
        
//        shippingCostValueLbl.text = getPrice(price: shippingCost)
//        comissionValueLbl.text = getPrice(price: Commission)
//        vatValueLbl.text = getPrice(price: VAT)
//        totalReceivedValueLbl.text = getPrice(price: totalRecieve)
//        let total = shippingCost + VAT
//        myOfferTotalLbl.text = getPrice(price: total)
//        setMyOfferView()
        orderDetailsPresenter.getDelegateOrderDetails(id: orderID, isFromReload: true)
    }
    
    func setMyOfferView(){
        myOfferView.isHidden = false
        newOfferView.isHidden = true
        setAddRateView()
        setUserData()
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
    
    func hideMyOfferView(){
        myOfferView.isHidden = true
        newOfferView.isHidden = false
    }
    
    func parseMyOffersData(){
        myOfferView.isHidden = true
        if order.offers != nil{
            if (order.offers?.count)! > 0{
                let offer = order.offers![0]
                var totalReceivedValue = 0.0
                var totalValue = 0.0
                
                if offer.cost != nil{
                    shippingCostValueLbl.text = getPrice(price: offer.cost!)
                    totalReceivedValue = offer.cost!
                    totalValue = offer.cost!
                }else{
                    shippingCostValueLbl.text = "-"
                }
                
                if offer.commission != nil{
                    if offer.commission == 0{
                        comissionValueLbl.text = "free_commission".localized()
                    }else{
                        comissionValueLbl.text = getPrice(price: offer.commission!)
                    }
                    totalReceivedValue -= offer.commission!
                }else{
                    comissionValueLbl.text = "-"
                }
                
//                if offer.vat != nil{
//                    vatValueLbl.text = getPrice(price: offer.vat!)
//                    totalValue += offer.vat!
//                }else{
//                    vatValueLbl.text = "-"
//                }
                
                totalReceivedValueLbl.text = getPrice(price: totalReceivedValue)
                myOfferTotalLbl.text = getPrice(price: totalValue)
                
                //no changes actual price equal total price
                addedToWalletLbl.isHidden = true
                addedToWalletTitleLbl.isHidden = true
                addedToWalletView.isHidden = true
                addedToWalletLbl.text = ""
                addedToWalletTitleLbl.text = ""
                
                //hide item price
                itemPriceTitleLbl.isHidden = true
                itemPriceValueLbl.isHidden = true
                itemPriceView.isHidden = true
                acceptedOfferViewTop.constant = 5
                
                //hide discount field
               hideDiscountView()
                
                setMyOfferView()
            }
        }
    }
    
    func setOrderAcceptedOffer(){
        myOfferView.isHidden = true
        
        addRateLbl.isHidden = true
        addRateView.isHidden = true
        starRateView.isHidden = false
        
        
        var totalReceivedValue = 0.0
        var totalValue = 0.0
        var changes = 0.0

        if order.delivery_price != nil{
            shippingCostValueLbl.text = getPrice(price: order.delivery_price!)
            totalReceivedValue = order.delivery_price!
            totalValue = order.delivery_price!
            setMyOfferView()
        }else{
            // no offer
            shippingCostValueLbl.text = "-"
        }
        
        if order.commission != nil{
            if order.commission == 0{
                comissionValueLbl.text = "free_commission".localized()
            }else{
                comissionValueLbl.text = getPrice(price: order.commission!)
            }
            totalReceivedValue -= order.commission!
        }else{
            comissionValueLbl.text = "-"
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
                acceptedOfferViewTop.constant = 30
            }else{
                acceptedOfferViewTop.constant = 26
            }
        }else{
            //hide item price
            itemPriceTitleLbl.isHidden = true
            itemPriceValueLbl.isHidden = true
            itemPriceView.isHidden = true
            acceptedOfferViewTop.constant = 5
        }
        
        if order.actual_paid != nil && order.total_price != nil{
            addedToWalletLbl.isHidden = false
            addedToWalletTitleLbl.isHidden = false
            addedToWalletView.isHidden = false
            changes = order.actual_paid! - order.total_price!
            if order.actual_paid! > order.total_price!{
                addedToWalletLbl.text = "+\(getPrice(price: changes))"
                addedToWalletTitleLbl.text = "added_to_wallet".localized()
                totalValue += changes
            }else if order.actual_paid! < order.total_price!{
                addedToWalletLbl.text = "\(getPrice(price: changes))"
                addedToWalletTitleLbl.text = "added_to_wallet".localized()
                totalValue -= changes
            }else{
                //no changes actual price equal total price
                addedToWalletLbl.isHidden = true
                addedToWalletTitleLbl.isHidden = true
                addedToWalletView.isHidden = true
                addedToWalletLbl.text = ""
                addedToWalletTitleLbl.text = ""
            }
        }else{
            //no changes actual price equal total price
            addedToWalletLbl.isHidden = true
            addedToWalletTitleLbl.isHidden = true
            addedToWalletView.isHidden = true
            addedToWalletLbl.text = ""
            addedToWalletTitleLbl.text = ""
        }
        
        totalReceivedValueLbl.text = getPrice(price: totalReceivedValue)
        if order.actual_paid != nil{
            myOfferTotalLbl.text = getPrice(price: order.actual_paid!)
        }else{
            if totalValue < 0{
                myOfferTotalLbl.text = getPrice(price: 0)
            }else{
                myOfferTotalLbl.text = getPrice(price: totalValue)
            }
        }
        // after accepted hide cancel offer view and view call button
        cancelOfferLbl.isHidden = true
        cancelOfferView.isHidden = true
        cancelOfferViewHeight.constant = 0
        myOfferCallView.isHidden = false
        
    }
    
    func hideDiscountView(){
        discountLbl.isHidden = true
        discountTitleLbl.isHidden = true
        discountView.isHidden = true
        discountLbl.text = ""
        discountTitleLbl.text = ""
        discountTop.constant = 0
        discountBottom.constant = 0
    }
    
    func setUserData(){
        var userData = UserData()
        
        if order.user != nil{
            userData = order.user!
        }
        
        if userData.name != nil{
            myOfferNameLbl.text = userData.name
        }else{
            myOfferNameLbl.text = ""
        }
        
        if userData.id != nil{
            selectedProfileID = userData.id!
        }
        
        myOfferProfileImg.image = UIImage(named: "avatar")
        if userData.image != nil{
            if userData.image?.medium != nil{
                let url = URL(string: (userData.image?.medium)!)
                print("url \(String(describing: url))")
                self.myOfferProfileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
        if userData.rating != nil{
            setRate(rate: (userData.rating)!)
        }else{
            setRate(rate: 5)
        }
    }
    
    func setRate(rate: Double){
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
}

extension DelegateOrderDetailsVC: RateOrderDelegate{
    
    func rateOrderSuccessfully(order: Order) {
        setData(order: order)
    }
    
}

// TRAKING
extension DelegateOrderDetailsVC{
    
    
    func getDelegateRoute(location: CLLocation){
        print("getDelegateRoute in user details")
        self.delegateLocation = location
        self.currentLocation = location.coordinate
//        if !isDelegateRouteDrawed {
//            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation, isDelegatePath: true)
//        }
        if orderRouteStatus == 0{
            //delegate on his way to pickup
            if pickupLocation.longitude != 0.0 && pickupLocation.latitude != 0.0 && location.coordinate.longitude != 0.0 && location.coordinate.latitude != 0.0{
                orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation, isDelegatePath: true, orderStatus: order.status ?? "")
            }
        }else if orderRouteStatus == 1{
            //delegate on his way to destination
            if destinationLocation.longitude != 0.0 && destinationLocation.latitude != 0.0 && location.coordinate.longitude != 0.0 && location.coordinate.latitude != 0.0{
                orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: destinationLocation, isDelegatePath: true, orderStatus: order.status ?? "")
            }
        }
        showAllMarkers()
    }
    
    func updateCarOnMAp(location: CLLocation){
        var oldLocation = CLLocation()
        if orderRouteStatus != 2{ // ended trip so we don't need to delegate on map or location
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
                //modified2
                currentLocation = location.coordinate
                
                if (order.status ?? "") == "delivery_in_progress"{
                    self.getFromDelegateToDestinationDistance()
                }else{
                    self.getFromDelegateToPickupDistance()
                }
                
                CATransaction.begin()
                CATransaction.setAnimationDuration(1.0)
                carMarker.position = location.coordinate
                carMarker.rotation = GMSGeometryHeading(oldLocation.coordinate, location.coordinate)
                CATransaction.commit()
            }
            
            oldLocation = location
        }else{
            if mapView != nil && carMarker != nil{
                delegatePolyline.map = nil
                carMarker.map = nil
            }
        }
    }
    
    // TO CHECK IF DELEGATE NEW LOCATION ON THE DRAWED ROUTE OR NOT
    func checkDelegateRoute(location: CLLocation){
        if delegatePolyline.path != nil{
            let path = delegatePolyline.path
            let result = GMSGeometryIsLocationOnPathTolerance(location.coordinate, path!, true, 10)
            if result{
                print("removed the drived path")
                let points = GMSGeometryInterpolate(delegateLocation.coordinate, pickupLocation, 1)
                print(points)
                let str = trackingManager.removeDrivedRoute(polylineStr: (path?.encodedPath())!, delegateLocation: location)
                delegatePolyline.map = nil
                showPath(polyStr: str, isDelegatePath: true)
                calculateDrivenDistance(location: location)
            }else{
                print("remove the past path and create new one")
                delegateCurrentLocation = location
                removePath(location: location)
            }
        }else{
            print("remove the past path and create new one")
            delegateCurrentLocation = location
            removePath(location: location)
        }
    }
    
    func removePath(location: CLLocation){
        delegatePolyline.map = nil
        if orderRouteStatus == 0{
            //delegate on his way to pickup
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }else if orderRouteStatus == 1{
            //delegate on his way to destination
            orderDetailsPresenter.getPolylineRoute(from: location.coordinate, to: destinationLocation, isDelegatePath: true, orderStatus: order.status ?? "")
        }
    }
    
    func setOrderRouteStatus(){
        if order.status != nil{
            if order.status! == "new" || order.status! == "pending" || order.status! == "assigned" || order.status! == "in_progress"{
                orderRouteStatus = 0
                orderDistanceFullView.isHidden = false
                orderNewDistanceFullView.isHidden = true
                orderPickupImg.image = UIImage(named: "shop_ic")
            }else if order.status! == "delivery_in_progress"{
                orderRouteStatus = 1
                orderDistanceFullView.isHidden = true
                orderNewDistanceFullView.isHidden = false
                orderPickupImg.image = UIImage(named: "car_ic")
            }else if order.status! == "cancelled" || order.status! == "delivered"{
                orderRouteStatus = 2
                orderDistanceFullView.isHidden = true
                orderNewDistanceFullView.isHidden = false
                orderPickupImg.image = UIImage(named: "shop_ic")
            }
        }
        if orderRouteStatus == 0{
            trackingManager.setDeliveryStatus(isBeforePickup: true)
        }else if orderRouteStatus == 1{
            trackingManager.setDeliveryStatus(isBeforePickup: false)
        }
    }
    
    func calculateDrivenDistance(location: CLLocation){
        self.delegateOldLocation = delegateCurrentLocation
        let disntance = GMSGeometryDistance(delegateOldLocation.coordinate, location.coordinate)
        delegateDistance -= disntance
        if orderRouteStatus == 1{ // delegate destination view
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
