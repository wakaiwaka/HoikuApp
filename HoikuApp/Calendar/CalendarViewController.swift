//
//  CalendarViewController.swift
//  HoikuApp
//
//  Created by 若原昌史 on 2018/09/05.
//  Copyright © 2018年 若原昌史. All rights reserved.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift
import SVProgressHUD

class CalendarViewController: UIViewController, FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance{
    
    let realm = try! Realm()
    
    fileprivate weak var calendar:FSCalendar!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var detailWork: UILabel!
    @IBOutlet weak var createShiftButton: UIButton!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    
    fileprivate var selectDate:Date = Date()
    
    var allShiftArray = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "シフト"
        self.naviBar.title = "シフト"
        setUpView()
    }
    
    func judgeHoliday(_ date:Date)-> Bool{
        let tmpCalendar = Calendar(identifier: .gregorian)
        
        let year = tmpCalendar.component(.year, from: date)
        let month = tmpCalendar.component(.month, from: date)
        let day = tmpCalendar.component(.day, from: date)
        
        let holiday = CalculateCalendarLogic()
        return holiday.judgeJapaneseHoliday(year: year, month: month, day: day)
        
    }
    
    func getWeekIdx(_ date:Date)-> Int{
        let tmpCalendar = Calendar(identifier: .gregorian)
        return tmpCalendar.component(.weekday, from: date)
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        
        if self.judgeHoliday(date){
            return UIColor.red
        }
        
        let weekday = self.getWeekIdx(date)
        if weekday == 1 {
            return UIColor.red
        }
        else if weekday == 7 {
            return UIColor.blue
        }
        
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        
        self.date.text = "\(month)月\(day)日"
        let oneDay = "\(year)年\(month)月\(day)日"
        
        let predicate = NSPredicate(format:"date == %@",oneDay)
        
        let selectedShift = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false).filter(predicate).first
        
        if selectedShift == nil{
            self.smallLabel.text = ""
            self.detailWork.text = "シフト作成をタップして予定を作成しよう！"
        }else{
            self.smallLabel.text = selectedShift?.smallText
            self.detailWork.text = selectedShift?.detailText
        }
    }
    
    private func setUpView(){
        
        let calendar = FSCalendar(frame: CGRect(x: 0, y: (self.navigationController?.navigationBar.frame.maxY)!, width: self.view.frame.width, height: 300))
        
        calendar.dataSource = self
        calendar.delegate = self
        view.addSubview(calendar)
        
        self.calendar = calendar
        
        self.date.text = ""
        self.detailWork.text = ""
        self.smallLabel.text = ""
        createShiftButton.backgroundColor = UIColor.orange
        createShiftButton.setTitleColor(UIColor.white, for: UIControl.State.normal)
        
        let smallLabelBorder = UIView(frame: CGRect(x: 0, y: smallLabel.frame.height - 0.3, width: smallLabel.frame.width, height: 0.3))
        
        smallLabelBorder.backgroundColor = UIColor.orange
        
        smallLabel.addSubview(smallLabelBorder)
        
    }
    
    @IBAction func createShift(_ sender: UIButton) {
        let nc = self.storyboard?.instantiateViewController(withIdentifier:"CreatePlansNavigationController" ) as! UINavigationController
        
        let createPlansViewController = nc.topViewController as! CreatePlansViewController
        
        let selectedDate:Date? = calendar.selectedDate
        
        if let selectedDate = selectedDate {
            let tmp = Calendar(identifier: .gregorian)
            let year = tmp.component(.year, from: selectedDate)
            let month = tmp.component(.month, from: selectedDate)
            let day = tmp.component(.day, from: selectedDate)
            let oneDay = "\(year)年\(month)月\(day)日"
            
            let predicate = NSPredicate(format:"date == %@",oneDay)
            
            let selectedShifArray = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false).filter(predicate)
            
            if selectedShifArray.count == 0 && allShiftArray.count != 0{
                //選択された日のデータが入力されてない時の動き
                let shift = Shift()
                shift.id = allShiftArray.max(ofProperty: "id")! + 1
                shift.date = "\(year)年\(month)月\(day)日"
                createPlansViewController.shift = shift
                self.present(nc,animated: true,completion: nil)
                print("作成")
            }else if selectedShifArray.count != 0 && allShiftArray.count != 0{
                //すでに入力されている時の動き
                createPlansViewController.shift = selectedShifArray.first
                self.present(nc,animated: true,completion: nil)
                print("編集")
            }else{
                //初めて予定を入力する時の動き
                let shift = Shift()
                shift.date = "\(year)年\(month)月\(day)日"
                createPlansViewController.shift = shift
                self.present(nc,animated: true,completion: nil)
                print("新規")
            }
        }else{
            //selectedDateがnilの時
             SVProgressHUD.showError(withStatus: "カレンダー内からシフト作成する日付をタップして選択しよう！")
            return print("何も動きを起こさない")
        }
    }
    

    
    
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
        //カレンダー内に午前、午後などの予定を記入する。
        let tmp = Calendar(identifier: .gregorian)
        let year = tmp.component(.year, from: date)
        let month = tmp.component(.month, from: date)
        let day = tmp.component(.day, from: date)
        
        let oneDay = "\(year)年\(month)月\(day)日"
        
        let predicate = NSPredicate(format:"date == %@",oneDay)
        
        let selectedShift:Shift? = try! Realm().objects(Shift.self).filter(predicate).first
        
        if let selectedShiftEX = selectedShift{
            
            return selectedShiftEX.detailWork
        }
        return ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let selectedDate:Date? = calendar.selectedDate
        
        if let selectedDate = selectedDate{
            
            let tmp = Calendar(identifier: .gregorian)
            let year = tmp.component(.year, from: selectedDate)
            let month = tmp.component(.month, from: selectedDate)
            let day = tmp.component(.day, from: selectedDate)
            
            let oneDay = "\(year)年\(month)月\(day)日"
            
            let predicate = NSPredicate(format:"date == %@",oneDay)
            
            let selectedShift = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false).filter(predicate).first
            
            self.date.text = selectedShift?.date
            self.detailWork.text = selectedShift?.detailText
            self.smallLabel.text = selectedShift?.smallText
            
            calendar.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
