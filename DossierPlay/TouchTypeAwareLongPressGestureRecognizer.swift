//
//  TouchTypeAwareLongPressGestureRecognizer.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import Foundation
import UIKit
import UIKit.UIGestureRecognizerSubclass

class TouchTypeAwareLongPressGestureRecognizer: UILongPressGestureRecognizer {

    var touchType: UITouchType?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        touchType = touches.first?.type
        super.touchesBegan(touches, with: event)
    }
    
}
