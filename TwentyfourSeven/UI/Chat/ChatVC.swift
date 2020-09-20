//
//  ChatVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/20/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Cosmos
import GrowingTextView
import Toaster
import MBProgressHUD
import FirebaseDatabase
import CoreLocation

class ChatVC: UIViewController , GrowingTextViewDelegate, Dimmable{

    @IBOutlet weak var back_icon: UIBarButtonItem!
 
    // distance view
    @IBOutlet weak var orderNewDistanceFullView: UIView!
    @IBOutlet weak var orderNewDistanceBgView: UIView!
    @IBOutlet weak var orderNewDistanceCirlcleView: UIView!
    @IBOutlet weak var orderNewDistanceLbl: UILabel!
    @IBOutlet weak var orderPickupImg: UIImageView!
    // full distance view
    @IBOutlet weak var orderDistanceFullView: UIView!
    @IBOutlet weak var orderFromDistanceBgView: UIView!
    @IBOutlet weak var orderFromDistanceCirlcleView: UIView!
    @IBOutlet weak var orderFromDistanceLbl: UILabel!
    @IBOutlet weak var orderToDistanceBgView: UIView!
    @IBOutlet weak var orderToDistanceCirlcleView: UIView!
    @IBOutlet weak var orderToDistanceLbl: UILabel!
    
    //chat with info
    @IBOutlet weak var chatterImage: UIImageView!
    @IBOutlet weak var chatterName: UILabel!
    @IBOutlet weak var chatterRate: CosmosView!
    @IBOutlet weak var trackOrderView: UIView!
    @IBOutlet weak var trackOrderLbl: UILabel!
    @IBOutlet weak var trackOrderConstraint: NSLayoutConstraint!
    @IBOutlet weak var chatterView: UIView!
    @IBOutlet weak var callLbl: UILabel!

    @IBOutlet weak var tableView: UITableView!
    
    //send message view
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var msgTV: GrowingTextView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var galleryView: UIView!
    @IBOutlet weak var cameraaView: UIView!
    @IBOutlet weak var sendViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendViewHeight: NSLayoutConstraint!
    
    
    //change order status view
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var changeOrderStatusView: UIView!
    @IBOutlet weak var changeOrderStatusLbl: UILabel!
    @IBOutlet weak var changeOrderStatusHeight: NSLayoutConstraint!

    @IBOutlet weak var noNwView: UIView!
    @IBOutlet weak var noNetworkTitleLbl: UILabel!
    @IBOutlet weak var noNetworkDescLbl: UILabel!
    @IBOutlet weak var noNetworkReloadLbl: UILabel!
    @IBOutlet weak var noNetworkReloadImg: UIImageView!
    
    var imageFile: UIImage!
    var mimeType = ""
    var loadingView: MBProgressHUD!
    let dimLevel: CGFloat = 0.5
    let dimSpeed: Double = 0.5
    
    var isFromMyOrders = false
    var photosManager = PhotosManager()
    let userDefault = UserDefault()
    var chatPresenter: ChatPresenter!
    var order = Order()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // if open chat as delegate of this order will be true .. if open chat as customer of this order will be false
    var isDelegateOfOrder = false
    
    var messages = [ChatMessage]()
    var chatManager = ChatManager()
    var userType = ChatRecipientType.RECIPIENT_TYPE_ALL
    //ti make scroll to bottom first time only with animation ,
    var isFirstTime = true
    var selectedUrl = ""
    var isFromPushNotifications = false
    var timer = Timer()

    //TRACKING
    //0 .. before pickup item   1 .. after pickup   2.. after end the ride
    var orderRouteStatus = 0
    let trackingManager = TrackingManager()
    let orderDetailsManager = OrderDetailsManager()
    var delegateLocation = CLLocation()
    var pickupLocation = CLLocation()
    var destinationLocation = CLLocation()
    var isNeedToUpdateDistance = true
    
    var selectedProfileID = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        chatPresenter = ChatPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        chatPresenter.setView(view: self)
        
        setUI()
        setGestures()
        setOrderData()
        getChatMessages()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
        NotificationCenter.default.removeObserver(self)
        if appDelegate.isRTL{
            chatterRate.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        
    }
    
  
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardObserver()
        if appDelegate.isRTL{
            chatterRate.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
        //modified2
        trackingManager.getUpdatedOnDelegateLocation()

    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            sendViewBottomConstraint.constant = keyboardSize.height
            self.scrollToBottomRow()
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        //addressBottomConstraint.constant = 20
        sendViewBottomConstraint.constant = 0
        self.scrollToBottomRow()
//        UIView.animate(withDuration: 0.25, animations: { () -> Void in
//            self.view.layoutIfNeeded()
//        })
    }
    
   
    func setGestures(){
        let reloadTap = UITapGestureRecognizer(target: self, action: #selector(reloadData))
        noNetworkReloadImg.addGestureRecognizer(reloadTap)
        
        let reloadLblTap = UITapGestureRecognizer(target: self, action: #selector(reloadData))
        noNetworkReloadLbl.addGestureRecognizer(reloadLblTap)
        
        let delegateNameTab = UITapGestureRecognizer(target: self, action: #selector(profileInfoPressed))
        chatterName.addGestureRecognizer(delegateNameTab)
        
        let delegateImgTab = UITapGestureRecognizer(target: self, action: #selector(profileInfoPressed))
        chatterImage.addGestureRecognizer(delegateImgTab)
    }
    
    func setUI(){
        self.tableView.isHidden = true

        chatterImage.layer.setCornerRadious(radious: 5.0, maskToBounds: true)
        setCornerRadius(selectedView: orderDistanceFullView, radius: 12)
        setCornerRadius(selectedView: orderFromDistanceBgView, radius: 5)
        setCornerRadius(selectedView: orderFromDistanceCirlcleView, radius: 3.5)
        setCornerRadius(selectedView: orderToDistanceBgView, radius: 5)
        setCornerRadius(selectedView: orderToDistanceCirlcleView, radius: 3.5)
        setCornerRadius(selectedView: orderNewDistanceBgView, radius: 5)
        setCornerRadius(selectedView: orderNewDistanceCirlcleView, radius: 3.5)
        setCornerRadius(selectedView: orderNewDistanceFullView, radius: 12)
        
        trackOrderView.layer.setCornerRadious(radious: 8.0, maskToBounds: true)
        changeOrderStatusView.layer.setCornerRadious(radious: 10.0, maskToBounds: true)
        chatterView.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)
        statusView.layer.setShadow(opacity: 0.7, radious: 5, shadowColor:  UIColor.lightGray.cgColor)
        //add bottom border TO STATUS VIEW
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: statusView.frame.size.height-1, width: statusView.frame.width, height: 1)
        bottomBorder.backgroundColor = Colors.hexStringToUIColor(hex: "BCC5D3").cgColor
        statusView.layer.addSublayer(bottomBorder)
        
        
        msgTV.delegate = self
        msgTV.placeholder = "chatPlaceholder".localized()
        trackOrderLbl.text = "trackOrder".localized()
        sendLabel.text = "send".localized()
        noNetworkTitleLbl.text = "no_network_title".localized()
        noNetworkDescLbl.text = "no_network_desc".localized()
        noNetworkReloadLbl.text = "no_network_reload".localized()
        callLbl.text = "call".localized()

        orderFromDistanceLbl.text = ""
        orderToDistanceLbl.text = ""
        
        if appDelegate.isRTL{
            back_icon.image = UIImage(named: "back_ar_ic")
            msgTV.textAlignment = .right
        }else{
            back_icon.image = UIImage(named: "back_ic")
            msgTV.textAlignment = .left
        }
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        if order.id != nil{
            self.navigationItem.title = "\("delegate_order".localized()) #\(order.id!)"
        }
        
        setFonts()
        checkDelegateView()
    
    }
    
    
    @objc func reloadData(){
        if Utils.isConnectedToNetwork(){
            getChatMessages()
        }
    }
    
    func setOrderData(){
        
        if isDelegateOfOrder{
            userType = ChatRecipientType.RECIPIENT_TYPE_DELEGATE
            //get user data if current user is the delgate of the order
            if order.user != nil{
                if let userImage = order.user!.image {
                    if let userMediumImage = userImage.medium {
                        let url = URL(string: userMediumImage)
                        print("url \(String(describing: url))")
                        self.chatterImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
                    }else{
                        self.chatterImage.image = UIImage(named: "avatar")
                    }
                }else{
                    self.chatterImage.image = UIImage(named: "avatar")
                }
                
                if let userName = order.user!.name{
                    chatterName.text = userName
                }else{
                    chatterName.text = ""
                }
                
                if let id = order.user?.id{
                    selectedProfileID = id
                }
                
                if order.user?.rating != nil{
                    setRate(rate: (order.user?.rating)!)
                }else{
                    setRate(rate: 5)
                }
                
            }else{
                chatterName.text = ""
                self.chatterImage.image = UIImage(named: "avatar")
            }
        }else{
            userType = ChatRecipientType.RECIPIENT_TYPE_CUSTOMER
            //get delegate data if current user is the user of the order
            if order.delegate != nil{
                if let delegateImage = order.delegate!.image {
                    if let delegateMediumImage = delegateImage.medium {
                        let url = URL(string: delegateMediumImage)
                        print("url \(String(describing: url))")
                        self.chatterImage.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
                    }else{
                        self.chatterImage.image = UIImage(named: "avatar")
                    }
                }else{
                    self.chatterImage.image = UIImage(named: "avatar")
                }
                
                if let delegateName = order.delegate!.name{
                    chatterName.text = delegateName
                }else{
                    chatterName.text = ""
                }
                
                if let id = order.delegate?.id{
                    selectedProfileID = id
                }
                
                if order.delegate?.delegate_rating != nil{
                    setRate(rate: (order.delegate?.delegate_rating)!)
                }else{
                    setRate(rate: 5)
                }
            }else{
                chatterName.text = ""
                self.chatterImage.image = UIImage(named: "avatar")
            }
        }
        setOrderRouteStatus()
        setOrderLocations()
    }
    
    func setFonts(){
        chatterName.font = Utils.customDefaultFont(chatterName.font.pointSize)
        trackOrderLbl.font = Utils.customDefaultFont(trackOrderLbl.font.pointSize)
        trackOrderConstraint.constant = trackOrderLbl.intrinsicContentSize.width
        msgTV.font = Utils.customDefaultFont((msgTV.font?.pointSize)!)
        sendLabel.font = Utils.customDefaultFont(sendLabel.font.pointSize)
        changeOrderStatusLbl.font = Utils.customDefaultFont(changeOrderStatusLbl.font.pointSize)
        noNetworkTitleLbl.font = Utils.customBoldFont(noNetworkTitleLbl.font.pointSize)
        noNetworkDescLbl.font = Utils.customDefaultFont(noNetworkDescLbl.font.pointSize)
        noNetworkReloadLbl.font = Utils.customDefaultFont(noNetworkReloadLbl.font.pointSize)
        callLbl.font = Utils.customDefaultFont(callLbl.font.pointSize)

        orderNewDistanceLbl.font = Utils.customDefaultFont(orderNewDistanceLbl.font.pointSize)
        orderFromDistanceLbl.font = Utils.customDefaultFont(orderFromDistanceLbl.font.pointSize)
        orderToDistanceLbl.font = Utils.customDefaultFont(orderToDistanceLbl.font.pointSize)
    }
    
    func addKeyboardObserver(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func checkDelegateView(){
        // set actions on order to delegate only
        if isDelegateOfOrder{
            changeOrderStatusHeight.constant = 55
            setOrderStatus()
        }else{
            changeOrderStatusHeight.constant = 0
        }
    }
    
    func setOrderStatus(){
        if changeOrderStatusLbl != nil && changeOrderStatusView != nil{
            changeOrderStatusLbl.text = ""
            if order.status != nil{
                if order.status! == "assigned"{
                    changeOrderStatusLbl.text = "start_ride".localized()
                    changeOrderStatusView.backgroundColor = Colors.hexStringToUIColor(hex: "E84450")
                }else if order.status! == "in_progress"{
                    changeOrderStatusLbl.text = "pick_item".localized()
                    changeOrderStatusView.backgroundColor = Colors.hexStringToUIColor(hex: "498BCA")
                }else if order.status! == "delivery_in_progress"{
                    changeOrderStatusLbl.text = "delivered_action".localized()
                    changeOrderStatusView.backgroundColor = Colors.hexStringToUIColor(hex: "E84450")
                }
            }
        }
    }
    
    func setRate(rate: Double){
        chatterRate.update()
        chatterRate.settings.updateOnTouch = false
        chatterRate.rating = rate
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        UIView.animate(withDuration: 0.2) {
            print(height)
            self.sendViewHeight.constant = height + 20
            self.view.layoutIfNeeded()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            changeHighlightedTextColor(label: sendLabel, active: false)
        }else{
            changeHighlightedTextColor(label: sendLabel, active: true)
        }
    }
  
    func changeHighlightedTextColor(label : UILabel , active : Bool){
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            if active{
                label.textColor = Colors.hexStringToUIColor(hex: "E84450")
            }else{
                label.textColor = Colors.hexStringToUIColor(hex: "BCC5D3")
            }
        })
    }
    
    @IBAction func unwindFromPickItem(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: dimSpeed)
        addKeyboardObserver()
    }
    
    @IBAction func unwindFromDelivery(_ segue: UIStoryboardSegue) {
        dimFullScreen(.out, speed: dimSpeed)
    }
    
    @IBAction func backAction(_ sender: Any) {
        chatManager.removeObservers()

        if isFromPushNotifications{
            performSegue(withIdentifier: "toNotifications", sender: self)
        }else{
            if isFromMyOrders{
                if self.presentingViewController?.presentingViewController != nil{
                    self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
                }else{
                    performSegue(withIdentifier: "toMyOrders", sender: self)
                }
            }else{
                performSegue(withIdentifier: "toMyOrders", sender: self)
            }
        }
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func sendMessage(_ sender: Any) {
        print("sendMessage")
        if !msgTV.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty{
            if !Utils.isConnectedToNetwork(){
                showNetworkError()
            }else{
                sendMessage()
            }
        }
        
    }
    
    @IBAction func addImageFromCamera(_ sender: Any) {
        print("addImageFromCamera")
        self.view.endEditing(true)
        photosManager.openCamera()
        
    }
    
    @IBAction func addImageFromGallery(_ sender: Any) {
        print("addImageFromGallery")
        self.view.endEditing(true)
        photosManager.openGallary()
    }
    
    @IBAction func trackOrder(_ sender: Any) {
        print("trackOrder")
        self.view.endEditing(true)
        // now navigate to user order details without check user or delegate
        if isDelegateOfOrder{
            performSegue(withIdentifier: "toDelegateOrderDetails", sender: self)
        }else{
            performSegue(withIdentifier: "toUserOrderDetails", sender: self)
        }
    }
    
    @IBAction func changeOrderStatus(_ sender: Any) {
       
        print("changeOrderStatus")
        self.view.endEditing(true)
        changeOrderStatusAction()
    }
    
    @objc func profileInfoPressed(_ sender: Any) {
        self.view.endEditing(true)
        performSegue(withIdentifier: "toProfile", sender: self)
    }
    
    @IBAction func callAction(){
        if isDelegateOfOrder {
            if order.user != nil{
                if order.user?.mobile != nil{
                    callPhoneNumber(phone: (order.user?.mobile)!)
                }
            }
        }else{
            if order.delegate != nil{
                if order.delegate?.mobile != nil{
                    callPhoneNumber(phone: (order.delegate?.mobile)!)
                }
            }
        }
    }
    
    func callPhoneNumber(phone: String) {
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
    
    func resultOfCapturingImages(result : String , imageFile : UIImage, mimeType : String){
        print("resultOfCapturingImages")
        if result == "imageTypeError"{
            Toast.init(text: "imageTypeError".localized()).show()
        }else if result == "imageSizeError"{
            Toast.init(text: "imageSizeError".localized()).show()
        }else if result == "noError"{
            self.imageFile = imageFile
            self.mimeType = mimeType
            self.performSegue(withIdentifier: "ImageSelectionPreview", sender: self)
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyOrders"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 1
        }else if segue.identifier == "toUserOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! UserOrderDetailsVC
            if order.id != nil{
                vc.orderID = self.order.id!
            }
            vc.isFromChat = true
        }else if segue.identifier == "toDelegateOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! DelegateOrderDetailsVC
            if order.id != nil{
                vc.orderID = self.order.id!
            }
            vc.isFromChat = true
        }else if segue.identifier == "toPickItem"{
            let vc = segue.destination as! PickItemVC
            vc.order = order
            vc.pickITemDelegate = self
            NotificationCenter.default.removeObserver(self)
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "toConfirmDelivery"{
            let vc = segue.destination as! ConfirmDeliveryVC
            vc.order = order
            dimFullScreen(.in, alpha: dimLevel, speed: dimSpeed)
        }else if segue.identifier == "showImage"{
            let vc = segue.destination as! ViewFullImageVC
            vc.imageUrl = selectedUrl
        }else if segue.identifier == "toNotifications"{
            let vc = segue.destination as! UserTabBar
            vc.selectedIndex = 0
        }else if segue.identifier == "toProfile"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! ProfileVC
            if isDelegateOfOrder{
                vc.isUser = true
            }else{
                vc.isUser = false
            }
            vc.userId = selectedProfileID
        }else if segue.identifier == "ImageSelectionPreview"{
            let vc = segue.destination as! ViewFullImageVC
            vc.showSendBtn = true
            vc.imageFile = imageFile
            vc.mimeType = mimeType
            vc.orderId = self.order.id ?? 0
            vc.imageDelegate = self
        }
        
        
        
    }
}

extension ChatVC : UITableViewDelegate , UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  messages.count
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if messages.indices.contains(indexPath.row){
            //created by if system equal 0 ..... users equal user id
            if  messages[indexPath.row].created_by ?? 0  != 0 {
                //chat between user and delegate
                var isSender = false
                if self.userDefault.getUserData().id != nil{
                    if messages[indexPath.row].created_by ?? 0  == self.userDefault.getUserData().id!{
                        isSender = true
                    }
                }
                
                if !isSender{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RecieverChatCell", for: indexPath) as! MessageChatCell
                    cell.setCell(index: indexPath.row , order : self.order, isSender: isSender, chatMessage: messages[indexPath.row], isDelegtateOfOrder: self.isDelegateOfOrder, imageDelegate: self)
                    return cell
                }else{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SenderChatCell", for: indexPath) as! MessageChatCell
                    cell.setCell(index: indexPath.row , order : self.order, isSender: isSender, chatMessage: messages[indexPath.row], isDelegtateOfOrder: self.isDelegateOfOrder, imageDelegate: self)
                    return cell
                }
            }else{
                //system msgs
                let cell = tableView.dequeueReusableCell(withIdentifier: "RecieverChatCell", for: indexPath) as! MessageChatCell
                cell.setCell(index: indexPath.row , order : self.order, isSender: false, chatMessage: messages[indexPath.row], isDelegtateOfOrder: self.isDelegateOfOrder, imageDelegate: self)
                return cell
            }
            
        }
        
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

extension ChatVC: ChangeOrderStatusDelegate{
    
    func pickItemSuccessfully(order: Order) {
        self.order = order
        //make order status delivery_in_progress after pick item
        showStatusChangedSuccessfully(newStatus: "delivery_in_progress")
    }
   
    func changeOrderStatusAction(){
        if changeOrderStatusLbl.text == "start_ride".localized(){ //start ride action
            if order.id != nil{
                chatPresenter.startRide(orderID: order.id!)
            }
        }else if changeOrderStatusLbl.text == "pick_item".localized(){//pick item action
            performSegue(withIdentifier: "toPickItem", sender: self)
        }else if changeOrderStatusLbl.text == "delivered_action".localized(){//deliver action
            performSegue(withIdentifier: "toConfirmDelivery", sender: self)
        }
    }
    
    func changeOrderStatus(status: String){
        order.status = status
        isNeedToUpdateDistance = true
        setOrderStatus()
        setOrderRouteStatus()
        setOrderLocations()
    }
}

extension ChatVC: ChatView{
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
    
    func showNetworkError() {
        Toast.init(text: "connectionFailed".localized()).show()
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg: String) {
        Toast.init(text:msg).show()
    }
    
    func showStatusChangedSuccessfully(newStatus: String) {
        self.order.status = newStatus
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        setOrderStatus()
        isNeedToUpdateDistance = true
        setOrderRouteStatus()
        setOrderLocations()
    }
    
    
}

//DATABASE

extension ChatVC {
    
    func getChatMessages(){
        if Utils.isConnectedToNetwork(){
            self.showloading()
            if self.order.id != nil{
                chatManager.initRefernces(orderId: self.order.id! , view : self)
                chatManager.getMessages()
            }
            checkNoNetworkConnectivity()
        }else{
            self.noNwView.isHidden = false
            self.hideLoading()
        }
    }
    
    func  gotChatMessgaes(chatMsgs: [ChatMessage]){
        self.noNwView.isHidden = true
        self.hideLoading()
        self.messages.removeAll()
        let filtered = chatMsgs.filter { $0.recipient_type == ChatRecipientType.RECIPIENT_TYPE_ALL || $0.recipient_type == userType}
        print(filtered)
        self.messages = filtered
        self.tableView.reloadData()
        self.scrollToBottomRow()
        self.timer.invalidate()
        
    }
    
    func sendMessage(){
        var senderId = ""
        if userDefault.getUserData().id != nil{
            senderId = String(userDefault.getUserData().id!)
        }
        chatManager.sendMessage(msg: self.msgTV.text, userId: Int(senderId) ?? 0)
        self.msgTV.text = ""
        self.scrollToBottomRow()
    }
    
    func checkNoNetworkConnectivity(){
         timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(checkData)), userInfo: nil, repeats: true)
    }
    
    @objc func checkData(){
        if self.messages.count == 0 {
            self.hideLoading()
            self.noNwView.isHidden = false
        }else{
            self.noNwView.isHidden = true
        }
    
    }

}

extension ChatVC {
    
    func scrollToBottomRow() {
        DispatchQueue.main.async {
            guard self.tableView.numberOfSections > 0 else { return }
            
            // Make an attempt to use the bottom-most section with at least one row
            var section = max(self.tableView.numberOfSections - 1, 0)
            var row = max(self.tableView.numberOfRows(inSection: section) - 1, 0)
            var indexPath = IndexPath(row: row, section: section)
            
            // Ensure the index path is valid, otherwise use the section above (sections can
            // contain 0 rows which leads to an invalid index path)
            while !self.indexPathIsValid(indexPath) {
                section = max(section - 1, 0)
                row = max(self.tableView.numberOfRows(inSection: section) - 1, 0)
                indexPath = IndexPath(row: row, section: section)
                
                // If we're down to the last section, attempt to use the first row
                if indexPath.section == 0 {
                    indexPath = IndexPath(row: 0, section: 0)
                    break
                }
            }
            
            // In the case that [0, 0] is valid (perhaps no data source?), ensure we don't encounter an
            // exception here
            guard self.indexPathIsValid(indexPath) else { return }
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            self.tableView.isHidden = false
        }
    }
    
    func indexPathIsValid(_ indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        let row = indexPath.row
        return section < self.tableView.numberOfSections && row < self.tableView.numberOfRows(inSection: section)
    }
}


extension ChatVC : ImageDelegate{
    
    func showImage(url: String) {
        self.selectedUrl = url
        self.performSegue(withIdentifier: "showImage", sender: self)
    }
    
    func saveImagetoDB(chatImage: ChatImage) {
        var senderId = ""
        if userDefault.getUserData().id != nil{
            senderId = String(userDefault.getUserData().id!)
        }
        self.chatManager.saveChatImage(chatImg: chatImage, userId: Int(senderId) ?? 0 )
    }
}

// TRAKING
extension ChatVC{
    
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
    
    func setOrderLocations(){
        if order.from_lat != nil && order.from_lng != nil{
            pickupLocation = CLLocation(latitude: order.from_lat!, longitude: order.from_lng!)
        }
        
        if order.to_lat != nil && order.to_lng != nil{
            destinationLocation = CLLocation(latitude: order.to_lat!, longitude: order.to_lng!)
        }
        
        if orderRouteStatus == 0{//distance from pickup to destination
            chatPresenter.getPolylineRoute(from: pickupLocation.coordinate, to: destinationLocation.coordinate, isDelegatePath: false, orderStatus: order.status ?? "")
        }
        
        if trackingManager.databaseRef == nil{
            trackingManager.initRefernces(delegateID: getDelegateID(), viewContoller: self, pickupLocation: self.pickupLocation.coordinate, destinationLocation: destinationLocation.coordinate)
        }
        
        //modified2
        trackingManager.getUpdatedOnDelegateLocation()

        //trackingManager.getLastDelegateLocation()
        

    }
    
    func getDelegateID() -> Int{
        var id = 0
        if isDelegateOfOrder{
            // user as delegate
            if userDefault.getUserData().id != nil{
                id = userDefault.getUserData().id!
            }
        }else{
            if order.delegate != nil{
                if order.delegate?.id != nil{
                    id = (order.delegate?.id)!
                }
            }
        }
        return id
    }
    
    func updateDelegateLocation(location: CLLocation){
        delegateLocation = location
        
        if let orderStatus = order.status{
            if orderStatus == "delivery_in_progress"{
                self.getFromDelegateToDestinationDistance()
            }else{
                self.getFromDelegateToPickupDistance()
            }
        }
      //  if isNeedToUpdateDistance{
//            self.delegateLocation = location
//            if orderRouteStatus == 0{ //distance to pickup
//                chatPresenter.getPolylineRoute(from: location.coordinate, to: pickupLocation.coordinate, isDelegatePath: true)
//            }else{
//                // distance to distenation
//                chatPresenter.getPolylineRoute(from: location.coordinate, to: destinationLocation.coordinate, isDelegatePath: true)
//            }
//            isNeedToUpdateDistance = false
//        }
    }
    
    func setDistance(isDelegatePath: Bool, distanceValue: Double){
        if isDelegatePath{
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

    }
    
    func getFromDelegateToDestinationDistance(){
        if delegateLocation.coordinate.latitude != 0.0 && delegateLocation.coordinate.longitude != 0.0 && order.from_lat != nil && order.from_lng != nil{
            let distance = orderDetailsManager.getDistanceValue(fromLocationLat: delegateLocation.coordinate.latitude, fromLocationLng: delegateLocation.coordinate.longitude, toLocationLat: order.to_lat!, toLocationLng: order.to_lng!)
            setDistance(isDelegatePath: true, distanceValue: distance)
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
    
    
}
