//
//  NotificationDialogView.swift
//  Reefey
//
//  Created by Reza Juliandri on 27/08/25.
//
import SwiftUI

struct NotificationDialogView: View {
    var identifyDialogData: IdentifyDialogData
    @State private var isRotating = false

    var body: some View {
        HStack{
            Spacer()
            ZStack {
                VStack {
                    Image("Starfish")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .padding(.bottom, 20)
                        .rotationEffect(.degrees(isRotating ? 360 : 0))
                        .animation(isRotating ? .linear(duration: 4.0).repeatForever(autoreverses: false) : .default,
                                   value: isRotating)
                        .onAppear {
                            isRotating = identifyDialogData.isRotatingStarfish
                        }
                        .onChange(of: identifyDialogData.isRotatingStarfish) {
                            withAnimation {
                                isRotating = identifyDialogData.isRotatingStarfish
                            }
                        }
                    Text(identifyDialogData.title)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                        .foregroundColor(Color(hex: "#145B55"))
                    if identifyDialogData.isShowBody {
                        Text(identifyDialogData.body)
                            .font(.title3)
                            .padding(.bottom, 20)
                            .foregroundColor(Color(hex: "#145B55"))
                    }
                    
                    if identifyDialogData.isShowButton {
                        Button(action: identifyDialogData.buttonAction) {
                            HStack{
                                Spacer()
                                Text(identifyDialogData.buttonText)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color.white)
                                Spacer()
                            }
                            .padding()
                            .background(Color(hex: "#4CAFA1"))
                            .cornerRadius(20)
                        }.buttonStyle(PlainButtonStyle())
                    }
                    
                    if identifyDialogData.isShowSecondaryButton {
                        Button(action: identifyDialogData.buttonSecondaryAction) {
                            HStack{
                                Spacer()
                                Text(identifyDialogData.buttonSecondaryText)
                                    .fontWeight(.semibold)
                                    .foregroundColor(Color(hex: "#098889"))
                                Spacer()
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(20)
                        }.buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 40)
                .padding(.horizontal, 20)
                .background(Color.primary.opacity(0.8).colorInvert())
                .cornerRadius(20)
                .overlay(
                    identifyDialogData.showXButton ?
                    Button(action: identifyDialogData.xButtonAction) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "#145B55"))
                            .frame(width: 24, height: 24)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 1)
                    }
                        .buttonStyle(PlainButtonStyle())
                        .offset(x: -15, y: 15)
                    : nil,
                    alignment: .topTrailing
                )
            }
            Spacer()
        }
        .padding()
    }
}
#Preview {
    NotificationDialogView(identifyDialogData: IdentifyDialogData(
        title: "Identifying...",
        body: "Once your animal is identified, it will automatically stored in your collection",
        isShowButton: false,
        isRotatingStarfish: true,
    ))
}
