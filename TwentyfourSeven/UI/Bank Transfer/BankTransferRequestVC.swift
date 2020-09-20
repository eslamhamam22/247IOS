//
//  BankTransferRequestVC.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/21/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import MBProgressHUD
import Toaster
import DropDown


class BankTransferRequestVC: UIViewController {

    @IBOutlet weak var bank_icon: UIBarButtonItem!
    @IBOutlet weak var bankTransferLbl: UILabel!
    @IBOutlet weak var bankTransferView: UIView!
    
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var attachDocumentLbl: UILabel!
    @IBOutlet weak var transferDocumentView: UIView!
    @IBOutlet weak var transferDocumentLbl: UILabel!
    @IBOutlet weak var bankName: UILabel!
    @IBOutlet weak var bankAccountView: UIView!
    @IBOutlet weak var transferred_toLbl: UILabel!
    
    @IBOutlet weak var bankAmount: UITextField!
    @IBOutlet weak var documentDeleteImg: UIImageView!
    @IBOutlet weak var documentImg: UIImageView!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var submitView: UIView!
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var loadingView: MBProgressHUD!
    var photosManager = PhotosManager()
    var accounts = [BankAccount]()
    var accountsNames = [String]()
    let accountsDropDwon = DropDown()
    var bankSelected = false
    var attachmentUploaded = false
    var amountAdded = false

    var selectedBank = BankAccount()
    var imageFile: UIImage!
    var mimeType = ""
    var bankTransferRequestPresenter : BankTransferRequestPresenter!

    override func viewDidLoad() {
        initPresenter()
        setUI()
        accountsNames = accounts.map{$0.bank_name ?? ""}

    }
    
    
    func initPresenter(){
        bankTransferRequestPresenter = BankTransferRequestPresenter(userRepository: Injection.provideUserRepository(), walletRepository: Injection.provideWalletRepository())
        bankTransferRequestPresenter.setView(view: self)
    }

    func setUI(){
        controlUploadDocumentVisibility(visible: true)
        checkUserInputs()

        setLocalization()
        setFonts()
    
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "Submit_transaction".localized()
        
        if appDelegate.isRTL{
            bank_icon.image = UIImage(named: "back_ar_ic")
            bankAmount.textAlignment = .right
        }else{
            bank_icon.image = UIImage(named: "back_ic")
            bankAmount.textAlignment = .left
        }
        

        bankTransferView.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "bcc5d3").cgColor, width: 0.5)
       // bankAccountView.layer.setBorder(borderColor: Colors.hexStringToUIColor(hex: "bcc5d3").cgColor, width: 0.5)
        bankAccountView.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)
        bankAccountView.layer.setCornerRadious(radious: 10, maskToBounds: false)
        bankAmount.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)
        bankAmount.layer.setCornerRadious(radious: 10, maskToBounds: false)
        submitView.layer.setCornerRadious(radious: 10, maskToBounds: true)
        transferDocumentView.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)
        transferDocumentView.layer.setCornerRadious(radious: 10, maskToBounds: false)
        
       customizeTextField()

    }
    
    func customizeTextField(){
        //add padding to text field
        bankAmount.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: bankAmount.frame.height))
        bankAmount.leftViewMode = .always
        bankAmount.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: bankAmount.frame.height))
        bankAmount.rightViewMode = .always
        bankAmount.delegate = self
        bankAmount.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        textField.text = textField.text?.replacedArabicDigitsWithEnglish
    }
    
    func setLocalization(){
        bankTransferLbl.text = "Bank_Submition".localized()
        transferred_toLbl.text = "Transferred_to".localized()
        bankName.text = "Choose_Bank".localized()
        transferDocumentLbl.text = "Transfer_document".localized()
        attachDocumentLbl.text = "Attach_document".localized()
        submitLbl.text = "bank_submit".localized()
        amountLbl.text = "amount".localized()
    }
    
    func setFonts(){
        bankTransferLbl.font = Utils.customDefaultFont(bankTransferLbl.font.pointSize)
        transferred_toLbl.font = Utils.customBoldFont(transferred_toLbl.font.pointSize)
        bankName.font = Utils.customBoldFont(bankName.font.pointSize)
        transferDocumentLbl.font = Utils.customBoldFont(transferDocumentLbl.font.pointSize)
        attachDocumentLbl.font = Utils.customBoldFont(attachDocumentLbl.font.pointSize)
        submitLbl.font = Utils.customBoldFont(submitLbl.font.pointSize)
        amountLbl.font = Utils.customBoldFont(amountLbl.font.pointSize)
    }

    @IBAction func showBankAccounts(_ sender: Any) {
        self.view.endEditing(true)
        accountsDropDwon.anchorView = bankAccountView
        accountsDropDwon.bottomOffset = CGPoint(x: 0, y:(accountsDropDwon.anchorView?.plainView.bounds.height)!)
        accountsDropDwon.dataSource = self.accountsNames
        setDropDown()
        accountsDropDwon.show()
        
    }
    
    func setDropDown() {
        accountsDropDwon.direction = .bottom
        
        if appDelegate.isRTL {
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            accountsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .right
            }
        }else{
            DropDown.appearance().semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            accountsDropDwon.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
                cell.optionLabel.textAlignment = .left
            }
        }
        
        
        accountsDropDwon.selectionAction = { [unowned self] (index: Int, item: String) in
            self.bankSelected = true
            self.selectedBank = self.accounts[index]
            self.bankName.text = self.accountsNames[index]
            self.bankName.textColor = Colors.hexStringToUIColor(hex: "212121")

            self.checkUserInputs()
        }
        
    }
    
    func checkUserInputs(){
        if bankSelected && attachmentUploaded && amountAdded{
            self.submitView.backgroundColor = Colors.hexStringToUIColor(hex: "E84450").withAlphaComponent(1)
        }else{
            self.submitView.backgroundColor = Colors.hexStringToUIColor(hex: "E84450").withAlphaComponent(0.5)
        }
    }
    
    @IBAction func processBankTransfer(_ sender: Any) {
        if bankSelected && attachmentUploaded && amountAdded{
            self.view.endEditing(true)
            print("processBankTransfer")
            if self.bankAmount.text != nil && imageFile != nil && self.selectedBank.id != nil{
                if Double(self.bankAmount.text!) != nil{
                    self.bankTransferRequestPresenter.performBankTransfer(amount: Double(self.bankAmount.text!)!, imageFile: self.imageFile!, bankId: self.selectedBank.id! )
                }
            }
        }
    }
 
    @IBAction func hideKeyboard(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @IBAction func uploadDocument(_ sender: Any) {
        photosManager.loadPrescriptionPic(tabBarBtnAction: true)
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
            self.attachmentUploaded = true
            self.documentImg.image = imageFile
            self.controlUploadDocumentVisibility(visible: false)
            self.checkUserInputs()

            //self.performSegue(withIdentifier: "ImageSelectionPreview", sender: self)
        }
    }

    func controlUploadDocumentVisibility(visible : Bool){
        if visible{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.documentImg.isHidden = true
                self.documentDeleteImg.isHidden = true
                self.transferDocumentView.isHidden = false
            })
          
        }else{
            UIView.animate(withDuration: 0.2, animations: { () -> Void in
                self.documentImg.isHidden = false
                self.documentDeleteImg.isHidden = false
                self.transferDocumentView.isHidden = true
            })
          
        }
    }
    
    @IBAction func deleteUploadedImg(_ sender: Any) {
        self.attachmentUploaded = false
        self.checkUserInputs()
        controlUploadDocumentVisibility(visible: true)
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "account"{
            let tabBarView = segue.destination as! UserTabBar
            tabBarView.selectedIndex = 3
        }
    }
}

extension BankTransferRequestVC : UITextFieldDelegate{
    

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        print("shouldChangeCharactersIn")
        let updatedString = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        if updatedString != nil{
            print(updatedString!)
            self.amountAdded = !updatedString!.isEmpty
        }
        checkUserInputs()
        return true
    }
}

extension BankTransferRequestVC : BankTransferRequestView{
    
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
    
    func transferredSuccessfully(){
        print("transferredSuccessfully")
        Toast.init(text: "transfer_success".localized()).show()
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.presentingViewController?.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        })
    }
}
