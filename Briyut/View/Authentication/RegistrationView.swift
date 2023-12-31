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
    @State private var loading: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                
                TopBar<BackButton, Text>(
                    text: "new-account-string",
                    leftButton: BackButton(presentationMode: _presentationMode)
                )
                
                AuthInputField(
                    field: $vm.email,
                    isSecureField: false,
                    title: "rubinko@gmail.com",
                    header: "your-email-string"
                )
                
                AuthInputField(
                    field: $vm.password,
                    isSecureField: true,
                    title: "min-6-characters-string",
                    header: "your-password-string"
                )
                
                AuthInputField(
                    field: $repeatPassword,
                    isSecureField: true,
                    title: "min-6-characters-string",
                    header: "repeat-password-string"
                )
                
                Spacer()
                
                Button {
                    createAccount()
                } label: {
                    AccentButton(
                        text: "create-account-string",
                        isButtonActive: vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword),
                        animation: loading
                    )
                }
                .disabled(!vm.validate(email: vm.email, password: vm.password, repeatPassword: repeatPassword) || loading)
            }
            .padding(.top, topPadding())
            .padding(.bottom, 20)
            .padding(.horizontal, 20)
            .background(Color.backgroundColor)
            .navigationBarBackButtonHidden(true)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .onEnded { gesture in
                        if gesture.translation.width > 100 {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                    .onEnded { gesture in
                        if gesture.translation.height > 100 {
                            hideKeyboard()
                        }
                    }
            )
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

extension RegistrationView {
    func createAccount() {
        Task {
            do {
                loading = true
                try await vm.createUserWithEmail()
                notEntered = false
                loading = false
                presentationMode.wrappedValue.dismiss()
            } catch {
                print("Can't create an account")
                loading = false
            }
        }

    }
}

