import SwiftUI

struct IdentifyDialogView: View {
    @Binding var identifyDialogState: IdentifyDialogEnum
    @Binding var isShowIdentifyDialog: Bool
    @Binding var path: [NavigationPath]
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                if let marineData = identifyDialogState.getIdentifyDialogData().marineData {
                    DataDialogView(
                        marineData: marineData, 
                        capturedImage: identifyDialogState.getIdentifyDialogData().capturedImage,
                        isShowIdentifyDialog: $isShowIdentifyDialog,
                        path: $path
                    )
                } else {
                    NotificationDialogView(
                        identifyDialogData: identifyDialogState.getIdentifyDialogData()
                    )
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.8))
        .onTapGesture {
            // Allow dismiss by tapping outside for UNLOCK case
            // This will be handled by the parent view
        }
    }
}

#Preview {
    IdentifyDialogView(identifyDialogState: .constant(.LOADING), isShowIdentifyDialog: .constant(true), path: .constant([]))
}
