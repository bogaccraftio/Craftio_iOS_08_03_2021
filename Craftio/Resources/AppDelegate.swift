
import UIKit
import MBProgressHUD
import IQKeyboardManagerSwift
import GoogleMaps
import GooglePlaces
import Firebase
import NotificationCenter
import UserNotifications
import FirebaseInstanceID
import FirebaseMessaging
import FirebaseDatabase
import FirebaseCore
import CoreData
import SVProgressHUD
import Fabric
import Crashlytics
import Photos
import Stripe

let APPDELEGATE: AppDelegate? = UIApplication.shared.delegate as? AppDelegate

enum userType {
    case Crafter
    case Client
    case none
}

enum bankDetailFilled {
    case Yes
    case No
    case none
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,MessagingDelegate,UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    var progressView = UIView()
    var login_type = Int()
    var presentView = String()
    var alertMessage = String()
    var selectedUserType: userType = .none
    var viewMap: GMSMapView!
    var uerdetail: UserData?
    var serviceListData = [[String: Any]]()
    var CurrentLocationAddress = String()
    var CurrentLocationLat = Double()
    var CurrentLocationLong = Double()
    var SelectedLocationAddress = String()
    var SelectedLocationCity = String()
    var SelectedLocationLat = Double()
    var SelectedLocationLong = Double()
    var deviceToken = String()
    var remoteNotificationData = NSDictionary()
    var navigationController = UINavigationController()
    var isAddressEdited = false
    var ref: DatabaseReference!
    var isBackCameraController = false
    var isChatViewcontroller = false
    var notificationCount = 0
    var chatCount = 0
    var totalConut = 0
    var arrUnreadCount = NSMutableArray()
    var isChat = false
    var ChatjobID = String()
    var jobDetailImages = [Any]()
    var isFirstTime = true
    var isFirstTimeForFillBankDetail = true
    var selectedChatUser = String()
    var selectedDefaultJobImage: Any = ""
    var freequoteQty: Int = 0
    var freequoteExpireDate: String = ""
    var freeremainingQuote: String = ""
    var city: String = ""
    var currentCity: String = ""
    var bankDetailNotFilled: bankDetailFilled = .No
    var isUpdateLocationAtFirst = true
    
    var LetsGetWork_PlaceHolder = ""
    var ChatMessage_PlaceHolder = ""
    var AddReview_PlaceHolder = ""
    var NeedHelpVC_PlaceHolder = ""
    var countryName = ""
    var countryNameCode = ""
    var is_Emergency = String()
    var notificationjobID = String()
    var notificationCrafterID = String()
    var deleteImageTimer = Timer()
    var deleteImageTimerCounter = 0
    var capturedMedia = [Any]()
    var profileUserID = String()
    var isProfileOpen = false
    var googlePlacesMapAPI = String()
    
    var imgDefault : UIImage?
    var appGreenColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        getSettingDetail()
        Fabric.with([Crashlytics.self])
        IQKeyboardManager.shared.enable = true
        GMSServices.provideAPIKey(Google_Map_API_Key)
        GMSPlacesClient.provideAPIKey(Google_Map_API_Key)
        self.initmap()
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications() // To remove all delivered notifications
        application.applicationIconBadgeNumber = 0
        self.setupProgressView()
        deviceToken = UserDefaults.standard.value(forKey: "token") as? String ?? "kjsdi98dsa9n7"
       // Stripe.setDefaultPublishableKey("pk_test_i0nYBijd2RmgYbhaoHLTN7Jb00xUO967Fm")
        // Stripe.setDefaultPublishableKey("pk_test_29PZKlRu8tGzYW4BR3r7MRFE00yxJLqNmm")

        
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SplashVC") as! SplashVC
        
        navigationController = UINavigationController(rootViewController: nextViewController)
        navigationController.navigationBar.isHidden = true
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        appdelegate.window!.rootViewController = navigationController
        
        if UserDefaults.standard.value(forKey:"userId") != nil
        {
            let data = UserDefaults.standard.value(forKey: "login_data") as? Data
            if data != nil{
                do
                {
                    APPDELEGATE?.uerdetail = try? JSONDecoder().decode(UserData.self, from: data!)
                }
            }
            
            getProfileDetails(userId: UserDefaults.standard.value(forKey:"userId") as? String ?? "", Sessiontoken: UserDefaults.standard.value(forKey:"sessionToken") as? String ?? "")
        }
        else
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
            
            navigationController = UINavigationController(rootViewController: nextViewController)
            navigationController.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if #available(iOS 13.0, *) {
                window!.overrideUserInterfaceStyle = .light
            }
            appdelegate.window!.rootViewController = navigationController
        }
        if UserDefaults.standard.value(forKey:"usertype") != nil{
            if UserDefaults.standard.value(forKey:"usertype") as? String == "1"{
                selectedUserType = .Client
            }else if UserDefaults.standard.value(forKey:"usertype") as? String == "2"{
                selectedUserType = .Crafter
            }else{
                selectedUserType = .none
            }
        }
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { (isgranted, error) in
                if isgranted{
                }
            }
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        let remoteNotification: NSDictionary! = launchOptions?[.remoteNotification] as? NSDictionary
        if (remoteNotification != nil)
        {
            remoteNotificationData = remoteNotification
        }
        application.registerForRemoteNotifications()
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()
        ref = Database.database().reference()
        
        navigationController.interactivePopGestureRecognizer?.isEnabled = false
        
        return true
    }
    
    func initmap(){
        viewMap = GMSMapView (frame: CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        LoadMap()
    }
    
    private func splashScreen()
    {
        let launchScreenVC = UIStoryboard.init(name: "LaunchScreen", bundle: nil)
        let rootVC = launchScreenVC .instantiateViewController(withIdentifier: "splashVC")
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        }
        self.window?.rootViewController = rootVC
        self.window?.makeKeyAndVisible()
        if UserDefaults.standard.value(forKey:"userId") != nil
        {
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            //        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "SelectionVC") as! SelectionVC
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            
            navigationController = UINavigationController(rootViewController: nextViewController)
            navigationController.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if #available(iOS 13.0, *) {
                window!.overrideUserInterfaceStyle = .light
            }
            appdelegate.window!.rootViewController = navigationController
            
            if remoteNotificationData.count > 0
            {
                let userInfo = remoteNotificationData as? [String:Any]
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if ((userInfo?["tag"] as? String) != nil)
                    {
                        let type = userInfo?["tag"] as? String
                        if type == "3" || type == "4"{
                            let data = ["user_id":"\(userInfo?["user_id"] as? String ?? "")"]
                            self.navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo?["_id"] as? String ?? "")")
                        }else if type == "7" || type == "6" {
                            let data = ["user_id":"\(userInfo?["user_id"] as? String ?? "")"]
                            self.navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo?["_id"] as? String ?? "")")
                        }else if type == "13"{
                            let data = convertToDictionary(text:(userInfo?["jobs"] as? String ?? ""))
                            self.navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo?["_id"] as? String ?? "")")
                        }else if type == "30"{
                            let data = ["user_id":"\(userInfo?["user_id"] as? String ?? "")"]
                            self.navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo?["_id"] as? String ?? "")")
                        }else{
                            let data = convertToDictionary(text:(userInfo?["jobs"] as? String ?? ""))
                            self.navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo?["_id"] as? String ?? "")")
                        }
                    }
                    else
                    {
                        let data = convertToDictionary(text:self.remoteNotificationData["gcm.notification.data"] as! String)
                        
                        self.redirectionFRomChat(userInfo: data!)
                    }
                }
            }
        }
        else
        {
            if (APPDELEGATE?.isChatViewcontroller)!{
                return
            }
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
            
            navigationController = UINavigationController(rootViewController: nextViewController)
            navigationController.navigationBar.isHidden = true
            let appdelegate = UIApplication.shared.delegate as! AppDelegate
            if #available(iOS 13.0, *) {
                window!.overrideUserInterfaceStyle = .light
            }
            appdelegate.window!.rootViewController = navigationController
        }
    }
    
    var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationArrived"), object: nil, userInfo: [:])
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    @objc func counter(){
        APPDELEGATE?.deleteImageTimerCounter += 1
    }
    
    func deletePhoto(assets: [PHAsset]){
        APPDELEGATE?.deleteImageTimerCounter = 0
        APPDELEGATE?.deleteImageTimer.invalidate()
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
        }) { (success, error) in
            print(success)
        }
    }
    
    func isfromChat(){
        APPDELEGATE?.isChatViewcontroller = false
    }
    
    func getSettingDetail(){
        WebService.Request.patch(url: getSettingData, type: .get, parameter: nil, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                if let data = response!["data"] as? [String: Any] {
                    self.googlePlacesMapAPI = "\(data["google_api_key"] as? String ?? "\(Google_Map_API_Key)")"
                    GMSServices.provideAPIKey(self.googlePlacesMapAPI)
                    GMSPlacesClient.provideAPIKey(self.googlePlacesMapAPI)
                    self.initmap()
                }else{
                    self.googlePlacesMapAPI = Google_Map_API_Key
                    GMSServices.provideAPIKey(Google_Map_API_Key)
                    GMSPlacesClient.provideAPIKey(Google_Map_API_Key)
                    self.initmap()
                }
            }
        }
    }

    
    //MARK:- Call Profile API
    func getProfileDetails(userId:String,Sessiontoken:String)
    {
        var params = [String:String]()
        var usertype = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            params = ["user_id": "2", "loginuser_id": "2", "session_token": "P@8ADeIFME"]
            usertype = Crafter
        }
        else
        {
            params = ["user_id": "1", "loginuser_id": "1", "session_token": "P@8ADeIFME"]
            usertype = Client
        }
        params = ["user_id": "\(userId)", "loginuser_id": "\(userId)", "session_token": "\(Sessiontoken)","review_required":"0","user_type": usertype,"is_own_profile": "1"]
        WebService.Request.patch(url: getUserProfile, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        do
                        {
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                            APPDELEGATE?.uerdetail = try? JSONDecoder().decode(UserData.self, from: jsonData)
                            UserDefaults.standard.set(jsonData, forKey: "login_data")
                            UserDefaults.standard.set(dataresponse?["_id"] as? String ?? "", forKey: "userId")
                            UserDefaults.standard.set(dataresponse?["session_token"] as? String ?? "", forKey: "sessionToken")
                            if APPDELEGATE?.uerdetail?.user_type == "1"{
                                
                            }
                            UserDefaults.standard.synchronize()
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                    }
                    else
                    {
                        
                    }
                } else
                {
                }
            }else{
                
            }
            self.splashScreen()
        }
    }
}

// progressView Setup
extension AppDelegate {
    
    func setupProgressView() {
        progressView.frame = UIScreen.main.bounds
        progressView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        let progress = MBProgressHUD.showAdded(to: progressView, animated: true)
        progress.animationType = .zoomOut
    }
    
    func addProgressView() {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 50))
        SVProgressHUD.setForegroundColor(UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0))
        SVProgressHUD.show()
    }
    
    func hideProgrssVoew() {
        SVProgressHUD.dismiss()
    }
    
    func presentSideMenu(viewController: UIViewController){
        let sideMenu = viewController.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as? MenuVC
        viewController.navigationController?.pushViewController(sideMenu!, animated: true)
    }
    
    func dismissSideMenu(viewController: UIViewController)
    {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func showAlertMessageForLoginViewJobCreate(message:String,viewController: UIViewController)
    {
        let alertController = UIAlertController(title: "", message: "Job Created Successfully!", preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
        })
        alertController.addAction(ok)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func showAlertMessage(message:String,viewController: UIViewController){
        alertController(message: message, controller: viewController)
    }
    
    //Load map
    func LoadMap(){
        let google_location_manager = GoogleLocation.GoogleSharedManager
        google_location_manager.delegate = self
        google_location_manager.init_location(self.viewMap, startUpdatingLocation: true, viewinfo: findtopViewController() ?? UIViewController(), displayMarkerOtherMatkers: false)
    }
    
    func addLoginSubview(viewcontroller: UIViewController,oprnfrom:String,data:[String:Any],image:[Any]){
        IQKeyboardManager.shared.enable = false
        let loginView = APPDELEGATE!.loadLoginView()
        loginView.initLoginView(viewopenFrom:oprnfrom, UserData: data, Images: image)
        loginView.frame = viewcontroller.view.bounds
        viewcontroller.view.addSubview(loginView)
    }
    
    func loadLoginView() -> LoginView{
        let infoWindow = LoginView.instanceFromNib() as! LoginView
        return infoWindow
    }
    
    //Alert Popup
    func addAlertPopupview(viewcontroller: UIViewController,oprnfrom:String,message:String)
    {
        let AlertView = APPDELEGATE!.loadAlertPopupView()
        AlertView.displayPopup = .oneButton
        AlertView.initAlertPopupView(viewopenFrom:oprnfrom, UserData: message, price: "")
        AlertView.frame = viewcontroller.view.bounds
        viewcontroller.view.addSubview(AlertView)
    }
    
    func addAlertPopupviewWithCompletion(viewcontroller: UIViewController,oprnfrom:String,message:String,completion: ((Bool)->())?)
    {
        let AlertView = APPDELEGATE!.loadAlertPopupView()
        AlertView.displayPopup = .oneButton
        AlertView.initAlertPopupView(viewopenFrom:oprnfrom, UserData: message, price: "")
        AlertView.completion = {
            completion!(true)
        }
        AlertView.frame = viewcontroller.view.bounds
        viewcontroller.view.addSubview(AlertView)
    }

    
    func addalertTwoButtonPopup(viewcontroller: UIViewController,oprnfrom:String,message:String,price: String = "",completion: ((Bool)->())?){
        let AlertView = APPDELEGATE!.loadAlertPopupView()
        AlertView.displayPopup = .TwoButton
        AlertView.initAlertPopupView(viewopenFrom:oprnfrom, UserData: message,price: price)
        AlertView.completion = {
            completion!(AlertView.selectedButton)
        }
        AlertView.frame = viewcontroller.view.bounds
        viewcontroller.view.addSubview(AlertView)
    }
    
    func loadAlertPopupView() -> AlertPopup{
        let infoWindow = AlertPopup.instanceFromNib() as! AlertPopup
        return infoWindow
    }
    
    
    func addViewForPopUpPlayVideo(viewcontroller: UIViewController,strVideoUrl:String){
        let AlertView = APPDELEGATE!.loadAlertPopupViewPlayVideo()
        AlertView.frame = viewcontroller.view.bounds
        AlertView.playVideo(strVideoURL: strVideoUrl)
        viewcontroller.view.addSubview(AlertView)
    }
    
    func loadAlertPopupViewPlayVideo() -> PlayVideo{
        let infoWindow = PlayVideo.instanceFromNib() as! PlayVideo
        return infoWindow
    }

}

extension AppDelegate:GoogleLocationUpdateProtocol
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
                    APPDELEGATE!.CurrentLocationAddress = str
                    APPDELEGATE!.CurrentLocationLat = location.coordinate.latitude
                    APPDELEGATE!.CurrentLocationLong = location.coordinate.longitude
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
}


//NOtification Methods
extension AppDelegate{
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        Messaging.messaging().apnsToken = deviceToken
        let _: String = UIDevice.current.identifierForVendor!.uuidString
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                APPDELEGATE?.deviceToken = ""
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                APPDELEGATE?.deviceToken = result.token
                UserDefaults.standard.setValue("\(result.token)", forKey: "token")
                UserDefaults.standard.synchronize()
                print("Remote instance ID token: \(result.token)")
            }
        })
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
        print("my push is: %@", userInfo)
        guard application.applicationState == UIApplication.State.inactive else {
            return
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // Print full message.
        print(userInfo)
        if ((userInfo["tag"] as? String) != nil)
        {
            let data = convertToDictionary(text:(userInfo["jobs"] as? String ?? ""))
            let type = userInfo["tag"] as? String
            if data?["_id"] as? String == APPDELEGATE?.ChatjobID{
//                notificationCount -= 1
//                totalConut = notificationCount + chatCount
                readNotification(notifID: "\(userInfo["_id"] as? String ?? "")")
            }else if (type == "4" || type == "6" || type == "7" || type == "8") && isProfileOpen{
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: data)
            }else{                completionHandler(UNNotificationPresentationOptions.alert)
            }
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationArrived"), object: nil, userInfo: [:])
            if (APPDELEGATE?.isChatViewcontroller)!{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "JobNotificationPayment"), object: nil, userInfo: [:])
            }
        }
        else
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationArrived"), object: nil, userInfo: [:])
            let data = convertToDictionary(text:userInfo["gcm.notification.data"] as! String)
            if data?["conversationId"] as? String == APPDELEGATE?.selectedChatUser{
                self.updateMessageCounttojob(unreadMessageCountcount: 0, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobID: "\(data?["job_id"] as? String ?? "")")
                
                UpdateIsMessageReadOrNot(UserId: "\(data?["user_id"] as? String ?? "")", jobID: "\(data?["job_id"] as? String ?? "")", isRead: "1")
                completionHandler(UNNotificationPresentationOptions.badge)
            }else{
                completionHandler(UNNotificationPresentationOptions.alert)
            }
        }
        center.removeAllDeliveredNotifications()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        print(userInfo)
        
        print("my push is: %@", userInfo)
        if ((userInfo["tag"] as? String) != nil)
        {
            let type = userInfo["tag"] as? String
            if application.applicationState == UIApplication.State.inactive
            {
                if type == "3" || type == "4"{
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "7" || type == "6" {
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "13"{
                    let data = convertToDictionary(text:(userInfo["jobs"] as? String ?? ""))
                    navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "30"{
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else{
                    let data = convertToDictionary(text:(userInfo["jobs"] as? String ?? ""))
                    navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }
            }
            else
            {
                if type == "3" || type == "4"{
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "7" || type == "6" {
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "13"{
                    let data = convertToDictionary(text:(userInfo["jobs"] as? String ?? ""))
                    navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else if type == "30"{
                    let data = ["user_id":"\(userInfo["user_id"] as? String ?? "")"]
                    navigate(navigateToType: type!, notificationData: data, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }else{
                    let data = convertToDictionary(text:(userInfo["jobs"] as? String ?? ""))
                    navigate(navigateToType: type!, notificationData: data!, notificationID: "\(userInfo["_id"] as? String ?? "")")
                }
            }
        }
        else
        {
            if application.applicationState == UIApplication.State.inactive
            {
                let data = convertToDictionary(text:userInfo["gcm.notification.data"] as! String)
                redirectionFRomChat(userInfo: data!)
            }else{
                let data = convertToDictionary(text:userInfo["gcm.notification.data"] as! String)
                if ((data!["tag"] as? String) != nil){
                    readNotification(notifID: "\(userInfo["_id"] as? String ?? "")")
                }else{
                    if data?["conversationId"] as? String != nil{
                        self.updateMessageCounttojob(unreadMessageCountcount: 0, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobID: "\(data?["job_id"] as? String ?? "")")
                        
                        UpdateIsMessageReadOrNot(UserId: "\(data?["user_id"] as? String ?? "")", jobID: "\(data?["job_id"] as? String ?? "")", isRead: "1")
                    }else{
                    }
                }
                
                redirectionFRomChat(userInfo: data!)
            }
        }
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func applicationReceivedRemoteMessage(_ remoteMessage: MessagingRemoteMessage) {
        
        
        
    }
    
    
    //MARK :- Func Navigation
    func navigate(navigateToType: String, notificationData: [String: Any],notificationID: String)
    {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil  {
            return
        }
        if UIApplication.shared.applicationIconBadgeNumber == 0{
            
        }else{
            UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber - 1
        }
        readNotification(notifID: notificationID)
        if navigateToType == "1" || navigateToType == "5" || navigateToType == "8" || navigateToType == "9" || navigateToType == "10" || navigateToType == "21" || navigateToType == "22" || navigateToType == "23" || navigateToType == "24"
        {
            isChat = true
            let jobDetail:JobHistoryData?
            do {
                let jsonObject = try JSONSerialization.data(withJSONObject: notificationData as Any, options: []) as AnyObject
                jobDetail = try? JSONDecoder().decode(JobHistoryData.self, from: jsonObject as! Data)
                notificationjobID = jobDetail?._id ?? ""
                if APPDELEGATE?.selectedUserType == .Crafter{
                    notificationCrafterID = "\(APPDELEGATE?.uerdetail?.user_id ?? "")"
                    
                    getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?.user_id ?? "")", jobId: jobDetail?._id ?? "",service_image:jobDetail?.service_image ?? "",profile_image:jobDetail?.profile_image ?? "",fullname:jobDetail?.full_name ?? "")
                }else{
                    notificationCrafterID = jobDetail?.handyman_id ?? ""
                    
                    getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?.user_id ?? "")", jobId: jobDetail?._id ?? "",service_image:jobDetail?.service_image ?? "",profile_image:jobDetail?.profile_image ?? "",fullname:jobDetail?.full_name ?? "")
                }
            } catch{
                return
            }
        }else if navigateToType == "3"{
            if isProfileOpen{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: [:])
                return
            }
            if APPDELEGATE?.selectedUserType == .Crafter{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 2
                objProfileVC.strTag = "Crafter"
                objProfileVC.CrafterId = notificationData["user_id"] as? String ?? ""
                findtopViewController()?.navigationController?.pushViewController(objProfileVC, animated: true)
            }else{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 1
                objProfileVC.strTag = "Client"
                objProfileVC.CrafterId = notificationData["user_id"] as? String ?? ""
                findtopViewController()?.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }else if navigateToType == "7"{
            if isProfileOpen{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: [:])
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = notificationData["user_id"] as? String ?? ""
            findtopViewController()?.navigationController?.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "6"{
            if isProfileOpen{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: [:])
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 2
            objProfileVC.strTag = "Crafter"
            objProfileVC.CrafterId = notificationData["user_id"] as? String ?? ""
            findtopViewController()?.navigationController?.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "30"{
            if isProfileOpen{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: [:])
                return
            }
            if APPDELEGATE!.selectedUserType == .Crafter{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.strTag = "Crafter"
                objProfileVC.ProfileViewTag = 1
                objProfileVC.isFromSideMenu = true
                findtopViewController()?.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }else if navigateToType == "4"{
            if isProfileOpen{
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reloadProfile"), object: nil, userInfo: [:])
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = notificationData["user_id"] as? String ?? ""
            navigationController.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "2" || navigateToType == "11" || navigateToType == "25" || navigateToType == "26" || navigateToType == "27" || navigateToType == "28"{
            let jobDetail:JobHistoryData?
            do {
                let jsonObject = try JSONSerialization.data(withJSONObject: notificationData as Any, options: []) as AnyObject
                jobDetail = try? JSONDecoder().decode(JobHistoryData.self, from: jsonObject as! Data)
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                objJobDetailsVC.isEdit = false
                objJobDetailsVC.jobList = jobDetail
                objJobDetailsVC.StatusType = "10"
                navigationController.pushViewController(objJobDetailsVC, animated: true)
            } catch{
                return
            }
        }else if navigateToType == "12"{
            let jobDetail:JobHistoryData?
            do {
                let jsonObject = try JSONSerialization.data(withJSONObject: notificationData as Any, options: []) as AnyObject
                jobDetail = try? JSONDecoder().decode(JobHistoryData.self, from: jsonObject as! Data)
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
                objJobDetailsVC.jobList = jobDetail
                navigationController.pushViewController(objJobDetailsVC, animated: true)
            } catch{
                return
            }
        }else if navigateToType == "13"{
            let jobDetail:JobHistoryData?
            do {
                let jsonObject = try JSONSerialization.data(withJSONObject: notificationData as Any, options: []) as AnyObject
                jobDetail = try? JSONDecoder().decode(JobHistoryData.self, from: jsonObject as! Data)
                if APPDELEGATE?.uerdetail?.user_id == jobDetail?.handyman_id || APPDELEGATE?.uerdetail?.user_id == jobDetail?.client_id{
                    if jobDetail?.booking_status == "4"{
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
                        objJobDetailsVC.jobList = jobDetail
                        navigationController.pushViewController(objJobDetailsVC, animated: true)
                    }else{
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                        let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                        objJobDetailsVC.isEdit = false
                        objJobDetailsVC.jobList = jobDetail
                        if jobDetail?.booking_status == "2"{
                            objJobDetailsVC.StatusType = "10"
                        }else{
                            objJobDetailsVC.StatusType = "0"
                        }
                        navigationController.pushViewController(objJobDetailsVC, animated: true)
                    }
                }else{
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                    objJobDetailsVC.isEdit = false
                    objJobDetailsVC.jobList = jobDetail
                    if jobDetail?.booking_status == "2"{
                        objJobDetailsVC.StatusType = "11"
                    }else if jobDetail?.booking_status == "4"{
                        objJobDetailsVC.StatusType = "12"
                    }else{
                        objJobDetailsVC.StatusType = "0"
                    }
                    navigationController.pushViewController(objJobDetailsVC, animated: true)
                }
            } catch{
                return
            }
        }
        else
        {
            
        }
    }
    
    func getjobListingAll(myId:String,jobId:String,service_image:String,profile_image:String,fullname:String){
        isChat = true
        APPDELEGATE?.addProgressView()
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                APPDELEGATE?.hideProgrssVoew()
                if data != nil{
                    let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                    
                    var isAvail = false
                    var jobDetail:jobsAdded?
                    if conversion == nil{
                        return
                    }
                    for item in conversion ?? [] {
                        
                        if item.jobdetailID == self.notificationjobID && item.job_id == "\(self.notificationjobID)\(self.notificationCrafterID)"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    self.notificationCrafterID = ""
                    self.notificationjobID = ""
                    
                    if (jobDetail != nil){
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,service_image:service_image,profile_image:profile_image,fullname:fullname)
                    }
                }
            }else{
            }
        }
    }
    
    func UpdateIsMessageReadOrNot(myID:String,FromID:String,isRead:String){
        let paramJob = ["isRead":isRead] as [String : Any]
        FirebaseAPICall.FirebaseupdateLastMessage(MyuserId: myID, OponnentUserID: FromID, ChatuserDetail: paramJob, completion: { (status) in
            
        })
    }
    
    func redirecttoChat(conversationId:String,jobId:String,chat_option_status:String,jobdetail:jobsAdded,service_image:String,profile_image:String,fullname:String){
        if isChat{
            isChat = false
            if conversationId == APPDELEGATE?.selectedChatUser{
                if (APPDELEGATE?.isChatViewcontroller)!{
                    return
                }
            }
            
            guard checkNetworkConnectivity(isSilent: true) else { return }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
            APPDELEGATE?.isChatViewcontroller = true
            messages?.conversationId = conversationId
            messages?.jobId = jobId
            messages?.chat_option_status = chat_option_status
            messages?.service_image = service_image
            messages?.profile_image = profile_image
            messages?.fullname = fullname
            messages?.CrafterID = jobdetail.CrafterId ?? ""
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            navigationController.pushViewController(messages!, animated: true)
        }
    }
    
    func redirectionFRomChat(userInfo:[String:Any]){
        notificationjobID = "\(userInfo["jobdetailID"] as?String ?? "")"
        notificationCrafterID = "\(userInfo["CrafterId"] as?String ?? "")"
        
        
        getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?.user_id ?? "")", jobId: "\(userInfo["jobdetailID"] as?String ?? "")",service_image:"\(userInfo["service_image"] as?String ?? "")",profile_image:"\(userInfo["profile_image"] as?String ?? "")",fullname:"\(userInfo["fullname"] as?String ?? "")")
    }
    
    //MARK:- UnBlock User API
    func readNotification(notifID:String)
    {
        let params = ["notification_id": "\(notifID)", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","is_open":"1"]
        WebService.Request.patch(url: changeNotificationStatus, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                } else
                {
                }
            }
        }
    }
    
    func updateMessageCounttojob(unreadMessageCountcount:Int,userId:String,jobID:String){
        let param = ["unreadMessageCount":unreadMessageCountcount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobID, detail: param, completion: { (status) in
            print("success")
        })
    }
    
    func UpdateIsMessageReadOrNot(UserId:String,jobID:String,isRead:String){
        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: jobID, detail: param, completion: { (status) in
            print("success")
        })
    }
}
