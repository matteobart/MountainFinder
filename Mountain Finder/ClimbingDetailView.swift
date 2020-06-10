//
//  ClimbingDetailView.swift
//  Mountain Finder
//
//  Created by Matteo Bart on 6/9/20.
//  Copyright © 2020 Matteo Bart. All rights reserved.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct ClimbingDetailView: View {
    let climb: Climb
    @Binding var showingDetail: Bool
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    Text(self.climb.name).font(.headline)
                    
                    HStack {
                        Button("Done") {
                            self.showingDetail.toggle()
                        }.padding()
                        Spacer()
                    }
                }
                HStack {
                    VStack (alignment: .leading, spacing: 10) {
                        Text("\(self.climb.type)")
                        Text("Rating: \(self.climb.rating)")
                        if self.climb.numPitches != nil && self.climb.numPitches != -1 {
                            Text("Pitches: \(self.climb.numPitches!)")
                        }
                    }
                    Spacer()
                    VStack (alignment: .trailing, spacing: 15){
                        StarView(numStars: self.climb.stars)
                        Text("Votes: \(self.climb.starVotes)")
                    }
                }.padding()
                WebImage(url: URL(string: self.climb.imgMedium!.replacingOccurrences(of: "medium", with: "large"))).frame(maxWidth: 5*geo.size.width/6, maxHeight: 3*geo.size.height/5).scaledToFill().clipped()
                Spacer()
                if self.climb.distanceFrom != nil {
                    Text("\(String(format: "%.1f", self.climb.distanceFrom!)) mi away")
                }
                Text("Latitude: \(self.climb.latitude) Longitude: \(self.climb.longitude)").padding()
                
                HStack {
                    if self.climb.url != nil {
                        Button("Open in Safari"){
                            guard let url = URL(string: self.climb.url!) else { return }
                            UIApplication.shared.open(url)
                        }.padding()
                            .background(Color.blue)
                            .foregroundColor(Color.white)
                            .cornerRadius(15)
                    }
                    Button("Open in Apple Maps") {
                        let appleURL = URL(string: "http://maps.apple.com/?daddr=\(self.climb.latitude),\(self.climb.longitude)")
                        UIApplication.shared.open(appleURL!)
                    }.padding()
                        .background(Color.orange)
                        .foregroundColor(Color.white)
                        .cornerRadius(15)
                }
                
            }
        }
    }
}

struct StarView: View {
    let numStars: Float
    var body: some View {
        HStack {
            ForEach(0 ..< Int(numStars), id: \.self) { _ in
                Image(systemName: "star.fill")
            }
            if numStars.remainder(dividingBy: 1.0) > 0.5 {
                Image(systemName: "star.lefthalf.fill")
            }
        }
    }
}
