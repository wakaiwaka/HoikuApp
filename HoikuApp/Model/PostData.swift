//
//  PostData.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/11.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PostData:NSObject {
    var postId:String?
    var title:String?
    var name:String?
    var detail:String?
    var date:Date?
    var isLiked:Bool = false
    var likes:[String] = []
    var comments:[[String:Any]] = []
    
    //写真のurl
    var postImageArray:[String] = []
    
    //対象年齢のID
    var rateId:String?
    
    //カテゴリーのID
    var categoryId:String?
    
    //所要時間のID
    var requiredTimeId:String?
    
    //必要な材料
    var requiredMaterial:String?
    
    //共有のON/OFF
    var share:String? = "false"
    
    //投稿したユーザーのID
    var userId:String?
    
    //検索用のワード
    var searchWord:String?
    
    init(snapshot:DataSnapshot,myId:String) {
        self.postId = snapshot.key
        let valueDictionally = snapshot.value as! [String:Any]
        
        title = valueDictionally["title"] as? String
        detail = valueDictionally["detail"] as? String
        
        name = valueDictionally["name"] as? String
        
        let time = valueDictionally["time"] as? String
        self.date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
        
        if let likes = valueDictionally["likes"] as? [String]{
            self.likes = likes
        }
        
        for likeId in likes{
            if likeId == myId{
                self.isLiked = true
                break
            }
        }
        
        if let comments = valueDictionally["comments"] as? [[String:Any]]{
            self.comments = comments
        }
        
        if let postImageArray = valueDictionally["postImageArray"] as? [String]{
            self.postImageArray = postImageArray
        }
        
        rateId = valueDictionally["rateId"] as? String
        
        categoryId = valueDictionally["categoryId"] as? String
        
        share = valueDictionally["share"] as? String
        
        userId = valueDictionally["userId"] as? String
        
        requiredTimeId = valueDictionally["requiredTimeId"] as? String
        
        searchWord = valueDictionally["searchWord"] as? String
        
        requiredMaterial = valueDictionally["requiredMaterialId"] as? String
    }
}
