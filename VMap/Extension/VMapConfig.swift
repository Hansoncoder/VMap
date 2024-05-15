//
//  VMapConfig.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import Foundation
struct VMapConfig {
    static let apiKey = "Your app key"
    
    static let drivingURL = "https://maps.googleapis.com/maps/api/directions/json?origin=${1}&destination=${2}&mode=driving&key=\(VMapConfig.apiKey)"
    
}

struct VMapDefaultStyle {
    // navigation line
    static let lineColor = "#00FF66".color
    static let lineWidth: CGFloat = 10
    
    // Zoom
    static let normalZoom: Float = 15
    static let navigationZoom: Float = 18
}
