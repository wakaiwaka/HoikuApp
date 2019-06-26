//
//  EurekaCreatePlansViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/12/03.
//  Copyright © 2018 若原昌史. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift
import SVProgressHUD

class EurekaCreatePlansViewController: FormViewController {
    
    private let realm = try! Realm()
    public var shift:Shift!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //フォームを作成
        form
            //シフトのセクションを作成
            +++ Section("シフト詳細")
            <<< TextRow{row in
                row.title = "タイトル"
                row.placeholder = "タイトルを入力"
                row.tag = "smallText"
                
                //shiftのタイトルが入力済みの場合表示する
                if self.shift.smallText.isEmpty == false{
                    row.value = shift.smallText
                }
                }
            
            <<< TextAreaRow{row in
                row.placeholder = "詳細を入力してください"
                row.tag = "detailText"
                //shiftの詳細が入力済みの場合表示する
                if self.shift.detailText.isEmpty == false{
                    row.value = shift.detailText
                }
                }
            
            
            //勤務形態のセクションを作成する
            +++ Section("勤務形態")
            <<< PickerRow<String>(){
                $0.tag = "shiftPicker"
                $0.title = "勤務形態"
                $0.options = ["早番","日勤","遅番","休み","日早","日遅","延長","午前半","午後半","有休","夜間"]
                
                if shift.detailWork.isEmpty == false{
                    $0.value = shift.detailWork
                }else{
                    $0.value = "早番"
                }
                }
            
        //勤務時間の作成
            <<< TimeInlineRow(""){
                $0.tag = "initTime"
                $0.title = "始業時間"
                $0.value = shift.initTime
        }
        
            
            <<< TimeInlineRow(""){
                $0.tag = "finishTime"
                $0.title = "終業時間"
                $0.value = shift.finishTime
        }
        
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        let smallTextRow = form.rowBy(tag: "smallText") as! TextRow
        let detailTextRow = form.rowBy(tag: "detailText") as! TextAreaRow
        let shiftPicker = form.rowBy(tag: "shiftPicker") as! PickerRow<String>
        let initT = form.rowBy(tag: "initTime") as! TimeInlineRow
        let finishT = form.rowBy(tag: "finishTime") as! TimeInlineRow
        
        
        if let smallText = smallTextRow.value ,let detailText = detailTextRow.value,let shift = shiftPicker.value,let initTime = initT.value,let finishTime = finishT.value  {
            
            //シフトを保存する
            try! realm.write {
                self.shift.smallText = smallText
                self.shift.detailText = detailText
                self.shift.detailWork = shift
                self.shift.initTime = initTime
                self.shift.finishTime = finishTime
                realm.add(self.shift, update: true)
            }
            
            //画面を閉じる
            SVProgressHUD.showSuccess(withStatus: "保存しました！")
            self.dismiss(animated: true, completion: nil)
        }else{
            SVProgressHUD.showError(withStatus: "タイトルと詳細を入力してください")
            return
        }
        
    }
    
    //キャンセルボタンをタップした時の処理、画面を閉じる
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}
