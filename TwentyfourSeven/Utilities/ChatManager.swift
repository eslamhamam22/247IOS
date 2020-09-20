//
//  ChatManager.swift
//  TwentyfourSeven
//
//  Created by Dina Ragab on 3/6/19.
//  Copyright © 2019 Objects. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class ChatManager: NSObject{
    
    var  databaseRef : DatabaseReference!
    var  ordersChatsRef : DatabaseReference!
    var  orderRef : DatabaseReference!
    
    weak var  view : UIViewController!
    
    func initRefernces(orderId: Int , view : UIViewController){
        self.view=view
        databaseRef = Database.database().reference().child(APIURLs.DATABASE_TABEL)
        ordersChatsRef = databaseRef.child("orders_chat")
        orderRef = ordersChatsRef.child(String(orderId))
        
        //orderRef = ordersChatsRef.child("137")
    }

    //get firebase messages
    public func getMessages(){
        orderRef.observe(.value, with: {(snapshot) in
            if snapshot.exists(){
                var chat = [ChatMessage]()
                for msgs in snapshot.children {
                    let msgsSnapShot = msgs as! DataSnapshot
                    let msg = msgsSnapShot.value as! [String: Any]
                    print(msg)
                    var chatImages = [ChatImage]()
                    var message = Message()
                    var chatMessage = ChatMessage()
                    
                    //get order images
                    if let orderImages = msg["images"] as? [[String:Any]]{
                        for i in 0..<orderImages.count{
                            var chatImageDict = orderImages[i]
                            let imageId = chatImageDict["id"] as? Int
                            let imageURL = chatImageDict["url"] as? String
                            let chatImage = ChatImage(id: imageId, url: imageURL)
                            chatImages.append(chatImage)
                        }
                    }
                    
                    //get order text
                    if let chatText = msg["msg"] as? [String:Any]{
                        let defaultMsg = chatText["no_locale"] as? String
                        let en = chatText["en"] as? String
                        let ar = chatText["ar"] as? String
                        
                        message = Message(defaultMsg : defaultMsg , en : en , ar : ar)
                    }
                    
                    let created_by = msg["created_by"] as? Int
                    
                    let recipient_type = msg["recipient_type"] as? Int ?? ChatRecipientType.RECIPIENT_TYPE_ALL.rawValue
                    
                    let created_at = msg["created_at"] as? Double
                    
                    chatMessage = ChatMessage(msg : message , images : chatImages , created_by : created_by , recipient_type : ChatRecipientType(rawValue: recipient_type) , created_at :created_at)
                    print(chatMessage)
                    chat.append(chatMessage)
                    
                }
                self.updateChatScreen(chatMsgs: chat)
            }
            })
            
        
    }
    
    //set data to view
    func updateChatScreen(chatMsgs : [ChatMessage]){
        if let chatVc = self.view as? ChatVC{
            if chatVc.isViewLoaded{
                chatVc.gotChatMessgaes(chatMsgs: chatMsgs)
            }
        }

    }
    
    func sendMessage(msg : String , userId : Int){
        let defaultMsg = ["no_locale" : msg]
        let messageNode = ["msg" : defaultMsg ,
                           "created_by" : userId ,
                           "recipient_type" : 2 ,
                           "created_at" : ServerValue.timestamp()] as [String : Any]
        
        let key = orderRef.childByAutoId().key
        if key != nil{
            let msgsUpdate = ["\(String(describing: key!))" : messageNode]
            orderRef.updateChildValues(msgsUpdate)
        }
    }
    
    func saveChatImage(chatImg : ChatImage ,userId : Int){
        let image = ["id" : chatImg.id ?? 0 , "url" : chatImg.url ?? ""] as [String : Any]
        var images = [[:]]
        images.append(image)
        let messageNode = [ "images" : [image],
                           "created_by" : userId ,
                           "recipient_type" : 2 ,
                           "created_at" : ServerValue.timestamp()] as [String : Any]
        
        let key = orderRef.childByAutoId().key
        if key != nil{
            let msgsUpdate = ["\(String(describing: key!))" : messageNode]
            orderRef.updateChildValues(msgsUpdate)
        }
        
    

    }
    
   
    func topMostController() -> UIViewController {
        var topController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController
        while ((topController?.presentedViewController) != nil) {
            topController = topController?.presentedViewController
        }
        return topController!
    }
    
    func removeObservers(){
        orderRef.removeAllObservers()
        databaseRef.removeAllObservers()
        ordersChatsRef.removeAllObservers()
    }
    
}
