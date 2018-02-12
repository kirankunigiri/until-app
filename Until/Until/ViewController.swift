//
//  ViewController.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/10/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var periodCard: CardView!
    @IBOutlet weak var dayCard: CardView!
    
    // MARK: Properties
    @IBOutlet weak var periodTitleLabel: UILabel!
    @IBOutlet weak var dayTitleLabel: UILabel!
    var schedule: TimeManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timer), userInfo: nil, repeats: true)
    }
    
    @objc
    func timer() {
        
        // Check if it's the weekend
        guard 0 ... 4 ~= Date().dayNumberOfWeek()! - 2 else {
            periodCard.percentLabel.text = "No school!"
            periodCard.descriptionLabel.text = "Let's get some real work done."
            dayCard.isHidden = true
            return
        }
        
        let info = schedule.closestDateInfo
        periodTitleLabel.text = info.name
        let difference = info.date.timeIntervalSince1970 - Date().timeIntervalSince1970
        let timeRemaining = timeIntervalString(difference)
        
        // Check if school is already over
        if info.state == .afterSchool {
            periodCard.percentLabel.text = "School's over!"
            periodCard.descriptionLabel.text = "Let's get some real work done."
            periodCard.percent = 0
            dayTitleLabel.isHidden = true
            dayCard.isHidden = true
            return
        }
        
        // Check if it's before school
        if info.state == .beforeSchool {
            periodCard.percentLabel.text = "Get some sleep."
            periodCard.descriptionLabel.text = "\(timeRemaining)"
            periodCard.percent = 0
            dayTitleLabel.isHidden = true
            dayCard.isHidden = true
            return
        }
        
        
        dayTitleLabel.isHidden = false
        dayCard.isHidden = false
        
        periodCard.percent = 1.0 - difference/info.totalTime
        periodCard.percentLabel.text = "\(Int(periodCard.percent*100))%"
        periodCard.descriptionLabel.text = "\(timeRemaining)"
        
//        print(stringFromTimeInterval(interval: difference))
//        print("\(periodCard.percent)%")
//        print("difference \(difference) ||| total time \(info.totalTime)")
//        print("\(info.name) ends at \(timeString(info.date))")
        
//        scheduleTimeView.timeLabel.text = stringFromTimeInterval(interval: difference)
//        scheduleTimeView.progress = 1.0 - difference/info.totalTime
//        scheduleTimeView.descriptionLabel.text = "\(info.name) ends at \(timeString(date: info.date))"
    }
    
    func loadData() {
        let url = Bundle.main.url(forResource: "agenda", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let json = JSON(data: data)
        let arr = json.first!.1.array!
        print(arr[0])
        
        let dayIndex = Date().dayNumberOfWeek()!-2
        print(dayIndex)
        schedule = TimeManager(list: arr[dayIndex].arrayObject as! [String])
        printCurrentSchedule()
        
        print("Closest date")
//        if let date = schedule.closestDateInfo.date {
//            print(timeString(date))
//        } else {
//            print("School is already over!")
//        }
        print(timeString(schedule.closestDateInfo.date))
        print("Current date")
        print(timeString(Date()))
        
    }
    
    func printCurrentSchedule() {
        for date in schedule.dateList {
            print(timeString(date))
        }
    }
    
    func timeString(_ date: Date) -> String {
        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = "hh:mm"
        return outFormatter.string(from: date)
    }
    
    /** Returns a string in hh:mm format given a `TimeInterval` */
    func timeIntervalString(_ interval: TimeInterval) -> String {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .positional
        return dateComponentsFormatter.string(from: interval)!
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}



class TimeManager {
    
    var nameList: [String] = []
    var dateList: [Date] = []
    
    init(list: [String]) {
        for string in list {
            let components = string.components(separatedBy: "@")
            let name = components[0]
            nameList.append(name)
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            let oldDate = formatter.date(from: components[1])!
            
            
            //gather current calendar
            let calendar = Calendar.current
            //gather date components from date
            var oldDateComponents: DateComponents? = calendar.dateComponents(([.year, .month, .day, .hour, .minute, .second]), from: oldDate)
            var newDateComponents: DateComponents? = calendar.dateComponents(([.year, .month, .day, .hour, .minute, .second]), from: Date())
            //set date components
            newDateComponents?.hour = oldDateComponents?.hour
            newDateComponents?.minute = oldDateComponents?.minute
            newDateComponents?.second = oldDateComponents?.second
            //save date relative from date
            let newDate = calendar.date(from: newDateComponents!)!
            
            dateList.append(newDate)
        }
    }
    
    var closestDateInfo: (date: Date, totalTime: TimeInterval, name: String, state: UTState) {
        let currentDate = Date()
        for i in 0..<dateList.count-1 {
            let currentmin = currentDate.timeIntervalSince(dateList[i])
            // School has not started yet
            if i == 0 && currentmin < 0 {
                return (dateList[0], -currentmin, nameList[0], UTState.beforeSchool)
            }
            // School is already over
            if i == 6 && currentmin > 0 {
                return (Date(), 0, "After School", UTState.afterSchool)
            }
            // Get the next period that hasn't passed already
            if currentmin < 0 && i > 0 {
                var totalTime: TimeInterval = 0
                totalTime = dateList[i].timeIntervalSince1970 - dateList[i-1].timeIntervalSince1970
                return (dateList[i], totalTime, nameList[i], UTState.duringSchool)
            }
        }
        // Unknown
        return (Date(), -1, "Error", .noSchool)
    }
    
    func printDates() {
        let outFormatter = DateFormatter()
        outFormatter.locale = Locale(identifier: "en_US_POSIX")
        outFormatter.dateFormat = "hh:mm"
        for date in dateList {
            print(outFormatter.string(from: date))
        }
        print("\n")
    }
    
}



extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}
