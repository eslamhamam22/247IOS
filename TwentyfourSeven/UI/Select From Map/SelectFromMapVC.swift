//
//  SelectFromMapVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/23/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GoogleMaps
import Toaster
import Lottie

class SelectFromMapVC: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var addressNameTF: UILabel!
    @IBOutlet weak var mapViewPin: UIImageView!
    @IBOutlet weak var headerPinView: UIView!
    @IBOutlet weak var headerPinLbl: UILabel!
    @IBOutlet weak var pinBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    @IBOutlet weak var addressTitleLbl: UILabel!
    @IBOutlet weak var addressTitleWidth: NSLayoutConstraint!
    @IBOutlet weak var addressTitleView: UIView!
    
    @IBOutlet weak var confirmView: UIView!
    @IBOutlet weak var confirmLbl: UILabel!
    @IBOutlet weak var confirmIcon: UIImageView!
    @IBOutlet weak var coveredView: UIView!
    
    //no location
    @IBOutlet weak var noLocationView: UIView!
    @IBOutlet weak var noLocationLogoImg: UIImageView!
    @IBOutlet weak var noLocationTitleLbl: UILabel!
    @IBOutlet weak var noLocationDescLbl: UILabel!
    @IBOutlet weak var noLocationActivateLbl: UILabel!
    @IBOutlet weak var noLocationActivateImg: UIImageView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locationManager = LocationManager()
    var isValidAddressName = false
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var countryCode = ""
    var isFromCamera = false
    var isFromSearch = true
    var isFirstOne = true
    var destinationDelegate : DestinationDelegate!
    var cameraChangesCount = 0
    var needToClearMap = false
    var userDefault = UserDefault()
    var isFromHome = false
    var isFromDestination = false
    // 1.. from home with pickup    2.. from request with pickup   3.. from request with destination
    var fromType = 0
    
    var areaManager = AreaManager()
    
    private var boatAnimation: LOTAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        if mapView != nil{
            mapView.delegate = self
        }
        if latitude != 0.0 && longitude != 0.0{
            getLocation(location: CLLocation(latitude: latitude, longitude: longitude))
            if mapView != nil{
                mapView.isMyLocationEnabled = true
            }
        }else{
            if userDefault.getLastKnownLocation().lat != 0.0 && userDefault.getLastKnownLocation().lng != 0.0{
                self.latitude = userDefault.getLastKnownLocation().lat!
                self.longitude = userDefault.getLastKnownLocation().lng!
                if userDefault.getCountryCode() != nil{
                    self.countryCode = userDefault.getCountryCode()!
                    print("saved countryCode: \(countryCode)")
                }
                getLocation(location: CLLocation(latitude: latitude, longitude: longitude))
                if mapView != nil{
                    mapView.isMyLocationEnabled = true
                }
            }
            // get user location
            locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
        }
        
        setLocalization()
        setFonts()
        setUI()
        setGestures()
    }
    
  
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        
      
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        if needToClearMap{
            mapView.clear()
            mapView.stopRendering()
            mapView.removeFromSuperview()
            mapView = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        
        if fromType != 3{
            self.navigationItem.title = "pickupFrom".localized()
            mapViewPin.image = UIImage(named: "store_pin_map-1")
            confirmIcon.image = UIImage(named: "shop_ic-1")
            headerPinView.backgroundColor = Colors.hexStringToUIColor(hex: "E84450")
        }else{
            self.navigationItem.title = "WhereTo".localized()
            mapViewPin.image = UIImage(named: "destination_pin_map-1")
            confirmIcon.image = UIImage(named: "destination_ic_1")
            headerPinView.backgroundColor = Colors.hexStringToUIColor(hex: "366DB3")
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        setCornerRadius(selectedView: addressTitleView)
        setCornerRadius(selectedView: confirmView)
        setCornerRadius(selectedView: coveredView)
        setCornerRadius(selectedView: headerPinView)

        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
            addressNameTF.textAlignment = .right
            
        }else{
            backIcon.image = UIImage(named: "back_ic")
            addressNameTF.textAlignment = .left
        }
        
        coveredView.isHidden = false
        noLocationView.isHidden = true
        
        addressTitleWidth.constant = addressTitleLbl.intrinsicContentSize.width
        
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.getAddressName), userInfo: nil, repeats: true)
        
        addressTitleView?.layer.borderColor = UIColor.lightGray.cgColor
        addressTitleView?.layer.borderWidth = 0
        addressTitleView?.layer.masksToBounds = false
        addressTitleView?.layer.shadowOffset = CGSize(width: 2, height: 2)
        addressTitleView?.layer.shadowRadius = 3
        addressTitleView?.layer.shadowOpacity = 0.1
        
        setMapStyle()
        initAnimation()
    }
    
    func setLocalization(){
        if fromType != 3{ // destination
            confirmLbl.text = "confirm_pickup".localized()
            addressTitleLbl.text = "fromStore".localized()
            addressNameTF.text = "pickUp_point".localized()
        }else{
            confirmLbl.text = "confirm_destination".localized()
            addressTitleLbl.text = "toStore".localized()
            addressNameTF.text = "destination".localized()
        }
        addressNameTF.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")

    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setGestures(){
        let confirmTab = UITapGestureRecognizer(target: self, action: #selector(self.confirmAction))
        confirmView.addGestureRecognizer(confirmTab)
        
        let confirmLblTab = UITapGestureRecognizer(target: self, action: #selector(self.confirmAction))
        confirmLbl.addGestureRecognizer(confirmLblTab)
        
        let currentLocationTab = UITapGestureRecognizer(target: self, action: #selector(self.setCurrentLocation))
        currentLocationIcon.addGestureRecognizer(currentLocationTab)
        
        let addressTab = UITapGestureRecognizer(target: self, action: #selector(self.addressSearchPressed))
        addressNameTF.addGestureRecognizer(addressTab)
        
        let addressViewTab = UITapGestureRecognizer(target: self, action: #selector(self.addressSearchPressed))
        addressTitleView.addGestureRecognizer(addressViewTab)
        
        let activatetap = UITapGestureRecognizer(target: self, action: #selector(activateLocationAction))
        noLocationActivateImg.addGestureRecognizer(activatetap)
        
        let activateLblTap = UITapGestureRecognizer(target: self, action: #selector(activateLocationAction))
        noLocationActivateLbl.addGestureRecognizer(activateLblTap)
    }
    
    func setFonts(){
        confirmLbl.font = Utils.customDefaultFont(confirmLbl.font.pointSize)
        addressTitleLbl.font = Utils.customDefaultFont(addressTitleLbl.font.pointSize)
        addressNameTF.font = Utils.customDefaultFont(addressNameTF.font!.pointSize)
        headerPinLbl.font = Utils.customDefaultFont(headerPinLbl.font.pointSize)

        noLocationTitleLbl.font = Utils.customBoldFont(noLocationTitleLbl.font.pointSize)
        noLocationDescLbl.font = Utils.customDefaultFont(noLocationDescLbl.font.pointSize)
        noLocationActivateLbl.font = Utils.customDefaultFont(noLocationActivateLbl.font.pointSize)
    }
    
    func setLocationView(){
        noLocationTitleLbl.text = "no_location_title".localized()
        noLocationDescLbl.text = "no_location_desc".localized()
        noLocationActivateLbl.text = "no_location_activate".localized()
        noLocationLogoImg.image = UIImage(named: "gps_ic")
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
    
    @IBAction func backAction(_ sender: Any) {
        needToClearMap = true
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addressesAction(_ sender: Any) {
        performSegue(withIdentifier: "toAddresses", sender: self)
    }
    
    @objc func setCurrentLocation(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        isValidAddressName = true
        isFromSearch = false
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
    }
    
    @objc func confirmAction(){
        self.view.endEditing(true)
        if coveredView.isHidden{
            print("confirmAction")
            if !areaManager.isSelectedPointInBlockedArea(latitude: self.latitude, longitude: self.longitude){
                if isFromHome{
                    performSegue(withIdentifier: "toRequest", sender: self)
                }else{
                    destinationDelegate.selectAddress(latitude: self.latitude, longitude: self.longitude, address: addressNameTF.text!, title: "")
                    needToClearMap = true
                    dismiss(animated: true, completion: nil)
                }
            }else{
                Toast.init(text: "blockedAreaToast".localized()).show()
            }
            
        }
        
        ///
//        self.view.endEditing(true)
//        if coveredView.isHidden{
//            print("confirmAction")
//            if isFromHome{
//                performSegue(withIdentifier: "toRequest", sender: self)
//            }else{
//                destinationDelegate.selectAddress(latitude: self.latitude, longitude: self.longitude, address: addressNameTF.text!, title: "")
//                needToClearMap = true
//                dismiss(animated: true, completion: nil)
//            }
//        }
    }
    
    @objc func activateLocationAction(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                // Checking for setting is opened or not
                print("Setting is opened: \(success)")
            })
        }
    }
    
    @objc func addressSearchPressed(){
        print("addressNamePressed")
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    @objc func getUserLocation()
    {
        
        if locationManager.locationStatus == "denied" || locationManager.locationStatus == ""{
            //            Toast(text: "permissionDenied".localized()).show()
            setLocationView()
            noLocationView.isHidden = false
        }else{
            noLocationView.isHidden = true
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotLocation"), object: nil)
        }
        
        if locationManager.countryCode != "Error" && locationManager.countryCode != ""{
            self.countryCode = locationManager.countryCode
            self.userDefault.setCountryCode(locationManager.countryCode)
        }
        getLocation(location: locationManager.location)
        if mapView != nil{
            mapView.isMyLocationEnabled = true
        }
//        mapView.settings.myLocationButton = true
    }
    
    
    func getLocation(location : CLLocation)
    {
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: 16.0)
        if mapView != nil{
            mapView.camera = camera
        }
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        if !isFromSearch{
            self.isFromCamera = true
        }
        getAddressName()
    }

    @objc func getAddressName(){
        
        let location = CLLocation(latitude: latitude, longitude: longitude)
//        print("getAddressName function")
        if isFromCamera{
            print("is from camera")
            self.isFromCamera = false
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location, completionHandler: {
                placemarks, error in
                
                if error == nil && (placemarks?.count)! > 0 {
                    let placeMark = placemarks?.last
                    let lines  = "\(placeMark!.thoroughfare ?? "")\n\(placeMark!.postalCode ?? "") \(placeMark!.locality ?? "")\n\(placeMark!.administrativeArea ?? "")\n\(placeMark!.country ?? "")\n\(placeMark!.subAdministrativeArea ?? "")\n\(placeMark!.subThoroughfare ?? "")\n\(placeMark!.subLocality ?? "")"
                    print("postalcode \(placeMark!.postalCode ?? "")")
                    
                    if self.isValidAddressName{
                        var subThoroughfare = ""
                        if placeMark?.subThoroughfare != nil{
                            if (placeMark?.subThoroughfare?.contains("–"))!{
                                subThoroughfare = ""
                            }else if placeMark?.subThoroughfare == " "{
                                subThoroughfare = ""
                            }else{
                                subThoroughfare = (placeMark?.subThoroughfare)!
                            }
                        }else{
                            subThoroughfare = ""
                        }
                        self.coveredView.isHidden = true
                        var addressStr = "\(subThoroughfare) \(placeMark!.thoroughfare ?? "") \(placeMark!.subLocality ?? "") \(placeMark!.locality ?? "")"
                        if addressStr.first == " "{
                            addressStr.remove(at: addressStr.startIndex)
                        }
                        self.addressNameTF.text = addressStr
                        self.addressNameTF.textColor = Colors.hexStringToUIColor(hex: "#366db3")
                        
                        //                        self.deleteNameIcon.isHidden = false
                    }else{
                        self.isValidAddressName = true
                    }
                    let address = " \(placeMark!.locality ?? "") \(placeMark!.administrativeArea ?? "") \(placeMark!.country ?? "")"
                    print("address \(address)")
                    
                    print("lines \(lines)")
                    
                }else{
                    print("error: \(String(describing: error))")
                }
            })
        }else{
            self.isValidAddressName = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSearch")
        {
            let destinationController = segue.destination as! UINavigationController
            let vc = destinationController.topViewController as! LocationSearchVC
            vc.locationSearchDelegate = self
            vc.countryCode = self.countryCode
        }else if segue.identifier == "toAddresses"{
            let destinationController = segue.destination as! UINavigationController
            let vc = destinationController.topViewController as! ViewMyAddressesVC
            vc.isFromOrder = true
            vc.destinationDelegate = self
            vc.fromType = self.fromType
        }else if segue.identifier == "toRequest"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! RequestFromStoreVC
            vc.isFromRequestLocation = true
            vc.fromLat = self.latitude
            vc.fromLng = self.longitude
            vc.fromLocationDesc = addressNameTF.text!
            vc.countryCode = self.countryCode
        }
    }
}

extension SelectFromMapVC: DestinationDelegate{
    
    func selectAddress(latitude: Double, longitude: Double, address: String, title: String) {
        print("lat: \(latitude), lng: \(longitude), address: \(address)")
        if isFromHome {
            print("is from home")
            performSegue(withIdentifier: "toRequest", sender: self)
        }else{
            needToClearMap = true
//            self.dismiss(animated: false, completion: nil)
            destinationDelegate.selectAddress(latitude: latitude, longitude: longitude, address: address, title: title)
        }
    }
}

extension SelectFromMapVC: GMSMapViewDelegate{
    // Camera change Position this methods will call every time
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        cameraChangesCount += 1
     
        self.latitude = position.target.latitude
        self.longitude = position.target.longitude
        if !isFromSearch{
            self.isFromCamera = true
        }else{
            if cameraChangesCount > 1{
                isFromSearch = false
            }
        }
        
    }
    
    func mapView(_ mapView: GMSMapView, didDrag marker: GMSMarker) {
        print("didDrag")
    }
    
    func mapView(_ mapView: GMSMapView, didEndDragging marker: GMSMarker) {
        print("didEndDragging")
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("willMove")
//        mapViewPin.isHidden = true
//        beginAnimation()
        if fromType != 3{ //pickup
            headerPinLbl.text = "move_pickup".localized()
        }else{ // destination
            headerPinLbl.text = "move_destination".localized()
        }
        
        self.view.layoutIfNeeded()
        DispatchQueue.main.async {
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    self.pinBottomConstraint.constant = 10
                    self.view.layoutIfNeeded()
            } ,
                completion: nil
            )
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idleAt position")
//        mapViewPin.isHidden = false
        if fromType != 3{ //pickup
            headerPinLbl.text = "release_pickip".localized()
        }else{ // destination
            headerPinLbl.text = "release_destination".localized()
        }
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.pinBottomConstraint.constant = -4
            self.view.layoutIfNeeded()
        }
    }
    
    func mapViewDidFinishTileRendering(_ mapView: GMSMapView) {
        print("mapViewDidFinishTileRendering")
        self.isFirstOne = false
    }
    
    func initAnimation(){
        boatAnimation = LOTAnimationView(name: "data_pin")
        // Set view to full screen, aspectFill
        boatAnimation!.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        boatAnimation!.contentMode = .scaleAspectFit
        boatAnimation!.frame = self.mapViewPin.frame
        
    }
    
    @objc func beginAnimation() {
        // Add the Animation
        view.addSubview(boatAnimation!)
        self.boatAnimation?.play()
        print("splash: \( Double((self.boatAnimation?.animationDuration)!))")
    }
}

extension SelectFromMapVC: LocationSearchDelegate{
    func addSearchAddress(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.addressNameTF.text = address
        self.addressNameTF.textColor = Colors.hexStringToUIColor(hex: "#366db3")
        self.addressTitleView.isHidden = false
        self.coveredView.isHidden = true
        self.isFromSearch = true
        // reset camera change count to 0
        self.cameraChangesCount = 0
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        if mapView != nil{
            mapView.camera = camera
        }
    }
}



