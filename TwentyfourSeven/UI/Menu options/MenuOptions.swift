//
//  MenuOptions.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/27/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GrowingTextView
import MBProgressHUD
import Toaster
import DropDown

class MenuOptions: UIViewController , GrowingTextViewDelegate{

    @IBOutlet weak var menuOptions: UIView!
    @IBOutlet weak var cancelOrderLbl: UILabel!
    @IBOutlet weak var cancelOrderView: UIView!
    @IBOutlet weak var cancelOrderHeight: NSLayoutConstraint!
    @IBOutlet weak var submitComplainLbl: UILabel!
    
    
    //alert outlets
    @IBOutlet weak var alertTitle: UILabel!
    @IBOutlet weak var complain_txt: UITextView!
    @IBOutlet weak var alertYes: UILabel!
    @IBOutlet weak var alertNo: UILabel!
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var compalinTextHeight: NSLayoutConstraint!
    @IBOutlet weak var reasonErrorTxt: UILabel!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var reasonsView: UIView!
    @IBOutlet weak var reasonsTitleLbl: UILabel!

    var isDelegate = false
    var textField: UITextField?
    var isKeyboardShow = false
    var menuOptionsPresenter : MenuOptionsPresenter!
    var loadingView: MBProgressHUD!
    var orderDetailsManager = OrderDetailsManager()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var order = Order()
    let reasonsDropDwon = DropDown()
    var cancellationReasons = [CancellationReason]()
    var cancellationReasonsTitles = [String]()
    var selectedReason = CancellationReason()
    var showCancelOrder = false

    override func viewDidLoad() {
        super.viewDidLoad()
        initPresenter()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func initPresenter(){
        menuOptionsPresenter = MenuOptionsPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        menuOptionsPresenter.setView(view: self)
    }
    
    func setUI(){
        setFonts()
        setCancelView()
        
        self.menuOptions.layer.setCornerRadious(radious: 5.0, maskToBounds: true)
        self.cancelOrderLbl.text = "cancel_order".localized()
        self.submitComplainLbl.text = "submitComplain".localized()
        if isDelegate{
            self.alertTitle.text = "cancelDelegateAlert".localized()
        }else{
            self.alertTitle.text = "cancelOrderAlert".localized()
        }
        self.alertYes.text = "yes".localized()
        self.alertNo.text = "no".localized()
        self.reasonErrorTxt.text = "reasonValidation".localized()
        self.complain_txt.text = "reasonPlaceHolder".localized()
        self.reasonsTitleLbl.text = "reasonPlaceHolder".localized()
        complain_txt.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")

        alertView.layer.setCornerRadious(radious: 10.0, maskToBounds: true)
        orderDetailsManager.setCornerRadius(selectedView: shadowView, radius: 10)
        orderDetailsManager.setShadow(selectedView: shadowView)
        
        orderDetailsManager.setCornerRadius(selectedView: reasonsView, radius: 10)
        orderDetailsManager.setShadow(selectedView: reasonsView)
        
//        shadowView.layer.setCornerRadious(radious: 10.0)
//        shadowView.layer.setShadow(opacity: 0.5, radious: 5, shadowColor: UIColor.red.cgColor)
//        shadowView.clipsToBounds = true
        complain_txt.delegate = self
        if appDelegate.isRTL{
            complain_txt.textAlignment = .right
        }else{
            complain_txt.textAlignment = .left
        }
        
        //hide complain_txt
        complain_txt.isHidden = true
        shadowView.isHidden = true
        
        if showCancelOrder{
            menuOptions.isHidden = true
            menuOptionsPresenter.getCancellationReasons(isDelegate: isDelegate)
        }
    }
  
    func setFonts(){
        cancelOrderLbl.font = Utils.customDefaultFont(cancelOrderLbl.font.pointSize)
        submitComplainLbl.font = Utils.customDefaultFont(submitComplainLbl.font.pointSize)
        alertTitle.font = Utils.customDefaultFont(alertTitle.font.pointSize)
        complain_txt.font = Utils.customDefaultFont(complain_txt.font!.pointSize)
        alertYes.font = Utils.customDefaultFont(alertYes.font.pointSize)
        alertNo.font = Utils.customDefaultFont(alertNo.font.pointSize)
        reasonsTitleLbl.font = Utils.customDefaultFont(reasonsTitleLbl.font.pointSize)
        reasonErrorTxt.font = Utils.customDefaultFont(reasonErrorTxt.font.pointSize)
    }
    
    func setCancelView(){
        
        cancelOrderView.isHidden = false
        cancelOrderHeight.constant = 50
        
        if order.status != nil{
            if isDelegate{
                if order.status! == "new" || order.status! == "cancelled" || order.status! == "pending" || order.status! == "delivered"{
                    cancelOrderView.isHidden = true
                    cancelOrderHeight.constant = 0
                }
            }else{
                if order.status! == "delivery_in_progress" || order.status! == "cancelled" ||  order.status! == "assigned" || order.status! == "in_progress" || order.status! == "delivered"{
                    cancelOrderView.isHidden = true
                    cancelOrderHeight.constant = 0
                }
            }
        }
    }
    
    func setDropDown() {
        reasonsDropDwon.direction = .bottom
        reasonsDropDwon.width = reasonsView.frame.width
        reasonsDropDwon.cellNib = UINib(nibName: "CancelReasonCell", bundle: nil)
        reasonsDropDwon.cellHeight = 40

        if appDelegate.isRTL {
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            reasonsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .right
//                cell.optionLabel.numberOfLines = 2
                cell.optionLabel.font = Utils.customDefaultFont(13)
            }
        }else{
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            reasonsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .left
//                cell.optionLabel.numberOfLines = 2
                cell.optionLabel.font = Utils.customDefaultFont(13)
            }
        }
        
        reasonsDropDwon.selectionAction = { [unowned self] (index: Int, item: String) in
            self.selectedReason = self.cancellationReasons[index]
            self.reasonsTitleLbl.text = self.cancellationReasonsTitles[index]
            self.reasonsTitleLbl.textColor = Colors.hexStringToUIColor(hex: "212121")
        }
        
    }
    
    @IBAction func cancelOrder(_ sender: Any) {
//        if isDelegate{
//            menuOptions.isHidden = true
//            alertView.isHidden = false
//        }else{
//            performSegue(withIdentifier: "cancel", sender: self)
//        }
        menuOptions.isHidden = true
        menuOptionsPresenter.getCancellationReasons(isDelegate: isDelegate)
    }
    
    @IBAction func cancelOrderAlertAction(_ sender: Any) {
        print("alert pressed")
    }
    
    @IBAction func confirmCancelOrder(_ sender: Any) {
        self.view.endEditing(true)
        self.reasonErrorTxt.isHidden = true
//        if self.complain_txt.text! == "" || self.complain_txt.text! == "reasonPlaceHolder".localized(){
//            self.reasonErrorTxt.isHidden = false
//        }else{
//            if order.id != nil{
//                menuOptionsPresenter.cancelOrder(id: self.order.id!, reason: self.complain_txt.text!)
//            }
//        }
        
    
        if self.reasonsTitleLbl.text == "reasonPlaceHolder".localized(){
            self.reasonErrorTxt.isHidden = false
        }else{
            if order.id != nil && selectedReason.id != nil{
                if isDelegate{
                    menuOptionsPresenter.cancelDelegateOrder(id: self.order.id!, reason: selectedReason.id!)
                }else{
                    menuOptionsPresenter.cancelUserOrder(id: self.order.id!, reason: selectedReason.id!)
                }
            }
        }
    }
    
    @IBAction func cancelAlert(_ sender: Any) {
        self.view.endEditing(true)
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @IBAction func submitComplain(_ sender: Any) {
//        performSegue(withIdentifier: "complain", sender: self)
        performSegue(withIdentifier: "toSubmitComplaint", sender: self)
    }
    
    @IBAction func closeMenuOptions(_ sender: Any) {
        if isDelegate{
            if isKeyboardShow{
                self.view.endEditing(true)
            }else{
                performSegue(withIdentifier: "exit", sender: self)
            }
        }else{
            performSegue(withIdentifier: "exit", sender: self)
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        isKeyboardShow = true
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        isKeyboardShow = false
        
    }
    
    @IBAction func showCancellationReasons(_ sender: Any) {
        self.view.endEditing(true)
        reasonsDropDwon.anchorView = reasonsView
        reasonsDropDwon.bottomOffset = CGPoint(x: 0, y:(reasonsDropDwon.anchorView?.plainView.bounds.height)!)
        reasonsDropDwon.dataSource = cancellationReasonsTitles
        setDropDown()
        reasonsDropDwon.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toSubmitComplaint"{
            let navVc = segue.destination as! UINavigationController
            let vc = navVc.topViewController as! SubmitComplaintVC
            vc.complaintDelegate = self
            vc.id = order.id!
        }
    }
}

extension MenuOptions: MenuOptionsView{
    
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
    
    func cancelOrderSuccessfully(){
        print("cancelOrderSuccessfully")
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        self.performSegue(withIdentifier: "cancelSuccess", sender: self)
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
    
    func setCancellationReasons(reasons: [CancellationReason]){
        cancellationReasonsTitles = reasons.map{$0.title ?? ""}
        cancellationReasons = reasons
        alertView.isHidden = false
    }
    
    func cancellationReasonsFailure(){
        performSegue(withIdentifier: "exit", sender: self)
    }
}


extension MenuOptions : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "reasonPlaceHolder".localized() {
            textView.text = nil
            textView.textColor = Colors.hexStringToUIColor(hex: "#212121")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
        if textView.text.isEmpty {
            textView.text = "reasonPlaceHolder".localized()
            textView.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
        }
    }
    
   
}

extension MenuOptions: ComplaintDelegate{
    
    func backComplaintsPressed() {
        performSegue(withIdentifier: "complain", sender: self)

    }
}
