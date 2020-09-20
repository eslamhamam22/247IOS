//
//  RateVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 2/28/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Toaster
import MBProgressHUD

class RateVC: UIViewController {

    @IBOutlet weak var closeImg: UIImageView!
    @IBOutlet weak var rateView: UIView!
    @IBOutlet weak var rateViewCenter: NSLayoutConstraint!

    @IBOutlet weak var rateTitleLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!

    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentTV: UITextView!

    @IBOutlet weak var emojisLbl: UILabel!
    @IBOutlet weak var firstEmojiImg: UIImageView!
    @IBOutlet weak var secondEmojiImg: UIImageView!
    @IBOutlet weak var thirdEmojiImg: UIImageView!
    @IBOutlet weak var forthEmojiImg: UIImageView!
    @IBOutlet weak var fifthEmojiImg: UIImageView!
    @IBOutlet weak var coloredLineImg: UIImageView!

    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var submitLbl: UILabel!
    @IBOutlet weak var coveredView: UIView!

    var loadingView: MBProgressHUD!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedRate = 0
    var ratePresenter : RatePresenter!
    var order = Order()
    
    // if user rate his delegate = true ..  if delegate rate the user = false
    var isUserRateDelegate = false
    var rateOrderDelegate: RateOrderDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ratePresenter = RatePresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        ratePresenter.setView(view: self)
        setUI()
        setFonts()
        setLocalization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func setUI(){
        
        setCornerRadius(selectedView: rateView, radius: 12)
        setShadow(selectedView: rateView)
        setCornerRadius(selectedView: commentView, radius: 10)
        setShadow(selectedView: commentView)
        setCornerRadius(selectedView: profileImg, radius: 12)
        setCornerRadius(selectedView: submitView, radius: 10)
        setCornerRadius(selectedView: coveredView, radius: 10)

        commentTV.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")

        if(appDelegate.isRTL){
            self.commentTV.textAlignment = .right
            coloredLineImg.transform = CGAffineTransform(scaleX: -1, y: 1)
        }else{
            self.commentTV.textAlignment = .left
        }
        coveredView.isHidden = false
        commentTV.delegate = self
        setOrderData()
        resetEmojis()
    }
    
    func setFonts(){
        
        rateTitleLbl.font = Utils.customDefaultFont(rateTitleLbl.font.pointSize)
        nameLbl.font = Utils.customDefaultFont(nameLbl.font.pointSize)
        commentTV.font = Utils.customDefaultFont(commentTV.font!.pointSize)
        submitLbl.font = Utils.customDefaultFont(submitLbl.font.pointSize)
        emojisLbl.font = Utils.customDefaultFont(emojisLbl.font.pointSize)
    }
    
    func setLocalization(){
        
        if isUserRateDelegate{ // delegate rate
            rateTitleLbl.text = "review_driver_title".localized()
            emojisLbl.text = "review_driver".localized()
        }else{
            rateTitleLbl.text = "review_customer_title".localized()
            emojisLbl.text = "review_customer".localized()
        }
        submitLbl.text = "submit_rate".localized()
        commentTV.text = "rate_placeholder".localized()
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
    
    func setOrderData(){
        if isUserRateDelegate {
            //set delegate data
            setDelegateData()
        }else{
            //set user data
            setUserData()
        }
    }
    
    
    func setDelegateData(){
        var delegateData = DelegateData()
        
        if order.delegate != nil{
            delegateData = order.delegate!
        }
        
        if delegateData.name != nil{
            nameLbl.text = delegateData.name
        }else{
            nameLbl.text = ""
        }
        
        profileImg.image = UIImage(named: "avatar")
        if delegateData.image != nil{
            if delegateData.image?.medium != nil{
                let url = URL(string: (delegateData.image?.medium)!)
                print("url \(String(describing: url))")
                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
    }
    
    func setUserData(){
        var userData = UserData()
        
        if order.user != nil{
            userData = order.user!
        }
        
        if userData.name != nil{
            nameLbl.text = userData.name
        }else{
            nameLbl.text = ""
        }
        
        profileImg.image = UIImage(named: "avatar")
        if userData.image != nil{
            if userData.image?.medium != nil{
                let url = URL(string: (userData.image?.medium)!)
                print("url \(String(describing: url))")
                self.profileImg.kf.setImage(with: url, placeholder: UIImage(named: "avatar"))
            }
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            rateViewCenter.constant = -20
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.view.layoutIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        rateViewCenter.constant = 0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
    
    @IBAction func hideKeyboard(){
        self.view.endEditing(true)
    }
    
    // emojis actions
    @IBAction func firstEmojiPressed(_ sender: Any) {
        resetEmojis()
        firstEmojiImg.image = UIImage(named: "sad")
        self.selectedRate = 1
        coveredView.isHidden = true
    }
    
    @IBAction func secondEmojiPressed(_ sender: Any) {
        resetEmojis()
        secondEmojiImg.image = UIImage(named: "subtraction_18")
        self.selectedRate = 2
        coveredView.isHidden = true
    }
    
    @IBAction func thirdEmojiPressed(_ sender: Any) {
        resetEmojis()
        thirdEmojiImg.image = UIImage(named: "meh")
        self.selectedRate = 3
        coveredView.isHidden = true
    }
    
    @IBAction func forthEmojiPressed(_ sender: Any) {
        resetEmojis()
        forthEmojiImg.image = UIImage(named: "smile_(1)")
        self.selectedRate = 4
        coveredView.isHidden = true
    }
    
    @IBAction func fifthEmojiPressed(_ sender: Any) {
        resetEmojis()
        fifthEmojiImg.image = UIImage(named: "smile_(1)-2")
        self.selectedRate = 5
        coveredView.isHidden = true
    }
    
    @IBAction func submitRate(){
        self.view.endEditing(true)
        if selectedRate != 0{
            var comment = ""
            if commentTV.text != "" && commentTV.text != "rate_placeholder".localized(){
                comment = commentTV.text
            }
            
            if isUserRateDelegate{
                if order.id != nil{
                    ratePresenter.rateDelegate(orderId: order.id!, rating: selectedRate, comment: comment)
                }
            }else{
                if order.id != nil{
                    ratePresenter.rateCustomer(orderId: order.id!, rating: selectedRate, comment: comment)
                }
            }
//        }else{
//            Toast.init(text: "add_rate_error".localized()).show()
        }
    }
    
    @IBAction func closeAction(){
        self.view.endEditing(true)
       performSegue(withIdentifier: "exit", sender: self)
    }
    
    
    func resetEmojis(){
        self.view.endEditing(true)
        
        firstEmojiImg.image = UIImage(named: "sad-1")
        secondEmojiImg.image = UIImage(named: "subtraction_22")
        thirdEmojiImg.image = UIImage(named: "meh-1")
        forthEmojiImg.image = UIImage(named: "smile_(1)-1")
        fifthEmojiImg.image = UIImage(named: "smile_(1)-3")
    }
}
extension RateVC: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "rate_placeholder".localized() {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        view.endEditing(true)
        if textView.text.isEmpty {
            textView.text = "rate_placeholder".localized()
            textView.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")
        }
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//    }
//
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
//        let numberOfChars = newText.count // for Swift use count(newText)
//        return numberOfChars <= 255
//    }
}
extension RateVC: RateView{
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
        performSegue(withIdentifier: "exit", sender: self)
        rateOrderDelegate.rateOrderSuccessfully(order: order)
    }
    
}
