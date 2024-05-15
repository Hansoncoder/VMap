//
//  VMapViewController+Navigation.swift
//  VMap
//
//  Created by Admin on 5/14/24.
//

import Foundation
import GoogleMaps
import CoreMotion

/// MARK: Navigation view

extension VMapViewController {
    func calculateDirections(_ needNavigation: Bool = false) {
        guard let origin = self.mapView.myLocation?.coordinate,
              let destination = self.destination?.coordinate  else { return }
        let originText = "\(origin.latitude),\(origin.longitude)"
        let destinationText = "\(destination.latitude),\(destination.longitude)"
        
        let string = VMapConfig.drivingURL
            .replacingOccurrences(of: "${1}", with: originText)
            .replacingOccurrences(of: "${2}", with: destinationText)
        guard let url = URL(string: string) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            guard let data = data else { return }
            
            do {
                let result = try CleanJSONDecoder().decode(DirectionsResult.self, from: data)
                DispatchQueue.main.async {
                    self.result = result
                    if needNavigation {
                        self.startNavigation()
                    }
                }
            } catch {
                print("Error: \(error)")
            }
        }.resume()
    }
    
    func showRoute(_ result: DirectionsResult) {
        guard let route = result.routes.first else { return
        }
        
        let path = GMSPath(fromEncodedPath: route.overview_polyline.points)
        directionsRenderer?.map = nil
        directionsRenderer?.path = path
        directionsRenderer?.map = mapView
    }
}

extension VMapViewController {
    
    func startNavigation() {
        isNavigationView = true
        
        // showRoutePath
        if let result = result {
            showRoute(result)
        }
        
        // setup Bottom Tools
        bottomView.type = .navigation
        bottomView.showContainView()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        // setup mapView
        showMyLocation()
        enableNavigationView()
        
        // clean and record data
        routePath.removeAllCoordinates()
        startTime = Date()
        
        navigationTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
            timer in
            
            guard let origin = self.mapView.myLocation?.coordinate,
                  let destination = self.destination?.coordinate  else {
                return
            }
            
            let originText = "\(origin.latitude),\(origin.longitude)"
            let destinationText = "\(destination.latitude),\(destination.longitude)"
            
            let string = VMapConfig.drivingURL
                .replacingOccurrences(of: "${1}", with: originText)
                .replacingOccurrences(of: "${2}", with: destinationText)
            guard let url = URL(string: string) else {
                return
            }
            
            URLSession.shared.dataTask(with: url) {
                (data, response, error) in
                guard let data = data else { return }
                
                do {
                    let result = try CleanJSONDecoder().decode(DirectionsResult.self, from: data)
                    DispatchQueue.main.async {
                        self.showRoute(result)
                        self.updateNavigation(result)
                    }
                } catch {
                    print("Error: \(error)")
                }
            }.resume()
        }
    }
    
    func updateNavigation(_ result: DirectionsResult) {
        guard let route = result.routes.first else {
            return
        }
        
        let path = GMSPath(fromEncodedPath: route.overview_polyline.points)
        directionsRenderer?.path = path
    }
}


extension VMapViewController {
    @objc func exitNavigation() {
        mapView.animate(toZoom: VMapDefaultStyle.normalZoom)
        navigationTimer?.invalidate()
        mapView.clear()
        directionsRenderer?.map = nil
        endTime = Date()
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        showNavigationSummary()
    }
    
    func showNavigationSummary() {
        guard let startTime = startTime,
        let endTime = endTime else {
            return
        }
        
        let routePolyline = GMSPolyline(path: routePath)
        routePolyline.strokeColor = .lightGray
        routePolyline.strokeWidth = 10
        routePolyline.map = mapView
        
        let times = endTime.timeIntervalSince(startTime)
        let minutes = Int(times) / 60
        let seconds = Int(times) % 60
        self.bottomView.timeLabel.text = "\(minutes)mins \(seconds)s"
        
        bottomView.type = .overview
        bottomView.showContainView()
    }
}
