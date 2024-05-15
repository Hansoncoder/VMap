//
//  ViewController.swift
//  VMap
//
//  Created by Admin on 5/13/24.
//

import UIKit
import SnapKit

import CoreLocation
import GoogleMaps

class VMapViewController: UIViewController {
    lazy var locationManager = CLLocationManager()
    lazy var mapView: GMSMapView =  {
        let options = GMSMapViewOptions()
        options.camera = GMSCameraPosition(latitude: 1.285, longitude: 103.848, zoom: VMapDefaultStyle.normalZoom)
        let view = GMSMapView(options: options)
        return view
    }()
    
    // Renderer
    var directionsRenderer: GMSPolyline?
    
    //  Tools
    lazy var bottomView = VMapBottomToolView()
    lazy var zoomLevel: Float = VMapDefaultStyle.normalZoom
    
    // MARK: - data
    var isNavigationView: Bool = false
    // destination
    var destination: VMapPlaceModel? = nil {
        didSet {
            bottomView.clean()
            bottomView.placeLabel.text = destination?.name
        }
    }
    var result: DirectionsResult? = nil {
        didSet {
            bottomView.descLabel.text = result?.routes.first?.legs.first?.start_address
            bottomView.updateTime(result?.routes.first?.legs.first?.duration.text)
        }
    }
    // navigation
    var navigationTimer: Timer?
    
    // Route Overview
    var routePath = GMSMutablePath()
    var startTime: Date?
    var endTime: Date?
    
    
    //MARK: -  Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // map view
        setupMapView()
        
        // tools view
        setupToolView()
        
        // Location Authorization
        setupLocationManager()
        
        // DirectionsRenderer
        setupDirectionsRenderer()
    }
}

// MARK:  - GMSMapViewDelegate & Marker
extension VMapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapPOIWithPlaceID placeID: String, name: String, location: CLLocationCoordinate2D) {
        destination = VMapPlaceModel(id: placeID, name: name.filterChinese, coordinate: location)
        setupLocationInfo()
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if (self.bottomView.type != .navigation) {
            cleanDidClick()
            bottomView.clean()
            result = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        destination = VMapPlaceModel(name: "Dropped pin", coordinate: coordinate)
        setupLocationInfo()
        addMarker(coordinate: coordinate)
    }
    
    func setupLocationInfo() {
        mapView.clear()
        result = nil
        bottomView.type = .destination
        bottomView.showContainView()
        calculateDirections()
    }
    
    func addMarker(coordinate: CLLocationCoordinate2D) {
        
        let marker = GMSMarker(position: coordinate)
        marker.map = mapView
        
        // Geocode Coordinate
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { [weak self] response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            marker.title = lines.joined(separator: "\n")
            self?.destination?.name = address.thoroughfare
            self?.destination?.desc = marker.title
            
            self?.bottomView.descLabel.text = address.thoroughfare
            self?.bottomView.descLabel.text = marker.title
        }
    }
}

extension VMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        if bottomView.type != .navigation {
            locationManager.stopUpdatingLocation()
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: VMapDefaultStyle.normalZoom, bearing: 0, viewingAngle: 0)
        } else {
            routePath.add(location.coordinate)
            if isNavigationView {
                mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: VMapDefaultStyle.normalZoom, bearing: location.course, viewingAngle: mapView.camera.viewingAngle)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if bottomView.type != .navigation {
            locationManager.stopUpdatingHeading()
        }
        guard isNavigationView,
              let currentLocation = manager.location?.coordinate else {
            return
        }
        
        let camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: mapView.camera.zoom, bearing: newHeading.trueHeading, viewingAngle: mapView.camera.viewingAngle)
        mapView.animate(to: camera)
    }
}

// MARK: - setup
extension VMapViewController {
    private func setupLocationManager() {
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 100
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func setupDirectionsRenderer() {
        directionsRenderer = GMSPolyline()
        directionsRenderer?.strokeColor = VMapDefaultStyle.lineColor
        directionsRenderer?.strokeWidth = VMapDefaultStyle.lineWidth
    }
    
    private func setupMapView() {
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
        mapView.settings.compassButton = true
        
        mapView.autoresizingMask = [.flexibleWidth , .flexibleHeight]
        mapView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupToolView() {
        view.addSubview(bottomView)
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(200)
        }
        bottomView.delegate = self
    }
}

// MARK: - VMapBottomToolViewDelegate
extension VMapViewController: VMapBottomToolViewDelegate {
    func cleanDidClick() {
        mapView.clear()
        bottomView.clean()
        bottomView.type = .destination
        bottomView.hiddenContainView()
        enablePlainView()
    }
    
    func switchNavigationView() {
        isNavigationView = !isNavigationView
        if (isNavigationView) {
            enableNavigationView()
            showMyLocation()
        } else {
            enablePlainView()
        }
    }
    
    func showMyLocation() {
        if let myLocation = mapView.myLocation {
           mapView.animate(toLocation: myLocation.coordinate)
        }
    }
    
    func directionsDidClick() {
        bottomView.type = .destination
        bottomView.showContainView()
        if let result = result {
            showRoute(result)
        }
    }
    
    func enableNavigationView() {
        guard let location = mapView.myLocation else { return }
        let camera = GMSCameraPosition.camera(withTarget: location.coordinate, zoom: VMapDefaultStyle.navigationZoom, bearing: location.course, viewingAngle: 45)
        mapView.animate(to: camera)
        mapView.settings.scrollGestures = false
        mapView.settings.zoomGestures = false
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
    }

    func enablePlainView() {
        let camera = GMSCameraPosition.camera(withTarget: mapView.camera.target, zoom: VMapDefaultStyle.normalZoom, bearing: 0, viewingAngle: 0)
        mapView.animate(to: camera)
        mapView.settings.scrollGestures = true
        mapView.settings.zoomGestures = true
        mapView.settings.rotateGestures = true
        mapView.settings.tiltGestures = true
        if let path = directionsRenderer?.path {
            let bounds = GMSCoordinateBounds(path: path)
            mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50.0))
        }
    }
}
