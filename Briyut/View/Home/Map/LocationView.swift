//
//  LocationView.swift
//  Briyut
//
//  Created by Egor Bubiryov on 21.06.2023.
//

import SwiftUI

struct LocationView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var vm: LocationsViewModel
    var location: LocationModel? = nil
//    LocationModel(id: "", latitude: 0, longitude: 0, address: "Sumskaya, 17-А, Kharkiv")
    @State private var city: String = ""
    @State private var street: String = ""
    @State private var buildingNumber: String = ""
    @State private var coordinates: String = ""
    @State private var showAlert: Bool = false
    
    var body: some View {
        VStack {
            BarTitle<BackButton, DeleteAddressButton>(
                text: location != nil ? "Edit address" : "New address",
                leftButton: BackButton(),
                rightButton: location != nil ? DeleteAddressButton(showAlert: $showAlert) : nil
            )
            .padding(.bottom)
            
            ScrollView {
                VStack(spacing: ScreenSize.height * 0.02) {
                    
                    AccentInputField(promptText: "Харків", title: "City", input: $city)
                    
                    AccentInputField(promptText: "Сумська", title: "Street", input: $street)
                    
                    AccentInputField(promptText: "17-А", title: "Building", input: $buildingNumber)
                    
                    AccentInputField(promptText: "49.991236239813, 36.225463473776614", title: "Coordinates", input: $coordinates)
                }
            }
            Button {
                Task {
                    if location == nil {
                        do {
                            try await addNewAddress()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Can't add new address")
                        }
                    } else {
                        do {
                            try await editAddress()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print("Can't edit address")
                        }
                    }
                }
            } label: {
                AccentButton(
                    text: location != nil ? "Edit" : "Add",
                    isButtonActive: validateFields()
                )
            }
            .disabled(!validateFields())
        }
        .padding(.horizontal, 20)
        .padding(.bottom)
        .navigationBarBackButtonHidden()
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
        .onAppear {
            if let location {
                city = splitAddress().city
                street = splitAddress().street
                buildingNumber = splitAddress().house
                coordinates = "\(location.latitude), \(location.longitude)"
            }
        }
        .ignoresSafeArea(.keyboard)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Are you sure you want to delete this address?"),
                primaryButton: .destructive(Text("Delete"), action: {
                    Task {
                        try await vm.removeLocation(locationId: location!.id)
                        presentationMode.wrappedValue.dismiss()
                    }
                }),
                secondaryButton: .default(Text("Cancel"), action: { })
            )
        }


    }
    
    func addNewAddress() async throws {
        guard let coordinates = splitCoordinates() else {
            return
        }
        
        let (latitude, longitude) = coordinates
        
        let location = LocationModel(
            id: UUID().uuidString,
            latitude: latitude,
            longitude: longitude,
            address: "\(street), \(buildingNumber), \(city)"
        )
        try await vm.createNewLocation(location: location)
    }
    
    func editAddress() async throws {
        guard let coordinates = splitCoordinates() else {
            return
        }
        let (latitude, longitude) = coordinates
        
        try await vm.editLocation(
            locationId: location!.id,
            latitude: latitude,
            longitude: longitude,
            address: "\(street), \(buildingNumber), \(city)")
    }
       
    func validateFields() -> Bool {

        let cityRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)[A-ZА-ЯЄЇІ][a-zA-Zа-яА-ЯЄЇІіїє\\s-]*$"
        let cityPredicate = NSPredicate(format: "SELF MATCHES %@", cityRegex)
        let isCityValid = cityPredicate.evaluate(with: city)

        let streetRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[a-zA-Zа-яА-ЯЄЇІіїє]+(\\s+[a-zA-Zа-яА-ЯЄЇІіїє]+)*$"
        let streetPredicate = NSPredicate(format: "SELF MATCHES %@", streetRegex)
        let isStreetValid = streetPredicate.evaluate(with: street) && !street.contains(where: \.isNumber)

        let buildingNumberRegex = "^(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[^\\s]+$"
        let buildingNumberPredicate = NSPredicate(format: "SELF MATCHES %@", buildingNumberRegex)
        let isBuildingNumberValid = buildingNumberPredicate.evaluate(with: buildingNumber) && !buildingNumber.isEmpty

        return isCityValid && isStreetValid && isBuildingNumberValid && validateCoordinates()
    }

//    func validateFields() -> Bool {
//
//        let cityRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)[A-ZА-Я][a-zA-Zа-яА-Я\\s-]*$"
//        let cityPredicate = NSPredicate(format: "SELF MATCHES %@", cityRegex)
//        let isCityValid = cityPredicate.evaluate(with: city)
//
//        let streetRegex = "^(?!.*[\\s-]{2,})(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[a-zA-Zа-яА-Я]+(\\s+[a-zA-Zа-яА-Я]+)*$"
//        let streetPredicate = NSPredicate(format: "SELF MATCHES %@", streetRegex)
//        let isStreetValid = streetPredicate.evaluate(with: street) && !street.contains(where: \.isNumber)
//
//        let buildingNumberRegex = "^(?!^[-\\s])(?!.*[-\\s]$)(?!.*([\\s-])\\1)[^\\s]+$"
//        let buildingNumberPredicate = NSPredicate(format: "SELF MATCHES %@", buildingNumberRegex)
//        let isBuildingNumberValid = buildingNumberPredicate.evaluate(with: buildingNumber) && !buildingNumber.isEmpty
//
//        return isCityValid && isStreetValid && isBuildingNumberValid && validateCoordinates()
//    }
    
    private func validateCoordinates() -> Bool {
        let coordinateComponents = coordinates.components(separatedBy: ", ")
        
        guard coordinateComponents.count == 2 else {
            return false
        }
        
        for component in coordinateComponents {
            guard let coordinate = Double(component) else {
                return false
            }
            
            guard !coordinate.isNaN && !coordinate.isInfinite else {
                return false
            }
        }
        
        return true
    }
    
    func splitCoordinates() -> (Double, Double)? {
        let coordinateComponents = coordinates.components(separatedBy: ", ")
        
        guard coordinateComponents.count == 2,
              let latitude = Double(coordinateComponents[0].trimmingCharacters(in: .whitespaces)),
              let longitude = Double(coordinateComponents[1].trimmingCharacters(in: .whitespaces)) else {
            return nil
        }
        
        return (latitude, longitude)
    }
    
    private func splitAddress() -> (city: String, house: String, street: String) {
        
        guard let location = location else {
            return ("", "", "")
        }
        
        let components = location.address.components(separatedBy: ",")
        
        var city = ""
        var house = ""
        var street = ""
        
        if components.count >= 1 {
            city = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if components.count >= 2 {
            house = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if components.count >= 3 {
            street = components[2].trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return (city, house, street)
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView(vm: LocationsViewModel())
//            .environmentObject(LocationsViewModel())
    }
}

fileprivate struct DeleteAddressButton: View {
    
    @Binding var showAlert: Bool
    
    var body: some View {
        Button {
            showAlert = true
        } label: {
            BarButtonView(image: "trash", textColor: .white, backgroundColor: Color.destructiveColor)
        }
        .buttonStyle(.plain)
    }
}
