//
//  DoctorsList.swift
//  Briyut
//
//  Created by Egor Bubiryov on 08.05.2023.
//

import SwiftUI

struct AvailableDoctorsView: View {
    
    @Binding var choosenDoctors: [String]
    @EnvironmentObject var interfaceData: InterfaceData
    @Environment(\.presentationMode) var presentationMode
    var cornerRadius = ScreenSize.width / 30
    
    var body: some View {
        VStack {
            TopBar<BackButton, Text>(
                text: "specialists-string",
                leftButton: BackButton()
            )
            
            ScrollView {
                ForEach(interfaceData.doctors, id: \.userId) { doctor in
                    HStack {
                        
                        ProfileImage(
                            photoURL: doctor.photoUrl,
                            frame: ScreenSize.height * 0.06,
                            color: .clear,
                            padding: 10
                        )
                        .cornerRadius(ScreenSize.width / 30)
                        
                        Text("\(doctor.name ?? doctor.userId) \(doctor.lastName ?? "")")
                            .font(Mariupol.medium, 17)
                            .foregroundColor(choosenDoctors.contains(doctor.userId) ? .white : .primary)
                            .padding(.leading, 8)
                            .lineLimit(1)
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(height: ScreenSize.height * 0.08)
                    .background(choosenDoctors.contains(doctor.userId) ? Color.mainColor : Color.secondaryColor)
                    .cornerRadius(cornerRadius)
                    .onTapGesture {
                        if let index = choosenDoctors.firstIndex(of: doctor.userId) {
                            choosenDoctors.remove(at: index)
                        } else {
                            choosenDoctors.append(doctor.userId)
                        }
                    }
                }
                .listRowSeparator(.hidden)
            }
        }
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
        )
    }
}

struct DoctorsList_Previews: PreviewProvider {
    static var previews: some View {
        AvailableDoctorsView(choosenDoctors: .constant([]))
            .environmentObject(InterfaceData())
            .padding(.horizontal, 20)
            .background(Color.backgroundColor)
    }
}
