
import UIKit
import IQKeyboardManagerSwift
import AVFoundation

class JobNearByVC: UIViewController, UIGestureRecognizerDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblJobNearBy: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewTab: UIView!
    var count = 0
    
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    
    @IBOutlet weak var viewCrafterFilter: UIView!
    @IBOutlet weak var CraftercategoryViewBottom: NSLayoutConstraint!
    @IBOutlet weak var CrafterCollectionCategoy: UICollectionView!
    @IBOutlet weak var lblNoNearByJobsFilterCrafterSide: UILabel!
    @IBOutlet weak var btnFilterCrafter: UIButton!
    @IBOutlet weak var lblChatCount: UILabel!
    @IBOutlet weak var lblNotificationCount: UILabel!
    @IBOutlet weak var imgMenu: UIImageView!
    
    
    var serviceListData = [[String: Any]]()
    var selectedServiceData = [String: Any]()
    var isCategorySelected: Bool = false
    var jobList: [JobHistoryData]?
    var arrjobList: [JobHistoryData]?
    var search:String=""
    var selectedServiceIds = String()
    var arrSelectedIds = NSMutableArray()
    var blockSelectedIds : ((NSMutableArray)->())?
    var isFilterOpen = false
    var tap = UIGestureRecognizer()
    var selectedIndexpath = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        lblNoNearByJobsFilterCrafterSide.isHidden = true
        APPDELEGATE?.isfromChat()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses = [JobNearByVC.self]
        self.onLoadOperations()
        let nib = UINib.init(nibName: "CellJobsBearBy", bundle: nil)
        self.tblJobNearBy.register(nib, forCellReuseIdentifier: "CellJobsBearBy")
        CraftercategoryViewBottom.constant = -700
        self.CrafterCollectionCategoy.reloadData()
        self.tblJobNearBy.isHidden = true
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.view.addGestureRecognizer(self.tap)
        
        self.lblChatCount.isHidden = true
        self.lblNotificationCount.isHidden = true
        imgMenu.tintColorDidChange()
        NotificationCenter.default.addObserver(self, selector: #selector(self.notificationArrived(_:)), name: NSNotification.Name(rawValue: "notificationArrived"), object: nil)
    }
     
    @objc func handleTap(sender: UITapGestureRecognizer? = nil)
    {
        if self.isFilterOpen == true
        {
            self.isFilterOpen = false
            viewTab.isHidden = false
            hideShowCategoryViewCrafter(bottom: -700)
        }        
    }
    
    @objc func notificationArrived(_ notification: NSNotification) {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil{
//            lblMessageCount.isHidden = true
            lblChatCount.isHidden = true
            lblNotificationCount.isHidden = true
        }else{
            GetNotificationCountAPI()
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        print(touch.view!)
        if (touch.view? .isDescendant(of: self.tblJobNearBy))! || (touch.view? .isDescendant(of: self.CrafterCollectionCategoy))!
        {
            return false
        }
        return true
    }
    
    
    func onLoadOperations()
    {
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewNavigate.layer.mask = rectShape
        
        let frame2 = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width - 45, height: self.viewCrafterFilter.bounds.size.height)
        
        //radious on button
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.viewCrafterFilter.frame
        rectShape2.position = self.viewCrafterFilter.center
        rectShape2.path = UIBezierPath(roundedRect: frame2, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 25, height: 25)).cgPath
        self.viewCrafterFilter.layer.mask = rectShape2
        dropShadow(view:viewCrafterFilter,color: UIColor.gray, opacity: 0.5, offSet: CGSize(width: -1, height: 1), radius: 3, scale: true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            lblChatCount.isHidden = true
            lblNotificationCount.isHidden = true
        }else{
            GetNotificationCountAPI()
        }

        if APPDELEGATE!.SelectedLocationAddress == "" {
            APPDELEGATE!.SelectedLocationAddress = APPDELEGATE?.CurrentLocationAddress ?? ""
            APPDELEGATE?.SelectedLocationLong = APPDELEGATE?.CurrentLocationLong ?? 0.00
            APPDELEGATE?.SelectedLocationLat = APPDELEGATE?.CurrentLocationLat ?? 0.00
        }

        self.getJobListAPICall(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00)
        
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil 
        {
            self.lblChatCount.isHidden = true
            self.lblNotificationCount.isHidden = true
        }else{
            self.lblChatCount.isHidden = false
            self.lblNotificationCount.isHidden = false
            
            self.lblChatCount.text = "\(APPDELEGATE?.chatCount ?? 0)"
            self.lblNotificationCount.text = "\(APPDELEGATE?.notificationCount ?? 0)"
            
            if APPDELEGATE?.chatCount == 0
            {
                self.lblChatCount.isHidden = true
            }
            
            if APPDELEGATE?.notificationCount == 0
            {
                self.lblNotificationCount.isHidden = true
            }
        }
        self.viewTab.isHidden = false
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
                        self.updatecount()
                    }
                    else
                    {
                        
                    }
                } else
                {
                    //self.toastError("Something went wrong, please try again later")
                }
            }
//            self.getjobListingAll(myId: APPDELEGATE?.uerdetail?.user_id ?? "")
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


    func updatecount(){
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil || APPDELEGATE?.totalConut == 0
        {
            self.lblChatCount.isHidden = true
            self.lblNotificationCount.isHidden = true
        }else{
            //self.lblMessageCount.isHidden = false
            self.lblChatCount.isHidden = false
            self.lblNotificationCount.isHidden = false
            
            self.lblChatCount.text = "\(APPDELEGATE?.chatCount ?? 0)"
            self.lblNotificationCount.text = "\(APPDELEGATE?.notificationCount ?? 0)"
            
            if APPDELEGATE?.chatCount == 0
            {
                self.lblChatCount.isHidden = true
            }
            
            if APPDELEGATE?.notificationCount == 0
            {
                self.lblNotificationCount.isHidden = true
            }
        }
    }

    
    func hideShowCategoryViewCrafter(bottom: CGFloat)
    {
        self.CraftercategoryViewBottom.constant = bottom
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK :- Button Actions
    @IBAction func btnCrafterFilter(_ sender: UIButton)
    {
        self.isFilterOpen = false
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        if APPDELEGATE!.selectedUserType == .Crafter{
            selectedServiceIds = arrSelectedIds.componentsJoined(by: ",")
            self.getJobListAPICall(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00)
        }
    }
    
    @IBAction func btnHideCrafterFilter(_ sender: UIButton)
    {
        self.isFilterOpen = false
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
    }
    
    @IBAction func btnAddAction(_ sender: UIButton)
    {
        self.isFilterOpen = true
        viewTab.isHidden = true
        hideShowCategoryViewCrafter(bottom: 30)
    }
    
    @IBAction func btnGotoMap(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnJobListAction(_ sender: UIButton)
    {
        if  APPDELEGATE?.uerdetail?.user_id == nil  ||  APPDELEGATE?.uerdetail?.user_id == ""
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "JobHistory", data: [:], image:[])
        }
        else
        {
            let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "JobHistory") as! JobHistory
            objJobHistoryVC.serviceListData = self.serviceListData
            self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
        }
    }
    
    @IBAction func btnGotoChat(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "Chat", data: [:], image:[])
            return
        }
            
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let objUnblockRehireVC = storyboard.instantiateViewController(withIdentifier: "ChatuserListViewController") as! ChatuserListViewController
        self.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
    }
    
    @IBAction func btnGotoNotification(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "NotificationListVC", data: [:], image:[])
            return
        }
        let objNotiListVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationListVC") as! NotificationListVC
        self.navigationController?.pushViewController(objNotiListVC, animated: true)
    }
    
    @IBAction func btnMenu(_ sender: Any)
    {
        APPDELEGATE?.presentSideMenu(viewController: self)
        self.viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
    }
    
    func dropShadow(view: UIView,color: UIColor, opacity: Float = 0.2, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
    }
    
    //Get Service List API Call
    func getJobListAPICall(serviceId:String,lat:Double,long:Double) {

        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(lat)","user_longitude":"\(long)","distance":"45","service_ids":"\(serviceId)","booking_status":"0","is_near_by": "1","is_nearby_new_jobs":"0"]

        WebService.Request.patch(url: getNearByMeJob, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    if response!["status"] as? Bool == true {
                        let dataresponse = response!["data"] as? [[String:Any]]
                        
                        if dataresponse != nil
                        {
                            do
                            {
                                let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                                
                                self.arrjobList = try? JSONDecoder().decode([JobHistoryData].self, from: jsonData)
                                
                                self.jobList = self.arrjobList
                                
                                if self.jobList?.count == 0{
                                    //self.jobList = []
                                    self.selectedIndexpath = 0
                                    self.arrjobList = []
                                    self.jobList = self.arrjobList
                                    self.tblJobNearBy.reloadData()
                                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"No new jobs available at the moment. Please check back soon!")
                                }
                                else
                                {
                                    self.tblJobNearBy.reloadData()
                                    self.tblJobNearBy.isHidden = false
                                }
                            }
                            catch
                            {
                                //self.jobList = []
                                self.arrjobList = []
                                self.selectedIndexpath = 0
                                self.jobList = self.arrjobList
                                self.tblJobNearBy.reloadData()
                                print(error.localizedDescription)
                            }
                            self.CrafterCollectionCategoy.reloadData()
                        }
                        else
                        {
                            //self.jobList = []
                            self.arrjobList = []
                            self.selectedIndexpath = 0
                            self.jobList = self.arrjobList
                            self.tblJobNearBy.reloadData()
                            self.CrafterCollectionCategoy.reloadData()
                            if self.jobList?.count == 0{
                                self.jobList = []
                                self.tblJobNearBy.reloadData()
                                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"No new jobs available at the moment. Please check back soon!")
                            }
                        }
                    } else
                    {
                        //self.jobList = []
                        self.arrjobList = []
                        self.selectedIndexpath = 0
                        self.jobList = self.arrjobList
                        self.tblJobNearBy.reloadData()
                        self.CrafterCollectionCategoy.reloadData()
                    }
                }
            }
            self.getServicesCrafter()
        }
    }
    
    func getServicesCrafter(){
        var serviceIds = String()
        for item in self.jobList ?? []{
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
                    self.CrafterCollectionCategoy.reloadData()
                }
            }
            if self.serviceListData.count > 0{
                self.btnFilterCrafter.isHidden = false
                self.lblNoNearByJobsFilterCrafterSide.isHidden = true
                self.CrafterCollectionCategoy.isHidden = false
            }else{
                self.btnFilterCrafter.isHidden = true
                self.lblNoNearByJobsFilterCrafterSide.isHidden = false
                self.CrafterCollectionCategoy.isHidden = true
            }
        }
    }

    @objc func JobIconTapped(_ sender: UIButton)
    {
        APPDELEGATE?.jobDetailImages = []
        for item in jobList?[sender.tag].media ?? []{
            APPDELEGATE?.jobDetailImages.append(item)
        }
        
        print(sender.tag)
        if self.jobList?[sender.tag].media.count ?? 0 > 0{
            let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            objCustomiseProfileVC.arrImages = self.jobList?[sender.tag].media
            //objCustomiseProfileVC.arrPreview = selectedMediaImages
            objCustomiseProfileVC.OpenFrom = "detail"
            objCustomiseProfileVC.jobID = self.jobList?[sender.tag]._id ?? ""
            objCustomiseProfileVC.blockCancel = {
            }
            objCustomiseProfileVC.modalPresentationStyle = .fullScreen
            self.present(objCustomiseProfileVC, animated: true, completion: nil)
        }
    }
    
}

extension JobNearByVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if jobList?.count == 0{
            return 0
        }
        if indexPath.row == jobList?.count {
            return 140
        }
        else
        {
            return 276 //+ 30
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if jobList?.count == 0{
            return 0
        }
        return (jobList?.count ?? 0) + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if indexPath.row == jobList?.count
        {//FOr Bottom Space
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellJobsBearBy", for: indexPath) as!  CellJobsBearBy//CellWorkHistory
        //
        if self.jobList?[indexPath.row].is_archive == "1"{
            cell.lblInactivated.isHidden = false
            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewMain.layer.borderWidth = 2.0
        }else{
            cell.lblInactivated.isHidden = true
            cell.viewMain.layer.borderColor = UIColor.clear.cgColor
            cell.viewMain.layer.borderWidth = 0.0
        }
        if self.jobList?[indexPath.row].is_emergency_job == 1
        {
            let str = jobList?[indexPath.row].description ?? ""
            let trimmedString = str.trimmingCharacters(in: .whitespaces)
            let myString = "Emergency! " + " \(trimmedString)"
            cell.lblInprogressDesc.attributedText = myString.SetAttributed(location: 0, length: 11, font: "Cabin-Regular", size: 15.0)
        }
        else
        {
            cell.lblInprogressDesc.text = jobList?[indexPath.row].description
        }
        //
        
        cell.lblLocation.text = jobList?[indexPath.row].address
        let imgURL = URL(string: jobList?[indexPath.row].service_image ?? "")
        cell.imgService.kf.setImage(with: imgURL, placeholder: nil)
        cell.Arrimg = jobList?[indexPath.row].media ?? []
        cell.pageController.numberOfPages = jobList?[indexPath.row].media.count ?? 0
        cell.btnJobIcon.tag = indexPath.row
        cell.btnJobIcon.addTarget(self, action: #selector(self.JobIconTapped(_:)), for: .touchUpInside)
        cell.blockPreview = {
            APPDELEGATE?.jobDetailImages = []
            for item in self.jobList?[indexPath.row].media ?? []{
                APPDELEGATE?.jobDetailImages.append(item)
            }
            
            if self.jobList?[indexPath.row].media.count ?? 0 > 0{
                let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                objCustomiseProfileVC.arrImages = self.jobList?[indexPath.row].media
                objCustomiseProfileVC.OpenFrom = "detail"
                //objCustomiseProfileVC.showPreviewAs = .fromOther
                objCustomiseProfileVC.blockCancel = {
                }
                objCustomiseProfileVC.modalPresentationStyle = .fullScreen
                self.present(objCustomiseProfileVC, animated: true, completion: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == jobList?.count{
            return
        }
        selectedIndexpath = indexPath.row
        let objJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
        viewTab.isHidden = false
        hideShowCategoryViewCrafter(bottom: -700)
        objJobDetailsVC.jobList = jobList?[indexPath.row]
        self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
    }
    
    //
    func getThumbnailImage_2(forUrl url: URL) -> UIImage?
    {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }
        catch let error
        {
            print(error)
        }
        
        return nil
    }
}

extension JobNearByVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
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
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                let data = serviceListData[indexPath.row]
                if arrSelectedIds.contains(data["_id"] as! String){
                    arrSelectedIds.remove(data["_id"] as! String)
                }else{
                    arrSelectedIds.add(data["_id"] as! String)
                }
                self.blockSelectedIds?(arrSelectedIds)
                CrafterCollectionCategoy.reloadData()
            }else{
            }
    }
    
}

extension JobNearByVC:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if string.isEmpty{
            search = String(search.dropLast())
        }else{
            search=textField.text!+string
        }
        
        self.jobList = self.arrjobList?.filter({ value -> Bool in
            //return value.description?.contains(search) ?? false
            
            return value.description?.range(of: search, options: .caseInsensitive) != nil
        })
        if self.jobList?.count == 0 && search == ""{
            jobList=arrjobList
        }
        tblJobNearBy.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtSearch{
            txtSearch.resignFirstResponder()
        }
        return false
    }
    
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.jobList = self.arrjobList?.filter({ value -> Bool in
            return value.description?.range(of: search, options: .caseInsensitive) != nil
        })
        
        if self.jobList?.count == 0 && search == ""{
            jobList=arrjobList
        }
        tblJobNearBy.reloadData()
    }
}
