//
//  DelegateSetOfferVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/14/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import GoogleMaps
import MBProgressHUD
import Toaster

class DelegateSetOfferVC: UIViewController {

    @IBOutlet weak var setOfferView: UIView!
    @IBOutlet weak var setOfferTitleLbl: UILabel!
    @IBOutlet weak var shippingCostTitleLbl: UILabel!
    @IBOutlet weak var shippingCostValueTF: UITextField!
    @IBOutlet weak var shippingCostErrorLbl: UILabel!
    @IBOutlet weak var shippingCostCurrencyLbl: UILabel!
    @IBOutlet weak var commissionTitleLbl: UILabel!
    @IBOutlet weak var commissionValueLbl: UILabel!
    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var vatValueLbl: UILabel!
    @IBOutlet weak var totalReceivedTitleLbl: UILabel!
    @IBOutlet weak var totalReceivedValueLbl: UILabel!
    @IBOutlet weak var readyLbl: UILabel!
    @IBOutlet weak var readyView: UIView!
    @IBOutlet weak var rejectLbl: UILabel!
    @IBOutlet weak var rejectView: UIView!
    
    @IBOutlet weak var freeCommissionView: UIView!
    @IBOutlet weak var freeCommissionLbl: UILabel!
    @IBOutlet weak var freeCommissionHeight: NSLayoutConstraint!

    var delegateSetOfferPresenter : DelegateSetOfferPresenter!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var setOfferDelegate : SetOfferDelegate!
    let orderDetailsManager = OrderDetailsManager()
    var loadingView: MBProgressHUD!
    var order = Order()
    var isFreeCommission = false
    var currentLocation = CLLocationCoordinate2D()
    var distance = 0.0
    var distanceToPickup = 0.0
    var distanceToDestination = 0.0
    var maxDistanceValue = 0.0
    var minDistanceValue = 0.0
    var minFixedValue = 0.0
    var isComissionPersentage = false
    var comissionFixedValue = 0.0
    var isVatPersentage = false
    var vatFixedValue = 0.0
    var errorMsg = ""
    
    var commissionFinalValue = 0.0
    var vatFinalValue = 0.0
    var totalReceivedFinalValue = 0.0
    var userDefault = UserDefault()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        delegateSetOfferPresenter = DelegateSetOfferPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        delegateSetOfferPresenter.setView(view: self)
        setUI()
        setFonts()
        setGesture()
        setLocalization()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        orderDetailsManager.setCornerRadius(selectedView: setOfferView, radius: 12)
        orderDetailsManager.setCornerRadius(selectedView: readyView, radius: 10)
        orderDetailsManager.setCornerRadius(selectedView: rejectView, radius: 10)
        orderDetailsManager.setCornerRadius(selectedView: freeCommissionView, radius: 5)
        shippingCostValueTF.delegate = self
        
        shippingCostErrorLbl.text = errorMsg
        totalReceivedValueLbl.text = ""
        totalReceivedTitleLbl.text = ""

        if appDelegate.isRTL{
            shippingCostValueTF.textAlignment = .right
        }else{
            shippingCostValueTF.textAlignment = .left
        }
        setFixedValues()
        
        //hide vat
        vatTitleLbl.text = ""
        vatValueLbl.text = ""
        vatTitleLbl.isHidden = true
        vatValueLbl.isHidden = true
    }
    
    func setFonts(){
        shippingCostTitleLbl.font = Utils.customDefaultFont(shippingCostTitleLbl.font.pointSize)
        commissionTitleLbl.font = Utils.customDefaultFont(commissionTitleLbl.font.pointSize)
        vatTitleLbl.font = Utils.customDefaultFont(vatTitleLbl.font.pointSize)
        readyLbl.font = Utils.customDefaultFont(readyLbl.font.pointSize)
        rejectLbl.font = Utils.customDefaultFont(rejectLbl.font.pointSize)
        totalReceivedTitleLbl.font = Utils.customDefaultFont(totalReceivedTitleLbl.font.pointSize)
        shippingCostErrorLbl.font = Utils.customDefaultFont(shippingCostErrorLbl.font.pointSize)
        freeCommissionLbl.font = Utils.customDefaultFont(freeCommissionLbl.font.pointSize)

        setOfferTitleLbl.font = Utils.customBoldFont(setOfferTitleLbl.font.pointSize)
        shippingCostCurrencyLbl.font = Utils.customBoldFont(shippingCostCurrencyLbl.font.pointSize)
        commissionValueLbl.font = Utils.customBoldFont(commissionValueLbl.font.pointSize)
        vatValueLbl.font = Utils.customBoldFont(vatValueLbl.font.pointSize)
        shippingCostValueTF.font = Utils.customBoldFont(shippingCostValueTF.font!.pointSize)
        totalReceivedValueLbl.font = Utils.customBoldFont(totalReceivedValueLbl.font!.pointSize)
    }
    
    func setGesture(){
        
        shippingCostValueTF.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        let viewTap = UITapGestureRecognizer(target: self, action: #selector(backAction))
        viewTap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(viewTap)
        
        let offerViewTap = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        offerViewTap.cancelsTouchesInView = false
        setOfferView.addGestureRecognizer(offerViewTap)
        
        let rejectTap = UITapGestureRecognizer(target: self, action: #selector(rejectAction))
        rejectView.addGestureRecognizer(rejectTap)
        
        let rejectLblTap = UITapGestureRecognizer(target: self, action: #selector(rejectAction))
        rejectLbl.addGestureRecognizer(rejectLblTap)
        
        let readyTap = UITapGestureRecognizer(target: self, action: #selector(readyAction))
        readyView.addGestureRecognizer(readyTap)
        
        let readyLblTap = UITapGestureRecognizer(target: self, action: #selector(readyAction))
        readyLbl.addGestureRecognizer(readyLblTap)
    }
    
    func setLocalization(){
        readyLbl.text = "submitOffer".localized()
        rejectLbl.text = "editCancel".localized()
        commissionTitleLbl.text = "offer_Comission".localized()
        setOfferTitleLbl.text = "set_Offer".localized()
        shippingCostTitleLbl.text = "Shipping_cost".localized()
//        vatTitleLbl.text = "VAT".localized()
        shippingCostCurrencyLbl.text = "sar".localized()
        freeCommissionLbl.text = "free_commission_msg".localized()
    }
    
    func setFixedValues(){
        
        distance = distanceToPickup + distanceToDestination
        print("total distance: \(distance)")

        if order.finance_settings != nil{
            if order.finance_settings?.min_mileage_cost != nil{
                let value = Double((order.finance_settings?.min_mileage_cost!)!)
                if value != nil{
                    self.minDistanceValue = value!*distance
                    print("minDistanceValue: \(minDistanceValue)")
                }
            }
            
            if order.finance_settings?.max_mileage_cost != nil{
                let value = Double((order.finance_settings?.max_mileage_cost!)!)
                if value != nil{
                    self.maxDistanceValue = value!*distance
                    print("minDistanceValue: \(maxDistanceValue)")
                }
            }
            
            if order.finance_settings?.min_fixed_cost != nil{
                let value = Double((order.finance_settings?.min_fixed_cost!)!)
                if value != nil{
                    self.minFixedValue = value!
                    print("minFixedValue: \(minFixedValue)")
                    if maxDistanceValue < minFixedValue{ // if max distance value is less than min fixed value take min fixed value
                        self.maxDistanceValue = minFixedValue
                        print("minDistanceValue: \(maxDistanceValue)")
                    }
                }
            }
            
//            if order.finance_settings?.vat_type != nil && order.finance_settings?.vat_value != nil{
//                if Int((order.finance_settings?.vat_type)!) == 0{ //percetange
//                    isVatPersentage = true
//                    vatValueLbl.text = "-"
//                }else if Int((order.finance_settings?.vat_type)!) == 1{ //fixed
//                    isVatPersentage = false
//                    let value = Double((order.finance_settings?.vat_value!)!)
//                    if value != nil{
//                        self.vatFixedValue = value!
//                        self.vatFinalValue = vatFixedValue
//                        self.vatValueLbl.text = getPrice(price: vatFixedValue)
//                    }
//                }
//            }
            
            if order.finance_settings?.commission_type != nil && order.finance_settings?.commission_value != nil{
                if Int((order.finance_settings?.commission_type)!) == 0{ //percetange
                    isComissionPersentage = true
                    commissionValueLbl.text = "-"
                }else if Int((order.finance_settings?.commission_type)!) == 1{ //fixed
                    isComissionPersentage = false
                    let value = Double((order.finance_settings?.commission_value!)!)
                    if value != nil{
                        self.comissionFixedValue = value!
                        self.commissionFinalValue = comissionFixedValue
                        self.commissionValueLbl.text = getPrice(price: comissionFixedValue)
                        if isVatPersentage{
//                            calculateVATValue(comissionValue: comissionFixedValue)
                        }
                    }
                }
            }
        }
        
        //free commission
        if isFreeCommission{
            freeCommissionLbl.isHidden = false
            freeCommissionView.isHidden = false
            freeCommissionHeight.constant = 25
            
            isComissionPersentage = false
            comissionFixedValue = 0
            commissionValueLbl.text = getPrice(price: 0)
            
            //no vat because no commission
//            if isVatPersentage{
//                vatValueLbl.text = getPrice(price: 0)
//                isVatPersentage = false
//                vatFixedValue = 0
//            }
        }else{
            freeCommissionLbl.isHidden = true
            freeCommissionView.isHidden = true
            freeCommissionHeight.constant = 0
        }
    }
    
    func calculateComissionValue(shippingCost: Double){
        if order.finance_settings != nil{
            if order.finance_settings?.commission_type != nil && order.finance_settings?.commission_value != nil{
                if Int((order.finance_settings?.commission_type)!) == 0{ //percetange
                    let persentageValue = Double((order.finance_settings?.commission_value!)!)
                    if persentageValue != nil{
                        let comissionValue = (shippingCost*persentageValue!)/100
                        print("comissionValue: \(comissionValue)")
                        self.commissionFinalValue = comissionValue
                        commissionValueLbl.text = getPrice(price: comissionValue)
                        let total = shippingCost - comissionValue
                        totalReceivedFinalValue = total
                        totalReceivedTitleLbl.text = "willReceive".localized()
                        totalReceivedValueLbl.text = "\(getPrice(price: total))"
                        if isVatPersentage{
//                            calculateVATValue(comissionValue: comissionValue)
                        }
                    }
                }
            }
        }
    }
    
    func calculateVATValue(comissionValue: Double){
        if order.finance_settings != nil{
            if order.finance_settings?.vat_type != nil && order.finance_settings?.vat_value != nil{
                if Int((order.finance_settings?.vat_type)!) == 0{ //percetange
                    let persentageValue = Double((order.finance_settings?.vat_value!)!)
                    if persentageValue != nil{
                        let vatValue = (comissionValue*persentageValue!)/100
                        print("comissionValue: \(vatValue)")
                        vatFinalValue = vatValue
                        vatValueLbl.text = getPrice(price: vatValue)
                    }
                }
            }
        }
    }
    
    func checkShippingCost(){
        let shippingCost = Double(shippingCostValueTF.text!)
        if shippingCost != nil{
            if shippingCost! < minDistanceValue{
                print("set minDistanceValue")
                if minDistanceValue < minFixedValue{  //shipping cost lower than min fixed value to shipping
                    print("set minFixedValue")
                    errorMsg = "\("minOfferError".localized()) \(getPrice(price: minFixedValue))"
                    shippingCostErrorLbl.text = errorMsg
                    if isComissionPersentage{
                        commissionValueLbl.text = "-"
                        totalReceivedTitleLbl.text = ""
                        totalReceivedValueLbl.text = ""
                        if isVatPersentage{
//                            vatValueLbl.text = "-"
                        }
                    }else{
                        totalReceivedTitleLbl.text = ""
                        totalReceivedValueLbl.text = ""
                    }
                    
                }else{ //shipping cost lower than min value to shipping calculating with distance
                    errorMsg = "\("minOfferError".localized()) \(getPrice(price: minDistanceValue))"
                    shippingCostErrorLbl.text = errorMsg
                    if isComissionPersentage{
                        commissionValueLbl.text = "-"
                        totalReceivedTitleLbl.text = ""
                        totalReceivedValueLbl.text = ""
                        if isVatPersentage{
//                            vatValueLbl.text = "-"
                        }
                    }else{
                        totalReceivedTitleLbl.text = ""
                        totalReceivedValueLbl.text = ""
                    }
                }
            }else if shippingCost! > maxDistanceValue{ //shipping cost greater than max value to shipping calculating with distance
                print("set maxDistanceValue")
                errorMsg = "\("maxOfferError".localized()) \(getPrice(price: maxDistanceValue))"
                shippingCostErrorLbl.text = errorMsg
                if isComissionPersentage{
                    commissionValueLbl.text = "-"
                    totalReceivedTitleLbl.text = ""
                    totalReceivedValueLbl.text = ""
                    if isVatPersentage{
//                        vatValueLbl.text = "-"
                    }
                }else{
                    totalReceivedTitleLbl.text = ""
                    totalReceivedValueLbl.text = ""
                }
            }else if shippingCost! < minFixedValue{  //shipping cost lower than min fixed value to shipping
                print("set minFixedValue")
                errorMsg = "\("minOfferError".localized()) \(getPrice(price: minFixedValue))"
                shippingCostErrorLbl.text = errorMsg
                if isComissionPersentage{
                    commissionValueLbl.text = "-"
                    totalReceivedTitleLbl.text = ""
                    totalReceivedValueLbl.text = ""
                    if isVatPersentage{
//                        vatValueLbl.text = "-"
                    }
                }else{
                    totalReceivedTitleLbl.text = ""
                    totalReceivedValueLbl.text = ""
                }
            }else{
                print("set shippingCost") // accepted value
                errorMsg = ""
                shippingCostErrorLbl.text = errorMsg
                if isComissionPersentage{
                    calculateComissionValue(shippingCost: shippingCost!)
                }else{
                    let total = shippingCost! - comissionFixedValue
                    totalReceivedTitleLbl.text = "willReceive".localized()
                    totalReceivedFinalValue = total
                    totalReceivedValueLbl.text = "\(getPrice(price: total))"
                    if isVatPersentage{
//                        calculateVATValue(comissionValue: comissionFixedValue)
                    }
                }
            }
        }else{
            errorMsg = ""
            shippingCostErrorLbl.text = errorMsg
            if isComissionPersentage{
                commissionValueLbl.text = "-"
                totalReceivedTitleLbl.text = ""
                totalReceivedValueLbl.text = ""
                if isVatPersentage{
//                    vatValueLbl.text = "-"
                }
            }else{
                totalReceivedTitleLbl.text = ""
                totalReceivedValueLbl.text = ""
            }
        }
    }
    
    func getDistance(fromLocationLat: Double, fromLocationLng: Double, toLocationLat: Double, toLocationLng: Double)-> Double{
        let location1 = CLLocation(latitude:fromLocationLat , longitude: fromLocationLng)
        let location2 = CLLocation(latitude: toLocationLat, longitude: toLocationLng)
        
        let distanceInMeters = location1.distance(from: location2)
        print("distanceInMeters: \(distanceInMeters)")
        return distanceInMeters/1000
    }
    
    func getPrice(price: Double) -> String{
//        if price.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(price)) \("sar".localized())"
//        }else{
            let priceStr = String(format: "%.2f", price)
            return "\(priceStr) \("sar".localized())"
//        }
    }
    
    @objc func rejectAction(){
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @objc func readyAction(){
        self.view.endEditing(true)
        if errorMsg != ""{
            shippingCostErrorLbl.text = errorMsg
        }else{
            if shippingCostValueTF.text != ""{
                let cost = Double(shippingCostValueTF.text!)
                if cost != nil{
                    var delegateReachedMax = false
                    if let maximumBalance = self.userDefault.getMaximumBalance(){
                        if let balance = userDefault.getUserData().balance {
                            if -balance > maximumBalance{
                                delegateReachedMax = true
                            }
                        }
                    }
                    
                    if delegateReachedMax{
                        Toast.init(text: "maxoffer".localized()).show()
                    }else{
                        delegateSetOfferPresenter.setOffer(id: order.id!, cost: cost!, distanceToPickup: distanceToPickup, distanceToDestination: distanceToDestination, currentLat: currentLocation.latitude, currentLng: currentLocation.longitude)
                    }
                }
            }
        }
    }
    
    @objc func backAction(){
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    @objc func hideKeyboard(){
        self.view.endEditing(true)
    }
}

extension DelegateSetOfferVC : UITextFieldDelegate{
    
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
        checkShippingCost()
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
extension DelegateSetOfferVC: DelegateSetOfferView{
    
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
        Toast(text: msg, duration: Delay.long).show()
    }
    
    func showSuccess() {
        var shippingCost = 0.0
        if Double(shippingCostValueTF.text!) != nil{
            shippingCost = Double(shippingCostValueTF.text!)!
        }
        setOfferDelegate.setOfferSuccessfully(shippingCost: shippingCost, Commission: commissionFinalValue, VAT: vatFinalValue, totalRecieve: totalReceivedFinalValue)
        
        performSegue(withIdentifier: "exit", sender: self)
    }
}
