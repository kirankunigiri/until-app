//
//  CardView.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/10/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit

@IBDesignable
class CardView: UIView {
    
    var contentView: UIView?
    var fillLayer: CALayer?
    var percent: Double = 0 {
        didSet {
            fillLayer!.frame.size.width = CGFloat(percent) * self.frame.size.width
        }
    }
    @IBInspectable var nibName: String?

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        viewSetup()
        contentView?.prepareForInterfaceBuilder()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSetup()
    }
    
    func viewSetup() {
        contentView = loadViewFromNib(nibName: "CardView")
        
        contentView!.layer.masksToBounds = true
        contentView!.clipsToBounds = true
        
        contentView!.layer.cornerRadius = 14
        fillLayer = CALayer()
        fillLayer?.frame = self.bounds
        fillLayer?.backgroundColor = UIColor(red:0.33, green:0.52, blue:0.99, alpha:1.0).cgColor
        self.contentView!.layer.addSublayer(fillLayer!)
        
        percent = 0.24
    }

}
