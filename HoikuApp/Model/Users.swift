//
//  Users.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/12.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Users: NSObject {
    //ユーザー名のデータ
    var userId:String?
    var userName:String?//ユーザー作成のときにdisplayNameを保存する
    var address:String?
    var post:[String] = []//自分の全投稿の配列
    var likes:[String] = []//自分のいいねしたものの配列 postIdが入る
    
    init(snapshot:DataSnapshot) {
        userId = snapshot.key
        let valueDictionally = snapshot.value as! [String:Any]
        
        
        userName = valueDictionally["userName"] as? String
        address = valueDictionally["address"] as? String
        
        if let post = valueDictionally["post"] as? [String]{
            self.post = post
        }
        
        if let likes = valueDictionally["likes"] as? [String]{
            self.likes = likes
        }
    }
}
