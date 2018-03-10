//
//  SquareModelSerializer.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import Foundation
import UIKit

public class SquareModel: NSObject {

    let locationKey = "location"
    let xKey = "x"
    let yKey = "y"

    let colorKey = "color"

    let squareSize = CGSize(width: 200, height: 200)

    var square: UIView
    var pickupOrigin: CGPoint?
    var color: UIColor

    public init(color: UIColor, location: CGPoint) {
        let square = UIView(frame: CGRect(origin: location, size: squareSize))
        square.backgroundColor = color
        square.layer.borderColor = UIColor.black.cgColor
        square.layer.borderWidth = 2.0
        self.square = square
        self.color = color
    }

    public var toDict: [String: Any] {
        let dict: [String: Any] = [
            locationKey: [
                xKey: square.frame.origin.x,
                yKey: square.frame.origin.y
            ],
            colorKey: [
                color.toDict
            ]
        ]
        return dict
    }
    
}

extension UIColor {

    public var toDict: [String: Any] {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        self.getRed(&red, green: &green, blue: &blue, alpha: nil)
        return [
            "red" : red,
            "green" : green,
            "blue" : blue,
        ]
    }
}
