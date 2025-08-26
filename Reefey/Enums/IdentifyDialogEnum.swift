//
//  IdentifyDialogEnum.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//


enum IdentifyDialogEnum {
    case LOADING
    case UNLOCK
    case OFFLINE
    
    func getIdentifyDialogData() -> IdentifyDialogData {
        switch self {
        case .LOADING:
            return IdentifyDialogData(
                title: "Identifying...",
                body: "Once your animal is identified, it will automatically stored in your collection",
                isShowButton: false,
                isRotatingStarfish: true
            )
        case .UNLOCK:
            return IdentifyDialogData(
                title: "Woohoo!",
                body: "Your photos taken during locked mode are ready to be identified!",
                buttonSecondaryText: "View unidentified images",
                isShowSecondaryButton: true,
            )
        case .OFFLINE:
            return IdentifyDialogData(
                title: "You're offline!",
                buttonText: "Take more photo",
                buttonSecondaryText: "View unidentified images",
                isShowBody: false,
                isShowButton: true,
                isShowSecondaryButton: true,
            )
        }
    }
}