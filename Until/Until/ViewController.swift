//
//  ViewController.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/10/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var periodCard: CardView!
    @IBOutlet weak var dayCard: CardView!
    
    // MARK: - Properties
    @IBOutlet weak var periodTitleLabel: UILabel!
    @IBOutlet weak var dayTitleLabel: UILabel!
    
    // MARK: - Logic Methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update title label
        titleLabel.text = TimeManager.todayString
        
        // If it's the weekend, end the flow here
        guard 0 ... 4 ~= Date().dayNumberOfWeek()! - 2 else {
            titleLabel.text = "No school today."
            subtitleLabel.text = "Chill and work on some cool stuff."
            periodTitleLabel.text = "The weekend"
            periodCard.percentLabel.text = "No school."
            periodCard.descriptionLabel.text = "Let's get some real work done."
            hideDayViews()
            return
        }
        
        // Load the time manager and run an update cycle
        TimeManager.shared.loadData()
        update()
        
        // Start the timer to update the UI realtime
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    // Constantly update the UI with the new times
    @objc
    func update() {
        
        // Setup all info and variables
        let info = TimeManager.shared.closestDateInfo
        periodTitleLabel.text = info.name
        
        // Difference for period
        let difference = info.date.timeIntervalSince1970 - Date().timeIntervalSince1970
        let periodTimeRemainingText = timeIntervalString(difference)
        
        // Check if school is already over
        if info.state == .afterSchool {
            periodCard.percentLabel.text = "School's over."
            periodCard.descriptionLabel.text = "Let's get some real work done."
            periodCard.percent = 0
            hideDayViews()
            return
        }
        
        // Check if it's before school
        if info.state == .beforeSchool {
            periodCard.percentLabel.text = "Get some sleep."
            periodCard.descriptionLabel.text = periodTimeRemainingText
            periodCard.percent = 0
            hideDayViews()
            return
        }
        
        // The date is now during school. Proceed with all card updates.
        
        // Calculate day card variables
        let dateList = TimeManager.shared.dateList
        let totalTimePassed = Date().timeIntervalSince1970 - dateList[0].timeIntervalSince1970
        let totalTimeDay = dateList[dateList.count - 1].timeIntervalSince1970 - dateList[0].timeIntervalSince1970
        let timeLeftInDay = dateList[dateList.count - 1].timeIntervalSince1970 - Date().timeIntervalSince1970
        let dayTimeRemainingText = timeIntervalString(timeLeftInDay)
        
        // Update period card
        periodCard.percent = 1.0 - difference/info.totalTime
        periodCard.percentLabel.text = "\(Int(periodCard.percent*100))%"
        periodCard.descriptionLabel.text = periodTimeRemainingText
        
        // Update day card
        showDayViews()
        dayCard.percent =  totalTimePassed/totalTimeDay
        dayCard.percentLabel.text = "\(Int(dayCard.percent*100))%"
        dayCard.descriptionLabel.text = dayTimeRemainingText
    }
    
    // MARK: - UI Methods
    func hideDayViews() {
        dayTitleLabel.isHidden = true
        dayCard.isHidden = true
    }
    
    func showDayViews() {
        dayTitleLabel.isHidden = false
        dayCard.isHidden = false
    }
    
    
    
    // MARK: - Debug Methods
    
    /** Prints the entire schedule */
    func printCurrentSchedule() {
        for date in TimeManager.shared.dateList {
            print(timeString(date))
        }
    }
    
    /** Converts a `Date` into a readable string for UI display */
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
    
    /** A secondary method to convert a time interval into a string. Currently not in use */
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
}
