//
//  CreatePlansViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/06.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD

class CreatePlansViewController: UIViewController{
    
    let realm = try! Realm()
    var shift:Shift!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    //シフト一覧を配列にまとめる
    let dataList = [0:"早番",1:"日勤",2:"遅番",3:"休み",4:"日早",5:"日遅",6:"延長",7:"午前半",8:"午後半",9:"有休",10:"夜間"]
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var smallTextLabel: UILabel!
    @IBOutlet weak var detailTextLabel: UILabel!
    @IBOutlet weak var detailWorkLabel: UILabel!
    
    @IBOutlet weak var smallTextView: UITextField!
    @IBOutlet weak var detailTextField: UITextView!
    @IBOutlet weak var detailWorkPicker: UIPickerView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景をタップするとキーボードが消える
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        detailWorkPicker.delegate = self
        detailWorkPicker.dataSource = self
        
        setUpView()
        
    }
    
    //戻るボタンを押した時の挙動
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //保存ボタンを押した時の挙動
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if smallTextView.text == ""{
            SVProgressHUD.showError(withStatus: "タイトルを記入してください")
            return
        }
        //タイトル、予定、シフトとシフトの一覧の配列のキーを保存
        try! realm.write {
            shift.detailText = detailTextField.text
            shift.smallText = smallTextView.text!
            shift.detailWork = dataList[detailWorkPicker.selectedRow(inComponent: 0)]!
            //for文でシフトとシフト一覧の配列の中からキーが一致するものを保存する
            for (key,value) in dataList{
                if value == shift.detailWork{
                    shift.detailWorkNumber = key
                }
            }
            realm.add(shift, update: true)
        }
        SVProgressHUD.showSuccess(withStatus: "保存しました！")
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    private func setUpView(){
        naviBar.title = "シフト作成"
        dateLabel.text = shift.date
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        
        let dateLabelBorder = UIView(frame: CGRect(x: 0, y: dateLabel.frame.height - 0.3, width: dateLabel.frame.width, height: 0.3))
        dateLabelBorder.backgroundColor = UIColor.orange
        dateLabel.layer.masksToBounds = true
        dateLabel.addSubview(dateLabelBorder)
        
        smallTextLabel.text = "タイトル"
        smallTextLabel.font = UIFont.systemFont(ofSize: 20)
        smallTextLabel.layer.backgroundColor = UIColor.orange.cgColor
        smallTextLabel.textColor = UIColor.white
        smallTextLabel.layer.cornerRadius = 10
        smallTextLabel.layer.masksToBounds = true
        
        
        detailTextLabel.text = "予定を入力"
        detailTextLabel.font = UIFont.systemFont(ofSize: 20)
        detailTextLabel.layer.backgroundColor = UIColor.orange.cgColor
        detailTextLabel.textColor = UIColor.white
        detailTextLabel.layer.cornerRadius = 10
        detailTextLabel.layer.masksToBounds = true
        
        detailWorkLabel.text = "勤務形態を選択"
        detailWorkLabel.font = UIFont()
        detailWorkLabel.font = UIFont.systemFont(ofSize: 20)
        detailWorkLabel.layer.backgroundColor = UIColor.orange.cgColor
        detailWorkLabel.textColor = UIColor.white
        detailWorkLabel.layer.cornerRadius = 10
        detailWorkLabel.layer.masksToBounds = true
        
        smallTextView.text = shift.smallText
        smallTextView.layer.borderColor = UIColor.orange.cgColor
        detailTextField.text = shift.detailText
        detailTextField.layer.borderWidth = 0.3
        detailTextField.layer.borderColor = UIColor.lightGray.cgColor
        detailTextField.layer.cornerRadius = 10
        
        
        detailWorkPicker.selectRow(shift.detailWorkNumber, inComponent: 0, animated: true)
    }
    
    @objc func dismissKeyboard(){
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}

extension CreatePlansViewController:UIPickerViewDelegate,UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return dataList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return dataList[row]
    }
    
}
