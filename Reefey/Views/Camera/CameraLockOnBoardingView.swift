//
//  CameraLockOnBoardingView.swift
//  Reefey
//
//  Created by Reza Juliandri on 27/08/25.
//
import SwiftUI

enum CameraLockOnBoardingStateEnum {
    case VOLUME
    case UNLOCK
    case DISABLED
    
    func nextState() -> CameraLockOnBoardingStateEnum {
        switch self {
        case .VOLUME:
            return .UNLOCK
        case .UNLOCK:
            return .DISABLED
        case .DISABLED:
            return .DISABLED
        }
    }
}

struct CameraLockOnBoardingView: View {
    @State var onboardingState: CameraLockOnBoardingStateEnum = UserDefaults.standard.bool(forKey: "hasCompletedCameraLockOnboarding") ? .DISABLED : .VOLUME
    
    private var hasCompletedOnboarding: Bool {
        UserDefaults.standard.bool(forKey: "hasCompletedCameraLockOnboarding")
    }
    
    private func markOnboardingAsCompleted() {
        UserDefaults.standard.set(true, forKey: "hasCompletedCameraLockOnboarding")
    }
    
    var body: some View {
        ZStack {
            if onboardingState != .DISABLED {
                Color.black.opacity(0.8)
                if onboardingState == .VOLUME {
                    HStack {
                        Rectangle()
                            .foregroundStyle(Color.white)
                            .frame(width: 10, height: 60)
                        Text("Press volume down button to take a picture")
                            .foregroundStyle(.white)
                        Spacer()
                    }.padding(.bottom, 245)
                }
                if onboardingState == .UNLOCK {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Long press button to unlock camera")
                                .foregroundStyle(.white)
                            Circle()
                                .fill(Color.white.opacity(0.8))
                                .frame(width: 65, height: 65)
                                .clipShape(Circle())
                        }
                        .padding(.horizontal,20)
                        .padding(.bottom, 40)
                        .padding(.top, 20)
                    }
                }
            }
        }
        .onTapGesture {
            onboardingState = onboardingState.nextState()
            if onboardingState == .DISABLED {
                markOnboardingAsCompleted()
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    CameraLockOnBoardingView()
}
