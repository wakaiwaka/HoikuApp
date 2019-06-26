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
import CSS3ColorsSwift

class CalendarViewController: UIViewController, FSCalendarDataSource,FSCalendarDelegate,FSCalendarDelegateAppearance{
    
    let realm = try! Realm()
    
    fileprivate weak var calendar:FSCalendar!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var smallLabel: UILabel!
    @IBOutlet weak var detailWork: UILabel!
    @IBOutlet weak var naviBar: UINavigationItem!
    
    
    fileprivate var selectDate:Date = Date()
    
    var allShiftArray = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "シフト"
        self.naviBar.title = "シフト"
        setUpView()
    }
    
    //休日の判定
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
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, subtitleDefaultColorFor date: Date) -> UIColor? {
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        
        let oneDay = "\(year)年\(month)月\(day)日"
        
        let predicate = NSPredicate(format: "date == %@", oneDay as CVarArg)
        let selectedShift = try! Realm().objects(Shift.self).sorted(byKeyPath: "date",ascending: false).filter(predicate).first
        
        appearance.subtitleFont = UIFont.systemFont(ofSize: 15)
        
        let dataList = [0:"早番",1:"日勤",2:"遅番",3:"休み",4:"日早",5:"日遅",6:"延長",7:"午前半",8:"午後半",9:"有休",10:"夜間"]
        
        
        if selectedShift?.detailWork == dataList[0]{
            return UIColor.blue
        }else if selectedShift?.detailWork == dataList[1]{
            return UIColor.magenta
        }else if selectedShift?.detailWork == dataList[2]{
            return UIColor.orange
        }else if selectedShift?.detailWork == dataList[3]{
            return UIColor.red
        }else if selectedShift?.detailWork == dataList[4]{
            return UIColor.green
        }else if selectedShift?.detailWork == dataList[5]{
            return UIColor.hotPink
        }else if selectedShift?.detailWork == dataList[6]{
            return UIColor.skyBlue
        }else if selectedShift?.detailWork == dataList[7]{
            return UIColor.tomato
        }else if selectedShift?.detailWork == dataList[8]{
            return UIColor.khaki
        }else if selectedShift?.detailWork == dataList[9]{
            return UIColor.cyan
        }else if selectedShift?.detailWork == dataList[10]{
            return UIColor.purple
        }
        return UIColor.black
    }
    /// カレンダー内をタップした時にその日付のタイトルや予定を下に表示する、内容がない場合はシフト作成するように促す
    ///
    /// - Parameters:
    ///   - calendar: FSCalendar
    ///   - date: 選択された日付
    ///   - monthPosition:
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
            self.detailWork.text = "作成編集ボタンをタップして予定を作成しよう！"
        }else{
            self.smallLabel.text = selectedShift?.smallText
            self.detailWork.text = selectedShift?.detailText
        }
    }
    
    //カレンダーの選択した場所の色を指定
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        return UIColor.orange
    }
    
    //カレンダーの今日の日にちの色
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        
        let tmpDate = Calendar(identifier: .gregorian)
        let year = tmpDate.component(.year, from: date)
        let month = tmpDate.component(.month, from: date)
        let day = tmpDate.component(.day, from: date)
        let oneDay = "\(year)年\(month)月\(day)日"
        
        
        let today = Date()
        
        let todayYear = tmpDate.component(.year, from: today)
        let todayMonth = tmpDate.component(.month, from: today)
        let todayDay = tmpDate.component(.day, from: today)
        
        let Today = "\(todayYear)年\(todayMonth)月\(todayDay)日"
        
        if oneDay == Today{
            return UIColor.mediumAquamarine
        }
        return nil
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
        
        let smallLabelBorder = UIView(frame: CGRect(x: 0, y: smallLabel.frame.height - 0.3, width: smallLabel.frame.width, height: 0.3))
        
        smallLabelBorder.backgroundColor = UIColor.orange
        
        smallLabel.addSubview(smallLabelBorder)
        
    }
    
    
    @IBAction func createsShift(_ sender: Any) {
        let nc = self.storyboard?.instantiateViewController(withIdentifier:"EurekaCreatePlansNavi" ) as! UINavigationController
        
        let createPlansViewController = nc.topViewController as! EurekaCreatePlansViewController
        
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
                //選択された日の予定が作成されていない場合の時の動き
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
        //カレンダー内に午前、午後などのシフト内容を記入する。
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
        
        //選択された日付が空ではない場合の処理
        if let selectedDate = selectedDate{
            
            
            let tmp = Calendar(identifier: .gregorian)
            let year = tmp.component(.year, from: selectedDate)
            let month = tmp.component(.month, from: selectedDate)
            let day = tmp.component(.day, from: selectedDate)
            
            //上記の情報より選択されたデータを取得する
            let oneDay = "\(year)年\(month)月\(day)日"
            
            let predicate = NSPredicate(format:"date == %@",oneDay)
            
            //選択された日付のデータをRealmより取ってくる
            let selectedShift = try! Realm().objects(Shift.self).sorted(byKeyPath: "date", ascending: false).filter(predicate).first
            
            //カレンダーの下にタイトルと詳細を表示する
            self.date.text = selectedShift?.date
            self.detailWork.text = selectedShift?.detailText
            self.smallLabel.text = selectedShift?.smallText
            
            //カレンダーをリロードする
            calendar.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
