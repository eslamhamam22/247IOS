//
//  AddAddressVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 12/31/18.
//  Copyright © 2018 Objects. All rights reserved.
//

import UIKit
import GoogleMaps
import Toaster
import MBProgressHUD

class AddAddressVC: UIViewController, GMSMapViewDelegate {

    var destinationMarker :GMSMarker!
//    var mapView : GMSMapView!
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var headerPinView: UIView!
    @IBOutlet weak var headerPinLbl: UILabel!
    @IBOutlet weak var pinBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var addressNameTF: UITextField!
    @IBOutlet weak var addressNameView: UIView!

    @IBOutlet weak var backIcon: UIImageView!
    @IBOutlet weak var deleteNameIcon: UIImageView!
    @IBOutlet weak var currentLocationIcon: UIImageView!
    @IBOutlet weak var addressTitleTF: UITextField!
    @IBOutlet weak var addressTitleView: UIView!
    @IBOutlet weak var addAddressView: UIView!
    @IBOutlet weak var addAddressLbl: UILabel!
    @IBOutlet weak var addressBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var coveredView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var locationManager = LocationManager()
    var isValidAddressName = false
    var addAddressPresenter : AddAddressPresenter!
    var loadingView: MBProgressHUD!
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var countryCode = ""
    var isFromCamera = false
    var isFromSearch = true
    var cameraChangesCount = 0
    var addressesDelegate : AddressesDelegate!
    var isFirstOne = true
    var isFromAnimations = true
    var userDefault = UserDefault()
    var needToClearMap = false

    override func viewDidLoad() {
        super.viewDidLoad()


        addAddressPresenter = AddAddressPresenter(repository: Injection.provideAddressesRepository(), userRepository: Injection.provideUserRepository())
        addAddressPresenter.setView(view: self)
//        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 16.0)
////        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
////        view = mapView
////        mapView.map(withFrame: CGRect.zero, camera: camera)
//        mapView.camera = camera
        
        mapView.delegate = self
        
        // Creates a marker in the center of the map.
//        let marker = GMSMarker()
//        marker.position = CLLocationCoordinate2D(latitude: -33.86, longitude: 151.20)
//        marker.title = "Sydney"
//        marker.snippet = "Australia"
//        marker.map = mapView
        
        if userDefault.getLastKnownLocation().lat != 0.0 && userDefault.getLastKnownLocation().lng != 0.0{
            self.latitude = userDefault.getLastKnownLocation().lat!
            self.longitude = userDefault.getLastKnownLocation().lng!
            getLocation(location: CLLocation(latitude: latitude, longitude: longitude))
            if mapView != nil{
                mapView.isMyLocationEnabled = true
            }
            isFromAnimations = true
        }
        // get user location
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
        
        addressTitleTF.delegate = self
        addressNameTF.delegate = self
        setUI()
        setGestures()
        setLocalization()
        setFonts()
    }
    
    deinit {
        mapView = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
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
     
        setCornerRadius(selectedView: addAddressView)
        setCornerRadius(selectedView: addressTitleView)
        setCornerRadius(selectedView: headerPinView)

        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
            addressTitleTF.textAlignment = .right
            addressNameTF.textAlignment = .right

        }else{
            backIcon.image = UIImage(named: "back_ic")
            addressTitleTF.textAlignment = .left
            addressNameTF.textAlignment = .left
        }
        addressTitleView.isHidden = true
        coveredView.isHidden = false
        deleteNameIcon.isHidden = false
        
       
        setMapStyle()
        Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(self.getAddressName), userInfo: nil, repeats: true)
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setGestures(){
        let addTab = UITapGestureRecognizer(target: self, action: #selector(self.addAddressAction))
        addAddressView.addGestureRecognizer(addTab)
        
        let addLblTab = UITapGestureRecognizer(target: self, action: #selector(self.addAddressAction))
        addAddressLbl.addGestureRecognizer(addLblTab)
        
        let currentLocationTab = UITapGestureRecognizer(target: self, action: #selector(self.setCurrentLocation))
        currentLocationIcon.addGestureRecognizer(currentLocationTab)
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
        let mapTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        mapTap.cancelsTouchesInView = false
        if mapView != nil{
            self.mapView.addGestureRecognizer(mapTap)
        }
        
        let addressTab = UITapGestureRecognizer(target: self, action: #selector(self.addressNamePressed))
        addressNameTF.addGestureRecognizer(addressTab)
        
        let addressViewTab = UITapGestureRecognizer(target: self, action: #selector(self.addressNamePressed))
        addressNameView.addGestureRecognizer(addressViewTab)
        
        let deleteTab = UITapGestureRecognizer(target: self, action: #selector(self.deleteAddressName))
        deleteNameIcon.addGestureRecognizer(deleteTab)
        
        let backTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        backIcon.addGestureRecognizer(backTab)
        
        addressTitleTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            addressBottomConstraint.constant = 20 + keyboardSize.height
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        addressBottomConstraint.constant = 20
    }
    
    func setLocalization(){
        addAddressLbl.text = "addNewAddress".localized()
        addressTitleTF.placeholder = "addressNamePlaceholder".localized()
//        addressNameTF.placeholder = "location".localized()
        addressNameTF.attributedPlaceholder = NSAttributedString(string: "location".localized(),
                                                               attributes: [NSAttributedString.Key.foregroundColor: Colors.hexStringToUIColor(hex: "EC6A73")])
    }
    
    func setFonts(){
        addAddressLbl.font = Utils.customDefaultFont(addAddressLbl.font.pointSize)
        headerPinLbl.font = Utils.customDefaultFont(headerPinLbl.font.pointSize)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    @objc func backPressed(){
        self.view.endEditing(true)
        needToClearMap = true
        dismiss(animated: true, completion: nil)
    }
    
    @objc func setCurrentLocation(){
        NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
        isValidAddressName = true
        isFromSearch = false
        locationManager.determineMyCurrentLocation(isNeedCountryCode: true)
    }
    
    @objc func deleteAddressName(){
//        addressNameTF.text = ""
//        addressTitleView.isHidden = true
//        addressTitleTF.text = ""
//        coveredView.isHidden = false
//        deleteNameIcon.isHidden = true
    }

    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text != ""{
            print("editing")
            coveredView.isHidden = true
        }else{
            print("no edit")
            coveredView.isHidden = false
        }
    }
    
    @objc func addAddressAction(){
        self.view.endEditing(true)
        if coveredView.isHidden{
            addAddressPresenter.addAddress(title: addressTitleTF.text!, address: addressNameTF.text!, latitude: self.latitude, longitude: self.longitude)
        }
    }
    
    @objc func addressNamePressed(){
        print("addressNamePressed")
        performSegue(withIdentifier: "toSearch", sender: self)
    }
    
    @objc func getUserLocation()
    {
        
        if locationManager.locationStatus == "denied"{
            Toast(text: "permissionDenied".localized()).show()
        }else{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "addAddressLocation"), object: nil)
        }
        
        if locationManager.countryCode != "Error" && locationManager.countryCode != ""{
            self.countryCode = locationManager.countryCode
            self.userDefault.setCountryCode(locationManager.countryCode)
        }
        getLocation(location: locationManager.location)
        if mapView != nil{
            mapView.isMyLocationEnabled = true
        }
        isFromAnimations = false
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
       // if not from animations in first opening
        if !isFromAnimations{
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
                                }else{
                                    subThoroughfare = (placeMark?.subThoroughfare)!
                                }
                            }else{
                                subThoroughfare = ""
                            }
                            self.addressNameTF.text = "\(subThoroughfare) \(placeMark!.thoroughfare ?? "") \(placeMark!.subLocality ?? "") \(placeMark!.locality ?? "")"
                            self.addressTitleView.isHidden = false
                            //                        self.deleteNameIcon.isHidden = false
                        }else{
                            self.isValidAddressName = true
                            self.addressTitleView.isHidden = true
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
                //            self.addressTitleView.isHidden = true
            }
        }
       
        
    }
    
    func updateLocationoordinates(coordinates:CLLocationCoordinate2D) {
//        if destinationMarker == nil
//        {
//            destinationMarker = GMSMarker()
//            destinationMarker.position = coordinates
//            let image = UIImage(named:"247_pin_map")
//            destinationMarker.icon = image
//            destinationMarker.map = mapView
////            destinationMarker.appearAnimation = GMSMarkerAnimation.pop
//        }
//        else
//        {
//            CATransaction.begin()
//            CATransaction.setAnimationDuration(0.1)
//            destinationMarker.position =  coordinates
//            CATransaction.commit()
//
////            destinationMarker.map = nil
////            destinationMarker = GMSMarker()
////            destinationMarker.position = coordinates
////            let image = UIImage(named:"247_pin_map")
////            destinationMarker.icon = image
////            destinationMarker.map = mapView
//        }
    }
    
    // Camera change Position this methods will call every time
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        cameraChangesCount += 1
        var destinationLocation = CLLocation()
        destinationLocation = CLLocation(latitude: position.target.latitude,  longitude: position.target.longitude)
        let destinationCoordinate = destinationLocation.coordinate
        self.latitude = position.target.latitude
        self.longitude = position.target.longitude
        updateLocationoordinates(coordinates: destinationCoordinate)
        if !isFromAnimations{
            if !isFromSearch{
                self.isFromCamera = true
                //            self.isValidAddressName = true
            }else{
                if cameraChangesCount > 1{
                    isFromSearch = false
                }
            }
        }
   
//        if isValidAddressName{
//            getAddressName()
//        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print("didTapAt")
        self.view.endEditing(true)
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        print("willMove")
        headerPinLbl.text = "move_address_pin".localized()
        UIView.animate(withDuration: 1) {
            self.pinBottomConstraint.constant = 10
            self.view.layoutIfNeeded()
        }
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        print("idleAt position")
        headerPinLbl.text = "release_address_pin".localized()
        self.view.layoutIfNeeded()
        UIView.animate(withDuration: 0.2) {
            self.pinBottomConstraint.constant = -4
            self.view.layoutIfNeeded()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "toSearch")
        {
            let destinationController = segue.destination as! UINavigationController
            let vc = destinationController.topViewController as! LocationSearchVC
            vc.locationSearchDelegate = self
            vc.countryCode = self.countryCode
        }
    }
}

extension AddAddressVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else {
            return true }
        let newLength = text.count + string.count - range.length
        if(textField == addressTitleTF){
            return newLength <= 30
        }else if textField == addressNameTF{
            return false
        }
        return true
    }
}

extension AddAddressVC: LocationSearchDelegate{
    func addSearchAddress(latitude: Double, longitude: Double, address: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.addressNameTF.text = address
        self.addressTitleView.isHidden = false
        self.isFromSearch = true
        // reset camera change count to 0
        self.cameraChangesCount = 0
        let camera = GMSCameraPosition.camera(withLatitude: latitude, longitude: longitude, zoom: 16.0)
        if mapView != nil{
            mapView.camera = camera
        }
    }
}
extension AddAddressVC : AddAddressView{
    
    func showloading(){
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
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showNoData() {
        Toast.init(text: "no_data".localized()).show()
    }
    
    func showValidationError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func successAdd(){
        addressesDelegate.addAddressSuccessfully()
        needToClearMap = true
        self.dismiss(animated: true, completion: nil)
    }
    
}

