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
        self.backgroundColor = backgroundColor.brighterColor()
    }

}

extension UIView {

    @discardableResult   // 1
    func fromNib<T : UIView>() -> T? {   // 2
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)?.first as? T else {    // 3
            // xib not loaded, or its top view is of the wrong type
            return nil
        }
        self.addSubview(contentView)     // 4
        contentView.translatesAutoresizingMaskIntoConstraints = false   // 5
        return contentView   // 7
    }
}
