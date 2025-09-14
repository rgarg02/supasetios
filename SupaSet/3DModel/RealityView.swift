import SwiftUI
import RealityKit

struct RealityKitView: View {
    @State private var root: Entity?

    var body: some View {
        GeometryReader { geo in
            RealityView { content in
                // Load once
                if root == nil {
                    if let model = try? await Entity(named: "Male", in: .main) {
                        // 1) Center the model at world origin using visual bounds
                        let vb = model.visualBounds(recursive: true, relativeTo: nil)
                        model.position -= vb.center  // center the whole hierarchy
                        
                        // 2) Create and configure a camera
                        let cam = PerspectiveCamera()
                        cam.camera.fieldOfViewOrientation = .vertical
                        cam.camera.fieldOfViewInDegrees = 60   // pick a comfortable FOV
                        
                        // 3) Compute view aspect and horizontal FOV
                        let aspect = Float(max(geo.size.width, 1) / max(geo.size.height, 1))
                        let vFOV = Float(cam.camera.fieldOfViewInDegrees) * .pi / 180
                        let hFOV = 2 * atan(tan(vFOV / 2) * aspect)
                        
                        // 4) Choose a camera distance and compute uniform scale to fit
                        let distance: Float = 1.0  // meters from camera to origin
                        let maxHeight = 2 * distance * tan(vFOV / 2)
                        let maxWidth  = 2 * distance * tan(hFOV / 2)
                        let sY = maxHeight / max(vb.extents.y, 1e-4)
                        let sX = maxWidth  / max(vb.extents.x, 1e-4)
                        let s  = min(sX, sY) * 0.9  // margin
                        model.scale *= SIMD3<Float>(repeating: s)
                        
                        // 5) Place camera at +Z looking at origin
                        cam.position = [0, 0, distance]
                        // Optional: align camera to look at origin each frame if you animate
                        // cam.look(at: .zero, from: cam.position, relativeTo: nil)

                        content.add(model)
                        content.add(cam)
                        root = model
                    }
                }
            }
        }
    }
}
