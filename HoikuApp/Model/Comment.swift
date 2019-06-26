//
//  Comment.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/10/29.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseStorage


class Comment:NSObject{
    var attributedText:String?
    var date:String?
    var messageId:String?
    var userId:String?
    
    init(snapshot:DataSnapshot) {
        let valueDictionary = snapshot.value as! [String:Any]
        
        self.attributedText = valueDictionary["attributedText"] as? String
        
        self.date = valueDictionary["date"] as? String
        
        self.messageId = valueDictionary["messageId"] as? String
        
        self.userId = valueDictionary["userId"] as? String
        
    }
    
}
