//
//  UIView+Utils.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import Foundation
import UIKit

public extension UIView {

    func brighten() {
        guard let backgroundColor = backgroundColor else {
            return
        }
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let newColor = UIColor(red: min(red + 0.4, 1.0),
                               green: min(green + 0.4, 1.0),
                               blue: min(blue + 0.4, 1.0),
                               alpha: alpha)
        self.backgroundColor = newColor
    }

}

