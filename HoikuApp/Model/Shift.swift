//
//  Shift.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/07.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import Foundation
import RealmSwift

class Shift:Object{
    //シフトのモデル
    @objc dynamic var id:Int = 0
    @objc dynamic var date:String = ""
    @objc dynamic var detailText:String = ""
    @objc dynamic var smallText:String = ""
    @objc dynamic var detailWorkNumber:Int = 0
    @objc dynamic var detailWork:String = ""
    @objc dynamic var initTime = Date()
    @objc dynamic var finishTime = Date()
    
    override static func primaryKey()-> String?{
        return "id"
    }
    
}
