
import Foundation
import CoreLocation
import GoogleMaps
import MapKit

protocol GoogleLocationUpdateProtocol
{
    func locationDidUpdateToLocation(location : [CLLocation])
    func selectedMarker(index:NSInteger)
}

class GoogleLocation: NSObject, CLLocationManagerDelegate
{
    static let GoogleSharedManager = GoogleLocation()
    private var locationManager = CLLocationManager()
    var currentLocation : [CLLocation]!
    var delegate : GoogleLocationUpdateProtocol!
    var map_type = GMSMapView()
    var infoWindow = MapMarkerView()
    var viewinfo = UIViewController()
    var locationMarker : GMSMarker? = GMSMarker()
    var markerimagename = String()
    var displayMarkerOtherMatkers = true
    var isFirstTime = true
    var timer = Timer()
    
    override init ()
    {
        super.init()
        self.map_type.delegate = self
    }
    
    func init_location(_ type:GMSMapView, startUpdatingLocation:Bool,viewinfo:UIViewController,displayMarkerOtherMatkers:Bool)
    {
        self.displayMarkerOtherMatkers = displayMarkerOtherMatkers
        self.map_type = type
        self.locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        if startUpdatingLocation == true
        {
        }
        else
        {
            DispatchQueue.main.async
                {
                    self.delegate.locationDidUpdateToLocation(location: self.currentLocation)
            }
        }
        
        getaddress(location: locationManager.location ?? CLLocation (latitude: 51.5100909, longitude: -0.1341891))
        self.viewinfo = viewinfo
        NotificationCenter.default.addObserver(self,selector: #selector(self.hideMarkerView),name: Notification.Name("hideMarkerView"),object: nil)
        if APPDELEGATE?.selectedUserType == .Client
        {
            self.markerimagename = "map-pin"//"cmap"
        }
        else
        {
            self.markerimagename = "map_marker"
        }
        APPDELEGATE?.CurrentLocationLat = locationManager.location?.coordinate.latitude ?? 51.5100909
        APPDELEGATE?.CurrentLocationLong = locationManager.location?.coordinate.longitude ?? -0.1341891
        APPDELEGATE?.SelectedLocationLat =  APPDELEGATE!.CurrentLocationLat
        APPDELEGATE?.SelectedLocationLong =  APPDELEGATE!.CurrentLocationLong
        
        self.map_type.delegate = self
        self.delegate.locationDidUpdateToLocation(location: [locationManager.location ?? CLLocation (latitude: 51.5100909, longitude: -0.1341891)])
        self.Google_Map()
        timer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
    }
    
    func updateLocation()  {
        self.locationManager.startUpdatingLocation()
    }
    
    @objc func runTimedCode()  {
    }
    
    func getaddress(location:CLLocation){
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil
            {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0
            {
                let pm = (placemarks?[0])! as CLPlacemark
                let str = (pm.addressDictionary!["FormattedAddressLines"]! as! NSArray).componentsJoined(by: ", ")
                print(str)
                APPDELEGATE?.CurrentLocationAddress = str
                APPDELEGATE?.CurrentLocationLat = location.coordinate.latitude
                APPDELEGATE?.CurrentLocationLong = location.coordinate.longitude
                APPDELEGATE?.SelectedLocationAddress =  APPDELEGATE!.CurrentLocationAddress
                APPDELEGATE?.SelectedLocationLat =  APPDELEGATE!.CurrentLocationLat
                APPDELEGATE?.SelectedLocationLong =  APPDELEGATE!.CurrentLocationLong
                APPDELEGATE?.city = pm.locality ?? ""
                APPDELEGATE?.currentCity = pm.locality ?? ""
                APPDELEGATE?.SelectedLocationCity = pm.locality ?? ""
                if APPDELEGATE?.SelectedLocationCity == ""{
                    APPDELEGATE?.city = pm.administrativeArea ?? ""
                    APPDELEGATE?.currentCity = pm.administrativeArea ?? ""
                    APPDELEGATE?.SelectedLocationCity = pm.administrativeArea ?? ""
                    if APPDELEGATE?.SelectedLocationCity == ""{
                        APPDELEGATE?.city = pm.country ?? ""
                        APPDELEGATE?.currentCity = pm.country ?? ""
                        APPDELEGATE?.SelectedLocationCity = pm.country ?? ""
                    }
                }
            }
            else
            {
                print("Problem with the data received from geocoder")
                DispatchQueue.main.async
                    {
                        
                }
            }
        })
    }
    
    @objc private func hideMarkerView(notification: NSNotification)
    {
        self.infoWindow.removeFromSuperview()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        currentLocation = locations
        DispatchQueue.main.async
            {
                self.delegate.locationDidUpdateToLocation(location: self.currentLocation)
        }
        self.locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
    
    func Google_Map()
    {
        let camera = GMSCameraPosition.camera(withLatitude: locationManager.location?.coordinate.latitude ?? 51.5100909,longitude: locationManager.location?.coordinate.longitude ?? -0.1341891,zoom: 14.0)
        self.map_type.camera = camera
        
        do
        {
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                self.map_type.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
        setcurrentLocation(type: self.map_type, location: locationManager.location ?? CLLocation (latitude: 51.5100909, longitude: -0.1341891))
    }
        
    func setcurrentLocation(type:GMSMapView,location:CLLocation){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let markerView = loadCurrentLocNib()
        markerView.initPulse()
        marker.iconView = markerView
        marker.iconView?.tag = 500000
        marker.groundAnchor = CGPoint (x: 0.5, y: 0.5)
        marker.map = type
    }
}

extension GoogleLocation: GMSMapViewDelegate
{
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    {
        if APPDELEGATE?.selectedUserType == .Client
        {
            return true
        }
    
        if marker.iconView?.tag == 500000 || marker.iconView?.tag == 10000{
            return true
        }
        infoWindow.removeFromSuperview()
        print(marker)
        infoWindow = loadNiB()
        locationMarker = marker
        infoWindow.center = self.map_type.projection.point(for: CLLocationCoordinate2D(latitude: marker.position.latitude, longitude: marker.position.longitude))
        infoWindow.center.y = infoWindow.center.y
        
        //
        infoWindow.layer.masksToBounds = true
        infoWindow.layer.cornerRadius = 27.0
        infoWindow.clipsToBounds = true
        // border
        infoWindow.layer.borderWidth = 0.2
        infoWindow.layer.borderColor = UIColor.gray.cgColor
        // shadow
        infoWindow.layer.shadowColor = UIColor.gray.cgColor
        infoWindow.layer.shadowOffset = CGSize(width: 3, height: 3)
        infoWindow.layer.shadowOpacity = 0.7
        infoWindow.layer.shadowRadius = 4.0
        //
        infoWindow.tag = (marker.iconView?.tag)!
        infoWindow.jobviewVC = viewinfo
        infoWindow.detail = marker.userData as? JobHistoryData
        infoWindow.setupData()
        self.viewinfo.view.addSubview(infoWindow)
        return true
    }
    
    func loadNiB() -> MapMarkerView
    {
        let infoWindow = MapMarkerView.instanceFromNib() as! MapMarkerView
        return infoWindow
    }
    
    func loadCurrentLocNib() -> CustomCurrentLocationView{
        let infoWindow = CustomCurrentLocationView.instanceFromNib() as! CustomCurrentLocationView
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition)
    {
        if APPDELEGATE?.selectedUserType == .Client
        {
            return
        }

        if (self.locationMarker?.position != nil){
            guard let location = self.locationMarker?.position else {
                print("locationMarker is nil")
                return
            }
            infoWindow.center = mapView.projection.point(for: location)
            infoWindow.center.y = infoWindow.center.y
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D)
    {
        if APPDELEGATE?.selectedUserType == .Client
        {
            return 
        }

        infoWindow.removeFromSuperview()
    }
}

