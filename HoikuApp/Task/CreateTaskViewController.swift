//
//  CreateTaskViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/04.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import RealmSwift
import SVProgressHUD
import UserNotifications

class CreateTaskViewController: UIViewController {
    
    public var task:Task!
    private let realm = try! Realm()
    @IBOutlet weak var naviBar: UINavigationItem!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var taskDate: UIDatePicker!
    
    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorSegmented: UISegmentedControl!
    
    override func viewDidLoad() {
        
        setUpView()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func setUpView(){
        
        self.naviBar.title = "メモ作成"
        nameLabel.text = "メモ"
        nameLabel.font = UIFont.systemFont(ofSize: 20)
        nameLabel.textColor = UIColor.white
        nameLabel.layer.cornerRadius = 10
        nameLabel.layer.backgroundColor = UIColor.orange.cgColor
        nameLabel.layer.masksToBounds = true
        
        nameTextField.borderStyle = .none
        nameTextField.layer.borderWidth = 0.3
        nameTextField.layer.borderColor = UIColor.black.cgColor
        nameTextField.layer.cornerRadius = 10
        nameTextField.text = task.name
        
        contentLabel.text = "詳細"
        contentLabel.font = UIFont.systemFont(ofSize: 20)
        contentLabel.textColor = UIColor.white
        contentLabel.layer.cornerRadius = 10
        contentLabel.layer.backgroundColor = UIColor.orange.cgColor
        contentLabel.layer.masksToBounds = true
        
        
        contentTextView.layer.borderWidth = 0.3
        contentTextView.layer.borderColor = UIColor.black.cgColor
        contentTextView.layer.cornerRadius = 10
        contentTextView.text = ""
        contentTextView.text = task.content
        
        dateLabel.text = "期限"
        dateLabel.font = UIFont.systemFont(ofSize: 20)
        dateLabel.textColor = UIColor.white
        dateLabel.layer.backgroundColor = UIColor.orange.cgColor
        dateLabel.layer.cornerRadius = 10
        dateLabel.layer.masksToBounds = true
        
        taskDate.date = task.date
        
        colorSegmented.removeAllSegments()
        colorSegmented.insertSegment(withTitle: "白", at: 0, animated: true)
        colorSegmented.insertSegment(withTitle: "赤", at: 1, animated: true)
        colorSegmented.insertSegment(withTitle: "カーキ", at: 2, animated: true)
        colorSegmented.insertSegment(withTitle: "緑", at: 3, animated: true)
        colorSegmented.insertSegment(withTitle: "水色", at: 4, animated: true)
        colorSegmented.selectedSegmentIndex = task.colorNum
        colorSegmented.tintColor = UIColor.orange
        
        colorLabel.textColor = .white
        colorLabel.backgroundColor = UIColor.orange
        colorLabel.layer.cornerRadius = 10
        colorLabel.layer.masksToBounds = true
        colorLabel.font = UIFont.systemFont(ofSize: 20)
    }
    
    //保存ボタンをタップした時の処理
    @IBAction func saveButton(_ sender: UIBarButtonItem) {
        try! realm.write {
            task.name = nameTextField.text!
            task.content = contentTextView.text!
            task.date = taskDate.date
            task.colorNum = self.colorSegmented.selectedSegmentIndex
            realm.add(self.task, update: true)
        }
        SVProgressHUD.showSuccess(withStatus: "作成しました！")
        setNotification()
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    //戻るボタンをタップした時の処理
    @IBAction func backButtonTapped(_ sender: UIBarButtonItem) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    private func setNotification(){
        let content = UNMutableNotificationContent()
        if task.name == ""{
            content.title = "タイトルなし"
        }else{
            content.title = task.name
        }
        
        if task.content == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.content
        }
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        
        let dateComponents = calendar.dateComponents([.year,.month,.day,.hour,.minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        let center = UNUserNotificationCenter.current()
        center.add(request){(error) in
            print(error ?? "ローカル通知 OK")
        }
        
        center.getPendingNotificationRequests{(requests:[UNNotificationRequest]) in
            for request in requests{
                print("/----------")
                print(request)
                print("---------/")
            }
        }
    }    
}


