//
//  IdentifyDialogEnum.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//
import UIKit

enum IdentifyDialogEnum {
    case LOADING
    case UNLOCK(viewUnidentifiedAction: () -> Void = {}, dismissAction: () -> Void = {})
    case OFFLINE(morePhotosAction: () -> Void = {}, viewUnidentifiedAction: () -> Void)
    case UNIDENTIFIED(morePhotosAction: () -> Void = {}, viewUnidentifiedAction: () -> Void = {})
    case RATE_LIMIT(viewUnidentifiedAction: () -> Void = {}, dismissAction: () -> Void = {})
    case IDENTIFIED(marineData: MarineData, capturedImage: UIImage, dismissAction: () -> Void = {})
    
    func getIdentifyDialogData() -> IdentifyDialogData {
        switch self {
        case .LOADING:
            return IdentifyDialogData(
                title: "Identifying...",
                body: "Once your animal is identified, it will automatically stored in your collection",
                isShowButton: false,
                isRotatingStarfish: true,
            )
        case .UNLOCK(let viewUnidentifiedAction, let dismissAction):
            return IdentifyDialogData(
                title: "Woohoo!",
                body: "Your photos taken during locked mode are ready to be identified!",
                buttonSecondaryText: "View unidentified images",
                buttonSecondaryAction: viewUnidentifiedAction,
                isShowSecondaryButton: true,
                showXButton: true,
                xButtonAction: dismissAction
            )
        case .OFFLINE(let morePhotosAction, let viewUnidentifiedAction):
            return IdentifyDialogData(
                title: "You're offline!",
                buttonText: "Take more photo",
                buttonAction: morePhotosAction,
                buttonSecondaryText: "View unidentified images",
                buttonSecondaryAction: viewUnidentifiedAction,
                isShowBody: false,
                isShowButton: true,
                isShowSecondaryButton: true,
            )
        case .UNIDENTIFIED(let morePhotosAction, let viewUnidentifiedAction):
            return IdentifyDialogData(
                title: "No match found",
                body: "Your photos might not match any marine species in our database",
                buttonText: "Take more photo",
                buttonAction: morePhotosAction,
                buttonSecondaryText: "View unidentified images",
                buttonSecondaryAction: viewUnidentifiedAction,
                isShowBody: true,
                isShowButton: true,
                isShowSecondaryButton: true
            )
        case .RATE_LIMIT(let viewUnidentifiedAction, let dismissAction):
            return IdentifyDialogData(
                title: "AI limit reached!",
                body: "You've reached your AI identification limit for now. You can still view your previously identified images.",
                buttonSecondaryText: "View unidentified images",
                buttonSecondaryAction: viewUnidentifiedAction,
                isShowBody: true,
                isShowButton: false,
                isShowSecondaryButton: true,
                showXButton: true,
                xButtonAction: dismissAction
            )
        case .IDENTIFIED(let marineData, let capturedImage, let dismissAction):
            return IdentifyDialogData(
                buttonText: "View details",
                buttonSecondaryText: "Add to collection",
                isShowBody: false,
                isShowButton: false,
                isShowSecondaryButton: false,
                showXButton: true,
                xButtonAction: dismissAction,
                marineData: marineData,
                capturedImage: capturedImage
            )
        }
    }
}
