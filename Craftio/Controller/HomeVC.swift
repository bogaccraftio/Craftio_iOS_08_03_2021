
import UIKit
import Kingfisher
import AVKit
import AVFoundation
import CoreLocation
import GoogleMaps
import Lightbox
import IQKeyboardManagerSwift
import Photos
import StoreKit
import Alamofire
import AlamofireImage
import MapKit


class HomeVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIGestureRecognizerDelegate {
    
    @IBOutlet weak var categoryViewBottom: NSLayoutConstraint!
    @IBOutlet weak var viewTab: UIView!
    @IBOutlet weak var viewCat: UIView!
    @IBOutlet weak var lblMessageCount: UILabel!
    @IBOutlet weak var collectionCategoy: UICollectionView!
    @IBOutlet weak var viewMap: GMSMapView!
    @IBOutlet weak var topSearch: UIView!
    @IBOutlet weak var lblCurrentLocation: UILabel!
    @IBOutlet weak var lblNoNearByJobsFilterCrafterSide: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnFilterCrafter: UIButton!
    @IBOutlet weak var AddImage: UIImageView!
    
    @IBOutlet weak var btnUrgent: UIButton!
    @IBOutlet weak var lblUrgent: UILabel!
    
    @IBOutlet weak var lblChatCount: UILabel!
    @IBOutlet weak var lblNotificationCount: UILabel!
    
    @IBOutlet weak var lblEmergency: UILabel!
    @IBOutlet weak var heightlblEmerg: NSLayoutConstraint!//47
    @IBOutlet weak var bottomGivingYouTrouble: NSLayoutConstraint!//47
    
    var imagePicker = UIImagePickerController()
    var images = [UIImage]()
    var serviceListData = [[String: Any]]()
    var selectedServiceData = [String: Any]()
    var isCategorySelected: Bool = false
    var isFirstTime = true
    var CrafterList: [JobNearByData]?
    var jobListClients: [JobHistoryData]?
    var selectedServiceIds = String()
    var arrSelectedIds = NSMutableArray()
    var currentMarker = GMSMarker()
    var isadd = false
    var changeAddress = false
    var isFirstTImeService = true
    var arrUnreadCount = NSMutableArray()
    var google_location_manager = GoogleLocation()
    var arrDummyLocation = [CLLocation]()
    var isCountryCodeAvail = true
    var oldLocationForDummyPinsClientSide: CLLocation?
    var distanceFromLastLocation: Double = 0.0
    
    @IBOutlet weak var viewCrafterFilter: UIView!
    @IBOutlet weak var CraftercategoryViewBottom: NSLayoutConstraint!
    @IBOutlet weak var CraftercollectionCategoy: UICollectionView!
    
    @IBOutlet weak var BtnRedAlert: UIButton!
    var productsArray = [SKProduct]()
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblNoNearByJobsFilterCrafterSide.isHidden = true
        APPDELEGATE?.isfromChat()
        lblMessageCount.isHidden = true
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses = [HomeVC.self]

        APPDELEGATE!.isAddressEdited = false
        self.categoryViewBottom.constant = 0
        CraftercategoryViewBottom.constant = -700
        self.setNeedsStatusBarAppearanceUpdate()
        APPDELEGATE!.SelectedLocationAddress = ""
        APPDELEGATE!.SelectedLocationLat = APPDELEGATE?.CurrentLocationLat ?? 0.00
        APPDELEGATE!.SelectedLocationLong = APPDELEGATE?.CurrentLocationLat ?? 0.00
        let panRec = UIPanGestureRecognizer(target: self, action: #selector(self.didDragMap(_:)))
        panRec.delegate = self
        viewMap?.addGestureRecognizer(panRec)
        
        let tapREc = UITapGestureRecognizer(target: self, action: #selector(self.didTapMap(_:)))
        tapREc.delegate = self
        tapREc.numberOfTapsRequired = 2
        viewMap?.addGestureRecognizer(tapREc)

        onloadOperations()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.viewMap.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationArrived(_:)), name: NSNotification.Name(rawValue: "notificationArrived"), object: nil)
        
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            let nrbyIcon = #imageLiteral(resourceName: "Combined ShapeA").withRenderingMode(.alwaysTemplate)
            self.btnUrgent.setImage(nrbyIcon, for: .normal)
            self.btnUrgent.tintColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 0.7)
                //UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 0.7)
            self.lblUrgent.text = "Nearby"
        }
        else
        {
            self.btnUrgent.setImage(#imageLiteral(resourceName: "icon-emergency-services-2-300x300"), for: .normal)
            self.lblUrgent.text = "Urgent"
        }
        self.lblChatCount.isHidden = true
        self.lblNotificationCount.isHidden = true
        self.getPlaceHolders()
    }
    
     @objc func handleTap(sender: UITapGestureRecognizer? = nil){
        if APPDELEGATE!.selectedUserType == .Crafter{
            viewTab.isHidden = false
            hideShowCategoryViewCrafter(bottom: -700)
        }
        else{
            if isadd{
                hideShowCategoryView(bottom: 0)
                isadd = false
                self.AddImage.image = UIImage(named: "plus")
                //self.AddImage.tintColor = UIColor.clear
            }         
        }
     }
    
    @objc func notificationArrived(_ notification: NSNotification) {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
            lblMessageCount.isHidden = true
            lblChatCount.isHidden = true
            lblNotificationCount.isHidden = true
        }else{
            GetNotificationCountAPI()
        }
//        updatecount()
    }

    //MARK :- function declaration
    func onloadOperations() {
        
        topSearch.layer.masksToBounds = true
        topSearch.layer.cornerRadius = 5.0
        topSearch.clipsToBounds = false
        topSearch.layer.shadowColor = UIColor.gray.cgColor
        topSearch.layer.shadowOpacity = 0.5
        topSearch.layer.shadowOffset = CGSize.zero
        topSearch.layer.shadowRadius = 5
        
        dropShadow(view:viewCat,color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        
        //radious on button
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.btnMenu.frame
        rectShape.position = self.btnMenu.center
        rectShape.path = UIBezierPath(roundedRect: self.btnMenu.bounds, byRoundingCorners: [.topRight , .bottomRight], cornerRadii: CGSize(width: 5, height: 5)).cgPath
        self.btnMenu.layer.mask = rectShape
        
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width - 45, height: self.viewCrafterFilter.bounds.size.height)
        
        //radious on button
        rectShape.bounds = self.viewCrafterFilter.frame
        rectShape.position = self.viewCrafterFilter.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 25, height: 25)).cgPath
        self.viewCrafterFilter.layer.mask = rectShape
        dropShadow(view:viewCrafterFilter,color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        google_location_manager = GoogleLocation.GoogleSharedManager
        google_location_manager.delegate = self
        google_location_manager.init_location(self.viewMap, startUpdatingLocation: true, viewinfo: self, displayMarkerOtherMatkers: true)
        arrDummyLocation = getMockLocationsFor(location: CLLocation (latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong), itemCount: 7)
    }
    
    override func viewWillAppear(_ animated: Bool){
        viewTab.isHidden = false
        //For display MessageCount
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
            lblMessageCount.isHidden = true
            lblChatCount.isHidden = true
            lblNotificationCount.isHidden = true
        }else{
            GetNotificationCountAPI()
        }
        
        if APPDELEGATE!.selectedUserType == .Crafter{
            //            getServiceListNewAPICall()
        }else{
            self.serviceListData = [[String:Any]]()
            APPDELEGATE!.serviceListData = [[String:Any]]()
            self.collectionCategoy.reloadData()
            getServiceListAPICall()
        }
        
        if APPDELEGATE!.SelectedLocationAddress == "" {
            APPDELEGATE!.SelectedLocationAddress = APPDELEGATE?.CurrentLocationAddress ?? ""
            APPDELEGATE?.SelectedLocationLong = APPDELEGATE?.CurrentLocationLong ?? 0.00
            APPDELEGATE?.SelectedLocationLat = APPDELEGATE?.CurrentLocationLat ?? 0.00
        }

        self.BtnRedAlert.isHidden = true
        
        if APPDELEGATE!.selectedUserType == .Client{
            self.AddImage.image = UIImage(named: "plus")
            self.AddImage.tintColor = UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0)
        }else{
            self.AddImage.image = UIImage(named: "menu-1")
            self.AddImage.tintColor = UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0)
        }
            changeAddress = true
            if APPDELEGATE!.SelectedLocationAddress == ""{
                self.lblCurrentLocation.text = APPDELEGATE?.CurrentLocationAddress ?? ""
            }else{
                self.lblCurrentLocation.text = APPDELEGATE?.SelectedLocationAddress ?? ""
            }
            if APPDELEGATE!.selectedUserType == .Crafter{
                self.isFirstTImeService = true
                self.getJobListAPICall(serviceId: "",lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00,callSilently:false)
            }else{
                self.getCrafters(lat: APPDELEGATE?.SelectedLocationLat  ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00, callSilently: false)
            }
        self.getaddress(latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong)
        LocationCenter(lat:APPDELEGATE!.SelectedLocationLat,long:APPDELEGATE!.SelectedLocationLong)
    }
    
    //Set Location to Center of Map
    func LocationCenter(lat:Double,long:Double){
        let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 14.0)
        self.viewMap?.animate(to: camera)
    }
    
    //MARK :- Button Actions
    @IBAction func btnCenterLocation(_ sender: UIButton) {
        google_location_manager.updateLocation()

        APPDELEGATE!.isAddressEdited = false
        self.lblCurrentLocation.text = APPDELEGATE!.CurrentLocationAddress
        
        self.currentMarker.position = CLLocationCoordinate2D(latitude: APPDELEGATE!.CurrentLocationLat, longitude: APPDELEGATE!.CurrentLocationLong)
        self.currentMarker.map = self.viewMap
        APPDELEGATE!.SelectedLocationLat = APPDELEGATE!.CurrentLocationLat
        APPDELEGATE!.SelectedLocationLong = APPDELEGATE!.CurrentLocationLong
        getaddress(latitude: APPDELEGATE?.CurrentLocationLat ?? 0.00, longitude: APPDELEGATE?.CurrentLocationLong  ?? 0.00)
        LocationCenter(lat:APPDELEGATE!.CurrentLocationLat,long:APPDELEGATE!.CurrentLocationLong)
    }
    
    @IBAction func btnAddAction(_ sender: UIButton) {
        
        NotificationCenter.default.post(name: Notification.Name("hideMarkerView"), object: "register")
        if APPDELEGATE?.selectedUserType == .Crafter{
            hideShowCategoryViewCrafter(bottom: 30)
            viewTab.isHidden = true
        }else{
            self.lblEmergency.isHidden = true
            heightlblEmerg.constant = 0
            //bottomGivingYouTrouble.constant = 29
            if isadd{
                hideShowCategoryView(bottom: 0)
                isadd = false
                self.AddImage.image = UIImage(named: "plus")
            }
            else{
                hideShowCategoryView(bottom: 420)
                isadd = true
                let ImgAdd = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
                self.AddImage.image = ImgAdd
                self.AddImage.tintColor = UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0)
                APPDELEGATE?.is_Emergency = "0"
            }
        }
    }
    
    @IBAction func btnCrafterFilter(_ sender: UIButton) {
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        if APPDELEGATE!.selectedUserType == .Crafter{
            selectedServiceIds = arrSelectedIds.componentsJoined(by: ",")
             self.getJobListAPICall(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00,callSilently:false)
        }
    }
    
    @IBAction func btnHideCrafterFilter(_ sender: UIButton) {
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
    }
    
    @IBAction func btnGotoChat(_ sender: UIButton){
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        hideShowCategoryView(bottom: 0)
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "Chat", data: [:], image:[])
            return
        }
        
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let objUnblockRehireVC = storyboard.instantiateViewController(withIdentifier: "ChatuserListViewController") as! ChatuserListViewController
        self.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
    }
    
    @IBAction func btnGotoNotification(_ sender: UIButton){
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        hideShowCategoryView(bottom: 0)
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "NotificationListVC", data: [:], image:[])
            return
        }
        let objNotiListVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
        self.navigationController?.pushViewController(objNotiListVC, animated: true)
    }
    
    @IBAction func btnUrgent(_ sender: UIButton){
        if APPDELEGATE!.selectedUserType == .Crafter{
            hideShowCategoryViewCrafter(bottom: -700)
            hideShowCategoryView(bottom: 0)
            isadd = false
            
            let objJobNearByVC = self.storyboard?.instantiateViewController(withIdentifier: "JobNearByVC") as! JobNearByVC
            objJobNearByVC.serviceListData = APPDELEGATE!.serviceListData
            objJobNearByVC.blockSelectedIds = { arrData in
                self.arrSelectedIds = arrData
                self.collectionCategoy.reloadData()
            }
            self.navigationController?.pushViewController(objJobNearByVC, animated: true)
        }else{
            if isadd{
                hideShowCategoryView(bottom: 0)
                isadd = false
                self.AddImage.image = UIImage(named: "plus")
                //self.AddImage.tintColor = UIColor.clear
                self.lblEmergency.isHidden = true
                heightlblEmerg.constant = 0
            }else{
                hideShowCategoryView(bottom: 420)
                isadd = true
                let ImgAdd = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
                self.AddImage.image = ImgAdd
                self.AddImage.tintColor = UIColor(red:0, green: 243/255, blue: 145/255, alpha: 1.0)
                APPDELEGATE?.is_Emergency = "1"
                self.lblEmergency.isHidden = false
                heightlblEmerg.constant = 24.5
            }
        }
    }
    
    @IBAction func btnJobListAction(_ sender: UIButton) {
        hideShowCategoryViewCrafter(bottom: -700)
        hideShowCategoryView(bottom: 0)
        isadd = false
        
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "JobHistory", data: [:], image:[])
        }else{
            let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "JobHistory") as! JobHistory
            objJobHistoryVC.serviceListData = self.serviceListData
            self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
        }
    }
    
    @IBAction func btnMapAction(_ sender: UIButton) {
        viewTab.isHidden = false
        hideShowCategoryView(bottom: 0)
        isadd = false
        hideShowCategoryViewCrafter(bottom: -700)
        if APPDELEGATE!.selectedUserType == .Crafter{
            return
        }
        self.AddImage.image = UIImage(named: "plus")
        //self.AddImage.tintColor = UIColor.clear
    }
    
    @IBAction func btnAlert(_ sender: UIButton) {
        if isadd{
            hideShowCategoryView(bottom: 0)
            isadd = false
            self.AddImage.image = UIImage(named: "plus")
        }else{
            hideShowCategoryView(bottom: 420)
            isadd = true
            let ImgAdd = UIImage(named: "x")?.withRenderingMode(.alwaysTemplate)
            self.AddImage.image = ImgAdd
            self.AddImage.tintColor = UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0)
        }
    }

    @IBAction func btnCloseCategoryViewAction(_ sender: UIButton) {
        hideShowCategoryView(bottom: 0)
        isadd = false
        if APPDELEGATE!.selectedUserType == .Client{
            self.AddImage.image = UIImage(named: "plus")
        }else{
            self.AddImage.image = UIImage(named: "menu-1")
        }
    }
    
    @IBAction func btnSearch(_ sender: Any) {
        let location = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchViewController") as? LocationSearchViewController
        location?.selectedLoc = lblCurrentLocation.text ?? ""
        location?.bloackClearFilter = {
            self.selectedServiceIds = ""
            self.arrSelectedIds.removeAllObjects()
        }
        self.navigationController?.pushViewController(location!, animated: false)
        hideShowCategoryView(bottom: 0)
        isadd = false
        hideShowCategoryViewCrafter(bottom: -700)
        
        if APPDELEGATE!.selectedUserType == .Crafter{
            return
        }
        self.AddImage.image = UIImage(named: "plus")
    }
    
    @IBAction func btnMenu(_ sender: Any) {
        APPDELEGATE?.presentSideMenu(viewController: self)
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        hideShowCategoryView(bottom: 0)
    }
    
    func hideShowCategoryView(bottom: CGFloat) {
        self.categoryViewBottom.constant = bottom
        self.collectionCategoy.reloadData()
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if self.serviceListData.count > 0{
                self.collectionCategoy.scrollToItem(at: IndexPath (item: 0, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
            }
        }
    }
    
    func hideShowCategoryViewCrafter(bottom: CGFloat) {
        self.CraftercategoryViewBottom.constant = bottom
        self.CraftercollectionCategoy.reloadData()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            if self.serviceListData.count > 0{
                self.CraftercollectionCategoy.scrollToItem(at: IndexPath (item: 0, section: 0), at: UICollectionView.ScrollPosition.top, animated: true)
            }
        }
    }
    
    func openCamera() {
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.images.append(selectedImage)
            let objLetsGetWorkObj = self.storyboard?.instantiateViewController(withIdentifier: "LetsGetWorkVC") as! LetsGetWorkVC
            objLetsGetWorkObj.categoryData = self.selectedServiceData
            objLetsGetWorkObj.selectedMediaImages = self.images
            self.navigationController?.pushViewController(objLetsGetWorkObj, animated: true)
        }
        dismiss(animated: true)
    }
}

extension HomeVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionCategoy{
            let imgURL = URL(string: serviceListData[indexPath.row]["service_image"] as? String ?? "")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.imgCategory.kf.setImage(with: imgURL, placeholder: nil)
            cell.lblCategoryName.text = serviceListData[indexPath.row]["name"] as? String
            cell.imgSelected.isHidden = true
            return cell
        }else{
            let imgURL = URL(string: serviceListData[indexPath.row]["service_image"] as? String ?? "")
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
            cell.imgCategory.kf.setImage(with: imgURL, placeholder: nil)
            cell.lblCategoryName.text = serviceListData[indexPath.row]["name"] as? String
            if APPDELEGATE!.selectedUserType == .Crafter{
                if arrSelectedIds.contains(serviceListData[indexPath.row]["_id"] as! String){
                    cell.imgSelected.isHidden = false
                }else{
                    cell.imgSelected.isHidden = true
                }
            }else{
                cell.imgSelected.isHidden = true
            }
            return cell
        }
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        APPDELEGATE!.jobDetailImages = []
        if APPDELEGATE!.selectedUserType == .Crafter {
            let data = serviceListData[indexPath.row]
            if arrSelectedIds.contains(data["_id"] as! String){
                arrSelectedIds.remove(data["_id"] as! String)
            }else{
                arrSelectedIds.add(data["_id"] as! String)
            }
            CraftercollectionCategoy.reloadData()
        }else{
            self.selectedServiceData = serviceListData[indexPath.row]
            hideShowCategoryView(bottom: 0)
            showCamera()
            isadd = false
            APPDELEGATE?.LetsGetWork_PlaceHolder = serviceListData[indexPath.row]["description_hint"] as? String ?? "Write your problem."
            collectionCategoy.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    }
}

extension HomeVC:GoogleLocationUpdateProtocol
{
    func selectedMarker(index: NSInteger) {
        
    }
    
    func locationDidUpdateToLocation(location: [CLLocation]){
        if let location = location.first{
            let geoCoder = CLGeocoder()
            geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
                if error != nil{
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                if self.oldLocationForDummyPinsClientSide != nil{
                    self.distanceFromLastLocation = location.distance(from: self.oldLocationForDummyPinsClientSide!) // result is in meters
                    if self.distanceFromLastLocation > 3218{ // 1609 meter = 1 km
                        self.oldLocationForDummyPinsClientSide = location
                        self.arrDummyLocation = getMockLocationsFor(location: CLLocation (latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong), itemCount: Int.random(in: 1..<8))
                    }
                }else{
                    self.oldLocationForDummyPinsClientSide = location
                    self.arrDummyLocation = getMockLocationsFor(location: CLLocation (latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong), itemCount: Int.random(in: 1..<8))
                }

                if (placemarks?.count)! > 0{
                    let pm = (placemarks?[0])! as CLPlacemark
                    let str = (pm.addressDictionary!["FormattedAddressLines"]! as! NSArray).componentsJoined(by: ", ")
                    print(str)
                    if APPDELEGATE!.SelectedLocationAddress == ""{
                        self.lblCurrentLocation.text = str
                    }else{
                        self.lblCurrentLocation.text = APPDELEGATE!.SelectedLocationAddress
                    }
                    APPDELEGATE!.CurrentLocationAddress = str
                    APPDELEGATE!.CurrentLocationLat = location.coordinate.latitude
                    APPDELEGATE!.CurrentLocationLong = location.coordinate.longitude
                    if APPDELEGATE!.isAddressEdited == false{
                        self.currentMarker.position = CLLocationCoordinate2D(latitude: APPDELEGATE!.CurrentLocationLat, longitude: APPDELEGATE!.CurrentLocationLong)
                        self.currentMarker.map = self.viewMap
                    }
                }else{
                    print("Problem with the data received from geocoder")
                    DispatchQueue.main.async
                        {
                            
                    }
                }
            })
        }
    }
}

//MARK:- API CAll
extension HomeVC{
    //Get Service List API Call
    func getServiceListAPICall() {
        WebService.Request.patch(url: getServiceList, type: .get, parameter: nil, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    self.serviceListData = data
                    APPDELEGATE!.serviceListData = self.serviceListData
                    self.collectionCategoy.reloadData()
                }
            }
        }   
    }
    
    //MARK:- New Crafter Filter API
    //Get Service List API Call
    func getServiceListNewAPICall(){
       let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","user_latitude":"\(APPDELEGATE?.CurrentLocationLat ?? 0.00)","user_longitude":"\(APPDELEGATE?.CurrentLocationLong  ?? 0.00)","distance":"45","user_type":"2"]
        WebService.Request.patch(url: getAllServicesNew, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    self.serviceListData = data
                    APPDELEGATE!.serviceListData = self.serviceListData
                    self.collectionCategoy.reloadData()
                    self.CraftercollectionCategoy.reloadData()
                }
            }
        }
    }
    
    //Update Location
    func updateuserLocationData(){
        if !APPDELEGATE!.isUpdateLocationAtFirst{
            APPDELEGATE!.isUpdateLocationAtFirst = false
            return
        }
        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(APPDELEGATE?.CurrentLocationLat ?? 0.00)","user_longitude":"\(APPDELEGATE?.CurrentLocationLong  ?? 0.00)","distance":"45","user_type":"\(APPDELEGATE!.uerdetail?.user_type ?? "")","user_address":"\(APPDELEGATE?.CurrentLocationAddress ?? "")", "device_type": deviceType, "device_token": "\(APPDELEGATE?.deviceToken ?? "")","city": "\(APPDELEGATE?.currentCity ?? "")"]
        WebService.Request.patch(url: updateUserLocation, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                APPDELEGATE!.isUpdateLocationAtFirst = false
                if let data = response!["data"] as? [[String: Any]]{
                    self.collectionCategoy.reloadData()
                    self.CraftercollectionCategoy.reloadData()
                }
            }
        }
    }
    
    //get placeholders
    func getPlaceHolders(){
        WebService.Request.patch(url: getPlaceholders, type: .post, parameter: nil, callSilently: true, header: nil) { (response, error) in
            if error == nil{
                print(response!)
                if let data = response!["data"] as? [[String: Any]]{
                    if data.count > 0{
                        APPDELEGATE?.LetsGetWork_PlaceHolder = data[0]["lets_get_work_placeholder"] as? String ?? "Write your problem."
                        APPDELEGATE?.ChatMessage_PlaceHolder = data[0]["chat_screen_placeholder"]  as? String ?? ""
                        APPDELEGATE?.NeedHelpVC_PlaceHolder = data[0]["need_help_placeholder"]  as? String ?? "Write your problem."
                        APPDELEGATE?.AddReview_PlaceHolder = data[0]["add_review_placeholder"]  as? String ?? "Write your review."
                    }else{
                        APPDELEGATE?.LetsGetWork_PlaceHolder = "Write your problem."
                        APPDELEGATE?.ChatMessage_PlaceHolder = ""
                        APPDELEGATE?.NeedHelpVC_PlaceHolder = "Write your problem."
                        APPDELEGATE?.AddReview_PlaceHolder = "Write your review."
                    }
                }
            }
        }
    }

    //Get Crafter list For CLients
    func getCrafters(lat:Double,long:Double, callSilently: Bool){
        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(lat)","user_longitude":"\(long)","distance":"45"]
        WebService.Request.patch(url: getNearbyMeCrafter, type: .post, parameter: param, callSilently: callSilently, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]]{
                    if response!["status"] as? Bool == true {
                        let dataresponse = response!["data"] as? [[String:Any]]
                        if dataresponse != nil{
                            do{
                                let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                                self.CrafterList = try? JSONDecoder().decode([JobNearByData].self, from: jsonData)
                                self.jobListCount()
                            }catch{
                                print(error.localizedDescription)
                            }
                            self.CraftercollectionCategoy.reloadData()
                        }else{
                            self.CrafterList = []
                            self.jobListCount()
                        }
                    }else{
                        self.CrafterList = []
                        self.jobListCount()
                    }
                }
            }
        }
    }
    
    //Get Service List API Call
    func getJobListAPICall(serviceId:String,lat:Double,long:Double,callSilently:Bool) {
        
        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(lat)","user_longitude":"\(long)","distance":"45","service_ids":"\(serviceId)","booking_status":"0","is_near_by": "1","is_nearby_new_jobs":"1"]

        WebService.Request.patch(url: getNearByMeJob, type: .post, parameter: param, callSilently: callSilently, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]]{
                    if response!["status"] as? Bool == true {
                        let dataresponse = response!["data"] as? [[String:Any]]
                        for item in self.view.subviews{
                            if item.isKind(of: MapMarkerView.self){
                                item.removeFromSuperview()
                            }
                        }
                        if dataresponse != nil{
                            do{
                                let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                                
                                self.jobListClients = try? JSONDecoder().decode([JobHistoryData].self, from: jsonData)
                                self.jobListCount()
                                if self.isFirstTImeService{
                                    self.isFirstTImeService = false
                                }
                                if self.jobListClients?.count == 0 && appDelegate.isFirstTime{
                                    if !callSilently{
                                        appDelegate.isFirstTime = false
                                        self.serviceListData = []
                                        APPDELEGATE?.serviceListData = self.serviceListData
                                        self.CraftercollectionCategoy.reloadData()
                                        APPDELEGATE?.addAlertPopupview(viewcontroller: self, oprnfrom: "", message:"No new jobs available at the moment. Please check back soon!")
                                    }
                                }
                            }catch{
                                print(error.localizedDescription)
                            }
                        }else{
                            self.jobListClients = []
                            self.jobListCount()
                            self.serviceListData = []
                            APPDELEGATE?.serviceListData = self.serviceListData
                            self.CraftercollectionCategoy.reloadData()
                            if appDelegate.isFirstTime{
                                appDelegate.isFirstTime = false
                             APPDELEGATE?.addAlertPopupview(viewcontroller: self, oprnfrom: "", message:"No new jobs available at the moment. Please check back soon!")
                            }
                        }
                    }else{
                        self.jobListClients = []
                        self.jobListCount()
                        self.serviceListData = []
                        APPDELEGATE?.serviceListData = self.serviceListData
                        self.CraftercollectionCategoy.reloadData()
                        if appDelegate.isFirstTime{
                            appDelegate.isFirstTime = false
                            APPDELEGATE?.addAlertPopupview(viewcontroller: self, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                        }
                    }
                }
            }
            self.getServicesCrafter()
        }
    }
    
    func getServicesCrafter(){
        var serviceIds = String()
        for item in self.jobListClients ?? []{
            if serviceIds == ""{
                serviceIds = item.service_id ?? ""
            }else{
                serviceIds = "\(serviceIds),\(item.service_id ?? "")"
            }
        }
        let param = ["service_ids":"\(serviceIds)"]
        WebService.Request.patch(url: getAllServicesData, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    self.serviceListData = data
                    APPDELEGATE!.serviceListData = self.serviceListData
                    self.collectionCategoy.reloadData()
                    self.CraftercollectionCategoy.reloadData()
                }
            }
            if self.serviceListData.count > 0{
                self.btnFilterCrafter.isHidden = false
                self.lblNoNearByJobsFilterCrafterSide.isHidden = true
                self.CraftercollectionCategoy.isHidden = false
            }else{
                self.btnFilterCrafter.isHidden = true
                self.lblNoNearByJobsFilterCrafterSide.isHidden = false
                self.CraftercollectionCategoy.isHidden = true
            }
        }
    }
    
    func jobListCount(){
        viewMap.clear()
        if APPDELEGATE!.isAddressEdited == false{
            markers(Lat: APPDELEGATE?.SelectedLocationLat ?? 51.5100909, Long: APPDELEGATE?.SelectedLocationLong ?? -0.1341891)
        }else{
            markers(Lat: APPDELEGATE?.SelectedLocationLat ?? 51.5100909, Long: APPDELEGATE?.SelectedLocationLong ?? -0.1341891)
        }

        var tag = 0
        if APPDELEGATE?.selectedUserType == .Crafter{
            for item in self.jobListClients ?? []{
                self.setMarker(Lat: Double(item.client_latitude ?? "0") ?? 0.00, Long: Double(item.client_longitude ?? "0") ?? 0.00, tag: tag, userdara:item)
                tag += 1
            }
        }else{
            for item in self.CrafterList ?? []{
                self.setMarker(Lat: Double(item.user_latitude ?? "0") ?? 0.00, Long: Double(item.user_longitude ?? "0") ?? 0.00, tag: tag, userdara:item)
                tag += 1
            }
            if self.isCountryCodeAvail{
                for item in self.arrDummyLocation{
                    self.getdummyLocationIsinWaterOrNot(location: item, tag: tag)
                    tag += 1
                }
            }
        }
    }
    
    func markers(Lat:Double,Long:Double){
        currentMarker = GMSMarker()
        currentMarker.position = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
        let markerView = loadCurrentLocNib()
        markerView.initPulse()
        currentMarker.iconView = markerView
        currentMarker.iconView?.tag = 500000
        currentMarker.groundAnchor = CGPoint (x: 0.5, y: 0.5)
        currentMarker.zIndex = Int32(0)
        currentMarker.map = viewMap
    }
    
    func loadCurrentLocNib() -> CustomCurrentLocationView{
        let infoWindow = CustomCurrentLocationView.instanceFromNib() as! CustomCurrentLocationView
        return infoWindow
    }

    func setMarker(Lat:Double,Long:Double,tag:Int, userdara:Any){
        let marker = GMSMarker()
        marker.userData = userdara
        var coordi = CLLocationCoordinate2D()
        if APPDELEGATE?.selectedUserType == .Crafter{
            let data = userdara as? JobHistoryData
            coordi = checkIfMutlipleCoordinates(latitude: Lat, longitude: Long, id: (data?._id)!)
        }else{
            let data = userdara as? JobNearByData
            coordi = checkIfMutlipleCoordinates(latitude: Lat, longitude: Long, id: (data?._id)!)
        }
        marker.position = CLLocationCoordinate2D(latitude: coordi.latitude, longitude: coordi.longitude)

        var markerimagename = String()
        if APPDELEGATE!.selectedUserType == .Client{
            markerimagename = "map_marker"
            let markerImage = UIImage(named: markerimagename)
            let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 40, height: 40))
            let markerView = UIImageView (image: markerImage)
            markerView.frame = CGRect(x: (myNewView.frame.size.width/2) - 6, y: 7, width: 12, height: 12)
            markerView.image = #imageLiteral(resourceName: "logoImage")
            markerView.contentMode = .scaleAspectFit
            
            let imageName = "map_pin_job"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            let imageBackView = UIView (frame: CGRect(x: (myNewView.frame.size.width/2) - 10, y: 3, width: 20, height: 20))
            imageBackView.backgroundColor = .white
            myNewView.addSubview(imageBackView)
            myNewView.addSubview(markerView)
            myNewView.addSubview(imageView)
            marker.iconView = myNewView
            marker.iconView?.layer.cornerRadius = (marker.iconView?.frame.size.height)!/2.0
            marker.iconView?.layer.masksToBounds = true
        }else{
            markerimagename = "map_marker"
            let markerImage = UIImage(named: markerimagename)
            let detail = userdara as? JobHistoryData
            let imgURL = URL(string: detail?.service_image ?? "")
            //
            let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 40, height: 40))
            let markerView = UIImageView (image: markerImage)
            markerView.frame = CGRect(x: (myNewView.frame.size.width/2) - 7.5, y: 6, width: 15, height: 15)
            markerView.kf.setImage(with: imgURL, placeholder: markerImage)
            let imageName = "map_pin_job"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            myNewView.addSubview(markerView)
            myNewView.addSubview(imageView)
            marker.iconView = myNewView
            marker.iconView?.layer.cornerRadius = (marker.iconView?.frame.size.height)!/2.0
            marker.iconView?.layer.masksToBounds = true
        }
        marker.isTappable = true
        marker.zIndex = Int32(tag+1)
        marker.iconView?.tag = tag
        marker.groundAnchor = CGPoint (x: 0.5, y: 0.5)
        marker.map = viewMap
    }
    
    func setDummyMarkerForClient(Lat:Double,Long:Double,tag:Int, userdara:Any){
        let marker = GMSMarker()
        var coordi = CLLocationCoordinate2D()
        let data = userdara as? JobNearByData
        marker.position = CLLocationCoordinate2D(latitude: Lat, longitude: Long)
        
        var markerimagename = String()
        if APPDELEGATE!.selectedUserType == .Client{
            markerimagename = "map_marker"
            let markerImage = UIImage(named: markerimagename)
            let myNewView=UIView(frame: CGRect(x: 10, y: 100, width: 40, height: 40))
            let markerView = UIImageView (image: markerImage)
            markerView.frame = CGRect(x: (myNewView.frame.size.width/2) - 6, y: 7, width: 12, height: 12)
            markerView.image = #imageLiteral(resourceName: "logoImage")
            markerView.backgroundColor = .white
            markerView.contentMode = .scaleAspectFit
            
            let imageName = "map_pin_job"
            let image = UIImage(named: imageName)
            let imageView = UIImageView(image: image!)
            imageView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            let imageBackView = UIView (frame: CGRect(x: (myNewView.frame.size.width/2) - 10, y: 3, width: 20, height: 20))
            imageBackView.backgroundColor = .white
            myNewView.addSubview(imageBackView)
            myNewView.addSubview(markerView)
            myNewView.addSubview(imageView)
            marker.iconView = myNewView
            marker.iconView?.layer.cornerRadius = (marker.iconView?.frame.size.height)!/2.0
            marker.iconView?.layer.masksToBounds = true
        }
        marker.isTappable = true
        marker.zIndex = Int32(tag+1)
        marker.iconView?.tag = tag
        marker.groundAnchor = CGPoint (x: 0.5, y: 0.5)
        marker.map = viewMap
    }

    func checkIfMutlipleCoordinates(latitude : Double , longitude : Double,id:String) -> CLLocationCoordinate2D{
        var lat = latitude
        var lng = longitude
        
        var avail = false
        if lat == APPDELEGATE?.CurrentLocationLat && lng == APPDELEGATE?.CurrentLocationLong{
            let variation = (randomFloat(min: 0.0, max: 2.0) - 0.5) / 1500
            lat = lat + Double(variation)
            lng = lng + Double(variation)
            let finalPos = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
            return  finalPos
        }
        
        if APPDELEGATE?.selectedUserType == .Crafter{
            for item in jobListClients!{
                if item._id == id{
                    
                }else{
                    if "\(lat)" == item.client_latitude && "\(lng)" == item.client_longitude {
                        avail = true
                    }
                }
            }
        }else{
            for item in CrafterList!{
                if item._id == id{
                    
                }else{
                    if "\(lat)" == item.user_latitude && "\(lng)" == item.user_longitude {
                        avail = true
                    }
                }
            }
        }
        if avail{
            let variation = (randomFloat(min: 0.0, max: 2.0) - 0.5) / 1500
            lat = lat + Double(variation)
            lng = lng + Double(variation)
        }
        let finalPos = CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        return  finalPos
    }
    
    func randomFloat(min: Float, max:Float) -> Float {
        return (Float(arc4random()) / 0xFFFFFFFF) * (max - min) + min
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc func didDragMap(_ gestureRecognizer: UIGestureRecognizer?) {
//        if gestureRecognizer == {
//
//        }
        let latitude = viewMap.camera.target.latitude
        let longitude = viewMap.camera.target.longitude
        APPDELEGATE!.SelectedLocationLat = latitude
        APPDELEGATE!.SelectedLocationLong = longitude
        self.currentMarker.position = CLLocationCoordinate2D(latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong)
        self.currentMarker.map = self.viewMap
        if gestureRecognizer?.state == .ended {
            Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: false)
        }
    }
    
    @objc func didTapMap(_ gestureRecognizer: UIGestureRecognizer?) {
    }

    
    @objc func runTimedCode()  {
        let latitude = viewMap.camera.target.latitude
        let longitude = viewMap.camera.target.longitude
        APPDELEGATE!.SelectedLocationLat = latitude
        APPDELEGATE!.SelectedLocationLong = longitude
        self.currentMarker.position = CLLocationCoordinate2D(latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong)
        self.currentMarker.map = self.viewMap
        getaddress(latitude: latitude, longitude: longitude)
    }

    //Get address from lat long
    func getaddress(latitude: Double,longitude: Double)  {
        let location = CLLocation (latitude: latitude, longitude: longitude)
        let geoCoder = CLGeocoder()
        geoCoder.reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil{
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                self.lblCurrentLocation.text = ""
                return
            }
            self.updateuserLocationData()
            if (placemarks?.count)! > 0{
                let pm = (placemarks?[0])! as CLPlacemark
                if pm.country == "United Kingdom"{
                    if self.oldLocationForDummyPinsClientSide != nil{
                        self.distanceFromLastLocation = location.distance(from: self.oldLocationForDummyPinsClientSide!) // result is in meters
                        if self.distanceFromLastLocation > 1609{ // 1609 meter = 1 km
                            self.oldLocationForDummyPinsClientSide = location
                            self.arrDummyLocation = getMockLocationsFor(location: CLLocation (latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong), itemCount: Int.random(in: 1..<8))
                        }
                    }else{
                        self.oldLocationForDummyPinsClientSide = location
                        self.arrDummyLocation = getMockLocationsFor(location: CLLocation (latitude: APPDELEGATE!.SelectedLocationLat, longitude: APPDELEGATE!.SelectedLocationLong), itemCount: Int.random(in: 1..<8))
                    }
                }else{
                    self.arrDummyLocation = []
                }
            }

            if (placemarks?.count)! > 0{
                let pm = (placemarks?[0])! as CLPlacemark
                let str = (pm.addressDictionary!["FormattedAddressLines"]! as! NSArray).componentsJoined(by: ", ")
                print(str)
                if pm.inlandWater != nil || pm.ocean != nil{
                    self.isCountryCodeAvail = false
                }else{
                    self.isCountryCodeAvail = true
                }
                 if APPDELEGATE!.SelectedLocationAddress == ""{
                    self.lblCurrentLocation.text = str
                }else{
                    self.lblCurrentLocation.text = APPDELEGATE!.SelectedLocationAddress
                }
                self.lblCurrentLocation.text = str
                APPDELEGATE!.SelectedLocationAddress = str
                APPDELEGATE?.city = pm.locality ?? ""
                APPDELEGATE?.SelectedLocationCity = pm.locality ?? ""
                if APPDELEGATE?.SelectedLocationCity == ""{
                    APPDELEGATE?.city = pm.administrativeArea ?? ""
                    APPDELEGATE?.SelectedLocationCity = pm.administrativeArea ?? ""
                    if APPDELEGATE?.SelectedLocationCity == ""{
                        APPDELEGATE?.city = pm.country ?? ""
                        APPDELEGATE?.SelectedLocationCity = pm.country ?? ""
                    }
                }

                if APPDELEGATE!.selectedUserType == .Crafter{
                    self.getJobListAPICall(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00, callSilently: true)
                }else{
                    self.getCrafters(lat: APPDELEGATE?.SelectedLocationLat  ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00, callSilently: true)
                }
                self.jobListCount()
            }else{
                print("Problem with the data received from geocoder")
                DispatchQueue.main.async
                    {
                        
                }
            }
        })
    }

    //Get Notification Count API
    func GetNotificationCountAPI(){
        var user_type = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            user_type = Crafter
        }
        else
        {
            user_type = Client
        }

        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","send_user_type":"\(user_type)"]
        WebService.Request.patch(url: getNotificationCount, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true{
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil{
                        APPDELEGATE?.notificationCount = (dataresponse! as NSDictionary).value(forKey: "total_count") as! Int
                        APPDELEGATE?.chatCount = (dataresponse! as NSDictionary).value(forKey: "total_chat_count") as! Int

                        UIApplication.shared.applicationIconBadgeNumber = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                        
                        APPDELEGATE?.totalConut = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                        self.updatecount()
                       if APPDELEGATE!.selectedUserType == .Crafter{
                           if (dataresponse!["is_accountdetail_added"] as! String == "0" || dataresponse!["is_accountdetail_added"] as! String == ""){
                               APPDELEGATE?.bankDetailNotFilled = .No
                           }else{
                               APPDELEGATE?.bankDetailNotFilled = .Yes
                           }
                       }

                        if APPDELEGATE!.selectedUserType == .Crafter{
                            if (dataresponse!["is_accountdetail_added"] as! String == "0" || dataresponse!["is_accountdetail_added"] as! String == "") && appDelegate.isFirstTimeForFillBankDetail{
                                
                                appDelegate.isFirstTimeForFillBankDetail = false
                                APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Your bank details not filled fully please fill it by pressing YES.", completion: { (status) in
                                    if status{
                                    let objNotifySettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "BankingFormVC") as! BankingFormVC
                                    self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
                                        
                                    }else{
                                    }
                                })
                            }
                        }
                    }else{
                        
                    }
                }else{
                }
            }
        }
    }
    
    func updatecount(){
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil || APPDELEGATE?.totalConut == 0{
            self.lblMessageCount.isHidden = true
            self.lblChatCount.isHidden = true
            self.lblNotificationCount.isHidden = true
        }else{
            //self.lblMessageCount.isHidden = false
            self.lblChatCount.isHidden = false
            self.lblNotificationCount.isHidden = false
            
            self.lblMessageCount.text = "\(APPDELEGATE?.totalConut ?? 0)"
            self.lblChatCount.text = "\(APPDELEGATE?.chatCount ?? 0)"
            self.lblNotificationCount.text = "\(APPDELEGATE?.notificationCount ?? 0)"
            
            if APPDELEGATE?.chatCount == 0{
                self.lblChatCount.isHidden = true
            }
            
            if APPDELEGATE?.notificationCount == 0{
                self.lblNotificationCount.isHidden = true
            }
        }
    }


    func getjobListingAll(myId:String){
        APPDELEGATE?.addProgressView()
        var isLoad = true
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                if data != nil{
                    do{
                        let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                        var count = 0
                        for item in conversion ?? [] {
                            if item.unreadMessageCount ?? 0 > 0{
                                count += 1
                            }
                        }
                        self.updatecount()
                    }
                }
            }else{
            }
            if isLoad{
                APPDELEGATE?.hideProgrssVoew()
                isLoad = false
            }
        }
    }
}

//MARK:- Custom Camera
extension HomeVC
{
    func showCamera(){
        let objCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as? CameraVC
        objCamera?.imageSelectionLimit = 20
        objCamera?.blockCancel = { status in
            if status{
                let objLetsGetWorkObj = self.storyboard?.instantiateViewController(withIdentifier: "LetsGetWorkVC") as! LetsGetWorkVC
                objLetsGetWorkObj.categoryData = self.selectedServiceData
                objLetsGetWorkObj.selectedMediaImages = APPDELEGATE!.jobDetailImages
                self.navigationController?.pushViewController(objLetsGetWorkObj, animated: true)
            }
        }
        objCamera?.modalPresentationStyle = .fullScreen
        self.present(objCamera!, animated: true, completion: nil)
    }
}

extension HomeVC{
    func getdummyLocationIsinWaterOrNot(location: CLLocation, tag: NSInteger) {
//        0.560531,124.2522833,3z
        let url = "http://maps.googleapis.com/maps/api/staticmap?scale=2&center=\(location.coordinate.latitude),\(location.coordinate.longitude)&zoom=13&size=15x15&sensor=false&visual_refresh=true&style=feature:water|color:0x96CAF0&key=\(APPDELEGATE?.googlePlacesMapAPI ?? Google_Map_API_Key)"
        let str = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let imgUrl = URL(string: str!)
        let img = UIImageView (frame: CGRect (x: 0, y: 0, width: 10, height: 10))
        img.sd_setImage(with: imgUrl) { (image, error, cache, url) in
            if (image as? UIImage) != nil{
                let color = image?.averageColor!
                if color! < 0.55 || color! > 0.80{
                    self.setDummyMarkerForClient(Lat: location.coordinate.latitude, Long: location.coordinate.longitude, tag: tag, userdara: [:])
                }
            }
        }
    }
}

extension UIImage {
    var averageColor: Double? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return Double(bitmap[0]) / 255
    }
}


extension UIColor {
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        return NSString(format:"#%06x", rgb) as String
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
}

extension MKMapView {

    func topCenterCoordinate() -> CLLocationCoordinate2D {
        return self.convert(CGPoint(x: self.frame.size.width / 2.0, y: 0), toCoordinateFrom: self)
    }

    func currentRadius(coordinate: CLLocationCoordinate2D) -> Double {
        let centerLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let topCenterCoordinate = self.topCenterCoordinate()
        let topCenterLocation = CLLocation(latitude: topCenterCoordinate.latitude, longitude: topCenterCoordinate.longitude)
        return centerLocation.distance(from: topCenterLocation)
    }

}
