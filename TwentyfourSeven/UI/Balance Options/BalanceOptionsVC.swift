//
//  BalanceOptionsVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Alamofire
import Foundation
import CryptoSwift
import MBProgressHUD
import Toaster

class BalanceOptionsVC: UIViewController {

    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var minusAmoutLbl: UILabel!
    @IBOutlet weak var amoutLbl: UILabel!
    @IBOutlet weak var paymentSelectionLbl: UILabel!
    
    @IBOutlet weak var visaView: UIView!
    @IBOutlet weak var transferView: UIView!
    @IBOutlet weak var sadadView: UIView!
    
    @IBOutlet weak var sadadLbl: UILabel!
    @IBOutlet weak var visaLbl: UILabel!
    @IBOutlet weak var bankTranferLbl: UILabel!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
  //  let paycontroller = PayFortController.init(enviroment: APIURLs.payFortEnvirnmnet)
    var balanceOptionsPresenter : BalanceOptionsPresenter!
    var loadingView: MBProgressHUD!
    var paymentData = PaymentData()

    override func viewDidLoad() {
        super.viewDidLoad()
        initPresenter()
        setUI()
    }
    
    func initPresenter(){
        balanceOptionsPresenter = BalanceOptionsPresenter( walletRepository: Injection.provideWalletRepository() , userRepository: Injection.provideUserRepository())
        balanceOptionsPresenter.setView(view: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        customizaViews()
        setMinusBalance()
    }
    
    func setUI(){
        setLocalization()
        setFonts()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "addMoney".localized()
        
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
        }else{
            backIcon.image = UIImage(named: "back_ic")
        }
        
    }
    
    func customizaViews(){
        self.visaView.layer.borderWidth = 0.0
        self.sadadView.layer.borderWidth = 0.0
        self.transferView.layer.borderWidth = 0.0
        
        self.visaView.layer.setShadow(opacity : 0.7 , radious :10, shadowColor: UIColor.lightGray.cgColor)
        self.sadadView.layer.setShadow(opacity : 0.7 , radious :10, shadowColor: UIColor.lightGray.cgColor)
        self.transferView.layer.setShadow(opacity : 0.7 , radious :10, shadowColor: UIColor.lightGray.cgColor)
        
        self.visaView.layer.setCornerRadious(radious: 10.0, maskToBounds: false)
        self.sadadView.layer.setCornerRadious(radious: 10.0, maskToBounds: false)
        self.transferView.layer.setCornerRadious(radious: 10.0, maskToBounds: false)
    
    }
    
    func setLocalization(){
        amoutLbl.text = "addMoneyAmout".localized()
        visaLbl.text = "Cerdit_Card".localized()
        sadadLbl.text = "Sadad".localized()
        bankTranferLbl.text = "Bank_Transfer".localized()
        paymentSelectionLbl.text = "paymentSelection".localized()
    }
    
    func setMinusBalance(){
        var money = 0.0
        if let balance = userDefault.getUserData().balance {
            money = balance
        }
        minusAmoutLbl.text = "\(String(format: "%.2f", money)) \("sar".localized())"
    }
    
    func setFonts(){
        amoutLbl.font = Utils.customDefaultFont(amoutLbl.font.pointSize)
        minusAmoutLbl.font = Utils.customDefaultFont(minusAmoutLbl.font.pointSize)
        visaLbl.font = Utils.customDefaultFont(visaLbl.font.pointSize)
        sadadLbl.font = Utils.customDefaultFont(sadadLbl.font.pointSize)
        bankTranferLbl.font = Utils.customDefaultFont(bankTranferLbl.font.pointSize)
        paymentSelectionLbl.font = Utils.customBoldFont(paymentSelectionLbl.font.pointSize)

    }
    
    
    @IBAction func payViaVisa(_ sender: Any) {
        print("payViaVisa")
        customizaViews()
        customizeSelectedView(view: visaView)
        
        if let balance = userDefault.getUserData().balance {
            var amount = balance
            if amount < 0 {
                amount = -(amount)
                if amount > 0{
                    print("amount \(amount)")
                    self.balanceOptionsPresenter.getcheckoutId(amount: amount)
                }
            }
        }
    }
    
    @IBAction func payViaSadad(_ sender: Any) {
        print("payViaSadad")
        customizaViews()
        //customizeSelectedView(view: sadadView)
    }
    
    @IBAction func payViaBankTransfer(_ sender: Any) {
        print("payViaBankTransfer")
        customizaViews()
        customizeSelectedView(view: transferView)
        self.performSegue(withIdentifier: "bankTransfer", sender: self)
    }
    
    func customizeSelectedView(view : UIView){
        view.layer.shadowOpacity = 0.0;
        view.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "#4392f9").cgColor, width: 3)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "webViewSegue"{
            let paymentVC = segue.destination as! PaymentVC
            paymentVC.paymentData = paymentData
        }
    }
}


extension BalanceOptionsVC{
    
}

//extension BalanceOptionsVC{
//
//    func initializePayFortRequest(){
//        balanceOptionsPresenter.getcheckoutId()
//
//    }
//
//
//    func createApiRequestForInitPayment() {
//
//        do {
//            let bodyDict:[String:Any] = getRequestBody()
//            let jsonData = try JSONSerialization.data(withJSONObject: bodyDict, options: .prettyPrinted)
////
////
////            let request: URLRequest = HttpRequest.prepareHttpRequestWith(headers:nil,
////                                                                         body:jsonData,
////                                                                         apiUrlStr:APIURLs.payFortTest,
////                                                                         method:HttpMethod.POST)
//
////            Alamofire.request(APIURLs.payFortTest, method: .post, parameters: bodyDict, encoding: JSONEncoding.default, headers: nil).responseJSON { (result) in
////                print(result)
////                self.createPaymentApiRequest(response: result.result.value)
////            }
//
//
//        } catch let error as NSError {
//            print(error.localizedDescription)
//        }
//
//    }
//
//    func getRequestBody() -> [String:Any] {
//        let payloadDict = NSMutableDictionary()
//        payloadDict.setValue("en", forKey:"language" )
//        payloadDict.setValue("cjXYnVPO", forKey: "merchant_identifier")
//        payloadDict.setValue("QSCsH5s50WseQ5BWx8OA", forKey:"access_code" )
//        payloadDict.setValue("SDK_TOKEN", forKey:"service_command" )
//
//        let deviceID = UIDevice.current.identifierForVendor!.uuidString
//        payloadDict.setValue(deviceID, forKey:"device_id")
//
//        let paymentString = "TESTSHAINaccess_code=QSCsH5s50WseQ5BWx8OAdevice_id=\(deviceID)language=enmerchant_identifier=cjXYnVPOservice_command=SDK_TOKENTESTSHAIN"
//
//
//        let base64Str = paymentString.sha256()
//        payloadDict.setValue(base64Str, forKey:"signature")
//
//        return payloadDict as! [String : Any]
//
//    }
//
//
//
//    func createPaymentApiRequest(response:Any?) {
//        if (response != nil) {
//            let responseDict = response as! NSDictionary
//            let tokenStr = responseDict["sdk_token"] as! String
//            let marchantRefStr = responseDict["merchant_identifier"] as! String
//
//            let payloadDict = NSMutableDictionary.init()
//            payloadDict.setValue(tokenStr , forKey: "sdk_token")
//            //Payfort takes amounts in cents. So if you want $20.50, pass through the value of:
//            //Payfort takes Integers no float
//            payloadDict.setValue("100", forKey: "amount")
//            payloadDict.setValue("AUTHORIZATION", forKey: "command")
//            payloadDict.setValue("AED", forKey: "currency")
//            payloadDict.setValue("abcxxxx@group.com", forKey: "customer_email")
//            payloadDict.setValue("en", forKey: "language")
//            payloadDict.setValue(marchantRefStr, forKey: "merchant_reference")
//            payloadDict.setValue("SADAD" , forKey: "payment_option")
//          //  payloadDict.setValue("SABBP2P_UAT2" , forKey: "sadad_olp")
//
//
////            paycontroller?.callPayFort(withRequest: payloadDict, currentViewController: self,
////                                       success: { (requestDic, responeDic) in
////
////                                        print("Success:\(String(describing: responeDic))")
////
////            },
////                                       canceled: { (requestDic, responeDic) in
////
////                                        print("Canceled:\(String(describing: responeDic))")
////
////            },
////                                       faild: { (requestDic, responeDic, message) in
////
////                                        print("Failure:\(String(describing: responeDic))")
////                                        print("Failure message:\(String(describing: message))")
////
////            })
//        }
//    }
//
//
//
//}

extension BalanceOptionsVC : BalanceOptionsView{
    
    func showLoading() {
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
  
    
    func presentCheckoutUI(paymentData : PaymentData){
        
        
        let provider = OPPPaymentProvider(mode: OPPProviderMode.test)

        let checkoutSettings = OPPCheckoutSettings()
        
        // Set available payment brands for your shop
        checkoutSettings.paymentBrands = ["VISA", "DIRECTDEBIT_SEPA"]
        checkoutSettings.shopperResultURL = "com.amaz.TwentyfourSeven.payments://result"

        // Set shopper result URL
        let checkoutProvider = OPPCheckoutProvider(paymentProvider: provider, checkoutID: paymentData.checkout_id ?? "", settings: checkoutSettings)
        
        checkoutProvider!.presentCheckout(forSubmittingTransactionCompletionHandler: { (transaction, error) in
            
            print("transation \(String(describing: transaction?.redirectURL)) \(String(describing: transaction?.resourcePath))")
            guard let transaction = transaction else {
                // Handle invalid transaction, check error
                return
            }
            
            if transaction.type == .synchronous {
                // If a transaction is synchronous, just request the payment status
                // You can use transaction.resourcePath or just checkout ID to do it
                print("transaction.type == .synchronous")
            } else if transaction.type == .asynchronous {
                // The SDK opens transaction.redirectUrl in a browser
                // See 'Asynchronous Payments' guide for more details
                print("transaction.type == .asynchronous")
            } else {
                print("else ")
                // Executed in case of failure of the transaction for any reason
            }
        }, cancelHandler: {
            self.customizaViews()
            // Executed if the shopper closes the payment page prematurely
        })

        
    }
    
    func showPaymentInfoForum(paymentData : PaymentData){
        self.paymentData = paymentData
        self.performSegue(withIdentifier: "webViewSegue", sender: self)
    }
    
    
}
