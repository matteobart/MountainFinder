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
import CoreData

struct ClimbingDetailView: View {
    let climb: Climb
    @Binding var showingDetail: Bool
    @State var copyText = "Copy " // switched to copied when a user clicks the button
    var body: some View {
        GeometryReader { geo in
            VStack {
                ZStack {
                    WebImage(url: URL(string: self.climb.imgMedium!.replacingOccurrences(of: "medium", with: "large")))
                        .placeholder {
                            Image("mountainLarge").resizable()//.frame(width: 100, height: 100)
                                .scaledToFill().clipped() }
                        .frame(
                            idealWidth: geo.size.width,
                            idealHeight: 2*geo.size.height/5,
                            maxHeight: 2*geo.size.height/5)
                        .scaledToFill().clipped()
                    VStack {
                        ZStack {
                            Text(self.climb.name).font(.headline)
                            HStack {
                                Button("Done") {
                                    self.showingDetail.toggle()
                                }.font(.headline).padding()
                                Spacer()
                            }
                        }.background(Color.gray.opacity(0.7)).frame(width: geo.size.width) //set frame here otherwise it will be the same size as the image
                        Spacer()
                    }
                }.scaledToFit()
                VStack {
                    HStack { // Type, Rating, Star Rating, Votes
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
                    }
                    Spacer(minLength: 0)
                    HStack { // location, distance from
                        VStack (alignment: .leading) {
                            ForEach(self.climb.location, id: \.self) { sublocation in
                                Text(sublocation)
                            }
                        }
                        Spacer()
                        if self.climb.distanceFrom != nil {
                            Text("\(String(format: "%.1f", self.climb.distanceFrom!)) mi away")
                        }
                    }
                    Spacer(minLength: 0)
                    HStack { //Long + Lat
                        VStack (alignment: .leading) {
                            Text("Latitude: \(fourDecPrecision(float: self.climb.latitude))")
                            Text("Longitude: \(fourDecPrecision(float: self.climb.longitude))")
                        }
                        Spacer()
                        Button(self.copyText) {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = "\(fourDecPrecision(float: self.climb.latitude)), \(fourDecPrecision(float: self.climb.longitude))"
                            self.copyText = "Copied"
                        }.padding()
                            .background(Color.pink)
                            .foregroundColor(Color.white)
                            .cornerRadius(15)
                    }
                    Spacer(minLength: 0)
                    HStack { //Bottom Buttons
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
                }.padding()
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
            if numStars - Float(Int(numStars)) > 0.5 {
                Image(systemName: "star.lefthalf.fill")
            }
        }
    }
}

// wasnt ever to check if this preview actually works...
struct Helper: View {
    @State var binding: Bool = false
    @FetchRequest(entity: ClimbLocation.entity(), sortDescriptors: []) var savedLocations: FetchedResults<ClimbLocation>
    
    var body: some View {
        ClimbingDetailView(climb: Climb(savedLocations[0]), showingDetail: $binding)
        
    }
}


struct ClimbingDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        Helper()
    }
}
