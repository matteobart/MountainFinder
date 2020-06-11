//
//  ContentView.swift
//  Mountain Finder
//
//  Created by Matteo Bart on 6/7/20.
//  Copyright © 2020 Matteo Bart. All rights reserved.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: ClimbLocation.entity(), sortDescriptors: []) var savedLocations: FetchedResults<ClimbLocation>
    
    @State var allClimbs: [Climb] = []
    @State var coord = CLLocationCoordinate2D(latitude: 37.3229978, longitude: -122.0321823)
    @State var selected: [Bool] = Array.init(repeating: true, count: ClimbType.allCases.count) //different climbing types
    
    @State var selectedId: Int = -1
    @State var showingDetail: Bool = false
    
    var climbs: [Climb] {
        var ret: [Climb] = []
        for climb in self.allClimbs {
            for i in 0..<self.selected.count {
                if self.selected[i] {
                    let type = ClimbType.allCases[i]
                    if climb.typeList.contains(type) {
                        ret.append(climb)
                        break
                    }
                }
            }
        }
        return ret    }
    
    var annotations: [ClimbingPointAnnotation] {
        var ret: [ClimbingPointAnnotation] = []
        for climb in climbs {
            let t = ClimbingPointAnnotation(climb.id)
            t.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(climb.latitude), longitude: CLLocationDegrees(climb.longitude))
            t.title = climb.name
            t.subtitle = "\(climb.type) \(climb.rating)"
            ret.append(t)
        }
        return ret
    }
    
    //MAIN
    var body: some View {
        VStack {
            MapView(centerCoordinate: $coord, selectedId: $selectedId, showingDetail: $showingDetail, annotations: annotations)
            SearchBar(allClimbs: $allClimbs, selected: $selected, coord: coord).environment(\.managedObjectContext, self.moc)
            Filters(selected: $selected)
            ClimbList(climbs: climbs, coord: coord, selected: selected, selectedId: $selectedId, showingDetail: $showingDetail)
        }.sheet(isPresented: $showingDetail) {
            ClimbingDetailView(climb: self.climbs.first { $0.id == self.selectedId }!, showingDetail: self.$showingDetail)
        }.onAppear {
            self.moc.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.getSavedLocations()
        }
    }
    
    func getSavedLocations() {
        allClimbs = []
        for savedLoc in savedLocations {
            let newClimb = Climb(savedLoc)
            allClimbs.append(newClimb)
        }
    }
}

struct SearchBar: View {
    @Environment(\.managedObjectContext) var moc
    @State var isLoading: Bool = false
    @Binding var allClimbs: [Climb]
    @Binding var selected: [Bool]
    var coord: CLLocationCoordinate2D
    
    var body: some View {
        HStack {
            ActivityIndicator($isLoading)
            Button("Search (\(String(format: "%.3f", coord.latitude)),\(String(format: "%.3f", coord.longitude)))") {
                self.isLoading = true
                findClimbs(long: self.coord.longitude, lat: self.coord.latitude) { (climbs) in
                    self.isLoading = false
                    self.saveLocationsDB(climbs: climbs ?? [])
                    self.allClimbs.append(contentsOf: climbs ?? [])
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(Color.white)
            .cornerRadius(15)
            Button("Hide All") {
                for i in 0 ..< self.selected.count {
                    self.selected[i] = false
                }
            }
            .padding()
            .background(Color.orange)
            .foregroundColor(Color.white)
            .cornerRadius(15)
        }
        
    }
    
    func saveLocationsDB(climbs: [Climb]) {
        for i in 0 ..< climbs.count {
            let climb = climbs[i]
            let climbLoc = ClimbLocation(context: self.moc)
            climbLoc.id = Int64(climb.id)
            climbLoc.numPitches = Int16(climb.numPitches ?? -1)
            climbLoc.starVotes = Int16(climb.starVotes)
            climbLoc.latitude = climb.latitude
            climbLoc.longitude = climb.longitude
            climbLoc.stars = climb.stars
            climbLoc.imgMedium = climb.imgMedium
            climbLoc.imgSmall = climb.imgSmall
            climbLoc.imgSmallMed = climb.imgSmallMed
            climbLoc.imgSqSmall = climb.imgSqSmall
            climbLoc.location = climb.location.reduce("") { res, elem in
                if res == "" {
                    return elem
                } else {
                    return "\(res ?? "");\(elem)"
                }
            }
            climbLoc.name = climb.name
            climbLoc.rating = climb.rating
            climbLoc.type = climb.type
            climbLoc.url = climb.url
        }
        do {
            try self.moc.save()
        } catch {
            print(error)
        }
    }
}

struct Filters: View {
    @Binding var selected: [Bool]
    var body: some View {
        VStack {
            GeometryReader { geo in // when adding geo reader... will now take up maximum amount of space
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    Spacer(minLength: 10)
                    ForEach(0..<ClimbType.allCases.count, id: \.self) { i in
                        Button("\(ClimbType.allCases[i].rawValue)") {
                            self.selected[i].toggle()
                        }
                        .padding()
                        .background(self.selected[i] ? Color.green : Color.gray)
                        .cornerRadius(15)
                        .foregroundColor(.white)
                    }
                    Spacer(minLength: 10)
                }.frame(minWidth: geo.size.width) // this allow you to center the buttons (larger screens iPad)
            }
            }
        }.frame(height: 60) // ... so limit the height
    }
    
}

struct ClimbList: View {
    var climbs: [Climb]
    var coord: CLLocationCoordinate2D
    var selected: [Bool]
    
    @Binding var selectedId: Int
    @Binding var showingDetail: Bool
    
    var body: some View {
        var sortedClimbs: [Climb] = []
        for climb in self.climbs {
            let d = self.getDistance(coord1: self.coord, coord2: CLLocationCoordinate2D(latitude: CLLocationDegrees(climb.latitude), longitude: CLLocationDegrees(climb.longitude)))
            climb.distanceFrom = d
            if (d < 120.0) {
                sortedClimbs.append(climb)
            }
        }
        sortedClimbs = sortedClimbs.sorted {$0.distanceFrom ?? Float(Double.infinity) < $1.distanceFrom ?? Float(Double.infinity)}
        return HStack {
            if !climbs.isEmpty {
                List(sortedClimbs, id: \.self.id) { climb in
                    HStack {
                        WebImage(url: URL(string: climb.imgSqSmall!))
                        .placeholder {
                            Image("mountainLarge")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .scaledToFit()
                                .clipped()
                        }
                        .indicator(.activity)
                        .transition(.fade(duration: 0.5))
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        
                        VStack (alignment: .leading) {
                            Text(climb.name).font(.headline)
                            HStack { ForEach(climb.typeList, id: \.self) { Text($0.rawValue) } }
                            Text(climb.rating)
                            StarView(numStars: climb.stars)
                        }
                        Spacer()
                        VStack (alignment: .trailing) {
                            ForEach(climb.location, id: \.self) { subloc in
                                Text(subloc).font(.subheadline).lineLimit(1)
                            }
                            if climb.distanceFrom != nil {
                                Text("\(String(format: "%.1f", climb.distanceFrom!)) mi").font(.subheadline)
                            }
                        }
                        
                        }.contentShape(Rectangle()).onTapGesture {
                        self.selectedId = climb.id
                        self.showingDetail = true
                    }
                }
            } else {
                if !self.selected.contains(true) {
                    Text("Choose a Type")
                } else {
                    Text("No results")
                }
            }
        }
    }
    
    func getDistance(coord1: CLLocationCoordinate2D, coord2: CLLocationCoordinate2D) -> Float {
        let p1 = MKMapPoint(coord1)
        let p2 = MKMapPoint(coord2)
        let distance = p1.distance(to: p2) // meters
        return Float(distance) * 0.000621371
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

