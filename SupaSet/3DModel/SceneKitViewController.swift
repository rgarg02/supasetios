//
//  SceneKitViewController.swift
//  SupaSet
//
//  Created by Rishi Garg on 9/15/25.
//

import SwiftUI
import SceneKit
struct SceneKitContainer: UIViewRepresentable {
    // Bindings
    @Binding var selectedMuscle: MuscleGroup?
    let interactable: Bool
    var activePrimaryMuscles: Set<MuscleGroup>?
    var activeSecondaryMuscles: Set<MuscleGroup>?
    // Constants
    let modelName: String = "Male_Grouped.dae"
    let cameraPosition = SCNVector3(x: 0, y: 0, z: 10)
    let cameraRotation = SCNVector4(1, 0, 0, 1.5707963)
    let cameraFov = 45.0
    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        
        // Load the model
        let scene = SCNScene(named: modelName)
        sceneView.scene = scene
        applyDefaultMaterials(to: scene?.rootNode)
        // Enable user interaction
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = true
        sceneView.allowsCameraControl = true
        sceneView.backgroundColor = UIColor.clear
        sceneView.antialiasingMode = .none
        sceneView.defaultCameraController.maximumVerticalAngle = 0.001
        if interactable {
            let tapGesture = UITapGestureRecognizer(
                target: context.coordinator,
                action: #selector(Coordinator.handleTap(_:))
            )
            sceneView.addGestureRecognizer(tapGesture)
        }
        context.coordinator.initialTransform = sceneView.pointOfView?.transform
        return sceneView
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: SceneKitContainer
        var initialTransform: SCNMatrix4?
        init(_ parent: SceneKitContainer) {
            self.parent = parent
        }
        private var selectedNode: SCNNode?
        let cameraPosition = SCNVector3(x: 0, y: 0, z: 10)
        let cameraRotation = SCNVector4(1, 0, 0, 1.5707963)
        let cameraFov = 45.0
        @MainActor @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            guard let sceneView = gesture.view as? SCNView else { return }
            
            let location = gesture.location(in: sceneView)
            let hitResults = sceneView.hitTest(location, options: [:])
            
            if let hit = hitResults.first {
                let tappedNode = hit.node
                if let muscle = MuscleGroup(rawValue: tappedNode.name ?? "") {
                    selectMuscle(muscle: muscle, node: tappedNode, in: sceneView)
                }
            }
        }
        @MainActor private func selectMuscle(muscle: MuscleGroup, node: SCNNode, in sceneView: SCNView) {
            if parent.selectedMuscle == nil || parent.selectedMuscle != muscle {
                if let selectedNode {
                    unhighlight(node: selectedNode)
                }
                selectedNode = node
                parent.selectedMuscle = muscle
                zoomOn(node: node, in: sceneView)
                highlight(node: node)
            } else {
                selectedNode = nil
                unhighlight(node: node)
                resetZoom(in: sceneView)
                parent.selectedMuscle = nil
            }
        }
        @MainActor private func unhighlight(node: SCNNode) {
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            node.geometry?.materials.forEach { material in
                parent.applyDefaultMaterial(to: material)
            }
            SCNTransaction.commit()
        }
        @MainActor private func resetZoom(in sceneView: SCNView) {
            guard let cameraNode = sceneView.pointOfView else { return }
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            cameraNode.transform = initialTransform!
            SCNTransaction.commit()
        }
        @MainActor private func highlight(node: SCNNode) {
            
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            node.geometry?.materials.forEach { material
                in
                material.diffuse.contents = UIColor.red
            }
            SCNTransaction.commit()
        }
        @MainActor private func zoomOn(node: SCNNode, in sceneView: SCNView) {
            guard let cameraNode = sceneView.pointOfView else { return }
            
            // Get the bounding box center of the tapped muscle
            let (minVec, maxVec) = node.boundingBox
            let center = SCNVector3(
                (minVec.x + maxVec.x) / 2,
                (minVec.y + maxVec.y) / 2,
                (minVec.z + maxVec.z) / 2
            )
            
            // Convert to world position
            let worldCenter = node.convertPosition(center, to: nil)
            let isFront = worldCenter.y <= 0
            // Distance: scale with muscle size so bigger muscles are framed
            let muscleSize = max(maxVec.x - minVec.x,
                                 maxVec.y - minVec.y,
                                 maxVec.z - minVec.z)
            let distance: Float = Float(muscleSize) * 2.5
            
            // Place camera along +Y axis (side view), looking inward
            let zoomPosition: SCNVector3
                if isFront {
                    // Place camera in front of body
                    zoomPosition = SCNVector3(worldCenter.x,
                                              worldCenter.y - distance,
                                              worldCenter.z)
                } else {
                    // Place camera behind body
                    zoomPosition = SCNVector3(worldCenter.x,
                                              worldCenter.y + distance,
                                              worldCenter.z)
                }
            
            // Animate camera move & orientation
            SCNTransaction.begin()
            SCNTransaction.animationDuration = 1.0
            cameraNode.camera?.fieldOfView = cameraFov
            cameraNode.rotation = cameraRotation
            cameraNode.position = zoomPosition
            cameraNode.look(at: worldCenter)
            SCNTransaction.commit()
        }

    }
    func updateUIView(_ uiView: SCNView, context: Context) {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.65 // Adjust duration as needed
        SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        // 1. First, reset all materials to default
        applyDefaultMaterials(to: uiView.scene?.rootNode)
        
        // 2. Then, apply the new highlights
        if let primary = activePrimaryMuscles, let secondary = activeSecondaryMuscles {
            applyHighlights(to: primary, secondaryMuscles: secondary, in: uiView)
        }
        
        SCNTransaction.commit()
    }
    private func applyDefaultMaterials(to node: SCNNode?) {
        guard let node = node else { return }
        
        if let geometry = node.geometry {
            geometry.materials.forEach { material in
                applyDefaultMaterial(to: material)
            }
        }
        
        // Recursively apply to children
        for child in node.childNodes {
            applyDefaultMaterials(to: child)
        }
    }
    private func applyDefaultMaterial(to material: SCNMaterial, highlightedMuscles: [MuscleGroup]? = nil) {
        material.lightingModel = .physicallyBased
        material.diffuse.contents = UIColor(red: 0.85, green: 0.85, blue: 0.85, alpha: 1.0) // neutral light gray
        material.metalness.contents = 0.05  // almost non-metallic
        material.roughness.contents = 0.7   // matte, soft
        material.specular.contents = UIColor(white: 1.0, alpha: 0.2) // subtle highlights
        material.transparency = 1.0
        material.isDoubleSided = true
    }
    private func applyHighlights(to primaryMuscles: Set<MuscleGroup>, secondaryMuscles: Set<MuscleGroup>, in sceneView: SCNView) {
        sceneView.scene?.rootNode.childNodes.forEach { node in
            if secondaryMuscles.map({$0.rawValue}).contains(node.name) {
                node.geometry?.materials.forEach { material in
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = UIColor.systemYellow
                    material.metalness.contents = 0.05  // almost non-metallic
                    material.roughness.contents = 0.7   // matte, soft
                    material.specular.contents = UIColor(white: 1.0, alpha: 0.2) // subtle highlights
                    material.transparency = 1.0
                    material.isDoubleSided = true
                }
            }
            if primaryMuscles.map({$0.rawValue}).contains(node.name) {
                node.geometry?.materials.forEach { material in
                    material.lightingModel = .physicallyBased
                    material.diffuse.contents = UIColor.systemRed
                    material.metalness.contents = 0.05  // almost non-metallic
                    material.roughness.contents = 0.7   // matte, soft
                    material.specular.contents = UIColor(white: 1.0, alpha: 0.2) // subtle highlights
                    material.transparency = 1.0
                    material.isDoubleSided = true
                }
            }
        }
    }
}

#Preview {
    SceneKitContainer(selectedMuscle: .constant(nil), interactable: true)
}
