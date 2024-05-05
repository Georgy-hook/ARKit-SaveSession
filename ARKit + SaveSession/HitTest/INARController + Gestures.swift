//
//  INARController + Gestures.swift
//  IndoorsSDK
//
//  Created by Georgy on 16.02.2024.
//  Copyright © 2024 Indoors Navigation LLC. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
//import SCNPath

extension ARViewController: UIGestureRecognizerDelegate {
    func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.delegate = self
        self.view.addGestureRecognizer(tapGesture)
    }

    @IBAction func handleTap(_ gestureRecognizer: UITapGestureRecognizer) {
        guard gestureRecognizer.state == .ended else {
            return
        }
        if self.focusSquare.state != .initializing {
            let currentNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
            currentNode.geometry?.materials.first?.diffuse.contents = UIColor.red
            currentNode.position = focusSquare.position
            
            // Hit test to find a place for a virtual object.
            guard let hit = sceneView
                .hitTest(gestureRecognizer.location(in: sceneView), types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
                .first
                else { return }
            // Place an anchor for a virtual character. The model appears in renderer(_:didAdd:for:).
            let anchor = ARAnchor(name: "cube", transform: hit.worldTransform)
            sceneView.session.add(anchor: anchor)
            // Send the anchor info to peers, so they can place the same content.
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
            UserDefaults.standard.set(data, forKey: self.anchorDataKey)
            UserDefaults.standard.synchronize()

            
        }
        }
    
}
