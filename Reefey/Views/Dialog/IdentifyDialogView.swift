//
//  IdentifyDialogView.swift
//  Reefey
//
//  Created by Reza Juliandri on 26/08/25.
//
import SwiftUI

struct IdentifyDialogView: View {
    @State private var isRotating = false
    @Binding var identifyDialogState: IdentifyDialogEnum
    
    var identifyDialogData: IdentifyDialogData {
        identifyDialogState.getIdentifyDialogData()
    }
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                HStack{
                    Spacer()
                    VStack {
                        Image("Starfish")
                              .resizable()
                              .frame(width: 80, height: 80)
                              .padding(.bottom, 20)
                              .rotationEffect(.degrees(isRotating ? 360 : 0))
                              .animation(.linear(duration: 4.0).repeatForever(autoreverses: false),
                           value: isRotating)
                              .onAppear {
                                  isRotating = identifyDialogData.isRotatingStarfish
                              }
                              .onChange(of: identifyDialogData.isRotatingStarfish) {
                                  isRotating = identifyDialogData.isRotatingStarfish
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
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
        .ignoresSafeArea()
        .background(Color.black.opacity(0.8))
        
    }
}


#Preview {
    IdentifyDialogView(identifyDialogState: .constant(.LOADING))
}
