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
            // SwiftData saving is now handled in CameraViewModel
            print("AI failure callback triggered for asset: \(assetIdentifier)")
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
        isShowIdentifyDialog = false
        path.append(.unidentifiedImages)
    }
}
