//
//  StoreDetailsVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GoogleMaps
import Toaster
import MBProgressHUD
import Social
import MapKit

class StoreDetailsVC: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backImg: UIBarButtonItem!
    
    @IBOutlet weak var workingHoursView: UIView!

    @IBOutlet weak var workingHoursHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var workingHoursLbl: UILabel!
    @IBOutlet weak var workingHoursArrow: UIImageView!
    @IBOutlet weak var requestLbl: UILabel!
    @IBOutlet weak var requestView: UIView!

    @IBOutlet weak var mapView: GMSMapView!

    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBOutlet weak var distanceLblWidth: NSLayoutConstraint!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressIcon: UIImageView!
    @IBOutlet weak var storeImg: UIImageView!
    @IBOutlet weak var loadingScreenView: UIView!

    @IBOutlet weak var noNetworkView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var currentLocation = CLLocation()
    var countryCode = ""
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var storeDetailsPresenter : StoreDetailsPresenter!
    var loadingView: MBProgressHUD!
    var store = Place()
    var daysArr = [String]()
    var workingHoursArr = [String]()
    let userDefault = UserDefault()
    var placeID = ""
    var userLocation = CLLocationCoordinate2D()
    var storeLocation = CLLocationCoordinate2D()
    var isStoreLoaded = true
    var isFromShare = false
    var needToClearMap = false
    var areaManager = AreaManager()
    var locationManager = LocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.delegate = self
        storeDetailsPresenter = StoreDetailsPresenter(repository: Injection.providePlacesRepository())
        storeDetailsPresenter.setView(view: self)
        if isStoreLoaded{
            self.placeID = store.place_id!
            loadingScreenView.isHidden = true
        }else{
            loadingScreenView.isHidden = true
        }
        
        storeDetailsPresenter.getStoreDetails(id: self.placeID, isStoreLoaded: isStoreLoaded)
        tableView.delegate = self
        tableView.dataSource = self
        
        if isFromShare{
            // get user location to get current location
            locationManager.determineMyCurrentLocation(isNeedCountryCode: false)
        }
        if currentLocation.coordinate.latitude != 0.0 && currentLocation.coordinate.longitude != 0.0{
            let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 16.0)
            if mapView != nil{
                mapView.camera = camera
            }
        }
      
        setFonts()
        setUI()
        setGestures()
        setLocalization()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isFromShare{
            NotificationCenter.default.addObserver(self, selector: #selector(self.getUserLocation), name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if needToClearMap{
            mapView.clear()
            mapView.stopRendering()
            mapView.removeFromSuperview()
            mapView = nil
        }
    }
    
    func setUI(){
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        
        tableViewHeight.constant = 0
        workingHoursHeight.constant = 0
        workingHoursArrow.isHidden = true
        workingHoursLbl.isHidden = true
        
        storeView.layer.cornerRadius = 15
        storeView.layer.masksToBounds = true
        storeView.clipsToBounds = true
        
//        storeImg.layer.cornerRadius = 2
//        storeImg.layer.masksToBounds = true
//        storeImg.clipsToBounds = true
        
        storeView?.layer.borderColor = UIColor.lightGray.cgColor
        storeView?.layer.borderWidth = 0
        storeView?.layer.masksToBounds = false
        storeView?.layer.shadowOffset = CGSize(width: 2, height: 2)
        storeView?.layer.shadowRadius = 3
        storeView?.layer.shadowOpacity = 0.1
        
        workingHoursLbl.text = "workingHours".localized()
        requestLbl.text = "requestFromStore".localized()
        noNetworkView.isHidden = true

        setStoreData()
        if isStoreLoaded{
            setStoreImageUrl()
        }
        setMapStyle()
    }
    
    func setGestures(){
        
        let workingHourstap = UITapGestureRecognizer(target: self, action: #selector(workingHoursPressed))
        workingHoursView.addGestureRecognizer(workingHourstap)
        
        let requestTap = UITapGestureRecognizer(target: self, action: #selector(requestFromStore))
        requestView.addGestureRecognizer(requestTap)
        
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadAction))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
    }
    
    func setLocalization(){
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
    }
    
    func setFonts(){
        
        storeNameLbl.font = Utils.customDefaultFont(storeNameLbl.font.pointSize)
        distanceLbl.font = Utils.customDefaultFont(distanceLbl.font.pointSize)
        addressLbl.font = Utils.customDefaultFont(addressLbl.font.pointSize)
        statusLbl.font = Utils.customDefaultFont(statusLbl.font.pointSize)
        workingHoursLbl.font = Utils.customBoldFont(workingHoursLbl.font.pointSize)
        requestLbl.font = Utils.customBoldFont(requestLbl.font.pointSize)
        
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
    }
    
    @objc func getUserLocation(){
        
        if locationManager.locationStatus != "denied"{
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "gotCurrentLocation"), object: nil)
            currentLocation = locationManager.location
            if store.id != nil{
                let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 16.0)
                if mapView != nil{
                    mapView.camera = camera
                }
                setStoreData()
            }
        }
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
    
    func setStoreData(){
        if store.name != nil{
            storeNameLbl.text = "\u{200E}\(store.name!)"
            self.navigationItem.title = "\u{200E}\(store.name!)"
        }else{
            storeNameLbl.text = ""
        }
        
        if store.geometry != nil {
            if store.geometry?.location != nil{
                let location1 = CLLocation(latitude:self.currentLocation.coordinate.latitude , longitude: self.currentLocation.coordinate.longitude)
                let location2 = CLLocation(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!)
                
                // calculate distance
                let distanceInMeters = location1.distance(from: location2)
                print("distanceInMeters: \(distanceInMeters)")
                if Int(distanceInMeters) > 1000{
                    distanceLbl.text = "\(Int(distanceInMeters/1000)) \("Km".localized())"
                }else{
                    distanceLbl.text = "\(Int(distanceInMeters)) \("M".localized())"
                }
                
                if currentLocation.coordinate.latitude != 0.0 && currentLocation.coordinate.longitude != 0.0{
                    let camera = GMSCameraPosition.camera(withLatitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, zoom: 16.0)
                    if mapView != nil{
                        mapView.camera = camera
                    }
                }
                
                // set map
                if appDelegate.isRTL{
                    setMarkerOnMap(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, imageName: "btn_blue_ar")
                }else{
                    setMarkerOnMap(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, imageName: "btn_blue_en")
                }
                if appDelegate.isRTL{
                    setMarkerOnMap(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!, imageName: "btn_red_ar")
                }else{
                    setMarkerOnMap(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!, imageName: "btn_red_en")
                }
                
                let currentLat = CLLocationDegrees(exactly: currentLocation.coordinate.latitude)
                let currentLng = CLLocationDegrees(exactly: currentLocation.coordinate.longitude)
                 userLocation = CLLocationCoordinate2D(latitude: currentLat!, longitude: currentLng!)
                 storeLocation = CLLocationCoordinate2D(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!)
                
                Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.showAllMarkers), userInfo: nil, repeats: false)

            }else{
                distanceLbl.text = ""
            }
        }else{
            distanceLbl.text = ""
        }
//        loadStoreImage()
        
//        if store.icon != ""{
//            let url = URL(string: (store.icon!))
//            print("url \(String(describing: url))")
//            //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
//
//            if (store.icon?.contains("maps"))!{
//                storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale")) { (result) in
//                    switch result {
//                    case .success:
//                        self.storeImg.contentMode = .scaleToFill
//                    case .failure:
//                        self.storeImg.contentMode = .scaleAspectFit
//                    }
//                }
//            }else{
//                self.storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
//            }
//        }else{
//            self.storeImg.image = UIImage(named: "grayscale")
//        }
        
        if store.vicinity != nil{
            addressLbl.text = "\u{200E}\(store.vicinity!)"
            addressIcon.isHidden = false
        }else{
            addressLbl.text = ""
            addressIcon.isHidden = true
        }
        
        if store.opening_hours != nil{
            if store.opening_hours?.open_now != nil{
                if (store.opening_hours?.open_now)!{
                    statusLbl.text = "openNow".localized()
                    statusLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
                }else{
                    statusLbl.text = "closed".localized()
                    statusLbl.textColor = Colors.hexStringToUIColor(hex: "#e84450")
                }
            }else{
                statusLbl.text = ""
            }
        }else{
            statusLbl.text = ""
        }
        
        distanceLblWidth.constant = distanceLbl.intrinsicContentSize.width
    }
    
    func setStoreImageUrl(){
        let imageUrlStr = APIURLs.MAIN_URL + APIURLs.STORES_IMAGES + placeID
        //        if index%2 == 0 {
        //            imageUrlStr = "http://247dev.objectsdev.com/images/stores/branches/ChIJUUlF7-HmST4R1YOtNp_AGEk"
        //        }
        let imageUrl = URL(string: (imageUrlStr))
        print("url \(String(describing: imageUrl))")
        storeImg.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "grayscale"),
            options: nil)
        {
            result in
            switch result {
            case .success:
                print("Task done for:")
                break
            case .failure (let error):
                print("Job failed: \(error.localizedDescription)")
                if self.store.icon != ""{
                    let url = URL(string: (self.store.icon!))
                    print("url \(String(describing: url))")
                    if (self.store.icon?.contains("maps"))!{
                        self.storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale")) { (result) in
                            switch result {
                            case .success:
                                self.storeImg.contentMode = .scaleToFill
                            case .failure:
                                self.storeImg.contentMode = .scaleAspectFit
                            }
                        }
                    }else{
                        self.storeImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
                    }
                }else{
                    self.storeImg.image = UIImage(named: "grayscale")
                }
            }
        }
    }
    
    func setWorkingHours(){
        print("setWorkingHours")
        daysArr.removeAll()
        workingHoursArr.removeAll()
        
        for string in (store.opening_hours?.weekday_text)! {
            if let range = string.range(of: ": ") {
                let firstPart = string[string.startIndex..<range.lowerBound]
                let lastPart = string[range.upperBound..<string.endIndex]
                daysArr.append(String(firstPart))
                workingHoursArr.append(String(lastPart))
                print(firstPart)
                print(lastPart)
            }
        }
        tableView.reloadData()
    }
    
    func setStoreImage(){
        
//        if store.photos != nil{
//            if (store.photos?.count)! > 0{
//                if store.photos![0].photo_reference != nil{
//                    store.icon = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+store.photos![0].photo_reference!+"&key="+AppKeys.WEB_API_KEY
//                    return
//                }
//            }
//        }
        
        if userDefault.getCategories() != nil {
            if (userDefault.getCategories()?.count)! > 0{
                if store.types != nil{
                    if (store.types?.count)! > 0{
                        for category in userDefault.getCategories()!{
                            if store.types![0] == category.related_categories{
                                store.icon = category.image?.medium
                                break
                            }
                        }
                    }
                }
            }
           
        }
       
    }
    
    func loadStoreImage(){
        if store.photos != nil{
            if (store.photos?.count)! > 0{
                if store.photos![0].photo_reference != nil{
                    store.icon = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference="+store.photos![0].photo_reference!+"&key="+AppKeys.WEB_API_KEY
                }
            }
        }
        
    }
    
    func setMarkerOnMap(latitude: Double, longitude: Double, imageName: String){
        let marker = GMSMarker()
        let lat = CLLocationDegrees(exactly: latitude)
        let lng = CLLocationDegrees(exactly: longitude)
        marker.position = CLLocationCoordinate2D(latitude: lat!, longitude: lng!)
        let image = UIImage(named: imageName)
        marker.icon = image
        if mapView != nil{
            marker.map = mapView
        }
    }
    
//    func showAllMarkers(userLocation: CLLocationCoordinate2D, storeLocation: CLLocationCoordinate2D) {
    @objc func showAllMarkers() {
       
        
        if userLocation.latitude != 0.0 && userLocation.longitude != 0.0{ // no user location
            CATransaction.begin()
            CATransaction.setValue(1.0, forKey: kCATransactionAnimationDuration)
            let bounds = GMSCoordinateBounds(coordinate: userLocation, coordinate: storeLocation)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 130.0)
            if mapView != nil{
                mapView.animate(with: update)
                mapView.isMyLocationEnabled = true
            }
            CATransaction.commit()
//            mapView.settings.myLocationButton = true
        }else{
            let camera = GMSCameraPosition.camera(withLatitude: storeLocation.latitude, longitude: storeLocation.longitude, zoom: 16.0)
            if mapView != nil{
                mapView.camera = camera
            }
        }
       
//        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 150.0))
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.icon == UIImage(named: "destination_pin_map"){
            print("destination_pin_map")
            redirectToMaps(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, isCurrent: true)
        }else{
            print("pickup_pin_map")
            redirectToMaps(latitude: (store.geometry?.location?.lat)!, longitude: (store.geometry?.location?.lng)!, isCurrent: false)
        }
        return true
    }
    
   
    
    @objc func requestFromStore(){
        
        if userDefault.getToken() != nil{
            if !areaManager.isSelectedPointInBlockedArea(latitude: (self.storeLocation.latitude), longitude: (self.storeLocation.longitude)){
                performSegue(withIdentifier: "toRequest", sender: self)
            }else{
                Toast.init(text: "blockedAreaToast".localized()).show()
            }
        }else{
            userDefault.removeSession()
        }
        
//        if userDefault.getToken() != nil{
//            performSegue(withIdentifier: "toRequest", sender: self)
//        }else{
//            userDefault.removeSession()
//        }
    }
    
    func redirectToMaps(latitude: Double, longitude: Double, isCurrent: Bool){
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
            //            UIApplication.shared.open(URL(string:"comgooglemaps://?center=40.765819,-73.975866&zoom=14&views=traffic")!, options: [:], completionHandler: nil)
            print("open action sheet")
            openMapsSheet(latitude: latitude, longitude: longitude, isCurrent: isCurrent)
        } else {
            openAppleMapForPlace(latitude: latitude, longitude: longitude, isCurrent: isCurrent)
        }
    }
    func openAppleMapForPlace(latitude: Double, longitude: Double, isCurrent: Bool) {
        
        let regionDistance:CLLocationDistance = 100
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        if isCurrent{
            mapItem.name = "Current Location"
        }else{
            mapItem.name = store.name
        }
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openMapsSheet(latitude: Double, longitude: Double, isCurrent: Bool){
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
            self.openAppleMapForPlace(latitude: latitude, longitude: longitude, isCurrent: isCurrent)
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
    
    @objc func reloadAction(){
        storeDetailsPresenter.getStoreDetails(id: self.placeID, isStoreLoaded: isStoreLoaded)
    }
    
    @objc func workingHoursPressed(){
        if tableViewHeight.constant == 280{
            workingHoursArrow.image = UIImage(named: "anchor_upward")
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewHeight.constant = 0
                self.workingHoursHeight.constant = 50
                self.view.layoutIfNeeded()
            }, completion: nil)
        }else{
            self.view.layoutIfNeeded()
            workingHoursArrow.image = UIImage(named: "anchor_downward")
            UIView.animate(withDuration: 0.5, animations: {
                self.tableViewHeight.constant = CGFloat(7*40)
                self.workingHoursHeight.constant = CGFloat(7*40) + 50
                self.view.layoutIfNeeded()
            }, completion: nil)
        
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        needToClearMap = true
        if isFromShare{
            performSegue(withIdentifier: "toHome", sender: self)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func shareStore(_ sender: Any) {
//        let myURL = "TwentyFour7://\(placeID)"
        let myURL = "https://247dev.app.link/bKw3Z6YxIV?id=\(placeID)"
        print(myURL)
        let text = "".localized()
        let myWebsite = NSURL(string:myURL)!
        let actionSheet = UIAlertController(title: "", message: "".localized(), preferredStyle: UIAlertController.Style.actionSheet)
        let activityViewController = UIActivityViewController(activityItems: [text , myWebsite], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        let excludeActivities = [
            UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.airDrop]
        activityViewController.excludedActivityTypes = excludeActivities;
        let dismissAction = UIAlertAction(title: "close", style: UIAlertAction.Style.cancel) { (action) -> Void in
        }
        actionSheet.addAction(dismissAction)
        present(actionSheet, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRequest"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! RequestFromStoreVC
            self.store.place_id = placeID
            vc.fromStoreData = self.store
            vc.latitude = self.currentLocation.coordinate.latitude
            vc.longitude = self.currentLocation.coordinate.longitude
            vc.countryCode = self.countryCode
        }else if segue.identifier == "toHome"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 2
        }
    }
}

extension StoreDetailsVC : UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return daysArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let dayLbl = cell.contentView.viewWithTag(1) as? UILabel
        let hoursLbl = cell.contentView.viewWithTag(2) as? UILabel
        dayLbl!.font = Utils.customDefaultFont(dayLbl!.font.pointSize)
        hoursLbl!.font = Utils.customDefaultFont(hoursLbl!.font.pointSize)

        if daysArr.count > indexPath.row{
            dayLbl?.text = daysArr[indexPath.row]
        }else{
            dayLbl?.text = ""
        }
        
        if workingHoursArr.count > indexPath.row{
            hoursLbl?.text = workingHoursArr[indexPath.row]
        }else{
            hoursLbl?.text = ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
extension StoreDetailsVC: StoreDetailsView{
    
    func showloading() {
        loadingScreenView.isHidden = false
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
//        noNetworkView.isHidden = false
        self.noNetworkView.isHidden = false
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func setStoreData(store: Place) {

        if !isStoreLoaded{
            self.store = store
            self.store.icon = ""
            if userDefault.getDefaultCategory() != nil{
                if userDefault.getDefaultCategory()?.image != nil{
                    if userDefault.getDefaultCategory()?.image?.medium != nil{
                        self.store.icon = userDefault.getDefaultCategory()?.image?.medium
                    }
                }
            }
            setStoreImage()
            setStoreData()
            setStoreImageUrl()
        }
        if store.opening_hours != nil{
            if store.opening_hours?.weekday_text != nil{
                self.store.opening_hours?.weekday_text = store.opening_hours?.weekday_text
                tableViewHeight.constant = 0
                workingHoursHeight.constant = 50
                workingHoursArrow.isHidden = false
                workingHoursLbl.isHidden = false
                setWorkingHours()
            }else{
                tableViewHeight.constant = 0
                workingHoursHeight.constant = 0
                workingHoursArrow.isHidden = true
                workingHoursLbl.isHidden = true
            }
        }else{
            tableViewHeight.constant = 0
            workingHoursHeight.constant = 0
            workingHoursArrow.isHidden = true
            workingHoursLbl.isHidden = true
        }
        
        loadingScreenView.isHidden = true
        noNetworkView.isHidden = true
    }
}
