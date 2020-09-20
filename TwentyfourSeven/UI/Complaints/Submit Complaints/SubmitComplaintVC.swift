//
//  SubmitComplaintVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 3/24/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD
import GrowingTextView

class SubmitComplaintVC: UIViewController {

    @IBOutlet weak var backIcon: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var orderNoTitleLbl: UILabel!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var orderNoView: UIView!

    @IBOutlet weak var complaintTitleLbl: UILabel!
    @IBOutlet weak var complaintTV: UITextView!
    @IBOutlet weak var complaintView: UIView!
    
    @IBOutlet weak var descriptionTitleLbl: UILabel!
    @IBOutlet weak var descriptionTV: GrowingTextView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var descriptionViewHeight: NSLayoutConstraint!

    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var coveredView: UIView!

    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var id = 0
    var submitComplaintPresenter : SubmitComplaintPresenter!
    var complaintDelegate: ComplaintDelegate!
    var deviceManager = DeviceManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        submitComplaintPresenter = SubmitComplaintPresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        submitComplaintPresenter.setView(view: self)
        setUI()
    }
    

    func setUI(){
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: Utils.customBoldFont(17), NSAttributedString.Key.foregroundColor: UIColor.white]
        self.navigationController?.navigationBar.barStyle = .blackOpaque
        self.navigationItem.title = "complaint_title".localized()
        
        setCornerRadius(selectedView: orderNoView, radius: 11)
        setCornerRadius(selectedView: complaintView, radius: 10)
        setCornerRadius(selectedView: descriptionView, radius: 10)
        setCornerRadius(selectedView: submitView, radius: 10)
        setCornerRadius(selectedView: coveredView, radius: 10)
        setShadow(selectedView: complaintView)
        setShadow(selectedView: descriptionView)
        
        complaintTV.delegate = self
        descriptionTV.delegate = self
        
        complaintTV.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
        descriptionTV.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
        
        if deviceManager.getDeviceName() == "iPhone5"{
            descriptionTV.maxHeight = 120
        }else if deviceManager.getDeviceName() == "iPhone6"{
            descriptionTV.maxHeight = 240
        }else{
            descriptionTV.maxHeight = 270
        }
        
        if appDelegate.isRTL{
            backIcon.image = UIImage(named: "back_ar_ic")
            complaintTV.textAlignment = .right
            descriptionTV.textAlignment = .right
        }else{
            backIcon.image = UIImage(named: "back_ic")
            complaintTV.textAlignment = .left
            descriptionTV.textAlignment = .left
        }
        
        orderNoLbl.text = "\(id)"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        setFonts()
        setLocalization()
    }
    
    func setFonts(){
        orderNoTitleLbl.font = Utils.customDefaultFont(orderNoTitleLbl.font.pointSize)
        orderNoLbl.font = Utils.customDefaultFont(orderNoLbl.font.pointSize)
        complaintTitleLbl.font = Utils.customDefaultFont(complaintTitleLbl.font.pointSize)
        complaintTV.font = Utils.customDefaultFont(complaintTV.font!.pointSize)
        descriptionTitleLbl.font = Utils.customDefaultFont(descriptionTitleLbl.font.pointSize)
        descriptionTV.font = Utils.customDefaultFont(descriptionTV.font!.pointSize)
        submitLbl.font = Utils.customDefaultFont(submitLbl.font.pointSize)
    }
    
    func setLocalization(){
        complaintTV.text = "complaint_name".localized()
        descriptionTV.text = "complaint_desc".localized()
        complaintTitleLbl.text = "complaint_name_title".localized()
        descriptionTitleLbl.text = "complaint_desc_title".localized()
        orderNoTitleLbl.text = "complaint_order_no".localized()
        submitLbl.text = "complaint_submit".localized()
    }
    
    func setCornerRadius(selectedView : UIView, radius: CGFloat){
        selectedView.layer.cornerRadius = radius
        selectedView.layer.masksToBounds = true
        selectedView.clipsToBounds = true
    }
    
    func setShadow(selectedView : UIView){
        selectedView.layer.borderColor = Colors.hexStringToUIColor(hex: "#EDEDED").cgColor
        selectedView.layer.borderWidth = 0
        selectedView.layer.masksToBounds = false
        selectedView.layer.shadowOffset = CGSize(width: 1, height: 1)
        selectedView.layer.shadowRadius = 1
        selectedView.layer.shadowOpacity = 0.1
    }
    
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            var userInfo = notification.userInfo!
            var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            var contentInset:UIEdgeInsets = self.scrollView.contentInset
            contentInset.bottom = keyboardFrame.size.height
            scrollView.contentInset = contentInset
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
    }
    
    func checkValidation(){
        if complaintTV.text != "" && complaintTV.text != "complaint_name".localized() && descriptionTV.text != "" && descriptionTV.text != "complaint_desc".localized(){
            coveredView.isHidden = true
        }else{
            coveredView.isHidden = false
        }
    }
    
    
    @IBAction func hideKeyboard(){
        print("hideKeyboard")
        self.view.endEditing(true)
    }
    
    @IBAction func submitAction(){
        print("submitAction")
        self.view.endEditing(true)
        if coveredView.isHidden{ 
            var title = ""
            var desc = ""
            if complaintTV.text != "" && complaintTV.text != "complaint_name".localized(){
                title = complaintTV.text
            }
            
            if descriptionTV.text != "" && descriptionTV.text != "complaint_desc".localized(){
                desc = descriptionTV.text
            }
            
            submitComplaintPresenter.submitComplaint(id: id, title: title, desc: desc)
        }
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.view.endEditing(true)
        complaintDelegate.backComplaintsPressed()
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toMyComplaints"{
            let nav = segue.destination as! UINavigationController
            let vc = nav.topViewController as! MyComplaintsVC
            vc.isFromSubmit = true
            vc.complaintDelegate = self
        }
    }
}
extension SubmitComplaintVC: GrowingTextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView == complaintTV{
            if textView.text == "complaint_name".localized() {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }else if textView == descriptionTV{
            if textView.text == "complaint_desc".localized() {
                textView.text = nil
                textView.textColor = UIColor.black
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
        
        if textView.text.isEmpty {
            if textView == complaintTV{
                textView.text = "complaint_name".localized()
                textView.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
            }else if textView == descriptionTV{
                textView.text = "complaint_desc".localized()
                textView.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        checkValidation()
    }
    
    func textViewDidChangeHeight(_ textView: GrowingTextView, height: CGFloat) {
        if textView == descriptionTV{
            if height > 120{
                UIView.animate(withDuration: 0.2) {
                    print(height)
                    self.descriptionViewHeight.constant = height + 30
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count // for Swift use count(newText)
        if textView == complaintTV{
            return numberOfChars <= 30
        }else{
            return numberOfChars <= 512
        }
    }
}
extension SubmitComplaintVC: SubmitComplainView{
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
    
    func showSuccess(){
        Toast.init(text: "complaint_success".localized()).show()
        performSegue(withIdentifier: "toMyComplaints", sender: self)
    }
}

extension SubmitComplaintVC: ComplaintDelegate{
    func backComplaintsPressed() {
        complaintDelegate.backComplaintsPressed()
        dismiss(animated: true, completion: nil)
    }
}
