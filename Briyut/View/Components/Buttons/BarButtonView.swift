//
//  BarButton.swift
//  Briyut
//
//  Created by Egor Bubiryov on 05.05.2023.
//

import SwiftUI

struct BarButtonView: View {
    
    var cornerRadius = ScreenSize.width / 30
    var frame: CGFloat = ScreenSize.height * 0.06
    var image: String
    var scale: CGFloat? = nil
    var textColor: Color? = nil
    var backgroundColor: Color? = nil
    
    var body: some View {
        Image(image)
            .resizable()
            .scaleEffect((scale != nil) ? scale! : 0.4)
            .frame(width: frame, height: frame)
            .background(backgroundColor == nil ? Color.secondary.opacity(0.1) : backgroundColor)
            .cornerRadius(cornerRadius)
            .foregroundColor(textColor)
    }
}


struct BarButton_Previews: PreviewProvider {
    static var previews: some View {
        BarButtonView(image: "plus")
    }
}
