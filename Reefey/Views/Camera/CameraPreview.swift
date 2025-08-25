import SwiftUI
import AVFoundation

struct CameraPreview: UIViewRepresentable {
    @Binding var cameraVM: CameraViewModel

    func makeUIView(context: Context) -> PreviewView {
        let v = PreviewView()
        v.videoPreviewLayer.session = cameraVM.session
        v.videoPreviewLayer.videoGravity = .resizeAspectFill

        // Grab the active capture device (back camera here — adapt to your pipeline)
        if let deviceInput = cameraVM.session.inputs.compactMap({ $0 as? AVCaptureDeviceInput }).first {
            v.configureRotation(using: deviceInput.device) // <- iOS 17+ rotation
        }
        return v
    }

    func updateUIView(_ uiView: PreviewView, context: Context) {
        if uiView.videoPreviewLayer.session !== cameraVM.session {
            uiView.videoPreviewLayer.session = cameraVM.session
        }
    }
}

final class PreviewView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var videoPreviewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }

    // iOS 17+ rotation
    private var rotationCoordinator: AVCaptureDevice.RotationCoordinator?
    private var previewAngleObservation: NSKeyValueObservation?

    func configureRotation(using device: AVCaptureDevice) {
        // Create the coordinator. Passing the preview layer lets it compute the correct preview angle.
        let coord = AVCaptureDevice.RotationCoordinator(device: device, previewLayer: videoPreviewLayer)
        rotationCoordinator = coord

        // Keep preview leveled: observe angle changes and apply to the connection
        previewAngleObservation = coord.observe(\.videoRotationAngleForHorizonLevelPreview, options: [.initial, .new]) { [weak self] _, change in
            guard
                let self,
                let angle = change.newValue,
                let conn = self.videoPreviewLayer.connection,
                conn.isVideoRotationAngleSupported(angle)
            else { return }
            conn.videoRotationAngle = angle
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        videoPreviewLayer.frame = bounds
    }
}
