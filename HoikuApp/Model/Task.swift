//
//  Task.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/04.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import RealmSwift

class Task: Object {
    //タスク管理のモデル
    @objc dynamic var id = 0
    @objc dynamic var name = ""
    @objc dynamic var content = ""
    @objc dynamic var date = Date()
    @objc dynamic var colorNum = 0
    @objc dynamic var color = "白"
    
    override static func primaryKey() -> String?{
        return "id"
    }
    
}
