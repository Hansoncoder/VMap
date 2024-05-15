### Program Summary
&emsp; &emsp;This map application is developed using Google Maps as its foundation, offering robust route planning and navigation functionalities. Upon completing navigation, users are presented with a detailed trip summary.

- Features:
    + Long-press to add a marker, single-click to remove a marker.
    + Click on a business or marker to plan a route.
    + Click on a business or marker to initiate real-time navigation.

- To Run:
    + Please register your application with Google Maps to obtain an API key, and then configure it within your project's settings. Refer to the configuration file provided.
>```Swift
>struct VMapConfig {
>    static let apiKey = "Your apikey"
>}
>```

<img src="./Docs/readme.gif" width="250" height="480">

### Solution Steps

- Thoroughly review and understand the requirements.
- Begin by setting up the Google Maps Platform and carefully examine the official documentation and demos.
- Break down the task into manageable implementation steps:
    + Display the my location information.
    + Implement the functionality to click on a business to retrieve its location and display its name.
    + Develop route planning capabilities.
    + Implement real-time navigation and provide options to exit navigation.
    + Display a comprehensive summary at the conclusion of navigation.

### Code Snippets

- To display the user's location information:
```Swift
locationManager.startUpdatingLocation()

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: VMapDefaultStyle.normalZoom, bearing: location.course, viewingAngle: mapView.camera.viewingAngle)
    locationManager.stopUpdatingLocation()
}
```

- To clear a marker with a single click:
```Swift
func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    if (self.bottomView.type != .navigation) {
        cleanDidClick()
        bottomView.clean()
        result = nil
    }
}
```

- To add a marker with a long press:
```Swift
func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    let marker = GMSMarker(position: coordinate)
    marker.map = mapView
}
```

- To initiate route planning:
```Swift
func calculateDirections() {
    let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=${origin}&destination=${destination}&mode=driving&key=\(VMapConfig.apiKey)"
    guard let url = URL(string: urlString) else {
        return
    }
     URLSession.shared.dataTask(with: url) {
     ....
    }.resume()
}
```

- To begin real-time navigation:

```Swift
func startNavigation() {
    // showRoutePath
    if let result = result {
        showRoute(result)
    }
    
    // clean coordinate
    routePath.removeAllCoordinates()
    // record begin time
    startTime = Date()
    
    // startUpdating
    locationManager.startUpdatingLocation()
    locationManager.startUpdatingHeading()
        
    navigationTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) {
        calculateDirections()
        updateNavigation(result)
    }
}

func showRoute(result) {
    let route = result.routes.first
    let path = GMSPath(fromEncodedPath: route.overview_polyline.points)
    directionsRenderer?.map = nil
    directionsRenderer?.path = path
    directionsRenderer?.map = mapView
}

func updateNavigation() {
    let path = GMSPath(fromEncodedPath: points)
    directionsRenderer?.path = path
}

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    if isNavigationView {
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: VMapDefaultStyle.normalZoom, bearing: location.course, viewingAngle: mapView.camera.viewingAngle)
    }
}

func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    guard let currentLocation = manager.location?.coordinate else {
        return
    }
    // Record coordinate
    routePath.add(location.coordinate)
    
    // update camera
    let camera = GMSCameraPosition.camera(withTarget: currentLocation, zoom: mapView.camera.zoom, bearing: newHeading.trueHeading, viewingAngle: mapView.camera.viewingAngle)
    mapView.animate(to: camera)
}
```

- Show navigation summary：

```Swift
func exitNavigation() {
    // record end time
    endTime = Date()
    
    // some code
    ......
    
    // show summary
    showNavigationSummary()
    
}
func showNavigationSummary() {
    guard let startTime = startTime,
        let endTime = endTime else {
        return
    }
     
    // show time
    let times = endTime.timeIntervalSince(startTime)
    let minutes = Int(times) / 60
    let seconds = Int(times) % 60
    self.bottomView.timeLabel.text = "\(minutes)mins \(seconds)s"
    
    // show route path
    let routePolyline = GMSPolyline(path: routePath)
    routePolyline.strokeColor = .lightGray
    routePolyline.strokeWidth = 10
    routePolyline.map = mapView
}
```

### Issues Encountered
- Unable to display the authorization dialog to obtain user location information.
- Solution: 
  + Troubleshoot by comparing the process with the provided demo. 
  +  `step1:` Check Configuration Information.
  +  `step2:` Review the Authorization Request Process in Code.
  
```swift
// If the app requires foreground location permissions, it needs to configure
NSLocationWhenInUseUsageDescription;
// If the app requires background location permissions, it needs to configure
NSLocationAlwaysAndWhenInUseUsageDescription;

// iOS 6.0–8.0 Deprecated
NSLocationUsageDescription
// iOS 8.0–10.0 Deprecated
NSLocationAlwaysUsageDescription
```

### References
- [1][Google Maps Platform](https://developers.google.com/maps/documentation/directions)
- [2][Apple information property list](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationusagedescription)