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

    @IBOutlet var toolbarContainer: UIView!
    @IBOutlet var gridView: GridView!

    @IBOutlet var kineticsSwitch: UISwitch!
    @IBOutlet var gridSizeSlider: UISlider!
    @IBOutlet var gridSizeLabel: UILabel!
    
    var squareModels: [SquareModel] = []
    let persistenceService = PersistenceService()

    var animator: UIDynamicAnimator?
    var attachment: UIAttachmentBehavior?
    var collisionBehavior: UICollisionBehavior?
    var noRotationBehavior: UIDynamicItemBehavior?

    let colors: [UIColor] = [
        UIColor(hexString: "BF1363"),
        UIColor(hexString: "0E79B2"),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        setupToolBarAppearance()
        setupGridSlider()
        enablePhysics()
        addInitialSquares()
    }

    func setupToolBarAppearance() {
        toolbarContainer.layer.shadowOffset = CGSize(width: 0, height: 3)
        toolbarContainer.layer.shadowColor = UIColor.black.cgColor
        toolbarContainer.layer.shadowOpacity = 0.3
    }

    func setupGridSlider() {
        gridSizeSlider.minimumValue = 4
        gridSizeSlider.maximumValue = 256
        gridSizeSlider.value = 64
        updateGrid(with: CGFloat(gridSizeSlider.value))
    }

    func addInitialSquares() {
        squareModels = [
            SquareModel(color: colors[0], location: CGPoint(x: 100, y: 100)),
            SquareModel(color: colors[1], location: CGPoint(x: 500, y: 100))
        ]

        for square in squareModels.map({ $0.square }) {
            addSquareToGrid(square)
        }
    }

    func enablePhysics() {
        animator = UIDynamicAnimator(referenceView: gridView)

        let collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior.translatesReferenceBoundsIntoBoundary = true

        let noRotationBehavior = UIDynamicItemBehavior(items: [])
        noRotationBehavior.allowsRotation = false
        animator?.addBehavior(noRotationBehavior)

        self.collisionBehavior = collisionBehavior
        self.noRotationBehavior = noRotationBehavior
    }

    func enableCollisionDetection() {
        guard let collisionBehavior = collisionBehavior else {
            return
        }
        animator?.addBehavior(collisionBehavior)

        for square in squareModels.map( { $0.square } ) {
            self.collisionBehavior?.addItem(square)
        }
    }

    func disableCollisionDetection() {
        guard let collisionBehavior = collisionBehavior else {
            return
        }
        for item in collisionBehavior.items {
            collisionBehavior.removeItem(item)
        }
        animator?.removeBehavior(collisionBehavior)
    }

    func addSquareToGrid(_ square: UIView) {
        gridView.addSubview(square)
        addGestureRecognition(to: square)
        noRotationBehavior?.addItem(square)
    }

    func addGestureRecognition(to square: UIView) {
        let longPress = TouchTypeAwareLongPressGestureRecognizer(target: self, action: #selector(didTap(gesture:)))
        longPress.minimumPressDuration = 0.05
        square.addGestureRecognizer(longPress)
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
            gridView.bringSubview(toFront: square)
            UIView.animate(withDuration: 0.1) {
                square.brighten()
            }
            let absoluteLocation = gesture.location(in: gridView)
            let relativeLocation = gesture.location(in: square)
            squareModel.pickupOffset = UIOffset(horizontal: relativeLocation.x - square.bounds.midX,
                                                vertical: relativeLocation.y - square.bounds.midY)
            print("picked up from location \(absoluteLocation) with \(squareModel.pickupOffset!)")
            attachment = UIAttachmentBehavior(item: square, offsetFromCenter: squareModel.pickupOffset!, attachedToAnchor: absoluteLocation)
            animator?.addBehavior(attachment!)
        case .changed:
            let absoluteLocation = gesture.location(in: gridView)
            attachment?.anchorPoint = absoluteLocation
        case .ended, .cancelled:
            self.disableCollisionDetection()
            animator?.removeAllBehaviors()
            UIView.animate(withDuration: 0.05, animations: {
                squareModel.square.backgroundColor = squareModel.color
                if touchType != .stylus {
                    self.snapToGrid(square: square)
                }
            }, completion: { completed in
                self.animator?.addBehavior(self.noRotationBehavior!)
                if self.kineticsSwitch.isOn {
                    self.enableCollisionDetection()
                }
            })
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

    func save() {
        if persistenceService.isAuthorized {
            persistenceService.saveModels(squareModels)
        } else {
            persistenceService.authorize(from: self)
        }
    }

    @IBAction func kineticsSwitchFlipped(_ switchy: UISwitch) {
        if switchy.isOn {
            enableCollisionDetection()
        } else {
            disableCollisionDetection()
        }
    }

    @IBAction func sliderValueChanged(_ slider: UISlider) {
        updateGrid(with: CGFloat(slider.value))
    }

    @IBAction func addSquare(_ sender: UIButton) {
        guard squareModels.count < 5 else {
            return
        }
        let color = squareModels.count % 2 == 0 ? colors[0] : colors[1]
        let newSquareModel = SquareModel(color: color, location: CGPoint(x: gridView.center.x - SquareModel.squareSize.width,
                                                                         y: gridView.center.y - SquareModel.squareSize.height))
        squareModels.append(newSquareModel)
        addSquareToGrid(newSquareModel.square)
        if kineticsSwitch.isOn {
            self.collisionBehavior?.addItem(newSquareModel.square)
        }
    }

    func updateGrid(with value: CGFloat) {
        gridView.gridMode = .fixed(size: CGSize(width: value, height: value))
        gridSizeLabel.text = "\(Int(value))px"
    }

}

