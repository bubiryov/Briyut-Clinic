//
//  ProfileView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 06.05.2023.
//

import SwiftUI
import CachedAsyncImage

struct ProfileView: View {
    
    @EnvironmentObject var vm: ProfileViewModel
    @Binding var notEntered: Bool
    
    var body: some View {
        
        NavigationView {
            VStack {
                BarTitle<Text, BarButton>(text: "", rightButton: BarButton(notEntered: $notEntered))
                
                ProfileImage(photoURL: vm.user?.photoUrl, frame: ScreenSize.height * 0.12, color: Color.secondary.opacity(0.1))
                    .cornerRadius(ScreenSize.width / 20)
                
                HStack {
                    Text(vm.user?.name ?? (vm.user?.userId ?? ""))
                        .font(.title.bold())
                        .lineLimit(1)
                    
                    Text(vm.user?.lastName ?? "")
                        .font(.title.bold())
                        .lineLimit(1)
                }
                
                if vm.user?.isDoctor == true {
                    NavigationLink("Add doctor", destination: AddDoctorView())
                }
                
                Spacer()
                
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(notEntered: .constant(false))
            .environmentObject(ProfileViewModel())
    }
}

struct BarButton: View {
    
    @Binding var notEntered: Bool
    
    var body: some View {
        NavigationLink {
            EditProfileView(notEntered: $notEntered)
        } label: {
            BarButtonView(image: "settings")
        }
        .buttonStyle(.plain)
    }
}

struct ProfileImage: View {
    
    var photoURL: String?
    var frame: CGFloat
    var color: Color
    
    var body: some View {
        VStack {
            CachedAsyncImage(url: URL(string: photoURL ?? ""), urlCache: .imageCache) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                
            } placeholder: {
                Image(systemName: "person.fill")
                    .resizable()
                    .padding()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: frame, height: frame, alignment: .center)
                    .clipped()
                    .foregroundColor(.secondary)
                    .background(color)
            }
        }
    }
}
