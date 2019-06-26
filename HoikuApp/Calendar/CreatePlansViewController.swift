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

class CreatePlansViewController: UIViewController {
    
    let realm = try! Realm()
    var shift:Shift!
    private var oneShiftDetailWork:String = ""
    @IBOutlet weak var naviBar: UINavigationItem!
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        detailWorkPicker.delegate = self
        detailWorkPicker.dataSource = self
        
        setUpView()
        
    }
    
    @IBAction func backButton(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        if smallTextView.text == ""{
            SVProgressHUD.showError(withStatus: "タイトルを記入してください")
            return
        }
        try! realm.write {
            shift.detailText = detailTextField.text
            shift.smallText = smallTextView.text!
            shift.detailWork = dataList[detailWorkPicker.selectedRow(inComponent: 0)]!
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
        dateLabel.layer.backgroundColor = UIColor.orange.cgColor
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.layer.cornerRadius = 10
        dateLabel.textColor = UIColor.white
        dateLabel.layer.masksToBounds = true
        
        smallTextLabel.text = "タイトル"
        smallTextLabel.layer.backgroundColor = UIColor.orange.cgColor
        smallTextLabel.textColor = UIColor.white
        smallTextLabel.font = UIFont.systemFont(ofSize: 20)
        smallTextLabel.layer.cornerRadius = 10
        smallTextLabel.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        smallTextLabel.layer.masksToBounds = true
        
        
        detailTextLabel.text = "予定を入力"
        detailTextLabel.layer.backgroundColor = UIColor.orange.cgColor
        detailTextLabel.textColor = UIColor.white
        detailTextLabel.font = UIFont.systemFont(ofSize: 20)
        detailTextLabel.layer.cornerRadius = 10
        detailTextLabel.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner]
        detailTextLabel.layer.masksToBounds = true
        
        detailWorkLabel.text = "勤務形態を選択"
        detailWorkLabel.font = UIFont()
        detailWorkLabel.font = UIFont.systemFont(ofSize: 20)
        detailWorkLabel.layer.backgroundColor = UIColor.orange.cgColor
        detailWorkLabel.textColor = UIColor.white
        detailWorkLabel.layer.cornerRadius = 10
        detailWorkLabel.layer.maskedCorners = [.layerMaxXMinYCorner,.layerMinXMaxYCorner]
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
