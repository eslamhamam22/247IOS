//
//  ViewFullImageVC.swift
//  TwentyfourSeven
//
//  Created by Salma  on 1/9/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Kingfisher
import MBProgressHUD
import Toaster

class ViewFullImageVC: UIViewController {

    @IBOutlet weak var sendBtn: UIImageView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var closeImg: UIImageView!
    
    var image = Image()
    var imageUrl = ""
    var showSendBtn = false
    
    var imageFile: UIImage!
    var mimeType = ""
    var loadingView: MBProgressHUD!
    var viewFullImagePresenter : ViewFullImagePresenter!
    var orderId = 0 
    weak var imageDelegate : ImageDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sendBtn.isHidden = !showSendBtn
        //sendBtn.layer.setShadow(opacity : 0.7 , radious :5, shadowColor: UIColor.lightGray.cgColor)
        //sendBtn.clipsToBounds = true
        
        if !showSendBtn {
            if imageUrl == ""{
                if image.medium != nil{
                    let url = URL(string: (image.medium)!)
                    print("url \(String(describing: url))")
                    imageView.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
                }
            }else{
                if !imageUrl.starts(with: APIURLs.MAIN_URL){
                    let url = URL(string: "\(APIURLs.MAIN_URL)\(imageUrl)")
                    print("url \(String(describing: url))")
                    imageView.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
                }else{
                    let url = URL(string: "\(imageUrl)")
                    print("url \(String(describing: url))")
                    imageView.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
                }
            }
        }else{
            initPresenter()
            if imageFile != nil{
                imageView.image = imageFile
            }
        }
        
        let closeTab = UITapGestureRecognizer(target: self, action: #selector(self.backPressed))
        closeImg.addGestureRecognizer(closeTab)
    }
    
    func initPresenter(){
        viewFullImagePresenter = ViewFullImagePresenter(repository: Injection.provideOrderRepository(), userRepository: Injection.provideUserRepository())
        viewFullImagePresenter.setView(view: self)
    }
    
    
    @objc func backPressed(){
        dismiss(animated: true, completion: nil)
    }

    @IBAction func sendMessage(_ sender: Any) {
        viewFullImagePresenter.uploadImage(imageFile: self.imageFile, orderId: self.orderId)
    }
}

extension ViewFullImageVC : ViewFullImageView{
    
    func setImage(image: DelegateImageData) {
        self.dismiss(animated: true, completion: nil)
        if imageDelegate != nil{
            let chatImage = ChatImage(id: image.id ?? 0 , url: image.image?.medium ?? "")
            self.imageDelegate.saveImagetoDB(chatImage: chatImage)
        }
    }
    
    
    func showloading() {
        if(loadingView != nil) {
            loadingView.hide(animated: true)
            loadingView = nil
        }
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
        //self.noNetworkView.isHidden = false
    }
    
    func showGeneralError() {
        Toast.init(text: "general_error".localized()).show()
    }
    
    func showSusspendedMsg(msg : String){
        Toast.init(text:msg).show()
    }
    
}
