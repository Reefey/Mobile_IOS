//
//  CameraView+AIFailureCallback.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//

import SwiftUI

extension CameraView {
    func setupAIFailureCallback() {
        VM.onAIFailure = { [self] assetIdentifier in
            VM.saveToSwiftData(photoAssetIdentifier: assetIdentifier, context: modelContext)
        }
        
        VM.onAIProcessingComplete = { [self] in
            isShowIdentifyDialog = false
        }
        
        VM.onAIIdentificationSuccess = { [self] marineData, capturedImage in
            identifyDialogState = .IDENTIFIED(
                marineData: marineData,
                capturedImage: capturedImage,
                dismissAction: dismissDialog
            )
        }
        
        VM.onAIUnidentified = { [self] in
            identifyDialogState = .UNIDENTIFIED(
                morePhotosAction: dismissDialog,
                viewUnidentifiedAction: viewUnidentifiedImages
            )
        }
        
        VM.onNetworkUnavailable = { [self] in
            identifyDialogState = .OFFLINE(
                morePhotosAction: dismissDialog,
                viewUnidentifiedAction: viewUnidentifiedImages
            )
        }
        
        VM.onRateLimitExceeded = { [self] in
            identifyDialogState = .RATE_LIMIT(
                viewUnidentifiedAction: viewUnidentifiedImages,
                dismissAction: dismissDialog
            )
        }
    }
    
    func dismissDialog() {
        isShowIdentifyDialog = false
        identifyDialogState = .LOADING
    }
    
    func viewUnidentifiedImages() {
        cameraShow = false
        isShowIdentifyDialog = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            path = [.toBeIdentified]
        }
    }
}
