//
//  PrivatePosts.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/19.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseAuth



class PrivatePosts: NSObject {
    var postUserId:String?
    var date:Date?
    
    init(snapshot:DataSnapshot) {
        let valueDictionally = snapshot.value as! [String:Any]
        postUserId = valueDictionally["postUserId"] as? String
        let time = valueDictionally["time"] as? String
        date = Date(timeIntervalSinceReferenceDate: TimeInterval(time!)!)
    }
    
}
