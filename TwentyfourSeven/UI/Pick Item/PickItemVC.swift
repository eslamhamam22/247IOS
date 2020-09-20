//
//  PickItemVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/3/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster

class PickItemVC: UIViewController {

    @IBOutlet weak var pickItemView: UIView!
    @IBOutlet weak var pickItemViewCenter: NSLayoutConstraint!
    @IBOutlet weak var pickItemTitleLbl: UILabel!
    @IBOutlet weak var itemPriceTitleLbl: UILabel!
    @IBOutlet weak var itemPriceValueTF: UITextField!
    @IBOutlet weak var itemPriceCurrencyLbl: UILabel!
    @IBOutlet weak var shippingCostTitleLbl: UILabel!
    @IBOutlet weak var shippingCostValueLbl: UILabel!
    @IBOutlet weak var commissionTitleLbl: UILabel!
    @IBOutlet weak var commissionValueLbl: UILabel!
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var vatValueLbl: UILabel!
    @IBOutlet weak var totalTitleLbl: UILabel!
    @IBOutlet weak var totalValueLbl: UILabel!
    @IBOutlet weak var readyLbl: UILabel!
    @IBOutlet weak var readyView: UIView!
    @IBOutlet weak var rejectLbl: UILabel!
    @IBOutlet weak var rejectView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var order = Order()
    var pickItemPresenter: PickItemPresenter!
    var loadingView: MBProgressHUD!
    var initialTotal = 0.0
    var pickITemDelegate: ChangeOrderStatusDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        pickItemPresenter = PickItemPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        pickItemPresenter.setView(view: self)
        setUI()
        setFonts()
        setLocalization()
        setGesture()
    }
   
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        setCornerRadius(selectedView: pickItemView, radius: 12)
        setCornerRadius(selectedView: readyView, radius: 10)
        setCornerRadius(selectedView: rejectView, radius: 10)
        itemPriceValueTF.delegate = self

        if appDelegate.isRTL{
            itemPriceValueTF.textAlignment = .right
        }else{
            itemPriceValueTF.textAlignment = .left
        }
        setOrderData()
        
        //hide vat
        vatTitleLbl.text = ""
        vatValueLbl.text = ""
        vatTitleLbl.isHidden = true
        vatValueLbl.isHidden = true
    }
    
    func setFonts(){
        shippingCostTitleLbl.font = Utils.customDefaultFont(shippingCostTitleLbl.font.pointSize)
        itemPriceTitleLbl.font = Utils.customDefaultFont(itemPriceTitleLbl.font.pointSize)
        commissionTitleLbl.font = Utils.customDefaultFont(commissionTitleLbl.font.pointSize)
        vatTitleLbl.font = Utils.customDefaultFont(vatTitleLbl.font.pointSize)
        readyLbl.font = Utils.customDefaultFont(readyLbl.font.pointSize)
        rejectLbl.font = Utils.customDefaultFont(rejectLbl.font.pointSize)
        totalTitleLbl.font = Utils.customDefaultFont(totalTitleLbl.font.pointSize)

        pickItemTitleLbl.font = Utils.customBoldFont(pickItemTitleLbl.font.pointSize)
        itemPriceValueTF.font = Utils.customBoldFont(itemPriceValueTF.font!.pointSize)
        itemPriceCurrencyLbl.font = Utils.customBoldFont(itemPriceCurrencyLbl.font.pointSize)
        commissionValueLbl.font = Utils.customBoldFont(commissionValueLbl.font.pointSize)
        vatValueLbl.font = Utils.customBoldFont(vatValueLbl.font.pointSize)
        shippingCostValueLbl.font = Utils.customBoldFont(shippingCostValueLbl.font.pointSize)
        totalValueLbl.font = Utils.customBoldFont(totalValueLbl.font.pointSize)
    }
    
    func setLocalization(){
        readyLbl.text = "submit_price".localized()
        rejectLbl.text = "editCancel".localized()
        commissionTitleLbl.text = "offer_Comission".localized()
        pickItemTitleLbl.text = "pickItemTitle".localized()
        shippingCostTitleLbl.text = "Shipping_cost".localized()
//        vatTitleLbl.text = "VAT".localized()
        itemPriceCurrencyLbl.text = "sar".localized()
        totalTitleLbl.text = "totalOffer".localized()
        itemPriceTitleLbl.text = "item_price".localized()
    }
    
    func setGesture(){
        
        itemPriceValueTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        let viewTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        viewTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(viewTap)
        
        let pickItemViewTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        pickItemViewTap.cancelsTouchesInView = false
        pickItemView.addGestureRecognizer(pickItemViewTap)
        
        let rejectTap = UITapGestureRecognizer(target: self, action: #selector(rejectAction))
        rejectView.addGestureRecognizer(rejectTap)
        
        let rejectLblTap = UITapGestureRecognizer(target: self, action: #selector(rejectAction))
        rejectLbl.addGestureRecognizer(rejectLblTap)
        
        let readyTap = UITapGestureRecognizer(target: self, action: #selector(readyAction))
        readyView.addGestureRecognizer(readyTap)
        
        let readyLblTap = UITapGestureRecognizer(target: self, action: #selector(readyAction))
        readyLbl.addGestureRecognizer(readyLblTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func setOrderData(){
        var totalReceivedValue = 0.0
        var totalValue = 0.0
        
        if order.delivery_price != nil{
            shippingCostValueLbl.text = getPrice(price: order.delivery_price!)
            totalReceivedValue = order.delivery_price!
            totalValue = order.delivery_price!
        }else{
            shippingCostValueLbl.text = "-"
        }
        
        if order.commission != nil{
            if order.commission == 0{
                commissionValueLbl.text = "free_commission".localized()
            }else{
                commissionValueLbl.text = getPrice(price: order.commission!)
            }
            totalReceivedValue -= order.commission!
        }else{
            commissionValueLbl.text = "-"
        }
        
//        if order.vat != nil{
//            vatValueLbl.text = getPrice(price: order.vat!)
//            totalValue += order.vat!
//        }else{
//            vatValueLbl.text = "-"
//        }
        
        initialTotal = totalValue
        totalValueLbl.text = getPrice(price: totalValue)
    }
    
    func checkTotalValue(){
        let itemPrice = Double(itemPriceValueTF.text!)
        if itemPrice != nil{
            let totalValue = initialTotal + itemPrice!
            totalValueLbl.text = getPrice(price: totalValue)
        }else{
            totalValueLbl.text = getPrice(price: initialTotal)
        }
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setShadow(selectedView : UIView){
        selectedView.layer.borderColor = UIColor.lightGray.cgColor
        selectedView.layer.borderWidth = 0
        selectedView.layer.masksToBounds = false
        selectedView.layer.shadowOffset = CGSize(width: 2, height: 2)
        selectedView.layer.shadowRadius = 3
        selectedView.layer.shadowOpacity = 0.1
    }
    
    func getPrice(price: Double) -> String{
//        if price.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(price)) \("sar".localized())"
//        }else{
            let priceStr = String(format: "%.2f", price)
            return "\(priceStr) \("sar".localized())"
//        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.pickItemViewCenter.constant = -25
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.2) {
            self.pickItemViewCenter.constant = 0
            self.view.layoutIfNeeded()

        }
    }
    
    @objc func rejectAction(){
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @objc func readyAction(){
        self.view.endEditing(true)
        if order.id != nil{
            let cost = Double(itemPriceValueTF.text!)
            if cost != nil{
                pickItemPresenter.pickItem(orderID: order.id!, itemPrice: cost!)
            }else if itemPriceValueTF.text == ""{
                pickItemPresenter.pickItem(orderID: order.id!, itemPrice: 0.0)
            }else{
                
            }
        }
    }
    
    @objc func backAction(){
        self.view.endEditing(true)
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @IBAction func hideKeyboard(){
        self.view.endEditing(true)
    }
}
extension PickItemVC : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.replacedArabicDigitsWithEnglish
        checkTotalValue()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.contains("."))! && string == "."{
            return false
        }else if (textField.text?.contains("."))! && string == "٫"{
            return false
        }
        return true
    }
}
extension PickItemVC: PickItemView{
    
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
    
    func showSuccess(order: Order) {
        pickITemDelegate.pickItemSuccessfully(order: order)
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        performSegue(withIdentifier: "exit", sender: self)
    }
}
