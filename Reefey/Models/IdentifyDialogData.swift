//
//  IdentifyDialogData.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//
import UIKit

struct IdentifyDialogData {
    var title: String = ""
    var body: String = ""
    var buttonText: String = ""
    var buttonAction: () -> Void = { }
    var buttonSecondaryText: String = ""
    var buttonSecondaryAction: () -> Void = { }
    var isShowBody: Bool = true
    var isShowButton: Bool = false
    var isShowSecondaryButton: Bool = false
    var isRotatingStarfish: Bool = false
    var showXButton: Bool = false
    var xButtonAction: () -> Void = { }
    var marineData: MarineData? = nil
    var capturedImage: UIImage? = nil
}
