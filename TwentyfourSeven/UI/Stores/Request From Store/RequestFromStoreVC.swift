//
//  RequestFromStoreVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/22/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import Kingfisher
import AVFoundation
import SummerSlider
import DataCompression
import DropDown

class RequestFromStoreVC: UIViewController, Dimmable{

    @IBOutlet weak var backImg: UIBarButtonItem!

    @IBOutlet weak var storeView: UIView!
    @IBOutlet weak var fromStoreImg: UIImageView!
    @IBOutlet weak var fromStoreTitleLbl: UILabel!
    @IBOutlet weak var fromStoreNameLbl: UILabel!
    @IBOutlet weak var fromStoreStatusLbl: UILabel!
    @IBOutlet weak var fromStoreNameDescLbl: UILabel!
    @IBOutlet weak var fromStoreImgWidth: NSLayoutConstraint!
    @IBOutlet weak var fromStoreImgHeight: NSLayoutConstraint!
    @IBOutlet weak var fromStoreImgTrailing: NSLayoutConstraint!
    @IBOutlet weak var fromStoreView: UIView!
    @IBOutlet weak var fromStoreCloseImg: UIImageView!

    @IBOutlet weak var lineImg: UIImageView!

    @IBOutlet weak var toStoreTitleLbl: UILabel!
    @IBOutlet weak var toStoreNameLbl: UILabel!
    @IBOutlet weak var toStoreNameDescLbl: UILabel!
    @IBOutlet weak var toStoreCloseImg: UIImageView!
    @IBOutlet weak var toStoreView: UIView!

    @IBOutlet weak var descTitleLbl: UILabel!
    @IBOutlet weak var descView: UIView!
    @IBOutlet weak var descTV: UITextView!
    @IBOutlet weak var descTVHeight: NSLayoutConstraint!

    @IBOutlet weak var deliveryDurationTitleLbl: UILabel!
    @IBOutlet weak var deliveryDurationView: UIView!
    @IBOutlet weak var deliveryDurationLbl: UILabel!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!

    @IBOutlet weak var uploadImgTitleLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var uploadImgMaxTitleLbl: UILabel!

    //coupon
    @IBOutlet weak var addCouponTitleLbl: UILabel!
    @IBOutlet weak var addCouponLbl: UILabel!
    @IBOutlet weak var addCouponView: UIView!
    @IBOutlet weak var couponLbl: UILabel!
    @IBOutlet weak var couponView: UIView!
    
    @IBOutlet weak var submitRequestLbl: UILabel!
    @IBOutlet weak var submitRequestView: UIView!
    @IBOutlet weak var submitRequestBottom: NSLayoutConstraint!
    @IBOutlet weak var coveredView: UIView!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var prayerNote: UILabel!
    
    //record table cells
    var defaultRecordIcon : UIImageView!
    var defaultRecordLbl : UILabel!
    var recordTimerLbl : UILabel!
    var recordSaveLbl : UILabel!
    var recordCancelLbl : UILabel!
    var recordBgView : UIView!

    var audioManager = AudioManager()
    
//    var audioPlayer: AVAudioPlayer?
//    var audioRecorder: AVAudioRecorder?
    //0..for default   1..for recording
    var recordType = 0
    //0..for not record   1..for pending upload  2..for uploaded successfully  3..for uploaded failed  4..delete pending  5..delete successfully
    var recordUploadedType = 0
    var prodSeconds = String() // This value is set in a different view controller
    var intProdSeconds = 0.0
    var timer = Timer()
    var recordTime = ""
    var audioRecorderData = AudioRecorderData()
    var isSubmitAndUpload = false
    var audioData = Data()
    
    //images
    var images = [DelegateImageData]()
    var photosManager = PhotosManager()
    var imageFile: UIImage!
    var mimeType = ""
    var canAddImages = true
    
    var requestFromStorePresenter : RequestFromStorePresenter!
    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var textFrame = CGRect(x: 5, y: 5, width: 300, height: 55)
    var lastTextHeight : CGFloat = 55
    //from data
    var fromStoreData = Place()
    var isFromRequestLocation = false
    var fromLat = 0.0
    var fromLng = 0.0
    var fromLocationDesc = ""
    var fromLocationTitle = ""
    //to data
    var toLat = 0.0
    var toLng = 0.0
    var countryCode = ""
    var latitude = 0.0
    var longitude = 0.0
    
    //delivery duration
    let durationsDropDwon = DropDown()
    var durations = [String]()
    var prayerTimes = PrayerTimes()
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    var isdestinationPressed = false
    var couponCode = ""
    var orderID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        requestFromStorePresenter = RequestFromStorePresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository(), infoRepository: Injection.provideInfoRepository())
        requestFromStorePresenter.setView(view: self)
        //get prayer times
        requestFromStorePresenter.getPrayerTimes()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        setUI()
        setLocalization()
        setFonts()
        setGestures()
        if isFromRequestLocation{
            setFromLocationData()
        }else{
            setFromStoreData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        audioManager.stopRecorderAndPlayer()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        
        if appDelegate.isRTL{
            backImg.image = UIImage(named: "back_ar_ic")
        }else{
            backImg.image = UIImage(named: "back_ic")
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        if isFromRequestLocation{
            self.navigationItem.title = "request_from_location".localized()
        }else{
            self.navigationItem.title = "request_store_title".localized()
        }

        self.toStoreNameLbl.textColor = Colors.hexStringToUIColor(hex: "bcc5d3")
        descTV.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")

        durations.append("hr1".localized())
        durations.append("hr2".localized())
        durations.append("hr3".localized())
        deliveryDurationLbl.text = self.durations[0]

        setCornerRadius(selectedView: storeView)
        setCornerRadius(selectedView: descView)
        setCornerRadius(selectedView: deliveryDurationView)
//        setCornerRadius(selectedView: fromStoreImg)
        setCornerRadius(selectedView: coveredView)
        setCornerRadius(selectedView: couponView)

        if(appDelegate.isRTL){
            self.descTV.textAlignment = .right
        }else{
            self.descTV.textAlignment = .left
        }
        
        descTV.delegate = self
        coveredView.isHidden = false
        toStoreCloseImg.isHidden = true
        if !isFromRequestLocation{
            fromStoreCloseImg.isHidden = true
        }
        
        // hide tableview and collectionview for now
//        tableViewHeight.constant = 70
        tableViewHeight.constant = 0
        collectionViewHeight.constant = 80
        
        couponView.isHidden = true
    }
    
    func setLocalization(){
        descTitleLbl.text = "what_do_you_need".localized()
        submitRequestLbl.text = "submitRequest".localized()
        toStoreNameLbl.text = "destination".localized()
        descTV.text = "order_description_placeholder".localized()
        fromStoreTitleLbl.text = "fromStore".localized()
        toStoreTitleLbl.text = "toStore".localized()
        toStoreTitleLbl.text = ""
        toStoreNameDescLbl.text = ""
        fromStoreTitleLbl.text = ""
        uploadImgTitleLbl.text = "upload_image".localized()
        uploadImgMaxTitleLbl.text = "max_images".localized()
        prayerNote.text = ""
        addCouponTitleLbl.text = "add_coupon_title".localized()
        addCouponLbl.text = "add_coupon".localized()
        deliveryDurationTitleLbl.text = "delivery_duration".localized()
    }
    
    func setCornerRadius(selectedView : UIView){
        selectedView.layer.cornerRadius = 12
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setFonts(){
        
        fromStoreTitleLbl.font = Utils.customDefaultFont(fromStoreTitleLbl.font.pointSize)
        fromStoreNameLbl.font = Utils.customDefaultFont(fromStoreNameLbl.font.pointSize)
        fromStoreStatusLbl.font = Utils.customDefaultFont(fromStoreStatusLbl.font.pointSize)
        fromStoreNameDescLbl.font = Utils.customDefaultFont(fromStoreNameDescLbl.font.pointSize)
        toStoreTitleLbl.font = Utils.customDefaultFont(toStoreTitleLbl.font.pointSize)
        toStoreNameLbl.font = Utils.customDefaultFont(toStoreNameLbl.font.pointSize)
        toStoreNameDescLbl.font = Utils.customDefaultFont(toStoreNameDescLbl.font.pointSize)

        descTitleLbl.font = Utils.customBoldFont(descTitleLbl.font.pointSize)
        descTV.font = Utils.customDefaultFont(descTV.font!.pointSize)

        deliveryDurationTitleLbl.font = Utils.customBoldFont(deliveryDurationTitleLbl.font.pointSize)
        deliveryDurationLbl.font = Utils.customDefaultFont(deliveryDurationLbl.font.pointSize)

        uploadImgTitleLbl.font = Utils.customBoldFont(uploadImgTitleLbl.font.pointSize)
        uploadImgMaxTitleLbl.font = Utils.customDefaultFont(uploadImgMaxTitleLbl.font.pointSize)

        addCouponTitleLbl.font = Utils.customBoldFont(addCouponTitleLbl.font.pointSize)
        addCouponLbl.font = Utils.customDefaultFont(addCouponLbl.font.pointSize)
        couponLbl.font = Utils.customDefaultFont(couponLbl.font.pointSize)

        submitRequestLbl.font = Utils.customDefaultFont(submitRequestLbl.font.pointSize)
        prayerNote.font = Utils.customDefaultFont(prayerNote.font.pointSize)
    }
    
    func setGestures(){
        
        let keyboardTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        keyboardTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(keyboardTap)
        
        let destinationTap = UITapGestureRecognizer(target: self, action: #selector(destinationPressed))
        toStoreNameLbl.addGestureRecognizer(destinationTap)
        
        let destinationViewTap = UITapGestureRecognizer(target: self, action: #selector(destinationPressed))
        toStoreView.addGestureRecognizer(destinationViewTap)
        
        let destinationDescTap = UITapGestureRecognizer(target: self, action: #selector(destinationPressed))
        toStoreNameDescLbl.addGestureRecognizer(destinationDescTap)
        
        let destinationTitleTap = UITapGestureRecognizer(target: self, action: #selector(destinationPressed))
        toStoreTitleLbl.addGestureRecognizer(destinationTitleTap)
        
        let deleteDestinationTap = UITapGestureRecognizer(target: self, action: #selector(deleteDestinationAction))
        toStoreCloseImg.addGestureRecognizer(deleteDestinationTap)
        
        let deletePickupTap = UITapGestureRecognizer(target: self, action: #selector(deletePickupAction))
        fromStoreCloseImg.addGestureRecognizer(deletePickupTap)
        
        let submitTap = UITapGestureRecognizer(target: self, action: #selector(submitAction))
        submitRequestView.addGestureRecognizer(submitTap)
        
        let submitLblTap = UITapGestureRecognizer(target: self, action: #selector(submitAction))
        submitRequestLbl.addGestureRecognizer(submitLblTap)
        
        if isFromRequestLocation{
            let pickupViewTap = UITapGestureRecognizer(target: self, action: #selector(pickupPressed))
            fromStoreView.addGestureRecognizer(pickupViewTap)
            
            let pickupDescTap = UITapGestureRecognizer(target: self, action: #selector(pickupPressed))
            fromStoreNameDescLbl.addGestureRecognizer(pickupDescTap)
            
            let pickupTitleTap = UITapGestureRecognizer(target: self, action: #selector(pickupPressed))
            fromStoreNameLbl.addGestureRecognizer(pickupTitleTap)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setFromLocationData(){
        if fromLocationTitle != ""{
            fromStoreNameLbl.text = "\u{200E}\(fromLocationTitle)"
            fromStoreNameDescLbl.text = "\u{200E}\(fromLocationDesc)"
        }else{
            fromStoreNameLbl.text = "\u{200E}\(fromLocationDesc)"
            fromStoreNameDescLbl.text = ""
        }
        fromStoreNameLbl.numberOfLines = 2
        fromStoreStatusLbl.text = ""
        fromStoreImg.isHidden = true
        fromStoreImgWidth.constant = 0
        fromStoreImgHeight.constant = 0
        fromStoreImgTrailing.constant = 0
        lineImg.image = UIImage(named: "line_small")
    }
    
    func setFromStoreData(){
        
        if fromStoreData.name != nil{
            fromStoreNameLbl.text = "\u{200E}\(fromStoreData.name!)"
        }else{
            fromStoreNameLbl.text = ""
        }
        
//        if fromStoreData.icon != ""{
//            let url = URL(string: (fromStoreData.icon!))
//            print("url \(String(describing: url))")
//            //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
//            self.fromStoreImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
//        }else{
//            self.fromStoreImg.image = UIImage(named: "grayscale")
//        }
        setStoreImageUrl()
        
        if fromStoreData.vicinity != nil{
            fromStoreNameDescLbl.text = fromStoreData.vicinity
        }else{
            fromStoreNameDescLbl.text = ""
        }
        
        if fromStoreData.opening_hours != nil{
            if fromStoreData.opening_hours?.open_now != nil{
                if (fromStoreData.opening_hours?.open_now)!{
                    fromStoreStatusLbl.text = "openNow".localized()
                    fromStoreStatusLbl.textColor = Colors.hexStringToUIColor(hex: "#4ebf26")
                }else{
                    fromStoreStatusLbl.text = "closed".localized()
                    fromStoreStatusLbl.textColor = Colors.hexStringToUIColor(hex: "#e84450")
                }
            }else{
                fromStoreStatusLbl.text = ""
            }
        }else{
            fromStoreStatusLbl.text = ""
        }
        fromStoreStatusLbl.text = ""
    }
    
    func setStoreImageUrl(){
        let imageUrlStr = APIURLs.MAIN_URL + APIURLs.STORES_IMAGES + fromStoreData.place_id!
        let imageUrl = URL(string: (imageUrlStr))
        print("url \(String(describing: imageUrl))")
        fromStoreImg.kf.setImage(
            with: imageUrl,
            placeholder: UIImage(named: "grayscale"),
            options: nil)
        {
            result in
            switch result {
            case .success:
                print("Task done for:")
            case .failure:
                print("Job failed:")
                if self.fromStoreData.icon != ""{
                    let url = URL(string: (self.fromStoreData.icon!))
                    print("url \(String(describing: url))")
                    //                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"), options: [.forceRefresh])
                    self.fromStoreImg.kf.setImage(with: url, placeholder: UIImage(named: "grayscale"))
                }else{
                    self.fromStoreImg.image = UIImage(named: "grayscale")
                }
            }
        }
    }
    
    func setDropDown() {
        durationsDropDwon.direction = .bottom
        
        if appDelegate.isRTL {
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            durationsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .right
                cell.optionLabel.font = Utils.customDefaultFont(14)
            }
        }else{
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            durationsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .left
                cell.optionLabel.font = Utils.customDefaultFont(14)
            }
        }
        
        durationsDropDwon.selectionAction = { [unowned self] (index: Int, item: String) in
            self.deliveryDurationLbl.text = self.durations[index]
        }
        
    }
    
    @objc func deleteDestinationAction(){
        self.toStoreNameLbl.text = "destination".localized()
        self.toStoreNameLbl.textColor = Colors.hexStringToUIColor(hex: "bcc5d3")
        self.toStoreNameDescLbl.text = ""
        self.toStoreCloseImg.isHidden = true
        self.coveredView.isHidden = false
    }
    
    @objc func deletePickupAction(){
        self.fromStoreNameLbl.text = "pickUp_point".localized()
        self.fromStoreNameLbl.textColor = Colors.hexStringToUIColor(hex: "bcc5d3")
        self.fromStoreNameDescLbl.text = ""
        self.fromStoreCloseImg.isHidden = true
        self.coveredView.isHidden = false
    }
    
    @objc func hideKeyboard(){
        print("hideKeyboard")
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            submitRequestBottom.constant = 45 + keyboardSize.height
//            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height)
//            scrollView.setContentOffset(bottomOffset, animated: true)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        submitRequestBottom.constant = 45
    }
    
    @objc func pickupPressed(){
        print("pickupPressed")
        self.view.endEditing(true)
        self.isdestinationPressed = false
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    @objc func destinationPressed(){
        print("destinationPressed")
        self.view.endEditing(true)
        self.isdestinationPressed = true
        performSegue(withIdentifier: "toMap", sender: self)
    }
    
    @IBAction func showDeliveryDurations(_ sender: Any) {
        self.view.endEditing(true)
        durationsDropDwon.anchorView = deliveryDurationView
        durationsDropDwon.bottomOffset = CGPoint(x: 0, y:(durationsDropDwon.anchorView?.plainView.bounds.height)!)
        durationsDropDwon.dataSource = durations
        setDropDown()
        durationsDropDwon.show()
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        if isFromRequestLocation{
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func unwindFromAddCoupon(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: 0)
    }
    
    @IBAction func addCouponAction(_ sender: Any) {
        performSegue(withIdentifier: "toAddCoupon", sender: self)
    }
    
    @objc func submitAction(){
        self.view.endEditing(true)
        if coveredView.isHidden{ // no destination entered or description
            self.isSubmitAndUpload = false
            
            var fromType = 0
            if isFromRequestLocation{
                fromType = 0
            }else{
                fromType = 1
            }
            var descStr = ""
            if descTV.text != "order_description_placeholder"{
                descStr = descTV.text
            }
            var fromLat = 0.0
            var fromLng = 0.0
            if isFromRequestLocation{
                fromLat = self.fromLat
                fromLng = self.fromLng
            }else{
                if fromStoreData.geometry != nil {
                    if fromStoreData.geometry?.location != nil{
                        fromLat = (fromStoreData.geometry?.location?.lat)!
                        fromLng = (fromStoreData.geometry?.location?.lng)!
                    }
                }
            }
            
            var fromAddress = ""
            if isFromRequestLocation{
                if fromStoreNameDescLbl.text != ""{
                    fromAddress = fromStoreNameDescLbl.text!
                }else{
                    fromAddress = fromStoreNameLbl.text!
                }
            }else{
                if fromStoreData.vicinity != nil{
                    fromAddress = fromStoreData.vicinity!
                }
            }
            
            var storeName = ""
            if fromStoreData.name != nil{
                storeName = fromStoreData.name!
            }
            
            var toAddress = ""
            if toStoreNameDescLbl.text != ""{
                toAddress = toStoreNameDescLbl.text!
            }else{
                toAddress = toStoreNameLbl.text!
            }
            
            var recordId = 0
            if recordType == 2{ // have record
                if recordUploadedType == 2{  // 2..for uploaded successfully
                    if audioRecorderData.id != nil{
                        recordId = audioRecorderData.id!
                    }
                }else if recordUploadedType == 1{ // 1..for pending upload
                    print("waiting for upload")
                }else if recordUploadedType == 3{ // 3..for uploaded failed
                    print("faild for upload")
                    self.isSubmitAndUpload = true
                }
            }
            
            var deliveryDuration = 0
            if deliveryDurationLbl.text == "hr1".localized(){
                deliveryDuration = 1
            }else if deliveryDurationLbl.text == "hr2".localized(){
                deliveryDuration = 2
            }else if deliveryDurationLbl.text == "hr3".localized(){
                deliveryDuration = 3
            }
            
            if isSubmitAndUpload{
                requestFromStorePresenter.uploadRecord(recordData: audioData, isSubmitAndUpload: self.isSubmitAndUpload)
            }else{
                requestFromStorePresenter.requestOrder(desc: descStr, fromType: fromType, fromLat: fromLat, fromLng: fromLng, toLat: self.toLat, toLng: self.toLng, fromAddress: fromAddress, toAddress: toAddress, storeName: storeName, images: getImagesId(), voicenoteId: recordId, deliveryDuration: deliveryDuration, couponCode: self.couponCode)
            }
        }
    }
    
    func checkValidation(){
        if toStoreNameLbl.text != "destination".localized() && fromStoreNameLbl.text != "pickUp_point".localized() && descTV.text != "" && descTV.text != "order_description_placeholder".localized() && recordUploadedType != 1{
            coveredView.isHidden = true
        }else{
            coveredView.isHidden = false
        }
    }
    
    func getImagesId() -> String{
        var imagesIds = ""
        var imagesCount = 0
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
    
    func resultOfCapturingImages(result : String , imageFile : UIImage, mimeType : String){
        if result == "imageTypeError"{
            Toast.init(text: "imageTypeError".localized()).show()
        }else if result == "imageSizeError"{
            Toast.init(text: "imageSizeError".localized()).show()
        }else if result == "noError"{
            self.imageFile = imageFile
            self.mimeType = mimeType
            requestFromStorePresenter.uploadImage(imageFile: imageFile)
        }
    }
    
    func findTimeDifference(time: String) -> Int {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let timeDate = dateFormatter.date(from: time)
        if timeDate != nil{
            let calendar = Calendar.current
            let timeComponents = calendar.dateComponents([.hour, .minute], from: timeDate!)
            let nowComponents = calendar.dateComponents([.hour, .minute], from: Date())
            
            let difference = calendar.dateComponents([.minute], from: timeComponents, to: nowComponents).minute!
            print("difference: \(difference)")
            return difference
        }
        return 0
    }
    
    func isDuringPrayerTimes() -> Bool{
        if prayerTimes.Fajr != nil{
            if abs(findTimeDifference(time: prayerTimes.Fajr!)) <= 30{
                return true
            }
        }
        
        if prayerTimes.Dhuhr != nil{
            if abs(findTimeDifference(time: prayerTimes.Dhuhr!)) <= 30{
                return true
            }
        }
        
        if prayerTimes.Asr != nil{
            if abs(findTimeDifference(time: prayerTimes.Asr!)) <= 30{
                return true
            }
        }
        
        if prayerTimes.Maghrib != nil{
            if abs(findTimeDifference(time: prayerTimes.Maghrib!)) <= 30{
                return true
            }
        }
        
        if prayerTimes.Isha != nil{
            if abs(findTimeDifference(time: prayerTimes.Isha!)) <= 30{
                return true
            }
        }
        
        return false
    }
    
    func checkPrayerTimes(){
        if isDuringPrayerTimes(){
            durations.remove(at: 0)
            prayerNote.isHidden = false
            prayerNote.text = "prayerNote".localized()
        }else{
            prayerNote.isHidden = true
            prayerNote.text = ""
        }
        deliveryDurationLbl.text = self.durations[0]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMap"{
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController as! SelectFromMapVC
            vc.destinationDelegate = self
            vc.latitude = self.latitude
            vc.longitude = self.longitude
            vc.countryCode = self.countryCode
            if isdestinationPressed{ // 2.. from request with pickup   3.. from request with destination
                vc.fromType = 3
            }else{
                vc.fromType = 2
            }
        }else if segue.identifier == "toOrders"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 1
        }else if segue.identifier == "toOrderDetails"{
            let navVC = segue.destination as! UINavigationController
            let vc = navVC.topViewController as! UserOrderDetailsVC
            vc.orderID = self.orderID
            vc.isNeedToBackToOrders = true
        }else if segue.identifier == "toAddCoupon"{
            let vc = segue.destination as! AddCouponVC
            vc.addCouponDelegate = self
            vc.couponCode = couponCode
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }
    }
}

extension RequestFromStoreVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if recordType == 0{ // default cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
            setDefaultCell(cell: cell)
            return cell
        }else if recordType == 1{// recording cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
            setRecordingCell(cell: cell)
            return cell
        }else if recordType == 2{// playing cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "playCell", for: indexPath) as! PlayingRecordCell
            cell.setCell(totalTimeCount: intProdSeconds, recordTime: self.recordTime, delegate: self)
            return cell
        }
        return UITableViewCell()
       
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func setDefaultCell(cell: UITableViewCell){
        defaultRecordIcon = cell.contentView.viewWithTag(1) as? UIImageView
        defaultRecordLbl = cell.contentView.viewWithTag(2) as? UILabel
        
        defaultRecordLbl.text = "record_audio".localized()
        defaultRecordLbl.font = Utils.customDefaultFont(defaultRecordLbl.font.pointSize)
        
        let defaultRecordIconTap = UITapGestureRecognizer(target: self, action: #selector(startRecordAction))
        defaultRecordIcon.addGestureRecognizer(defaultRecordIconTap)
        
        let defaultRecordLblTap = UITapGestureRecognizer(target: self, action: #selector(startRecordAction))
        defaultRecordLbl.addGestureRecognizer(defaultRecordLblTap)
    }
    
    func setRecordingCell(cell: UITableViewCell){
        recordTimerLbl = cell.contentView.viewWithTag(1) as? UILabel
        recordCancelLbl = cell.contentView.viewWithTag(2) as? UILabel
        recordSaveLbl = cell.contentView.viewWithTag(3) as? UILabel
        recordBgView = cell.contentView.viewWithTag(4)

        setCornerRadius(selectedView: recordBgView)
        recordTimerLbl.text = "00:00".localized()
        recordCancelLbl.text = "cancel".localized()
        recordSaveLbl.text = "Save".localized()

        recordTimerLbl.font = Utils.customDefaultFont(recordTimerLbl.font.pointSize)
        recordCancelLbl.font = Utils.customDefaultFont(recordCancelLbl.font.pointSize)
        recordSaveLbl.font = Utils.customDefaultFont(recordSaveLbl.font.pointSize)

        let saveRecordLblTap = UITapGestureRecognizer(target: self, action: #selector(saveRecord))
        recordSaveLbl.addGestureRecognizer(saveRecordLblTap)
        
        let cancelRecordLblTap = UITapGestureRecognizer(target: self, action: #selector(cancelRecord))
        recordCancelLbl.addGestureRecognizer(cancelRecordLblTap)
        
        beginRecording()
    }
}

extension RequestFromStoreVC{
    
// ************* record actions ****************
    
    @objc func startRecordAction(){
        print("startRecordAction")
        audioManager.startRecord()
        recordType = 1
        tableView.reloadData()
    }
    
    func beginRecording(){
        audioManager.beginRecording()
        runProdTimer()
    }
    
    func getRecordTime(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
//        formatter.dateFormat = "h:mm a 'on' MMMM dd, yyyy"
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        
        let dateString = formatter.string(from: Date())
        print(dateString)   // "4:44 PM on June 23, 2016\n"
        self.recordTime = dateString
    }
    
    @objc func saveRecord(){
        print("saveRecord")
        audioManager.saveRecord()
        getRecordTime()
        timer.invalidate()
        recordType = 2  // saved
        tableView.reloadData()
    }
    
    func saveRecordData(recordData: Data){
        self.audioData = recordData
        isSubmitAndUpload = false
        requestFromStorePresenter.uploadRecord(recordData: audioData, isSubmitAndUpload: self.isSubmitAndUpload)
    }
    
    @objc func cancelRecord(){
        print("cancelRecord")
        recordType = 0  // default
        tableView.reloadData()
    }
    
    @objc func playPauseButton() {
        audioManager.playPauseRecord()
    }
    
    func runProdTimer() {
        timer = Timer.scheduledTimer(timeInterval: 0.25, target: self, selector: (#selector(updateProdTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateProdTimer() {

        intProdSeconds += 0.25
        if intProdSeconds == 120{ // max recording 2 mins (2*60)
            print("stop recording")
            audioManager.startRecord()
            timer.invalidate()
        }
        recordTimerLbl.text = prodTimeString(time: TimeInterval(exactly: self.intProdSeconds)!)
    }
    
    func prodTimeString(time: TimeInterval) -> String {
        let prodMinutes = Int(time) / 60 % 60
        let prodSeconds = Int(time) % 60
        
        return String(format: "%02d:%02d", prodMinutes, prodSeconds)
    }
}

extension RequestFromStoreVC: UITextViewDelegate{
   
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "order_description_placeholder".localized() {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
        if textView.text.isEmpty {
            textView.text = "order_description_placeholder".localized()
            textView.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        checkValidation()
        self.descTV?.isScrollEnabled = false
        if(appDelegate.isRTL){
            self.descTV.textAlignment = .right
        }else{
            self.descTV.textAlignment = .left
        }
        let contentSize = self.descTV?.sizeThatFits((self.descTV?.bounds.size)!)
        textFrame = descTV.frame
        textFrame.size.height = (contentSize?.height)!

        if textFrame.size.height > 80{
            if textFrame.size.height != lastTextHeight{
//              UIView.setAnimationsEnabled(false)
                descTVHeight.constant = (contentSize?.height)! + 10
                
//              UIView.setAnimationsEnabled(true)
            }
        }
        
        lastTextHeight = textFrame.size.height
        descTV.frame = textFrame
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        return numberOfChars <= 255
    }
}

extension RequestFromStoreVC: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if images.count == 0{
            return 2
        }else{
            return images.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! RequestImageCell
        if images.count == 0{
            if indexPath.row == 0{
                cell.setCell(image: DelegateImageData(), isPlusImage: true, delegate: self)
            }else{
                cell.setCell(image: DelegateImageData(), isPlusImage: false, delegate: self)
            }
        }else{
            if indexPath.row == 0{
                cell.setCell(image: DelegateImageData(), isPlusImage: true, delegate: self)
            }else{
                cell.setCell(image: images[indexPath.row - 1], isPlusImage: false, delegate: self)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if canAddImages{
            if indexPath.row == 0{
                self.view.endEditing(true)
                photosManager.loadPrescriptionPic(tabBarBtnAction: false)
            }
        }
    }
}

extension RequestFromStoreVC: DestinationDelegate{
    
    func selectAddress(latitude: Double, longitude: Double, address: String, title: String) {
        print("lat: \(latitude), lng: \(longitude), address: \(address)")
        if isdestinationPressed{
            print("isdestinationPressed")
            self.toLat = latitude
            self.toLng = longitude
            if title == ""{
                self.toStoreNameLbl.text = address
                self.toStoreNameDescLbl.text = ""
            }else{
                self.toStoreNameLbl.text = title
                self.toStoreNameDescLbl.text = address
            }
            self.toStoreNameLbl.textColor = Colors.hexStringToUIColor(hex: "366db3")
            self.toStoreCloseImg.isHidden = false
        }else{
            print("pickupPressed")
            self.fromLat = latitude
            self.fromLng = longitude
            if title == ""{
                self.fromStoreNameLbl.text = address
                self.fromStoreNameDescLbl.text = ""
            }else{
                self.fromStoreNameLbl.text = title
                self.fromStoreNameDescLbl.text = address
            }
            self.fromStoreNameLbl.textColor = Colors.hexStringToUIColor(hex: "E84450")
            self.fromStoreCloseImg.isHidden = false
        }
       
        checkValidation()
    }
    
}

extension RequestFromStoreVC: RequestFromStoreDelegate{
   
    func playRecord(){
        print("playRecord")
        audioManager.playRecord()
    }

    func pauseRecord() {
       audioManager.pauseRecord()
    }
    
    func deleteRecord() {
        self.recordUploadedType = 4 //pending delete
        if audioRecorderData.id != nil{
            requestFromStorePresenter.deleteRecord(id: audioRecorderData.id!)
        }
        recordType = 0  // default
        tableView.reloadData()
    }
    
    func deleteImage(id: Int) {
        requestFromStorePresenter.deleteImage(id: id)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("audioPlayerDidFinishPlaying")

        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "finishPlaying"), object: nil)
    }
}

extension RequestFromStoreVC: RequestFromStoreView{
    
    func showBlockedArea() {
        Toast.init(text: "blockedAreaToast".localized()).show()
    }
    
    func showloading() {
        loadingView = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingView.mode = MBProgressHUDMode.indeterminate
    }
    
    func hideLoading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
    }
    
    func showAudioloading(){
        self.recordUploadedType = 1 //pending upload
        checkValidation()
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PlayingRecordCell{
            cell.showProgressLoading()
        }
    }
    
    func hideAudioLoading(){
        let indexPath = IndexPath(row: 0, section: 0)
        if let cell = tableView.cellForRow(at: indexPath) as? PlayingRecordCell{
            cell.hideProgressLoading()
        }
    }
    
    func showNetworkError() {
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
    func showSuccess() {
        Toast.init(text: "order_added".localized()).show()
        performSegue(withIdentifier: "toOrders", sender: self)
    }
    
    func navigateToOrderDetails(order: Order) {
        Toast.init(text: "order_added".localized()).show()
        
        if order.id != nil{
            self.orderID = order.id!
            performSegue(withIdentifier: "toOrderDetails", sender: self)
        }
    }
    
    func showUploadAudioSuccess(data: AudioRecorderData) {
        self.recordUploadedType = 2 //success upload
        self.audioRecorderData = data
        checkValidation()
        if isSubmitAndUpload{
            submitAction()
        }
    }
    
    func showUploadAudioFailure() {
        self.recordUploadedType = 3 //failled upload
        checkValidation()
    }
    
    func setImage(image: DelegateImageData) {
        images.append(image)
        if images.count == 10{
            canAddImages = false
        }
        collectionView.reloadData()
    }
    
    func successDelete(id: Int){
        var count = 0
        for image in self.images {
            if image.id != nil{
                if image.id == id{
                    self.images.remove(at: count)
                    canAddImages = true
                    collectionView.reloadData()
                    return
                }
            }
            count += 1
        }
    }
    
    func setPrayerTimes(times: PrayerTimes) {
        self.prayerTimes = times
        checkPrayerTimes()
    }
    
    func removeCouponCode() {
        addCoupon(coupon: "")
    }
}

extension RequestFromStoreVC: AddCouponDelegate{
    
    func addCoupon(coupon: String) {
        couponCode = coupon
        if coupon != ""{
            addCouponView.isHidden = true
            couponView.isHidden = false
            couponLbl.text = coupon
        }else{
            addCouponView.isHidden = false
            couponView.isHidden = true
        }
    }
}
