//
//  Requests.swift
//  Mountain Finder
//
//  Created by Matteo Bart on 6\\/7\\/20.
//  Copyright © 2020 Matteo Bart. All rights reserved.
//

import Foundation

enum ClimbType: String, CaseIterable {
    case Sport = "Sport"
    case Trad = "Trad"
    case TopRope = "TR"
    case Boulder = "Boulder"
    case Ice = "Ice"
    case Snow = "Snow"
    case Alpine = "Alpine"
    case Aid = "Aid"
    case Mixed = "Mixed"
}

class ClimbResponse: Codable {
    let routes: [Climb]
    
}

class Climb: Codable {
    let id: Int
    let name: String
    let type: String
    var typeList: [ClimbType] {
        var ret: [ClimbType] = []
        for str in type.replacingOccurrences(of: " ", with: "").split(separator: ",") {
            if let cType = ClimbType(rawValue: String(str)) {
                ret.append(cType)
            } else {
                print(str)
            }
        }
        return ret
    }
    let rating: String
    let stars: Float
    let starVotes: Int
    let numPitches: Int?
    let location: [String]
    let url: String?
    let imgSqSmall: String?
    let imgSmall: String?
    let imgSmallMed: String?
    let imgMedium: String?
    let longitude: Float
    let latitude: Float
    
    var distanceFrom: Float? // not saved, but computed with map
    
    init(_ savedLocation: ClimbLocation){
        id = Int(savedLocation.id)
        name = savedLocation.name ?? ""
        type = savedLocation.type ?? ""
        rating = savedLocation.rating ?? ""
        stars = savedLocation.stars
        starVotes = Int(savedLocation.starVotes)
        numPitches = Int(savedLocation.numPitches)
        location = Array(savedLocation.location!.split(separator: ";").map{String($0)})
        url = savedLocation.url
        imgSqSmall = savedLocation.imgSqSmall
        imgSmall = savedLocation.imgSmall
        imgSmallMed = savedLocation.imgSmallMed
        imgMedium = savedLocation.imgMedium
        longitude = savedLocation.longitude
        latitude = savedLocation.latitude
    }
}

func findClimbs(long: Double, lat: Double, handler: @escaping ([Climb]?)->()) {
    var request = URLRequest(url: URL(string:
        "https://www.mountainproject.com/data/get-routes-for-lat-lon?lat=\(lat)&lon=\(long)&maxDistance=120&maxResults=500&key=\(apiKey)")!,
        timeoutInterval: Double.infinity)
    request.httpMethod = "GET"
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            print(String(describing: error))
            return
        }
        do {
            let climbResponse = try JSONDecoder().decode(ClimbResponse.self, from: data)
            handler(climbResponse.routes)
        } catch {
            print(error)
        }
        print(String(data: data, encoding: .utf8)!)
    }
    task.resume()
}

extension Array {
    func insertionIndexOf(_ elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

func fourDecPrecision(float: Float) -> String {
    return String(format: "%.4f", float)
}
