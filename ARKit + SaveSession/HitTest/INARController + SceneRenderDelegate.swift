//
//  INARController + Scene.swift
//  IndoorsSDK
//
//  Created by Georgy on 16.02.2024.
//  Copyright © 2024 Indoors Navigation LLC. All rights reserved.
//

import SceneKit
import ARKit
extension ARViewController: ARSCNViewDelegate{
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = ARSCNPlaneGeometry(device: MTLCreateSystemDefaultDevice()!) {
            geom.update(from: planeAnchor.geometry)
            geom.firstMaterial?.colorBufferWriteMask = .alpha
            node.geometry = geom
        }
        if let name = anchor.name, name.hasPrefix("cube") {
            let currentNode = SCNNode(geometry: SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0))
            currentNode.geometry?.materials.first?.diffuse.contents = UIColor.red
            node.addChildNode(currentNode)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        if let planeAnchor = anchor as? ARPlaneAnchor, planeAnchor.alignment == .vertical, let geom = node.geometry as? ARSCNPlaneGeometry {
            geom.update(from: planeAnchor.geometry)
        }
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.focusSquare.updateFocusNode()
        }
    }
}
