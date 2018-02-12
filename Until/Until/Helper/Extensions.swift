//
//  Extensions.swift
//  Until
//
//  Created by Kiran Kunigiri on 2/10/18.
//  Copyright © 2018 Kiran Kunigiri. All rights reserved.
//

import UIKit

extension UIView {
    
    func loadViewFromNib(nibName: String)  -> UIView? {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil).first as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        self.backgroundColor = UIColor.clear
        return view
    }
    
}
