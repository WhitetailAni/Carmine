//
//  UserInfo.swift
//  Carmine
//
//  Created by WhitetailAni on 7/26/24.
//

import SwiftUI

struct UserInfo: View {
    var title: String
    var subTitle: String
    var titleColor: Color
    var subTitleColor: Color
    var imageName: String
    var showChevron: Bool
    var dontClipImage: Bool
    
    init(title: String, subTitle: String, titleColor: Color, subTitleColor: Color, imageName: String, showChevron: Bool) {
        self.title = title
        self.subTitle = subTitle
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.imageName = imageName
        self.showChevron = showChevron
        self.dontClipImage = false
    }
    
    init(title: String, subTitle: String, titleColor: Color, subTitleColor: Color, imageName: String, showChevron: Bool, dontClipImage: Bool) {
        self.title = title
        self.subTitle = subTitle
        self.titleColor = titleColor
        self.subTitleColor = subTitleColor
        self.imageName = imageName
        self.showChevron = showChevron
        self.dontClipImage = true
    }

    var body: some View {
        HStack {
            if dontClipImage {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
            } else {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            }
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .foregroundColor(titleColor)
                if subTitle != "" {
                    Text(subTitle)
                        .font(.subheadline)
                        .foregroundColor(subTitleColor)
                        .multilineTextAlignment(.leading)
                        .opacity(0.8)
                }
            }
            .offset(x: 35)
            
            Spacer()
            Spacer()
            Spacer()
            
            if showChevron {
                Image(systemName: "chevron.right")
                    .opacity(0.5)
                    .font(.body.bold())
            }
        }
        .padding()
    }
}
