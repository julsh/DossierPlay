//
//  ViewController.swift
//  DossierPlay
//
//  Created by Julia Roggatz on 10.03.18.
//  Copyright © 2018 Julia Roggatz. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ViewController: UIViewController {

    var pinchDidTriggerSaveOrLoad: Bool = false

    @IBOutlet var gridView: GridView!
    var squareModels: [SquareModel] = []
    let persistenceService = PersistenceService()

    override func viewDidLoad() {
        super.viewDidLoad()
        gridView.gridMode = .fixed(size: CGSize(width: 25.0, height: 25.0))

        squareModels = [
            SquareModel(color: UIColor.red, location: CGPoint(x: 100, y: 100)),
            SquareModel(color: UIColor.blue, location: CGPoint(x: 500, y: 100))
        ]

        for square in squareModels.map({ $0.square }) {
            view.addSubview(square)
            let longPress = TouchTypeAwareLongPressGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
            longPress.minimumPressDuration = 0.05
            square.addGestureRecognizer(longPress)
        }

        view.addGestureRecognizer(UIPinchGestureRecognizer(target: self, action: #selector(didPinch(gesture:))))
    }

    @objc func didPinch(gesture: UIPinchGestureRecognizer) {
        if gesture.state == .began {
            pinchDidTriggerSaveOrLoad = false
        }
        guard pinchDidTriggerSaveOrLoad == false else {
            return
        }
        if gesture.scale > 2.0 {
            print("saving..")
            pinchDidTriggerSaveOrLoad = true
        } else if gesture.scale < 0.5 {
            print("loading..")
            pinchDidTriggerSaveOrLoad = true
        }
    }

    @objc func didTap(gesture: TouchTypeAwareLongPressGestureRecognizer) {
        guard
            let square = gesture.view,
            let index = squareModels.index(where: { $0.square == square }),
            let touchType = gesture.touchType
        else {
            return
        }

        let squareModel = squareModels[index]

        switch gesture.state {
        case .began:
            view.bringSubview(toFront: square)
            UIView.animate(withDuration: 0.1) {
                square.brighten()
            }
            squareModel.pickupOrigin = gesture.location(in: square)
        case .changed:
            let absoluteLocation = gesture.location(in: view)
            var frame = square.frame
            if let pickupOrigin = squareModel.pickupOrigin {
                frame.origin.x = absoluteLocation.x - pickupOrigin.x
                frame.origin.y = absoluteLocation.y - pickupOrigin.y
            } else {
                frame.origin = absoluteLocation
            }
            square.frame = frame
        case .ended, .cancelled:
            UIView.animate(withDuration: 0.1) {
                squareModel.square.backgroundColor = squareModel.color
                if touchType != .stylus {
                    self.snapToGrid(square: square)
                }
            }
        default:
            return
        }
    }

    func snapToGrid(square: UIView) {
        var frame = square.frame
        let columnIndex = round(frame.origin.x / gridView.gridSize.width)
        let rowIndex = round(frame.origin.y / gridView.gridSize.height)
        let snapLocation = CGPoint(x: columnIndex * gridView.gridSize.width,
                                   y: rowIndex * gridView.gridSize.height)
        frame.origin = snapLocation
        square.frame = frame
    }

    func save(sender: AnyObject) {
        if persistenceService.isAuthorized {
            persistenceService.saveModels()
        } else {
            persistenceService.authorize(from: self)
        }
    }

}

