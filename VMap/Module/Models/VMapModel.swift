//
//  VMapPlaceModel.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import CoreLocation

struct VMapPlaceModel {
    var id: String? = nil
    var name: String? = nil
    var desc: String? = nil
    var coordinate: CLLocationCoordinate2D
}

struct DirectionsResult: Codable {
    let routes: [Route]
}

struct Route: Codable {
    let overview_polyline: Polyline
    let legs: [Leg]
}

struct Polyline: Codable {
    let points: String
}

struct Leg: Codable {
    let start_address: String
    let start_location: Location
    
    let end_address: String
    let end_location: Location
    let duration: TextValue
    let distance: TextValue
}

struct TextValue: Codable {
    let text: String
    let value: Int
}

struct Location: Codable {
    let lat: Double
    let lng: Double
}
