//
//  Constants.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/10/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit

struct UTManager {
    
    static let colors = [
        UIColor(red:0.988,  green:0.333,  blue:0.333, alpha:1),
        UIColor(red:1,  green:0.451,  blue:0.392, alpha:1),
        UIColor(red:1,  green:0.561,  blue:0.392, alpha:1),
        UIColor(red:0.667,  green:0.333,  blue:0.988, alpha:1),
        UIColor(red:0.408,  green:0.333,  blue:0.988, alpha:1),
        UIColor(red:0.333,  green:0.522,  blue:0.988, alpha:1),
        UIColor(red:0.039,  green:0.639,  blue:0.714, alpha:1),
        UIColor(red:0.039,  green:0.714,  blue:0.580, alpha:1)
    ]
    
    static func getColorFromPercent(percent: Double) -> UIColor {
        if percent >= 1 {
            return colors[7]
        }
        let index = Int(floor(percent/0.125))
        print(index)
        return colors[index]
    }
}
