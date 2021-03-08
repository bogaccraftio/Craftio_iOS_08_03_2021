
import UIKit
import IQKeyboardManagerSwift
import Firebase
import SwiftKeychainWrapper
protocol loginViewDelegate
{
    func loginSuccessfull()
}


class LoginView: UIView, UITextFieldDelegate {

    
    @IBOutlet weak var viewBottomLogin: UIView!
    @IBOutlet weak var viewBottomRegister: UIView!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    
    @IBOutlet weak var txtNameRegi: UITextField!
    @IBOutlet weak var txtEmailRegi: UITextField!
    @IBOutlet weak var txtPasswordRegi: UITextField!
    @IBOutlet weak var loginbottom: NSLayoutConstraint!
    @IBOutlet weak var registerbottom: NSLayoutConstraint!
    @IBOutlet weak var logintop: NSLayoutConstraint!
    @IBOutlet weak var registertop: NSLayoutConstraint!

    @IBOutlet weak var viewLogin: UIView!
    @IBOutlet weak var Viewregister: UIView!
    var delegate : loginViewDelegate!
    var jobdata = [String:String]()
    var openFrom = String()
    var selectedMediaImages = [Any]()
    
    var isMailCheck = false
    
    var txtTag = Int()
    var is_service_provide = String()
    
    var appdelegateForPopup = UIApplication.shared.delegate as! AppDelegate
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "LoginView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }

    func initLoginView(viewopenFrom:String,UserData:[String:Any],Images:[Any]){
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        self.backgroundColor = UIColor.clear
        self.OnloadSetup()
        jobdata = UserData as! [String : String]
        openFrom = viewopenFrom
        selectedMediaImages = Images
        showView(type: "login")
        setPlacxeholder(textfield:txtEmail,title:"Email")
        setPlacxeholder(textfield:txtPassword,title:"Password")

        setPlacxeholder(textfield:txtEmailRegi,title:"Email")
        setPlacxeholder(textfield:txtPasswordRegi,title:"Password")
        setPlacxeholder(textfield:txtNameRegi,title:"Name")
        
        self.txtNameRegi.autocapitalizationType = .words
        
        self.txtEmail.autocorrectionType = .no
        self.txtPassword.autocorrectionType = .no
        self.txtNameRegi.autocorrectionType = .no
        self.txtEmailRegi.autocorrectionType = .no
        self.txtPasswordRegi.autocorrectionType = .no

        if #available(iOS 10.0, *) {
            self.txtEmail.textContentType = UITextContentType(rawValue: "")
            self.txtPassword.textContentType = UITextContentType(rawValue: "")
            self.txtNameRegi.textContentType = UITextContentType(rawValue: "")
            self.txtEmailRegi.textContentType = UITextContentType(rawValue: "")
            self.txtPasswordRegi.textContentType = UITextContentType(rawValue: "")
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeFirst),
            name: .txtBecomeFirst,
            object: nil
        )
        
        if APPDELEGATE?.selectedUserType == .Crafter
        {
            self.txtEmail.text = KeychainWrapper.standard.string(forKey: "CrafterEmail")
            self.txtPassword.text = KeychainWrapper.standard.string(forKey: "CrafterPassword")
        }
        else
        {
            self.txtEmail.text = KeychainWrapper.standard.string(forKey: "clientEmail")
            self.txtPassword.text = KeychainWrapper.standard.string(forKey: "clientPassword")
        }
    }
    
    func setPlacxeholder(textfield:UITextField,title:String){
        textfield.attributedPlaceholder = NSAttributedString(string: title,
                                                                 attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)])
    }
    
    @objc func becomeFirst(notification: NSNotification)
    {
        if self.txtTag == 1
        {
            self.txtEmail.becomeFirstResponder()
        }
        else if self.txtTag == 2
        {
            self.txtPassword.becomeFirstResponder()
        }
        else if self.txtTag == 3
        {
            self.txtNameRegi.becomeFirstResponder()
        }
        else if self.txtTag == 4
        {
            self.txtEmailRegi.becomeFirstResponder()
        }
        else if self.txtTag == 5
        {
            self.txtPasswordRegi.becomeFirstResponder()
        }
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {

            self.loginbottom.constant = -keyboardSize.height
            self.registerbottom.constant = -keyboardSize.height

            UIView.animate(withDuration: 1.0, animations: {
                self.layoutIfNeeded()
                self.updateConstraintsIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.loginbottom.constant = 0
            self.registerbottom.constant = 0

            UIView.animate(withDuration: 1.0, animations: {
                self.layoutIfNeeded()
                self.updateConstraintsIfNeeded()
            })
        }
    }

    func OnloadSetup()
    {
        InstanceID.instanceID().instanceID(handler: { (result, error) in
            if let error = error {
                APPDELEGATE?.deviceToken = "jashg87y2as"
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                APPDELEGATE?.deviceToken = result.token
                UserDefaults.standard.setValue("\(result.token)", forKey: "token")
                UserDefaults.standard.synchronize()
                print("Remote instance ID token: \(result.token)")
            }
        })

        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewBottomLogin.frame
        rectShape.position = self.viewBottomLogin.center
        var frame = CGRect (x: 0, y: self.viewBottomLogin.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.viewBottomLogin.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewBottomLogin.layer.mask = rectShape
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = self.viewBottomRegister.frame
        rectShape1.position = self.viewBottomRegister.center
        frame = CGRect (x: 0, y: self.viewBottomRegister.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.viewBottomRegister.bounds.size.height)
        rectShape1.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewBottomRegister.layer.mask = rectShape1
        
        viewBottomLogin.layer.masksToBounds = true
        viewBottomLogin.layer.cornerRadius = 19.0
        viewBottomLogin.clipsToBounds = false
        viewBottomLogin.layer.shadowColor = UIColor.gray.cgColor
        viewBottomLogin.layer.shadowOpacity = 0.9
        viewBottomLogin.layer.shadowOffset = CGSize.zero
        viewBottomLogin.layer.shadowRadius = 5

        viewBottomRegister.layer.masksToBounds = true
        viewBottomRegister.layer.cornerRadius = 19.0
        viewBottomRegister.clipsToBounds = false
        viewBottomRegister.layer.shadowColor = UIColor.gray.cgColor
        viewBottomRegister.layer.shadowOpacity = 0.5
        viewBottomRegister.layer.shadowOffset = CGSize.zero
        viewBottomRegister.layer.shadowRadius = 5

        self.loginbottom.constant = 0
        self.registerbottom.constant = 0
        
        txtNameRegi.returnKeyType = .next
        txtEmailRegi.returnKeyType = .next
        txtPasswordRegi.returnKeyType = .done
        txtEmail.returnKeyType = .next
        txtPassword.returnKeyType = .done

        UIView.animate(withDuration: 0.3, animations: {
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        })

    }
    
    //Email-Password Validation
    func validateRequiredField() -> Bool
    {
        if txtEmail.text == "" {
            self.txtTag = 1
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Email can not be blank.")
            return false            
        }
        else if !Validate.isValidEmail(testStr: txtEmail.text!) {
            self.txtTag = 1
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Please insert valid Email.")
            return false
        }else if txtPassword.text == "" {
            self.txtTag = 2
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Password can not be blank.")
            return false
        }
        else {
            return true
        }
    }
    
    //Register
    func validateRequiredFieldRegister() -> Bool
    {
        self.endEditing(true)
        if txtNameRegi.text == "" {
            self.txtTag = 3
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Name can not be blank.")            
            return false
        }
        else if txtEmailRegi.text == "" {
            self.txtTag = 4
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Email can not be blank.")
            return false
        }
        else if !Validate.isValidEmail(testStr: txtEmailRegi.text!) {
            self.txtTag = 4
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Please insert valid Email.")
            return false
        }
        else if txtPasswordRegi.text == "" {
            self.txtTag = 5
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "Password can not be blank.")
            return false
            
        }
        else {
            return true
        }
    }
    
    
    //Login API Call
    func LoginAPICall(email: String, password: String) {
        var params = [String: Any]()
        params = ["email_id": email, "password": password, "user_type": Client, "device_type": deviceType, "device_token": "\(APPDELEGATE?.deviceToken ?? "asdasfsfsf")","service_id":"\(jobdata["service_id"] ?? "")"]
       
        var keyChainEmail = ""
        var keyChainPassword = ""
        if APPDELEGATE?.selectedUserType == .Crafter{
            params["user_type"] = Crafter
            keyChainEmail = "CrafterEmail"
            keyChainPassword = "CrafterPassword"
        }else{
            params["user_type"] = Client
            keyChainEmail = "clientEmail"
            keyChainPassword = "clientPassword"
        }
        var service_id = ""
        if self.openFrom == "makeoffer"{
            service_id = "\(jobdata["service_id"] ?? "")"
            params["service_id"] = service_id
        }
        KeychainWrapper.standard.set(self.txtEmail.text ?? "", forKey: keyChainEmail)
        KeychainWrapper.standard.set(self.txtPassword.text ?? "", forKey: keyChainPassword)
        
        WebService.Request.patch(url: loginAPI, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if self.openFrom == "jobcreate" && APPDELEGATE?.selectedUserType == .Client{
                }else{
                }
                if service_id == ""{
                    self.is_service_provide = "1"
                }else{
                    self.is_service_provide = response!["is_service_provide"] as? String ?? "1"
                }
                
                if response!["status"] as? Bool == true {
                    self.removeFromSuperview()
                    let dataresponse = response!["data"] as? [String:Any]
                    UserDefaults.standard.set(dataresponse?["_id"] as? String ?? "", forKey: "userId")
                    UserDefaults.standard.set(dataresponse?["session_token"] as? String ?? "", forKey: "sessionToken")
                    UserDefaults.standard.synchronize()
                    self.getProfileDetails(userId: dataresponse?["_id"] as? String ?? "", token: dataresponse?["session_token"] as? String ?? "", isFromRegi: false)
                    self.insertUserToFirebase(userID: dataresponse?["_id"] as? String ?? "", detail: dataresponse!)
                } else
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "\(response!["msg"] as? String ?? "")")
                }
            }
        }
    }
    
    //Registration API Call
    func RegistrationAPICall(name: String, email: String, password: String) {
        var params = [String: Any]()
        params = ["user_name": name, "email_id": email, "password": password, "device_type": deviceType, "device_token": "\(APPDELEGATE?.deviceToken ?? "")","user_latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","user_longitude":"\(APPDELEGATE?.SelectedLocationLong  ?? 0.00)","user_address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","city": "\(APPDELEGATE?.city ?? "")"]
        
        var keyChainEmail = ""
        var keyChainPassword = ""
        if APPDELEGATE?.selectedUserType == .Crafter{
            params["user_type"] = Crafter
            keyChainEmail = "CrafterEmail"
            keyChainPassword = "CrafterPassword"
        }else{
            params["user_type"] = Client
            keyChainEmail = "clientEmail"
            keyChainPassword = "clientPassword"
        }
        
        KeychainWrapper.standard.set(self.txtEmailRegi.text ?? "", forKey: keyChainEmail)
        KeychainWrapper.standard.set(self.txtPasswordRegi.text ?? "", forKey: keyChainPassword)
        
        WebService.Request.patch(url: registerationAPI, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    self.is_service_provide = "0"
                    self.txtEmail.text = self.txtEmailRegi.text
                    self.txtPassword.text = self.txtPasswordRegi.text
                    self.txtNameRegi.text = ""
                    self.txtEmailRegi.text = ""
                    self.txtPasswordRegi.text = ""
                    let data = response!["data"] as? [String:Any]
                    let dataresponse = data!["user_data"] as? [String:Any]
                    UserDefaults.standard.set(dataresponse?["_id"] as? String ?? "", forKey: "userId")
                    UserDefaults.standard.set(dataresponse?["session_token"] as? String ?? "", forKey: "sessionToken")
                    UserDefaults.standard.synchronize()
                    self.getProfileDetails(userId: dataresponse?["_id"] as? String ?? "", token: dataresponse?["session_token"] as? String ?? "", isFromRegi: true)
                    self.insertUserToFirebase(userID: dataresponse?["_id"] as? String ?? "", detail: dataresponse!)
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: response!["msg"] as? String ?? "")
                }
            }
        }
    }
    
    //Get Profile
    func getProfileDetails(userId: String, token: String, isFromRegi: Bool)
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
        params = ["user_id": "\(userId)", "loginuser_id": "\(userId)", "session_token": "\(token)","review_required":"0","user_type":usertype,"is_own_profile": "1"]
        WebService.Request.patch(url: getUserProfile, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
                            UserDefaults.standard.synchronize()
                            self.removeFromSuperview()
                            self.updateuserLocationData()
                            if isFromRegi && appDelegate.selectedUserType == userType.Crafter{
                                self.removeFromSuperview()
                                let menu = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "MenuVC") as? MenuVC
                                menu?.isFromRegister = true
                            findtopViewController()?.navigationController?.pushViewController(menu!, animated: true)
                                return
                            }
                            if self.openFrom == "jobcreate" && APPDELEGATE?.selectedUserType == .Client{
                                if self.selectedMediaImages.count > 0{
                                    self.CreateJOb(params:self.jobdata,userID: dataresponse?["_id"] as? String ?? "", session_token: dataresponse?["session_token"] as? String ?? "")
                                }else{
                                    self.CreateJObwithouImage(params: self.jobdata,userID: dataresponse?["_id"] as? String ?? "", session_token: dataresponse?["session_token"] as? String ?? "")
                                }
                            }else if self.openFrom == "makeoffer"{
                                self.removeFromSuperview()
                                if self.is_service_provide == "0"{
                                    let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
                                    findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
                                }else{
                                    NotificationCenter.default.post(name: Notification.Name("isLogin"), object: nil)
                                }
                            }
                            else if self.openFrom == "Chat"
                            {
                                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                                let objUnblockRehireVC = storyboard.instantiateViewController(withIdentifier: "ChatuserListViewController") as! ChatuserListViewController
                                findtopViewController()?.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
                            }
                            else if self.openFrom == "NotificationListVC"
                            {
                                let objNotiListVC = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
                                findtopViewController()?.navigationController?.pushViewController(objNotiListVC, animated: true)
                            }
                            else if self.openFrom == "JobHistory"
                            {
                                let objJobHistoryVC = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "JobHistory") as! JobHistory
                                objJobHistoryVC.serviceListData = APPDELEGATE!.serviceListData
                                findtopViewController()?.navigationController?.pushViewController(objJobHistoryVC, animated: true)
                            }
                            else{
                                    self.removeFromSuperview()
                                        if ((findtopViewController() as? HomeVC) != nil){
                                            
                                        }else{
                                            let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
                                            findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
                                        }
                                    
                                    // topController should now be your topmost view controller
                            }
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                        self.GetNotificationCountAPI()
                    }
                    else
                    {
                        
                    }
                } else
                {
                }
            }
        }
    }

    //Save Job
    func CreateJOb(params:[String:String],userID: String, session_token: String)
    {
        
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        self.jobdata["job_created_date"] = "\(job_created_date)"
        
        self.jobdata["user_id"] = userID
        self.jobdata["loginuser_id"] = userID
        self.jobdata["session_token"] = session_token
        
        var intCount = 0
        var isVideo = false
        appDelegate.addProgressView()
        for i in 0..<(APPDELEGATE?.jobDetailImages.count)!{
            if let strimage = APPDELEGATE?.jobDetailImages[i] as? URL{
                if (strimage.absoluteString.contains(".mp4")) || (strimage.absoluteString.contains(".mov")){
                    var movieData: Data?
                    intCount += 1
                    isVideo = true
                    do {
                        movieData = try Data(contentsOf: strimage, options: Data.ReadingOptions.alwaysMapped)
                        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                        APPDELEGATE?.jobDetailImages[i] = compressedURL
                        compressVideo(inputURL: (strimage), outputURL: compressedURL) { (session) in
                            intCount -= 1
                            switch session!.status {
                            case .unknown:
                                break
                            case .waiting:
                                break
                            case .exporting:
                                break
                            case .completed:
                                
                                let data = NSData(contentsOf: compressedURL)
                                print("File size after compression: \(Double(data!.length / 1048576)) mb")
                            case .failed:
                                break
                            case .cancelled:
                                break
                            }
                            if intCount == 0{
                                self.uploadData(params: self.jobdata)
                            }
                        }
                    }catch{}
                }
            }
        }
        if !isVideo{
            self.uploadData(params: self.jobdata)
        }
    }
    
    func uploadData(params: [String: String]) {
        WebService.Request.uploadMultipleFiles(url: createJob, images : APPDELEGATE!.jobDetailImages, parameters:params, isDefaultImage: true, isBackgroundPerform:false, headerForAPICall : ["Content-type": "multipart/form-data"]){ (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "job", message:"\(response?["msg"] as? String ?? "")")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                }
            }
        }
    }

    
    func CreateJObwithouImage(params:[String:String],userID: String, session_token: String)
    {
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        self.jobdata["job_created_date"] = "\(job_created_date)"
        
        self.jobdata["user_id"] = userID
        self.jobdata["loginuser_id"] = userID
        self.jobdata["session_token"] = session_token

        WebService.Request.patch(url: createJob, type: .post, parameter: self.jobdata, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    if response!["status"] as? Bool == true {
                        APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "job", message:"\(response?["msg"] as? String ?? "")")
                    }
                }
                else
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")

                }
            }
        }
    }

    
    //CheckEmailRegistered
    func CheckEmailRegistered()
    {
        var param = ["email_id":"\(txtEmailRegi.text ?? "")"]
        if APPDELEGATE?.selectedUserType == .Crafter{
            param["user_type"] = Crafter
        }else{
            param["user_type"] = Client
        }
        WebService.Request.patch(url: emailCheck, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                } else
                {
                    self.txtEmailRegi.becomeFirstResponder()
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response!["msg"] as? String ?? "")
                }
            }
        }
    }
    
    //Get Notification Count API
    func GetNotificationCountAPI()
    {
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
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        APPDELEGATE?.notificationCount = (dataresponse! as NSDictionary).value(forKey: "total_count") as! Int
                        APPDELEGATE?.chatCount = (dataresponse! as NSDictionary).value(forKey: "total_chat_count") as! Int
                        if APPDELEGATE!.selectedUserType == .Crafter{
                            if (dataresponse!["is_accountdetail_added"] as! String == "0" || dataresponse!["is_accountdetail_added"] as! String == ""){
                                APPDELEGATE?.bankDetailNotFilled = .No
                            }else{
                                APPDELEGATE?.bankDetailNotFilled = .Yes
                            }
                        }
                        UIApplication.shared.applicationIconBadgeNumber = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                        
                        APPDELEGATE?.totalConut = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                        
                    }
                    else
                    {
                        
                    }
                } else
                {
                }
            }
            self.getjobListingAll(myId: APPDELEGATE?.uerdetail?.user_id ?? "")
        }
    }
    
    func getjobListingAll(myId:String){
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                if data != nil{
                    do
                    {
                        let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                        var count = 0
                        for item in conversion ?? [] {
                            if item.unreadMessageCount ?? 0 > 0{
                                count += 1
                            }
                        }
                    }
                }
            }else{
            }
        }
    }
    
    

    //MARK :- Button Actions
    
    @IBAction func btnLoginAction(_ sender: UIButton) {
        self.endEditing(true)
        if validateRequiredField() {
            self.endEditing(true)
            LoginAPICall(email: txtEmail.text!, password: txtPassword.text!)
        }
    }
    
    @IBAction func btnRegisterAction(_ sender: UIButton) {
        self.endEditing(true)
        if validateRequiredFieldRegister() {
            self.endEditing(true)
            RegistrationAPICall(name : txtNameRegi.text!, email: txtEmailRegi.text!, password: txtPasswordRegi.text!)
        }
    }
    
    @IBAction func btnLogin(_ sender: UIButton) {
       
        self.isMailCheck = true
        self.txtEmail.becomeFirstResponder()
        txtNameRegi.text = ""
        txtEmailRegi.text = ""
        txtPasswordRegi.text = ""
        showView(type: "login")
    }
    
    
    @IBAction func btndismiss(_ sender: UIButton) {
        self.isMailCheck = true
        self.endEditing(true)
        self.removeFromSuperview()
    }
    
    @IBAction func btnRegistrationAction(_ sender: UIButton) {
        
        self.isMailCheck = false
        self.txtNameRegi.becomeFirstResponder()
        txtEmail.text = ""
        txtPassword.text = ""
        showView(type: "register")
    }
    
    @IBAction func btnForgotPasswordAction(_ sender: UIButton) {
        self.endEditing(true)
        let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "ForgotPasswordVC") as? ForgotPasswordVC
      findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
    }
    
    //Hide and Show View
    func showView(type: String){
        if type == "login"{
            Viewregister.isHidden = true
            viewLogin.isHidden = false
        }else{
            viewLogin.isHidden = true
            Viewregister.isHidden = false
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        if textField == self.txtNameRegi
        {
            self.txtNameRegi.autocapitalizationType = .words
            txtNameRegi.returnKeyType = .next
            txtNameRegi.becomeFirstResponder()
        }
        else
        {
            textField.autocapitalizationType = .none
        }

        textField.autocorrectionType = .no
        textField.textContentType = UITextContentType(rawValue: "")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmailRegi{
            if txtEmailRegi.text == ""{
            }else if !Validate.isValidEmail(testStr: txtEmailRegi.text!) {
            }else{
                
                if self.isMailCheck
                {
                    
                }
                else
                {
                    CheckEmailRegistered()
                }
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtEmail{
            txtPassword.returnKeyType = .done
            if txtEmail.text == ""{
                return false
            }else if !Validate.isValidEmail(testStr: txtEmail.text!) {
                self.endEditing(true)
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please insert valid Email.")
                return false
                
            }else{
                txtPassword.becomeFirstResponder()
            }
        }else if textField == txtPassword{
//            txtPassword.resignFirstResponder()
            if validateRequiredField() {
                LoginAPICall(email: txtEmail.text!, password: txtPassword.text!)
            }
        }else if textField == txtNameRegi{
            txtEmailRegi.returnKeyType = .next
            if txtNameRegi.text == ""{
                return false
            }
            else
            {
                txtEmailRegi.becomeFirstResponder()
            }
        }else if textField == txtEmailRegi{
            txtPasswordRegi.returnKeyType = .done
            if txtEmailRegi.text == ""{
                return false
            }else if !Validate.isValidEmail(testStr: txtEmailRegi.text!) {
                self.endEditing(true)
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please insert valid Email.")
                return false
            }else{
               txtPasswordRegi.becomeFirstResponder()
            }
        }else if textField == txtPasswordRegi{
//            txtPasswordRegi.resignFirstResponder()
            if validateRequiredFieldRegister() {
                RegistrationAPICall(name : txtNameRegi.text!, email: txtEmailRegi.text!, password: txtPasswordRegi.text!)
            }
        }
        return false
    }
    
    // Textfield Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtNameRegi
        {
            do {
                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z ].*", options: [])
                if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                    return false
                }
            }
            catch {
                print("ERROR")
            }
            return true
        }
        else
        {
            return true
        }
    }
    
    //Firebase Login
    func insertUserToFirebase(userID:String,detail:[String:Any]) {
        let param = ["first_name":"\(detail[""] as? String ?? "")"]
        FirebaseAPICall.SaveUserToFirebase(userId: userID, userdetail: detail) { (status) in
            if status{
                
            }
        }
    }
    
    func updateuserLocationData(){
        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(APPDELEGATE?.CurrentLocationLat ?? 0.00)","user_longitude":"\(APPDELEGATE?.CurrentLocationLong  ?? 0.00)","distance":"45","user_type":"\(APPDELEGATE!.uerdetail?.user_type ?? "")","user_address":"\(APPDELEGATE?.CurrentLocationAddress ?? "")", "device_type": deviceType, "device_token": "\(APPDELEGATE?.deviceToken ?? "")","city": "\(APPDELEGATE?.currentCity ?? "")"]
        WebService.Request.patch(url: updateUserLocation, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
            }
        }
    }
}

extension NSNotification.Name
{
    static let txtBecomeFirst = Notification.Name("txtBecomeFirst")
}
