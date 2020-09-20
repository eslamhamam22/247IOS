//
//  ConfirmDeliveryVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class ConfirmDeliveryVC: UIViewController {

    @IBOutlet weak var deliverView: UIView!
    @IBOutlet weak var deliverTitleLbl: UILabel!
    @IBOutlet weak var deliverNoteLbl: UILabel!
    @IBOutlet weak var acceptedOfferViewTop: NSLayoutConstraint!

    @IBOutlet weak var itemPriceTitleLbl: UILabel!
    @IBOutlet weak var itemPriceValueLbl: UILabel!
    @IBOutlet weak var itemPriceView: UIView!
    
    @IBOutlet weak var shippingCostTitleLbl: UILabel!
    @IBOutlet weak var shippingCostValueLbl: UILabel!

    @IBOutlet weak var vatTitleLbl: UILabel!
    @IBOutlet weak var vatValueLbl: UILabel!
    
    @IBOutlet weak var discountTitleLbl: UILabel!
    @IBOutlet weak var discountValueLbl: UILabel!
    @IBOutlet weak var discountView: UIView!
    @IBOutlet weak var discountTop: NSLayoutConstraint!
    @IBOutlet weak var discountBottom: NSLayoutConstraint!

    @IBOutlet weak var totalCostTitleLbl: UILabel!
    @IBOutlet weak var totalCostValueLbl: UILabel!
    
    @IBOutlet weak var yesLbl: UILabel!
    @IBOutlet weak var yesView: UIView!
    @IBOutlet weak var noLbl: UILabel!
    @IBOutlet weak var noView: UIView!
    
    var order = Order()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var confirmDeliveryPresenter: ConfirmDeliveryPresenter!
    var loadingView: MBProgressHUD!

    override func viewDidLoad() {
        super.viewDidLoad()

        confirmDeliveryPresenter = ConfirmDeliveryPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        confirmDeliveryPresenter.setView(view: self)
        
        setUI()
        setFonts()
        setLocalization()
        setOrderData()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        setCornerRadius(selectedView: deliverView, radius: 12)
        setCornerRadius(selectedView: yesView, radius: 10)
        setCornerRadius(selectedView: noView, radius: 10)
        
        //hide vat
        vatTitleLbl.text = ""
        vatValueLbl.text = ""
        vatTitleLbl.isHidden = true
        vatValueLbl.isHidden = true
    }

    func setOrderData(){
        var totalValue = 0.0
        
        if order.delivery_price != nil{
            shippingCostValueLbl.text = getPrice(price: order.delivery_price!)
            totalValue = order.delivery_price!
        }else{
            //no offer
            shippingCostValueLbl.text = ""
        }
        
//        if order.vat != nil{
//            vatValueLbl.text = getPrice(price: order.vat!)
//            totalValue += order.vat!
//        }else{
//            vatValueLbl.text = "-"
//        }
        
        if order.discount != nil{
            if order.discount != 0{
                discountValueLbl.text = getPrice(price: order.discount!)
                totalValue -= order.discount!
            }else{
               hideDiscountField()
            }
        }else{
            hideDiscountField()
        }
        
        if order.item_price != nil{
            // view item price
            itemPriceValueLbl.text = getPrice(price: order.item_price!)
            totalValue += order.item_price!
            itemPriceTitleLbl.isHidden = false
            itemPriceValueLbl.isHidden = false
            itemPriceView.isHidden = false
            if appDelegate.isRTL{
                acceptedOfferViewTop.constant = 53
            }else{
                acceptedOfferViewTop.constant = 48
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
        
        totalCostValueLbl.text = getPrice(price: totalValue)
    }
    
    func hideDiscountField(){
        discountValueLbl.isHidden = true
        discountTitleLbl.isHidden = true
        discountView.isHidden = true
//        discountTop.constant = 0
        discountBottom.constant = 0
        discountTitleLbl.text = ""
        discountValueLbl.text = ""
    }
    
    func setFonts(){
        deliverNoteLbl.font = Utils.customDefaultFont(deliverNoteLbl.font.pointSize)
        itemPriceTitleLbl.font = Utils.customDefaultFont(itemPriceTitleLbl.font.pointSize)
        shippingCostTitleLbl.font = Utils.customDefaultFont(shippingCostTitleLbl.font.pointSize)
        vatTitleLbl.font = Utils.customDefaultFont(vatTitleLbl.font.pointSize)
        discountTitleLbl.font = Utils.customDefaultFont(discountTitleLbl.font.pointSize)
        totalCostTitleLbl.font = Utils.customDefaultFont(totalCostTitleLbl.font.pointSize)
        yesLbl.font = Utils.customDefaultFont(yesLbl.font.pointSize)
        noLbl.font = Utils.customDefaultFont(noLbl.font.pointSize)
        
        deliverTitleLbl.font = Utils.customBoldFont(deliverTitleLbl.font.pointSize)
        itemPriceValueLbl.font = Utils.customBoldFont(itemPriceValueLbl.font.pointSize)
        itemPriceValueLbl.font = Utils.customBoldFont(itemPriceValueLbl.font.pointSize)
        shippingCostValueLbl.font = Utils.customBoldFont(shippingCostValueLbl.font.pointSize)
        vatValueLbl.font = Utils.customBoldFont(vatValueLbl.font.pointSize)
        totalCostValueLbl.font = Utils.customBoldFont(totalCostValueLbl.font!.pointSize)
        discountValueLbl.font = Utils.customBoldFont(discountValueLbl.font!.pointSize)
    }
    
    func setLocalization(){
        deliverTitleLbl.text = "deliver_order".localized()
        deliverNoteLbl.text = "deliver_order_note".localized()
        
        itemPriceTitleLbl.text = "item_price".localized()
        shippingCostTitleLbl.text = "Shipping_cost".localized()
//        vatTitleLbl.text = "VAT".localized()
        totalCostTitleLbl.text = "totalOffer".localized()
        discountTitleLbl.text = "discount".localized()

        yesLbl.text = "delivered_action".localized()
        noLbl.text = "not_yet".localized()
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func getPrice(price: Double) -> String{
//        if price.truncatingRemainder(dividingBy: 1) == 0 {
//            return "\(Int(price)) \("sar".localized())"
//        }else{
            let priceStr = String(format: "%.2f", price)
            return "\(priceStr) \("sar".localized())"
//        }
    }
    
    @IBAction func confirmAction(){
        if order.id != nil{
            confirmDeliveryPresenter.completeRide(orderID: order.id!)
        }
    }
    
    @IBAction func orderOfferAction(){
    }
    
    @IBAction func backAction(){
        performSegue(withIdentifier: "exit", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDelegateOrderDetails"{
            let navigationVC = segue.destination as! UINavigationController
            let vc = navigationVC.topViewController as! DelegateOrderDetailsVC
            if order.id != nil{
                vc.orderID = self.order.id!
            }
            vc.isFromDeliverOrder = true
        }
    }
}
    
extension ConfirmDeliveryVC: ConfirmDeliveryView{
    
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
        self.appDelegate.myOrdersNeedUpdate = true
        self.appDelegate.currentOrdersNeedUpdate = true
        performSegue(withIdentifier: "toDelegateOrderDetails", sender: self)
    }
    
    
}
