//
//  GridView.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import Foundation
import UIKit

enum GridMode {
    case fixed(size: CGSize)
    case adaptive(rows: Int, columns: Int)
}

class GridView: UIView {

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = UIColor(hexString: "FAFAFF")
    }

    public var gridMode: GridMode = .fixed(size: CGSize(width: 50.0, height: 50.0)) {
        didSet {
            setNeedsDisplay()
        }
    }

    public var gridSize: CGSize {
        switch gridMode {
        case .fixed(let size):
            return size
        case .adaptive(let rows, let columns):
            let gridWidth = bounds.size.width / CGFloat(columns)
            let gridHeight = bounds.size.height / CGFloat(rows)
            return CGSize(width: gridWidth, height: gridHeight)
        }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context: CGContext = UIGraphicsGetCurrentContext() else {
            return
        }

        context.beginPath()

        let gridSize = self.gridSize

        var x: CGFloat = gridSize.width
        while x < rect.maxX {
            context.move(to: CGPoint(x: x, y: rect.minY))
            context.addLine(to: CGPoint(x: x, y: rect.maxY))
            x += gridSize.width
        }
        var y: CGFloat = gridSize.height
        while y < rect.maxY {
            context.move(to: CGPoint(x: rect.minX, y: y))
            context.addLine(to: CGPoint(x: rect.maxX, y: y))
            y += gridSize.height
        }

        context.closePath()
        context.setLineWidth(1.0)
//        context.setStrokeColor(UIColor(white: 0, alpha: 0.4).cgColor)
        context.setStrokeColor(UIColor(hexString: "F2EBE6").cgColor)
        context.strokePath()
    }
}
