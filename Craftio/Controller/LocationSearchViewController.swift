
import UIKit
import CoreLocation
import GoogleMaps
import GooglePlaces
import IQKeyboardManagerSwift

class LocationSearchViewController: UIViewController,UITextFieldDelegate
{
    @IBOutlet weak var lblMyLocation: UILabel!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var tblLocationList: UITableView!
    @IBOutlet weak var viewMap: UIView!
    @IBOutlet weak var btnCleartext: UIButton!
    //MARK:- variable declaration
    var placesClient: GMSPlacesClient!
    var placeArray = [GMSAutocompletePrediction]()
    var selectedLocation : ((GMSPlace)->())?
    var filter = GMSAutocompleteFilter()
    var bloackClearFilter : (()->())?
    
    var callBack : (()->())?
    
    var selectedLoc = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        
        //IQKeyboardManager.shared.enable = true
        btnCleartext.isHidden = true
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        

        
        placesClient = GMSPlacesClient()
        LoadMap()
        txtSearch.attributedPlaceholder = NSAttributedString(string: "Find your location",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor (red: 116.0/255.0, green: 122.0/255.0, blue: 130.0/255.0, alpha: 1.0)])
        lblMyLocation.text = selectedLoc
        tblLocationList.keyboardDismissMode = .interactive

    }
    
    //Load map
    func LoadMap(){
        self.viewMap.addSubview(APPDELEGATE!.viewMap)
        let camera = GMSCameraPosition.camera(withLatitude: APPDELEGATE?.CurrentLocationLat ?? (APPDELEGATE?.SelectedLocationLat ?? 0.00), longitude: APPDELEGATE?.CurrentLocationLong ?? (APPDELEGATE?.SelectedLocationLong ?? 0.00), zoom: 14.0)
        APPDELEGATE!.viewMap?.animate(to: camera)
    }
    

//Set Location to Center of Map
func LocationCenter(lat:Double,long:Double){
}

    @IBAction func btnClose(_ sender: Any) {
        txtSearch.text = ""
        btnCleartext.isHidden = true
        self.placeArray.removeAll()
        self.tblLocationList.reloadData()
    }
    
    @IBAction func btnCurrentLoc(_ sender: Any) {
        self.view.endEditing(true)
        APPDELEGATE!.isAddressEdited = true
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func btnBack(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    //MARK:- custome Action
    private func Autocomplate(searchString: String) {
        filter.type = .noFilter  //suitable filter type
        //
        self.placesClient.autocompleteQuery(searchString, bounds: nil, filter: filter) { (result,error ) in
            if error != nil {
                return
            }
            self.placeArray = result!
            DispatchQueue.main.async {
                self.tblLocationList.reloadData()
            }
        }
    }

    //MARK:- textfiled delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        if newString == "" {
            self.placeArray.removeAll()
            self.tblLocationList.reloadData()
            return true
        }
        if (txtSearch.text?.count)! > 0{
            btnCleartext.isHidden = false
        }else{
            btnCleartext.isHidden = true
        }
        self.Autocomplate(searchString:newString!)
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtSearch.resignFirstResponder()
        if (txtSearch.text?.count)! > 0{
            btnCleartext.isHidden = false
        }else{
            btnCleartext.isHidden = true
        }
        return false
    }

}

//MARK:- TableView Delegate and Datasource Methods
extension LocationSearchViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        //Get lable by Tag
        let lblName = cell.contentView.viewWithTag(1) as? UILabel
        let placeAttribute = placeArray[indexPath.row]
        lblName!.attributedText = placeAttribute.attributedFullText

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let placeAttribute = placeArray[indexPath.row]
        let placeid = placeAttribute.placeID
        self.view.endEditing(true)
        placesClient.lookUpPlaceID(placeid, callback: { (place, error) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            guard let place = place else {
                print("No place details for \(String(describing: placeid))")
                return
            }
            
            if self.selectedLocation != nil {
                self.selectedLocation!(place)
            }
            _ = CLLocation (latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            self.bloackClearFilter?()
            self.getaddress(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        })
    }
    
    //Get address from lat long
    func getaddress(latitude: Double,longitude: Double)  {
        let location = CLLocation (latitude: latitude, longitude: longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil{
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            
            if (placemarks?.count)! > 0{
                let pm = (placemarks?[0])! as CLPlacemark
                let str = (pm.addressDictionary!["FormattedAddressLines"]! as! NSArray).componentsJoined(by: ", ")
                print(str)
                
                APPDELEGATE!.SelectedLocationAddress = str
                APPDELEGATE!.SelectedLocationLat = latitude
                APPDELEGATE!.SelectedLocationLong = longitude
                APPDELEGATE!.isAddressEdited = true
                self.navigationController?.popViewController(animated: true)
                APPDELEGATE?.SelectedLocationCity = pm.locality ?? ""
                if APPDELEGATE?.SelectedLocationCity == ""{
                    APPDELEGATE?.city = pm.administrativeArea ?? ""
                    APPDELEGATE?.SelectedLocationCity = pm.administrativeArea ?? ""
                    if APPDELEGATE?.SelectedLocationCity == ""{
                        APPDELEGATE?.city = pm.country ?? ""
                        APPDELEGATE?.SelectedLocationCity = pm.country ?? ""
                    }
                }
            }else{
                print("Problem with the data received from geocoder")
                DispatchQueue.main.async
                    {
                        
                }
            }
        })
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
}

extension LocationSearchViewController:GoogleLocationUpdateProtocol
{
    func selectedMarker(index: NSInteger) {
        
    }
    
    func locationDidUpdateToLocation(location: [CLLocation])
    {
        if let location = location.first
        {
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
                    self.lblMyLocation.text = str
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
    }
    
    func getAddress(location:CLLocation){
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
}
