### Program Summary
&emsp; &emsp; This map is developed based on Google Maps and features route planning and navigation capabilities. After navigation ends, a trip summary is displayed.

- Features:
    + Long press to add marker, single click to remove marker.
    + Click on a business or marker to plan a route.
    + Click on a business or marker to start real-time navigation.

- Run:
Please register your application on Google Maps to obtain an API key, then configure it in your project. Configuration file.
```Swift
struct VMapConfig {
    static let apiKey = "Your apikey"
}
```
<img src="./Docs/readme.gif" width="250" height="480">

### Solution steps

- Carefully read and understand the requirements.
- Preliminary work includes setting up the Google Maps Platform and reviewing the official documentation and demos provided by the platform.
- Break down the task into implementation steps:
    + Display the user's location information.
    + Implement the ability to click on a business to retrieve its location and display the business name.
    + Implement route planning.
    + Implement navigation and exit navigation.
    + Display a summary at the end of the navigation.

- Display the user's location information.
```Swift
locationManager.startUpdatingLocation()

func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let location = locations.first else { return }
    mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: VMapDefaultStyle.normalZoom, bearing: 0, viewingAngle: 0)
    locationManager.stopUpdatingLocation()
}
```

- Single click to clear marker.
```Swift
func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
    if (self.bottomView.type != .navigation) {
        cleanDidClick()
        bottomView.clean()
        result = nil
    }
}
```

- Long press to add marker
```Swift
func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
    let marker = GMSMarker(position: coordinate)
    marker.map = mapView
}
```

- Get route planning
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

- Start real-time map navigation.
```Swift
func startNavigation() {
    // showRoutePath
    if let result = result {
        showRoute(result)
    }
    
    navigationTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: true) {
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

```

### Issues Encountered

- Request authorization dialog cannot be displayed, unable to obtain own location information.
- Solution: 
  + Troubleshoot by comparing the process with the demo. 
  +  `step1:` Check Configuration Information
  +  `step2:` Review the Authorization Request Process in Code
  
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

- [1][Google Maps Platform](https://developers.google.com/maps/documentation/directions)
- [2][Apple information property list](https://developer.apple.com/documentation/bundleresources/information_property_list/nslocationusagedescription)