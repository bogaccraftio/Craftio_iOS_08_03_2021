
import UIKit
import IQKeyboardManagerSwift
class Colors {
    var gl:CAGradientLayer!
    
    init() {
        let colorTop = UIColor(red: 192.0 / 255.0, green: 38.0 / 255.0, blue: 42.0 / 255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 35.0 / 255.0, green: 2.0 / 255.0, blue: 2.0 / 255.0, alpha: 1.0).cgColor
        
        self.gl = CAGradientLayer()
        self.gl.colors = [colorTop, colorBottom]
        self.gl.locations = [0.0, 1.0]
    }
}

class MenuVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    //
    //MARK:- Variables & Outlets
    
    @IBOutlet weak var viewCrafterFilter: UIView!
    @IBOutlet weak var CraftercollectionCategoy: UICollectionView!
    @IBOutlet weak var viewaddServicebottom: UIView!
    @IBOutlet weak var viewbottomGradiant: UIView!

    @IBOutlet weak var viewSwipe: UIView!
    @IBOutlet weak var btnClientSwipe: UIButton!
    @IBOutlet weak var btnCraftermanSwipe: UIButton!
    @IBOutlet weak var btnCancelService: UIButton!
    
    var serviceListData = [[String: Any]]()
    var selectedServiceData = [String: Any]()
    var jobList: [JobHistoryData]?
    var selectedServiceIds = String()
    var arrSelectedIds = NSMutableArray()
    var arrUnreadCount = NSMutableArray()
    var isFromRegister = false
    var gradient = AlphaGradientView()
    
    //
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    var arrMenu = [String]()
    
    @IBAction func btnClientSwipeAction(_ sender: Any) {
        self.btnClientSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
        self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
        self.btnCraftermanSwipe.backgroundColor = .clear
        self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
        
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure to Switch Crafter to Client", completion: { (status) in
            if status{
                self.logoutApiCall(changeUserType: "1")
            }else{
                self.btnCraftermanSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
                self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
                self.btnClientSwipe.backgroundColor = .clear
                self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if isFromRegister{
            isFromRegister = false
            btnCancelService.isHidden = true
            viewCrafterFilter.isHidden = false
            self.viewSwipe.isHidden = true
            self.gradient.isHidden = true
        }
    }
    
    @IBAction func btnCraftermanSwipeAction(_ sender: Any) {
        self.btnCraftermanSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
        self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
        self.btnClientSwipe.backgroundColor = .clear
        self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
        
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure to Switch Client to Crafter", completion: { (status) in
            if status{
                self.logoutApiCall(changeUserType: "2")
            }else{
                self.btnClientSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
                self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
                self.btnCraftermanSwipe.backgroundColor = .clear
                self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
            }
        })
    }
    
    @IBAction func switchChage(_ sender: UISwitch)
    {
        if sender.isOn == true
        {
            self.SetUserAvailabilityAPI(1)
            APPDELEGATE?.uerdetail?.available_status = "1"
        }
        else
        {
            self.SetUserAvailabilityAPI(0)
            APPDELEGATE?.uerdetail?.available_status = "0"
        }
    }
    
    @IBAction func btnEdit(_ sender: Any) {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
            return
        }
        let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomiseProfileVC") as! CustomiseProfileVC
        self.navigationController?.pushViewController(objCustomiseProfileVC, animated: true)
    }
    
    @IBAction func btnCloseMenu(_ sender: Any) {
        APPDELEGATE?.dismissSideMenu(viewController: self)
    }
    
    @IBOutlet weak var tblMenu: UITableView!
    override func viewDidLoad() {
        viewCrafterFilter.isHidden = true
        super.viewDidLoad()
        
        APPDELEGATE?.isfromChat()

        self.gradient = AlphaGradientView.init(frame: CGRect (x: 0.0, y: UIScreen.main.bounds.size.height - 100, width: UIScreen.main.bounds.size.width, height: 100))
        gradient.color = UIColor(red: 60.0/255.0, green: 65.0/255.0, blue: 53.0/255.0, alpha: 1.0)
        gradient.direction = GRADIENT_DOWN
        self.view.addSubview(gradient)

        //Set shadow
        let rectShape = CAShapeLayer()
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewaddServicebottom.bounds.size.height)
        rectShape.bounds = self.viewaddServicebottom.frame
        rectShape.position = self.viewaddServicebottom.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 25, height: 25)).cgPath
        self.viewaddServicebottom.layer.mask = rectShape
        dropShadow(view:viewaddServicebottom,color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)
        
        if APPDELEGATE?.selectedUserType == .Crafter{
            getServiceListAPICall()
        }
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses = [MenuVC.self]

        NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccess(_:)), name: NSNotification.Name(rawValue: "loginsuccess"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationArrived(_:)), name: NSNotification.Name(rawValue: "notificationArrived"), object: nil)


        self.viewSwipe.cornerRadius = 24
        self.viewSwipe.borderWidth = 1
        self.viewSwipe.borderColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
        self.view.bringSubviewToFront(viewSwipe)
        self.btnCraftermanSwipe.cornerRadius = 22
        self.btnClientSwipe.cornerRadius = 22

        //Crafter Menu
        if APPDELEGATE!.selectedUserType == .Crafter{
            arrMenu = ["My services","My profile","My settings","Need help?","Logout"]
            //"My jobs","My messages","My notifications",
            
            self.btnCraftermanSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
            self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
            self.btnClientSwipe.backgroundColor = .clear
            self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
            
            self.btnCraftermanSwipe.isUserInteractionEnabled = false
            
        }else{
            arrMenu = ["Re-hire a crafter","My profile","My settings","Need help?","Logout"]
            //"My jobs","My messages","My notifications",
            
            self.btnClientSwipe.backgroundColor = #colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1)
            self.btnClientSwipe.setTitleColor(#colorLiteral(red: 0.3018392324, green: 0.2833796144, blue: 0.2696759403, alpha: 1), for: .normal)
            self.btnCraftermanSwipe.backgroundColor = .clear
            self.btnCraftermanSwipe.setTitleColor(#colorLiteral(red: 0, green: 0.9457753301, blue: 0.6357114911, alpha: 1), for: .normal)
            
            self.btnClientSwipe.isUserInteractionEnabled = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
        }else{
            getjobListingAll(myId: APPDELEGATE?.uerdetail?.user_id ?? "")
        }
        self.GetNotificationCountAPI()
        self.tblMenu.reloadData()
    }
    
    @IBAction func btnclosePopup(_ sender: Any) {
        viewCrafterFilter.isHidden = true
        self.viewSwipe.isHidden = false
        self.gradient.isHidden = false
    }

    @IBAction func btnaddService(_ sender: Any) {
        SaveMyServices()
    }
    
    //tableView delegate Datasource
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 120))
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 120
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if APPDELEGATE!.selectedUserType == .Crafter{
            if indexPath.row == 0{
                if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
                {
                    return 105
                }
                return 156
            }else if indexPath.row == 1{
                if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
                {
                    return 0
                }
                return 60
            }else if indexPath.row == 3{
                return 45
            }
            else{
                return 58
            }
        }else{
            if indexPath.row == 0{
                if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
                {
                    return 105
                }
                return 156
            }else if indexPath.row == 3{
                return 45
            }
            else{
                return 58
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if APPDELEGATE!.selectedUserType == .Crafter{
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                //For Remove logout option
                return arrMenu.count + 2
            }
            return arrMenu.count + 2
        }else{
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                //For Remove logout option
                return arrMenu.count + 1
            }
            return arrMenu.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //For Profile Section
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellProfile", for: indexPath)
            let imgProfile = cell.contentView.viewWithTag(1) as? UIImageView
            //Set COrner
            imgProfile?.layer.cornerRadius = (imgProfile?.frame.size.height)! / 2.0
            imgProfile?.layer.masksToBounds = true
            
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                imgProfile!.image = UIImage (named: "Splash")
                imgProfile?.contentMode = .scaleAspectFit
            }else{
                let imgURL = URL(string: APPDELEGATE?.uerdetail?.profile_image ?? "")
                imgProfile!.kf.setImage(with: imgURL, placeholder: nil)
            }
            
            let lblName = cell.contentView.viewWithTag(2) as? UILabel
            lblName?.text = "\(APPDELEGATE?.uerdetail?.first_name ?? "") \(APPDELEGATE?.uerdetail?.last_name ?? "")"
            
            let btnEdit = cell.contentView.viewWithTag(3) as? UIButton
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                btnEdit?.isHidden = true
            }else{
                btnEdit?.isHidden = false
            }
            return cell
        }else if indexPath.row == 1 && APPDELEGATE!.selectedUserType == .Crafter{// FOr Switch
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellSwitch", for: indexPath)
            let activeSwitch = cell.contentView.viewWithTag(1) as? UISwitch
            let lblOnOff = cell.contentView.viewWithTag(2) as? UILabel
            
            if APPDELEGATE?.uerdetail?.available_status == "0" || APPDELEGATE?.uerdetail?.available_status == "" || APPDELEGATE?.uerdetail?.available_status == nil
            {
                activeSwitch?.setOn(false, animated: true)
                lblOnOff?.text = "Offline"
                lblOnOff?.textColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
                activeSwitch?.onTintColor = UIColor(red: 155/255, green: 155/255, blue: 155/255, alpha: 1.0)
            }
            else
            {
                activeSwitch?.setOn(true, animated: true)
                lblOnOff?.text = "Online"
                lblOnOff?.textColor = UIColor(red: 0, green: 192/255, blue: 132/255, alpha: 1.0)
                activeSwitch?.onTintColor = UIColor(red: 0, green: 192/255, blue: 132/255, alpha: 1.0)
            }
            return cell
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellredirect", for: indexPath)
            let lbltitle = cell.contentView.viewWithTag(1) as? UILabel
            let lblNotification = cell.contentView.viewWithTag(2) as? UILabel
            //Set COrner
            lblNotification?.layer.cornerRadius = (lblNotification?.frame.size.height)! / 2.0
            lblNotification?.layer.masksToBounds = true
            
            //Set Title
            if APPDELEGATE!.selectedUserType == .Crafter{
                lbltitle?.text = arrMenu[indexPath.row - 2]
            }else {
                lbltitle?.text = arrMenu[indexPath.row - 1]
            }
            lblNotification?.isHidden = true
            
            if (indexPath.row == 6 && APPDELEGATE!.selectedUserType == .Crafter){
                if APPDELEGATE?.uerdetail?.user_id == "" || APPDELEGATE?.uerdetail?.user_id == nil{
                    lbltitle?.text = "Login"
                }else{
                    lbltitle?.text = "Logout"
                }
            }
            if (indexPath.row == 5 && APPDELEGATE!.selectedUserType == .Client){
                if APPDELEGATE?.uerdetail?.user_id == "" || APPDELEGATE?.uerdetail?.user_id == nil{
                    lbltitle?.text = "Login"
                }else{
                    lbltitle?.text = "Logout"
                }
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath.row == 2 && APPDELEGATE!.selectedUserType == .Crafter)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            viewCrafterFilter.isHidden = false
            self.viewSwipe.isHidden = true
            self.gradient.isHidden = true
        }
        else if (indexPath.row == 1 && APPDELEGATE!.selectedUserType == .Client)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            let objUnblockRehireVC = self.storyboard?.instantiateViewController(withIdentifier: "UnblockRehireVC") as! UnblockRehireVC
            objUnblockRehireVC.isfrom = "client"
            self.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
        }
        else if (indexPath.row == 3 && APPDELEGATE!.selectedUserType == .Crafter) || (indexPath.row == 2 && APPDELEGATE!.selectedUserType == .Client)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.strTag = "Crafter"
                objProfileVC.ProfileViewTag = 1
                objProfileVC.isFromSideMenu = true
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
            else
            {
                let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.strTag = "Client"
                objProfileVC.ProfileViewTag = 2
                objProfileVC.isFromSideMenu = true
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }
        else if (indexPath.row == 4 && APPDELEGATE!.selectedUserType == .Crafter) || (indexPath.row == 3 && APPDELEGATE!.selectedUserType == .Client)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            
            let objSettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsVC") as! SettingsVC
            self.navigationController?.pushViewController(objSettingsVC, animated: true)
        }
        else if (indexPath.row == 5 && APPDELEGATE!.selectedUserType == .Crafter) || (indexPath.row == 4 && APPDELEGATE!.selectedUserType == .Client)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            let objNeedHelpVC = self.storyboard?.instantiateViewController(withIdentifier: "NeedHelpVC") as! NeedHelpVC
            self.navigationController?.pushViewController(objNeedHelpVC, animated: true)
        }
        else if (indexPath.row == 6 && APPDELEGATE!.selectedUserType == .Crafter) || (indexPath.row == 5 && APPDELEGATE!.selectedUserType == .Client)
        {
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }else{
                alertController()
            }
        }
    }
    
    func alertController()
    {
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to Logout?", completion: { (status) in
            if status{
                self.logoutApiCall(changeUserType: "0")
            }else{
            }
        })
    }
    
    //MARK:- Observer Methods
    @objc func loginSuccess(_ notification: NSNotification) {
        tblMenu.reloadData()
    }
    
    @objc func notificationArrived(_ notification: NSNotification) {
        tblMenu.reloadData()
    }

}

extension MenuVC
{
    //Logout User
    func logoutApiCall(changeUserType: String){
        var user_type = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            user_type = Crafter
        }
        else
        {
            user_type = Client
        }

        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "user_type":"\(user_type)"]
        WebService.Request.patch(url: logoutAPI, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            self.clearCache(changeUserType: changeUserType)
        }
    }
    
    func clearCache(changeUserType: String){
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
        
        if changeUserType == "2"{
            APPDELEGATE?.uerdetail = nil
            APPDELEGATE?.selectedUserType = .none
            APPDELEGATE!.isAddressEdited = false
            appDelegate.isFirstTime = true
            appDelegate.isFirstTimeForFillBankDetail = true
            APPDELEGATE!.selectedUserType = .Crafter
            UserDefaults.standard.set("2", forKey: "usertype")
            UserDefaults.standard.synchronize()
            let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
        }else if changeUserType == "1"{
            APPDELEGATE?.uerdetail = nil
            APPDELEGATE?.selectedUserType = .none
            APPDELEGATE!.isAddressEdited = false
            appDelegate.isFirstTime = true
            appDelegate.isFirstTimeForFillBankDetail = true
            APPDELEGATE!.selectedUserType = .Client
            UserDefaults.standard.set("1", forKey: "usertype")
            UserDefaults.standard.synchronize()
            let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
        }else{
            APPDELEGATE?.uerdetail = nil
            APPDELEGATE?.selectedUserType = .none
            APPDELEGATE!.isAddressEdited = false
            APPDELEGATE?.notificationCount = 0
            APPDELEGATE?.chatCount = 0
            APPDELEGATE?.totalConut = 0
            appDelegate.isFirstTime = true
            appDelegate.isFirstTimeForFillBankDetail = true
            self.tblMenu.reloadData()
            UIApplication.shared.applicationIconBadgeNumber = 0
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
            self.navigationController?.pushViewController(nextViewController, animated: true)
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

                        self.tblMenu.reloadData()
                    }
                    else
                    {
                        
                    }
                    UIApplication.shared.applicationIconBadgeNumber = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                } else
                {
                }
            }
        }
    }
    
    //MARK:- API CALL GET ALL SERVICEA
    func getServiceListAPICall() {
        let param = ["handyman_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")"]
        WebService.Request.patch(url: getServiceList, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    self.serviceListData = data
                    self.arrSelectedIds = NSMutableArray()
                    for item in data{
                        if item["selected"] as? String == "selected"{
                            self.arrSelectedIds.add(item["_id"] as! String)
                        }
                    }
                    self.CraftercollectionCategoy.reloadData()
                }
            }
        }
    }
    

    func getjobListingAll(myId:String){
        APPDELEGATE?.addProgressView()
        var isLoad = true
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
                        
                        self.tblMenu.reloadData()
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

    
    //MARK:- SAvE SERVICES
    func SaveMyServices() {
        if arrSelectedIds.count == 0{
            return
        }
        selectedServiceIds = arrSelectedIds.componentsJoined(by: ",")
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","serviceids":"\(selectedServiceIds)","user_type":"2"]
        WebService.Request.patch(url: AddServices, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)     
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        self.viewCrafterFilter.isHidden = true
                    }
                    else
                    {
                        self.viewCrafterFilter.isHidden = true
                    }
                } else
                {
                }
                self.viewSwipe.isHidden = false
                self.gradient.isHidden = false
            }
        }
    }

    
    //MARK:- User Availability API
    func SetUserAvailabilityAPI(_ Status:Int)
    {
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","available_status":"\(Status)"]
        WebService.Request.patch(url: changeUserStatus, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        self.tblMenu.reloadData()
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
}


extension MenuVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return serviceListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
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
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let data = serviceListData[indexPath.row]
        if arrSelectedIds.contains(data["_id"] as! String){
            arrSelectedIds.remove(data["_id"] as! String)
        }else{
            arrSelectedIds.add(data["_id"] as! String)
        }
        CraftercollectionCategoy.reloadData()
    }
}
