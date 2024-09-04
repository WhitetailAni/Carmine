//
//  AboutWindow.swift
//  Carmine
//
//  Created by WhitetailAni on 7/25/24.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
        Link(destination: URL(string: "https://twitter.com/whitetailani")!, label: {
            UserInfo(title: "WhitetailAni 🏳️‍⚧️", subTitle: "App developer", titleColor: Color(red: 0.129411765, green: 0.784313725, blue: 0.858823529), subTitleColor: Color(red: 0.560784314, green: 0.560784314, blue: 0.560784314), imageName: "Carmine", showChevron: true)
        })
        
        Link(destination: URL(string: "https://www.transitchicago.com/developers/traintracker/")!, label: {
            UserInfo(title: "CTA Bus Tracker API", subTitle: "Provides all bus and bus stop information", titleColor: Color(red: 0, green: 0.470588235, blue: 0.752941176), subTitleColor: Color(red: 0.82745098, green: 0.2666666667, blue: 0.470588235), imageName: "busTracker", showChevron: true, dontClipImage: true)
        })
    }
}
