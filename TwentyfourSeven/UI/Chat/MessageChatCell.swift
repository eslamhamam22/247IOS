//
//  MessageChatCell.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 2/26/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import UIKit
import Kingfisher


class MessageChatCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var msgText: UILabel!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var senderImg: UIImageView!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var ImagesCollectionView: UICollectionView!
    @IBOutlet weak var dateTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionViewWidth: NSLayoutConstraint!
    @IBOutlet weak var collectionViewHeight: NSLayoutConstraint!
    
    var order = Order()
    var chatMessage = ChatMessage()
    var index = 0
    var isSender = false
    var dateManager = DateManager()
    var collectionViewCellHeight = 75
    var collectionViewCellWidth = 75
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let userDefault = UserDefault()
    
    var width = 0
    var height = 0
    
    weak var imageDelegate : ImageDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        borderView.layer.setCornerRadious(radious: self.borderView.frame.width/2, maskToBounds: true)
        senderImg.layer.setCornerRadious(radious: self.senderImg.frame.width/2, maskToBounds: true)
        msgView.layer.setCornerRadious(radious: 10.0, maskToBounds: true)
        msgText.font = Utils.customDefaultFont(msgText.font.pointSize)
        dateLbl.font = Utils.customDefaultFont(dateLbl.font.pointSize)

        ImagesCollectionView.delegate = self
        ImagesCollectionView.dataSource = self
        let screenSize: CGRect = UIScreen.main.bounds
        let screenWidth = screenSize.width - 150
      
        width = Int(screenWidth/3)
        height = collectionViewCellWidth
        
    }
    
    func setCell(index : Int , order : Order , isSender : Bool , chatMessage : ChatMessage , isDelegtateOfOrder : Bool , imageDelegate : ImageDelegate!){
    
        self.index = index
        self.order = order
        self.chatMessage = chatMessage
        self.isSender = isSender
        self.imageDelegate = imageDelegate
        
        self.setMessageData(chatMessage : chatMessage)
        self.setCellAlignment()
        self.customizeCell(isDelegtateOfOrder : isDelegtateOfOrder)
    }
    
    func setCellAlignment(){
        if appDelegate.isRTL{
            if !isSender{
                dateLbl.textAlignment = .right
            }else{
                dateLbl.textAlignment = .left
            }
            msgText.textAlignment = .right
            ImagesCollectionView.semanticContentAttribute = .forceRightToLeft

        }else{
            msgText.textAlignment = .left
            ImagesCollectionView.semanticContentAttribute = .forceLeftToRight
            if !isSender{
                dateLbl.textAlignment = .left
            }else{
                dateLbl.textAlignment = .right
            }
        }
        
    }
    
    //set image and text color and backgtound color
    func customizeCell(isDelegtateOfOrder : Bool){
        
        if chatMessage.created_by ?? 0  != 0{
            if !isSender{
                //reciever cell
                self.msgView.backgroundColor = Colors.hexStringToUIColor(hex: "#f2f6f8")
                self.msgText.textColor = Colors.hexStringToUIColor(hex: "#6c727b")
                self.dateLbl.textColor = Colors.hexStringToUIColor(hex: "#bcc5d3")

                if isDelegtateOfOrder{
                    //get user data if current user is the delgate of the order
                    if order.user != nil{
                        if let userImage = order.user!.image {
                            if let userMediumImage = userImage.medium {
                                let url = URL(string: userMediumImage)
                                print("url \(String(describing: url))")
                                self.senderImg.kf.setImage(with: url, placeholder: UIImage(named: "user_circle"))
                            }else{
                                self.senderImg.image = UIImage(named: "user_circle")
                            }
                        }else{
                            self.senderImg.image = UIImage(named: "user_circle")
                        }
                    }else{
                        self.senderImg.image = UIImage(named: "user_circle")
                    }
                }else{
                    //get delegate data if current user is the user of the order
                    if order.delegate != nil{
                        if let delegateImage = order.delegate!.image {
                            if let delegateMediumImage = delegateImage.medium {
                                let url = URL(string: delegateMediumImage)
                                print("url \(String(describing: url))")
                                self.senderImg.kf.setImage(with: url, placeholder: UIImage(named: "user_circle"))
                            }else{
                                self.senderImg.image = UIImage(named: "user_circle")
                            }
                        }else{
                            self.senderImg.image = UIImage(named: "user_circle")
                        }
                        
                    }else{
                        self.senderImg.image = UIImage(named: "user_circle")
                    }
                }
            }else{
                //sender cell
                self.msgView.backgroundColor = Colors.hexStringToUIColor(hex: "#d4eaff")
                self.msgText.textColor = Colors.hexStringToUIColor(hex: "#3f4247")
                self.dateLbl.textColor = Colors.hexStringToUIColor(hex: "#366db3")

                if self.userDefault.getUserData().image != nil{
                    if let currentUserImage = self.userDefault.getUserData().image!.small {
                        let url = URL(string: currentUserImage)
                        print("url \(String(describing: url))")
                        self.senderImg.kf.setImage(with: url, placeholder: UIImage(named: "user_circle"))
                    }else{
                        self.senderImg.image = UIImage(named: "user_circle")
                    }
                }else{
                    self.senderImg.image = UIImage(named: "user_circle")
                }
            }

        }else{
            //system cell
            self.msgText.textColor = Colors.hexStringToUIColor(hex: "#3f4247")
            self.msgView.backgroundColor = Colors.hexStringToUIColor(hex: "#fedcdf")
            self.senderImg.image = UIImage(named: "avatar_circle")
            self.dateLbl.textColor = Colors.hexStringToUIColor(hex: "#97151e")
        }
    }
    
    
    func hideCollectionView(){
        if appDelegate.isRTL{
            self.dateTopConstraint.constant = -15
        }else{
            self.dateTopConstraint.constant = -7
        }
        
        self.collectionViewHeight.constant = 0
        self.collectionViewWidth.priority = UILayoutPriority(rawValue: 250.0)
        self.ImagesCollectionView.isHidden = true
    }
    
    func setMessageData(chatMessage : ChatMessage){
        //set content
        var msgTxt = ""
        if chatMessage.msg != nil{
            if chatMessage.msg?.defaultMsg != nil{
                msgTxt = chatMessage.msg!.defaultMsg!
            }else{
                if appDelegate.isRTL{
                    msgTxt = chatMessage.msg?.ar ?? ""
                }else{
                    msgTxt = chatMessage.msg?.en ?? ""
                }
            }
        }
        msgText.text = msgTxt
        
        //set date
        //convert timestamp to date
        let timeIntervalInSec = TimeInterval(chatMessage.created_at ?? 0.0) / 1000
        let chatMessageDate = Date(timeIntervalSince1970:  timeIntervalInSec)
        let msgDate = dateManager.convertToDateString(date : chatMessageDate , format : "h:mm a - dd MMM yyyy")
        dateLbl.text = msgDate
        
        
        //set images
        //set order images
        if let orderImages = chatMessage.images{
            self.ImagesCollectionView.isHidden = false
            //get collection view height
            if index != 0 && orderImages.count == 1{
                self.collectionViewCellWidth = 200
                self.collectionViewCellHeight = 200
                self.collectionViewWidth.constant =  CGFloat(200)
                self.collectionViewWidth.priority = UILayoutPriority(rawValue: 999)
                self.collectionViewHeight.constant =  200
                if appDelegate.isRTL{
                    self.dateTopConstraint.constant = 3
                }else{
                    self.dateTopConstraint.constant = 5
                }
                self.ImagesCollectionView.reloadData()
            }else{
                if orderImages.count > 0 {
                    self.collectionViewCellWidth = width
                    self.collectionViewCellHeight = height
                    var number = orderImages.count/3
                    if orderImages.count%3 != 0{
                        number = number + 1
                    }
                    self.collectionViewHeight.constant =  CGFloat(number*collectionViewCellHeight + ((orderImages.count%3) * 10))
                    self.collectionViewWidth.constant =  CGFloat((collectionViewCellWidth * 3) + 20)
                    print(collectionViewHeight.constant)
                    self.collectionViewWidth.priority = UILayoutPriority(rawValue: 999)
                    
                    self.dateTopConstraint.constant = 5
                    self.ImagesCollectionView.reloadData()
                }else{
                    hideCollectionView()
                }
            }
        }else{
            hideCollectionView()
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

extension MessageChatCell : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
   
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let orderImages = chatMessage.images {
            return orderImages.count
        }
        
        return 0 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath as IndexPath)
        let chatImageView = cell.contentView.viewWithTag(1) as! UIImageView
        if self.index == 0 {
            chatImageView.contentMode = .scaleToFill
        }else{
            chatImageView.contentMode = .scaleAspectFill
        }
        if self.chatMessage.images != nil{
            if (self.chatMessage.images?.indices.contains(indexPath.row))!{
                if let imageTobeDsiplayed = self.chatMessage.images![indexPath.row].url{
                    let url = URL(string: "\(imageTobeDsiplayed)")
                    print("url \(String(describing: url))")
                   chatImageView.kf.setImage(with: url, placeholder: UIImage(named: "louding_img_2"))
                }
            }
        }
       
        
        return cell
    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width : CGFloat(self.collectionViewCellWidth), height:  CGFloat(collectionViewCellHeight))
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
         return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let images = self.chatMessage.images {
            if images.indices.contains(indexPath.row){
                if imageDelegate != nil{
                    if images[indexPath.row].url != nil{
                        imageDelegate.showImage(url: images[indexPath.row].url!)
                    }
                }
            }
        }
    }
    
  
}
