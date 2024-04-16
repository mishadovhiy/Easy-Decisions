//
//  Constance.swift
//  Decisions
//
//  Created by Misha Dovhiy on 03.07.2020.
//  Copyright © 2020 Misha Dovhiy. All rights reserved.
//

import UIKit

struct Colors {
    
    static let background = UIColor.init(named: "backgroundColor")
    static let gray = UIColor.init(named: "GreyColor")
    static let purple = UIColor.init(named: "purpleColor")
    static let blue = UIColor.init(named: "blueColor")
    static let title = UIColor.init(named: "titleColor")
    static let text = UIColor.init(named: "textColor")
    static let yellow = UIColor.init(named: "yellowColor")
    static let orange = UIColor.init(named: "orangeColor")
    static let lightGrey = UIColor.init(named: "lightGreyColor")
    static let lightYellow = UIColor.init(named: "lightYellowColor")
    static let success = UIColor.init(named: "successColor")
    static let error = UIColor.init(named: "errorColor")
}

extension UIViewController {
    var brain: AppBrain {
        get {
            return AppDelegate.shared?.brain ?? .init()
        }
        set {
            AppDelegate.shared?.brain = newValue
        }
    }
}
