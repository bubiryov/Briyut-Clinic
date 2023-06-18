//
//  RegistrationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 01.05.2023.
//

import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var vm: AuthenticationViewModel
    @Binding var notEntered: Bool
    @State private var repeatPassword: String = ""
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                
                BarTitle<BackButton, Text>(
                    text: "New account",
                    leftButton: BackButton(presentationMode: _presentationMode)
                )
                
                AuthInputField(
                    field: $vm.email,
                    isSecureField: false,
                    title: "briyut@gmail.com",
                    header: "Your email address"
                )
                
                AuthInputField(
                    field: $vm.password,
                    isSecureField: true,
                    title: "min. 6 characters",
                    header: "Choose your password"
                )
                
                AuthInputField(
                    field: $repeatPassword,
                    isSecureField: true,
                    title: "min. 6 characters",
                    header: "Repeat password"
                )
                
                Spacer()
                
                Button {
                    Task {
                        try await vm.createUserWithEmail()
                        notEntered = false
                        presentationMode.wrappedValue.dismiss()
                    }
                } label: {
                    AccentButton(
                        text: "Create an account",
                        isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword))
                    
                }
                .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword))
            }
            .padding(.bottom)
            .padding(.horizontal, 20)
            .navigationBarBackButtonHidden(true)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
            )
            .onTapGesture {
                hideKeyboard()
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegistrationView(notEntered: .constant(false))
                .environmentObject(AuthenticationViewModel())
        }
    }
}

