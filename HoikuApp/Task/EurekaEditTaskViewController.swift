//
//  EurekaEditTaskViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/12/03.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import SVProgressHUD

class EurekaEditTaskViewController: FormViewController {
    
    public var task:Task!
    private let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //フォームを作成
        form
            //シフトのセクションを作成
            +++ Section("メモ詳細")
            <<< TextRow{row in
                row.title = "タイトル"
                row.placeholder = "タイトルを入力"
                row.tag = "name"
                
                //shiftのタイトルが入力済みの場合表示する
                if self.task.name.isEmpty == false{
                    row.value = task.name
                }
            }
            
            <<< TextAreaRow{row in
                row.placeholder = "詳細を入力してください"
                row.tag = "content"
                //shiftの詳細が入力済みの場合表示する
                if self.task.content.isEmpty == false{
                    row.value = task.content
                }
            }
            
            
            //期限ののセクションを作成する
            +++ Section("期限")
            <<< DateTimeInlineRow(""){
                $0.tag = "date"
                $0.title = "日時を選択"
                $0.value = task.date
                
            }
            
            //ふせんの色を決定するセクションを作成する
            +++ Section("ふせんの色")
            <<< SegmentedRow<String>(){row in
                row.tag = "backgroundColor"
                row.title = "色の指定"
                row.options = ["白","赤","カーキ","緑","水色"]
                row.value = task.color
        }
    }
    
    //保存ボタンをタップした時の挙動
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        //名前、詳細、期限、背景色のデータを取得する
        let nameRow = form.rowBy(tag: "name") as! TextRow
        let contentRow = form.rowBy(tag: "content") as! TextAreaRow
        let dateRow = form.rowBy(tag: "date") as! DateTimeInlineRow
        let backgroundColorRow = form.rowBy(tag: "backgroundColor") as! SegmentedRow<String>
        
        //各々の値がnilでない場合は保存する
        if let name = nameRow.value,let content = contentRow.value{
            try! realm.write {
                task.name = name
                task.content = content
                task.date = dateRow.value!
                task.color = backgroundColorRow.value!
                realm.add(task,update:true)
            }
            SVProgressHUD.showSuccess(withStatus: "保存に成功しました")
        }else{
            SVProgressHUD.showError(withStatus: "タイトルと詳細を記入してください")
        }
    }
    
}
