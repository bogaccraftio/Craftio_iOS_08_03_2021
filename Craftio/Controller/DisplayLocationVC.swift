
import UIKit
import GoogleMaps
import GooglePlaces


class DisplayLocationVC: UIViewController {

    @IBOutlet weak var viewMap: GMSMapView!
    var lat = String()
    var long = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        LoadMap()
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }

    
    //Load map
    func LoadMap(){
        let google_location_manager = GoogleLocation.GoogleSharedManager
        google_location_manager.delegate = self
        google_location_manager.init_location(self.viewMap, startUpdatingLocation: true, viewinfo: self, displayMarkerOtherMatkers: false)
        setMarker(Lat: Double(lat )!, Long: Double(long )!, tag: 10000)
    }

}

extension DisplayLocationVC:GoogleLocationUpdateProtocol
{
    func selectedMarker(index: NSInteger) {
        
    }
    
    func locationDidUpdateToLocation(location: [CLLocation])
    {
    }
    
    func setMarker(Lat:Double,Long:Double,tag:Int)
    {
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
        var markerimagename = String()
        markerimagename = "map-pin"//"cmap"
        let markerImage = UIImage(named: markerimagename)
        let markerView = UIImageView(image: markerImage)
        marker.iconView = markerView
        marker.iconView?.tag = tag
        marker.groundAnchor = CGPoint (x: 0.5, y: 0.5)
        marker.map = viewMap
        let camera = GMSCameraPosition.camera(withLatitude: Lat, longitude: Long, zoom: 14.0)
        
        self.viewMap?.animate(to: camera)
    }

}
