//
//  TodayViewController.swift
//  Until Widget
//
//  Created by Kiran Kunigiri on 3/22/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var periodCard: CardView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Update card view UI
        periodCard.contentView?.backgroundColor = UIColor.clear
        periodCard.contentView?.layer.cornerRadius = 0
        periodCard.fillLayer?.frame.size.height = self.view.frame.size.height
        periodCard.percent = 0.8
        
        // If it's the weekend, end the flow here
        guard 0 ... 4 ~= Date().dayNumberOfWeek()! - 2 else {
            periodCard.percentLabel.text = "No school."
            periodCard.descriptionLabel.text = "Let's get some real work done."
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
        
        // Difference for period
        let difference = info.date.timeIntervalSince1970 - Date().timeIntervalSince1970
        let periodTimeRemainingText = timeIntervalString(difference)
        
        // Check if school is already over
        if info.state == .afterSchool {
            periodCard.percentLabel.text = "School's over."
            periodCard.descriptionLabel.text = "Let's get some real work done."
            periodCard.percent = 0
            return
        }
        
        // Check if it's before school
        if info.state == .beforeSchool {
            periodCard.percentLabel.text = "Get some sleep."
            periodCard.descriptionLabel.text = periodTimeRemainingText
            periodCard.percent = 0
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
        periodCard.percentLabel.text = periodTimeRemainingText
        periodCard.descriptionLabel.text = "\(Int(periodCard.percent*100))%"
    }
    
    /** Returns a string in hh:mm format given a `TimeInterval` */
    func timeIntervalString(_ interval: TimeInterval) -> String {
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .positional
        return dateComponentsFormatter.string(from: interval)!
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
}
