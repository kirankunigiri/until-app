//
//  TimeManager.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/12/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import Foundation

class TimeManager {
    
    static let shared = TimeManager()
    
    var nameList: [String] = []
    var dateList: [Date] = []
    
    /** Loads the schedule from the JSON file */
    func loadData() {
        let url = Bundle.main.url(forResource: "agenda", withExtension: "json")!
        let data = try! Data(contentsOf: url)
        
        let json = JSON(data: data)
        let arr = json.first!.1.array!
        
        let dayIndex = Date().dayNumberOfWeek()! - 2
        self.setup(list: arr[dayIndex].arrayObject as! [String])
    }
    
    /** Sets up the dates */
    func setup(list: [String]) {
        for string in list {
            let components = string.components(separatedBy: "@")
            let name = components[0]
            nameList.append(name)
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.dateFormat = "HH:mm"
            let oldDate = formatter.date(from: components[1])!
            
            
            // Gather current calendar
            let calendar = Calendar.current
            // Gather date components from date
            var oldDateComponents: DateComponents? = calendar.dateComponents(([.year, .month, .day, .hour, .minute, .second]), from: oldDate)
            var newDateComponents: DateComponents? = calendar.dateComponents(([.year, .month, .day, .hour, .minute, .second]), from: Date())
            // Set date components
            newDateComponents?.hour = oldDateComponents?.hour
            newDateComponents?.minute = oldDateComponents?.minute
            newDateComponents?.second = oldDateComponents?.second
            // Save date relative from date
            let newDate = calendar.date(from: newDateComponents!)!
            
            dateList.append(newDate)
        }
    }
    
    /** Returns information about the closest time */
    var closestDateInfo: (date: Date, totalTime: TimeInterval, name: String, state: UTState) {
        let currentDate = Date()
        for i in 0..<dateList.count {
            let currentmin = currentDate.timeIntervalSince(dateList[i])

            // School has not started yet
            if i == 0 && currentmin < 0 {
                return (dateList[0], -currentmin, nameList[0], UTState.beforeSchool)
            }
            // School is already over
            if i == dateList.count-1 && currentmin > 0 {
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
    
    /** Returns the current date as a readable string */
    static var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM. dd"
        return formatter.string(from: Date())
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


// An extension to return the day of the week
extension Date {
    func dayNumberOfWeek() -> Int? {
        return Calendar.current.dateComponents([.weekday], from: self).weekday
    }
}

