
import UIKit
import AVFoundation

class JobHistory: UIViewController, UIGestureRecognizerDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblWorkHistory: UITableView!
    @IBOutlet weak var lblSegment: UILabel!
    @IBOutlet weak var btnPending: UIButton!
    @IBOutlet weak var btnInprocess: UIButton!
    @IBOutlet weak var btnComplete: UIButton!
    var tag = Int()
    var isClient = String()
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    
    @IBOutlet weak var viewCrafterFilter: UIView!
    @IBOutlet weak var CrafterCategoryViewBottom: NSLayoutConstraint!
    @IBOutlet weak var crafterCollectionCategoy: UICollectionView!
    @IBOutlet weak var lblNoNearByJobsFilterCrafterSide: UILabel!
    @IBOutlet weak var btnFilterCrafter: UIButton!
    @IBOutlet weak var imgMenu: UIImageView!
    
    var serviceListData = [[String: Any]]()    
    var isCategorySelected: Bool = false
    var selectedType = "0"
    var selectedServiceIds = String()
    var arrSelectedIds = NSMutableArray()

    var jobList: [JobHistoryData]?
    var selectedIndexpath = NSInteger()
    
    var tap = UIGestureRecognizer()
    var isFilterOpen = false
    var isChat = false
    var chattedUser: [jobsAdded]?
    var selectedIndex = 0
    var selectedIndexPath = 0
    var selectIndexPsthForChat = 0

    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //MARK:- Default Methods
    override func viewDidLoad(){
        super.viewDidLoad()
        lblNoNearByJobsFilterCrafterSide.isHidden = true
        APPDELEGATE?.isfromChat()
        self.setNeedsStatusBarAppearanceUpdate()
        self.serviceListData = (APPDELEGATE?.serviceListData)!
        
        CrafterCategoryViewBottom.constant = -700
        self.crafterCollectionCategoy.reloadData()
        
        if APPDELEGATE!.selectedUserType == .Client
        {
            self.isClient = "Client"
        }
        else
        {
            self.isClient = "Crafter"
        }
        let nib = UINib.init(nibName: "CellWorkHistory", bundle: nil)
        self.tblWorkHistory.register(nib, forCellReuseIdentifier: "CellWorkHistory")
        self.tblWorkHistory.isHidden = true
        
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
        
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        imgMenu.tintColorDidChange()
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil)
    {
        if self.isFilterOpen == true
        {
            self.isFilterOpen = false            
            hideShowCategoryViewCrafter(bottom: -700)
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
    {
        print(touch.view!)
        if (touch.view? .isDescendant(of: self.tblWorkHistory))! || (touch.view? .isDescendant(of: self.crafterCollectionCategoy))!
        {
            return false
        }
        return true
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        isChat = false
        if APPDELEGATE!.SelectedLocationAddress == "" {
            APPDELEGATE!.SelectedLocationAddress = APPDELEGATE?.CurrentLocationAddress ?? ""
            APPDELEGATE?.SelectedLocationLong = APPDELEGATE?.CurrentLocationLong ?? 0.00
            APPDELEGATE?.SelectedLocationLat = APPDELEGATE?.CurrentLocationLat ?? 0.00
        }

        if APPDELEGATE!.selectedUserType == .Crafter && selectedType == "0"{
            self.getJobListAPICallForCrafter(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00)
        }else{
            self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
        }
        
    }
    
    func dropShadow(view: UIView,color: UIColor, opacity: Float = 0.2, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
    }
    
    func hideShowCategoryViewCrafter(bottom: CGFloat)
    {
        self.CrafterCategoryViewBottom.constant = bottom
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK :- Button Actions
    
    @IBAction func btnCrafterFilter(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        selectedServiceIds = arrSelectedIds.componentsJoined(by: ",")
        if APPDELEGATE!.selectedUserType == .Crafter &&  self.selectedType == "0"{
            self.getJobListAPICallForCrafter(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00)
        }else{
            self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
        }
    }
    
    @IBAction func btnHideCrafterFilter(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
    }
    
    @IBAction func btnMenuAction(_ sender: UIButton)
    {
        APPDELEGATE?.presentSideMenu(viewController: self)
        hideShowCategoryViewCrafter(bottom: -700)
    }
    
    //show filter action
    //MARK :- Button Actions
    @IBAction func btnFilterOpenAction(_ sender: UIButton)
    {
        if self.CrafterCategoryViewBottom.constant == 30{
            hideShowCategoryViewCrafter(bottom: -700)
        }else{
            hideShowCategoryViewCrafter(bottom: 30)
            self.isFilterOpen = true
        }
    }
    
    @IBAction func btnPendingTapped(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        sender.setTitleColor(UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0), for: .normal)
        self.btnInprocess.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.btnComplete.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.lblSegment.frame.origin.x = self.btnPending.frame.origin.x + 25
        self.tag = 0
        selectedType = "0"
        if APPDELEGATE!.selectedUserType == .Crafter{
            self.getJobListAPICallForCrafter(serviceId: self.selectedServiceIds,lat: APPDELEGATE?.SelectedLocationLat ?? 0.00, long: APPDELEGATE?.SelectedLocationLong  ?? 0.00)
        }else{
            self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
        }
    }
    @IBAction func btnInprocessTapped(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        sender.setTitleColor(UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0), for: .normal)
        self.btnPending.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.btnComplete.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.lblSegment.frame.origin.x = self.btnInprocess.frame.origin.x + 25
        self.tag = 1
        selectedType = "2"
        self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
    }
    
    @IBAction func btnCompleteTapped(_ sender: UIButton)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        sender.setTitleColor(UIColor(red: 0, green: 243/255, blue: 145/255, alpha: 1.0), for: .normal)
        self.btnPending.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.btnInprocess.titleLabel?.textColor = UIColor(red: 168/255, green: 185/255, blue: 208/255, alpha: 1.0)
        self.lblSegment.frame.origin.x = self.btnComplete.frame.origin.x + 25
        self.tag = 2
        selectedType = "4"
        self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
    }
    
    @IBAction func btnBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //Get Service List API Call For Crafter Pending
    func getJobListAPICallForCrafter(serviceId:String,lat:Double,long:Double) {
        
        let param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")","user_latitude":"\(lat)","user_longitude":"\(long)","distance":"45","service_ids":"\(serviceId)","booking_status":"0","is_near_by": "0","is_nearby_new_jobs":"0"]
        
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
                                
                                self.jobList = try? JSONDecoder().decode([JobHistoryData].self, from: jsonData)
                                self.tblWorkHistory.isHidden = false
                                self.tblWorkHistory.reloadData()
                            }
                            catch
                            {
                                self.jobList = nil
                                print(error.localizedDescription)
                            }
                            self.crafterCollectionCategoy.reloadData()
                        }
                        else
                        {
                            self.jobList = nil
                            self.crafterCollectionCategoy.reloadData()
                        }
                    } else
                    {
                        self.jobList = nil
                        self.crafterCollectionCategoy.reloadData()
                    }
                }else{
                    self.jobList = nil
                }
                self.crafterCollectionCategoy.reloadData()
            }
            self.getServicesCrafter()
            print(error?.localizedDescription)
        }
    }

    //Get Service List API Call
    func getJobListAPICall(serviceID:String, JobStatus:String) {
                
        var user_type = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            user_type = Client
        }
        else
        {
            user_type = Crafter
        }

        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "service_id": "\(serviceID)", "job_status": JobStatus, "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":user_type]
        
        WebService.Request.patch(url: getJobListing, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
                                
                                self.jobList = try? JSONDecoder().decode([JobHistoryData].self, from: jsonData)
                                self.tblWorkHistory.isHidden = false
                                self.tblWorkHistory.reloadData()
                            }
                            catch
                            {
                                self.jobList = nil
                                print(error.localizedDescription)
                            }
                            self.crafterCollectionCategoy.reloadData()
                        }
                        else
                        {
                            self.jobList = nil
                            self.crafterCollectionCategoy.reloadData()
                        }
                    } else
                    {
                        self.jobList = nil
                        self.crafterCollectionCategoy.reloadData()
                    }
                }else{
                    self.jobList = nil
                }
                self.crafterCollectionCategoy.reloadData()
            }
            self.getServicesCrafter()
        }
    }
    
    //MARK:- Delete API
    func DeleteJobAPI(_ loginuser_id:String,session_token:String,job_id:String,index: NSInteger)
    {
        var user_type = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            user_type = Client
        }
        else
        {
            user_type = Crafter
        }
        let params = ["loginuser_id": loginuser_id, "session_token": session_token, "job_id":job_id,"user_type":user_type]
        WebService.Request.patch(url: deleteJob, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                self.getJobListAPICall(serviceID:self.selectedServiceIds, JobStatus:self.selectedType)
                    self.crafterCollectionCategoy.reloadData()
                }
                else
                {
                        
                }
            }
        }
    }
    
    //
    @objc func DeleteTapped(_ sender: UIButton)
    {
        print(sender.tag)
        selectIndexPsthForChat = sender.tag
        let U_id = "\(APPDELEGATE?.uerdetail?.user_id ?? "")"
        let Session =  "\(APPDELEGATE?.uerdetail?.session_token ?? "")"
        let job_id = jobList?[sender.tag]._id!
        if jobList?[sender.tag].is_delete == "1"{
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure to delete this job?", completion: { (status) in
                if status{
                    self.getjobAllFirebase(myId: "\(APPDELEGATE?.uerdetail?._id ?? "")", jobId: "\(self.jobList?[sender.tag]._id ?? "")", fromQue: false, jobData: (self.jobList?[sender.tag])!)
                    self.DeleteJobAPI(U_id, session_token: Session, job_id: job_id!,index: sender.tag)
                }else{
                }
            })
        }
        else if jobList?[sender.tag].is_archive != "1"{
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure to archive this job? Archived jobs can’t be activate again", completion: { (status) in
                if status{
                    self.getjobAllFirebase(myId: "\(APPDELEGATE?.uerdetail?._id ?? "")", jobId: "\(self.jobList?[sender.tag]._id ?? "")", fromQue: false, jobData: (self.jobList?[sender.tag])!)
                    self.DeleteJobAPI(U_id, session_token: Session, job_id: job_id!,index: sender.tag)
                }else{
                }
            })
        }
    }
    
    @objc func EditChatTapped(_ sender: UIButton)
    {
        selectedIndex = sender.tag
        if self.tag == 0
        {
            let objJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
            objJobDetailsVC.isEdit = true
            objJobDetailsVC.StatusType = self.selectedType
            objJobDetailsVC.jobList = self.jobList?[sender.tag]
            self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
        }
        else
        {
            selectedIndexpath = sender.tag
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            isChat = true
            getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? "")", jobId: "\(jobList?[sender.tag]._id ?? "")", fromQue: false)
        }
        
        print(sender.tag)
        
    }
    
    @objc func JobIconTapped(_ sender: UIButton)
    {
        selectedIndex = sender.tag
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
    
    @objc func ProfileTapped(_ sender: UIButton)
    {
        selectedIndex = sender.tag
        if jobList?[sender.tag].is_block == "0"
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                print(sender.tag)
                let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 1
                objProfileVC.strTag = "Client"
                objProfileVC.CrafterId = jobList?[sender.tag].client_id ?? ""
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
            else
            {
                print(sender.tag)
                let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 2
                objProfileVC.strTag = "Crafter"
                objProfileVC.CrafterId = jobList?[sender.tag].handyman_id ?? ""
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }
        else
        {
            
        }
    }
}

extension JobHistory: UITableViewDelegate, UITableViewDataSource
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellWorkHistory", for: indexPath) as! CellWorkHistory
        cell.viewInprogress.isHidden = true

        cell.btnDelete.tag = indexPath.row
        cell.btnEditChat.tag = indexPath.row
        cell.btnJobIcon.tag = indexPath.row
        cell.btnProfile.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.DeleteTapped(_:)), for: .touchUpInside)
        cell.btnEditChat.addTarget(self, action: #selector(self.EditChatTapped(_:)), for: .touchUpInside)
        cell.btnJobIcon.addTarget(self, action: #selector(self.JobIconTapped(_:)), for: .touchUpInside)
        cell.btnProfile.addTarget(self, action: #selector(self.ProfileTapped(_:)), for: .touchUpInside)
        
        let imgURL = URL(string: jobList?[indexPath.row].service_image ?? "")
        cell.imgService.kf.setImage(with: imgURL, placeholder: nil)
        cell.Arrimg = jobList?[indexPath.row].media ?? []
        cell.pageController.numberOfPages = jobList?[indexPath.row].media.count ?? 0
        //
        cell.blockPreview = {
            APPDELEGATE?.jobDetailImages = []
            for item in self.jobList?[indexPath.row].media ?? []{
                APPDELEGATE?.jobDetailImages.append(item)
            }
            self.selectedIndex = indexPath.row
            if self.jobList?[indexPath.row].media.count ?? 0 > 0{
                let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
                objCustomiseProfileVC.arrImages = self.jobList?[indexPath.row].media
                objCustomiseProfileVC.OpenFrom = "detail"
                objCustomiseProfileVC.blockCancel = {
               
                }
                objCustomiseProfileVC.modalPresentationStyle = .fullScreen
                self.present(objCustomiseProfileVC, animated: true, completion: nil)
            }
        }
        //
        if self.isClient == "Client"
        {
            if self.jobList?[indexPath.row].full_name == nil || self.jobList?[indexPath.row].full_name == ""{
                cell.lblName.text = "\(self.jobList?[indexPath.row].first_name ?? "")"
            }else{
                let nm = self.jobList?[indexPath.row].full_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: self.jobList?[indexPath.row].full_name ?? "")
                if tempName.count >= 2{
                    cell.lblName.text = "\(UName)."
                }else{
                    cell.lblName.text = "\(UName)"
                }
            }
            
            cell.lblLocation.text = jobList?[indexPath.row].address
            cell.lblPrice.text = "£ \(jobList?[indexPath.row].booking_amount ?? "0.0")"
            //
            if self.jobList?[indexPath.row].is_emergency_job == 1
            {
                let str = jobList?[indexPath.row].description ?? ""
                let trimmedString = str.trimmingCharacters(in: .whitespaces)
                let myString = "Emergency! " + " \(trimmedString)"
                cell.lblDescInProgress.attributedText = myString.SetAttributed(location: 0, length: 10, font: "Cabin-Regular", size: 15.0)
                cell.lblInprogressDesc.attributedText = myString.SetAttributed(location: 0, length: 10, font: "Cabin-Regular", size: 15.0)
            }
            else
            {
                cell.lblDescInProgress.text = jobList?[indexPath.row].description
                cell.lblInprogressDesc.text = jobList?[indexPath.row].description
            }
            //
            
            var rate = jobList?[indexPath.row].job_review
            let rate1 = rate?.removeFirst()
            
            cell.lblRate.text = "\(rate1 ?? "0").0"
            if cell.lblRate.text == "0.0" || cell.lblRate.text == "" || cell.lblRate.text == "0"{
                cell.lblRate.text = "NEW"
            }
            
            let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            if rate1 == "0"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = UIColor.white
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = UIColor.white
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "1"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = UIColor.white
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "2"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "3"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "4"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "5"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = APPDELEGATE?.appGreenColor
                
            }
            let imgURL = URL(string: jobList?[indexPath.row].profile_image ?? "")
            cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            if self.tag == 0
            {
                cell.viewProfile.isHidden = true
                let img = UIImage(named: "edit")
                cell.btnEditChat.setImage(img, for: .normal)
                cell.btnEditChat.isHidden = false
                cell.btnDelete.isHidden = false
            }
            else if self.tag == 1
            {
                cell.viewreview.isHidden = false
                cell.heightReview.constant = 19
                cell.viewProfile.isHidden = false
                let img = UIImage(named: "chat")
                cell.btnEditChat.setImage(img, for: .normal)
                cell.btnEditChat.isHidden = false
                cell.viewInprogress.isHidden = false
                cell.btnDelete.isHidden = true
            }
            else if self.tag == 2
            {
                cell.viewreview.isHidden = false
                cell.heightReview.constant = 19

                cell.viewProfile.isHidden = false
                let img = UIImage(named: "chat")
                cell.btnEditChat.setImage(img, for: .normal)
                //cell.lblPrice.text = "£240"
                cell.viewInprogress.isHidden = false
                if (jobList?[indexPath.row].reported_client == 1 || jobList?[indexPath.row].reported_handyman == 1) && jobList?[indexPath.row].is_block == "0"{
                    cell.btnEditChat.isHidden = false
                }else{
                    cell.btnEditChat.isHidden = true
                }
                cell.btnDelete.isHidden = true
            }
        }
        else
        {
            if self.jobList?[indexPath.row].full_name == nil || self.jobList?[indexPath.row].full_name == ""{
                cell.lblName.text = "\(self.jobList?[indexPath.row].first_name ?? "")"
            }else{
                let nm = self.jobList?[indexPath.row].full_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: self.jobList?[indexPath.row].full_name ?? "")
                if tempName.count >= 2{
                    cell.lblName.text = "\(UName)."
                }else{
                    cell.lblName.text = "\(UName)"
                }
            }
            
            cell.lblLocation.text = jobList?[indexPath.row].address
            
            cell.lblPrice.text = "£ \(jobList?[indexPath.row].booking_amount ?? "0.0")"
            //
            if self.jobList?[indexPath.row].is_emergency_job == 1
            {
                let str = jobList?[indexPath.row].description ?? ""
                let trimmedString = str.trimmingCharacters(in: .whitespaces)
                let myString = "Emergency! " + " \(trimmedString)"
                cell.lblDescInProgress.attributedText = myString.SetAttributed(location: 0, length: 10, font: "Cabin-Regular", size: 15.0)
                cell.lblInprogressDesc.attributedText = myString.SetAttributed(location: 0, length: 10, font: "Cabin-Regular", size: 15.0)
                
            }
            else
            {
                cell.lblDescInProgress.text = jobList?[indexPath.row].description
                cell.lblInprogressDesc.text = jobList?[indexPath.row].description
            }
            //
            
            var rate = jobList?[indexPath.row].job_review
            let rate1 = rate?.removeFirst()
            
            cell.lblRate.text = "\(rate1 ?? "0").0"
            if cell.lblRate.text == "0.0" || cell.lblRate.text == "" || cell.lblRate.text == "0"{
                cell.lblRate.text = "NEW"
            }

            let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
            if rate1 == "0"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = UIColor.white
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = UIColor.white
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "1"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = UIColor.white
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "2"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = UIColor.white
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "3"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = UIColor.white
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "4"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = UIColor.white
            }
            else if rate1 == "5"
            {
                cell.imgRate1.image = starImg
                cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate2.image = starImg
                cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate3.image = starImg
                cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate4.image = starImg
                cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
                cell.imgRate5.image = starImg
                cell.imgRate5.tintColor = APPDELEGATE?.appGreenColor
            }
            
            let imgURL = URL(string: jobList?[indexPath.row].profile_image ?? "")
            cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            cell.btnDelete.isHidden = true
            cell.viewreview.isHidden = true
            cell.heightReview.constant = 0

            if self.tag == 0
            {
                cell.viewProfile.isHidden = true
                let img = UIImage(named: "edit")
                cell.btnEditChat.setImage(img, for: .normal)
                //cell.lblPrice.text = ""
                cell.btnEditChat.isHidden = true
            }
            else if self.tag == 1
            {
                cell.viewreview.isHidden = false
                cell.heightReview.constant = 19

                cell.viewProfile.isHidden = false
                let img = UIImage(named: "chat")
                cell.btnEditChat.setImage(img, for: .normal)
                //cell.lblPrice.text = "£240"
                cell.btnEditChat.isHidden = false
                cell.viewInprogress.isHidden = false
            }
            else if self.tag == 2
            {
                cell.viewreview.isHidden = false
                cell.heightReview.constant = 19

                cell.viewProfile.isHidden = false
                let img = UIImage(named: "chat")
                cell.btnEditChat.setImage(img, for: .normal)
                //cell.lblPrice.text = "£240"
                cell.btnEditChat.isHidden = false
                cell.viewInprogress.isHidden = false
                if (jobList?[indexPath.row].reported_client == 1 || jobList?[indexPath.row].reported_handyman == 1) && jobList?[indexPath.row].is_block == "0"{
                    cell.btnEditChat.isHidden = false
                }else{
                    cell.btnEditChat.isHidden = true
                }
            }
        }
        
        if self.jobList?[indexPath.row].is_archive == "1" || (self.jobList?[indexPath.row].cancellation_status == "1" && self.jobList?[indexPath.row].cancelled_user_type == "1") || self.jobList?[indexPath.row].cancellation_status == "2"{
            cell.lblInactivated.isHidden = false
            cell.lblInactivated.text = "Client cancelled this job."
            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewMain.layer.borderWidth = 2.0
            cell.btnEditChat.isHidden = true
        }else if self.jobList?[indexPath.row].cancellation_status == "1" && self.jobList?[indexPath.row].cancelled_user_type == "2"{
            cell.lblInactivated.isHidden = false
            cell.lblInactivated.text = "Crafter cancelled this job."
            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewMain.layer.borderWidth = 2.0
            cell.btnEditChat.isHidden = true
        }else if self.jobList?[indexPath.row].cancellation_status == "3"{
            cell.lblInactivated.isHidden = false
            // if resolve 1 then Canceled by agreement else as it is
            if self.jobList?[indexPath.row].is_resolved == "1"
            {
                cell.lblInactivated.text = "Canceled by agreement."
            }else{
                cell.lblInactivated.text = "Job is under dispute."
            }
            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewMain.layer.borderWidth = 2.0
            cell.btnEditChat.isHidden = true
        }else{
            cell.lblInactivated.isHidden = true
            cell.viewMain.layer.borderColor = UIColor.clear.cgColor
            cell.viewMain.layer.borderWidth = 0.0
            if self.tag == 0{
                if appDelegate.selectedUserType == .Crafter{
                    cell.btnEditChat.isHidden = true
                }else{
                    cell.btnEditChat.isHidden = false
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        hideShowCategoryViewCrafter(bottom: -700)
        self.selectedIndex = indexPath.row
        self.selectedIndexPath = indexPath.row
        if self.tag == 2
        {
            if (self.jobList?[indexPath.row].cancellation_status == "0" || self.jobList?[indexPath.row].cancellation_status == "") && (self.jobList?[indexPath.row].is_archive == "" || self.jobList?[indexPath.row].is_archive == "0"){
                let objCompletedJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
                objCompletedJobDetailsVC.jobList = self.jobList?[indexPath.row]
                self.navigationController?.pushViewController(objCompletedJobDetailsVC, animated: true)
            }else{
                let objJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                objJobDetailsVC.isEdit = false
                objJobDetailsVC.jobList = self.jobList?[indexPath.row]
                objJobDetailsVC.StatusType = "10"
                objJobDetailsVC.isInProcess = true
                self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
            }
        }
        else if self.tag == 1{
            let objJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
            objJobDetailsVC.isEdit = false
            objJobDetailsVC.jobList = self.jobList?[indexPath.row]
            objJobDetailsVC.StatusType = "10"
            objJobDetailsVC.isInProcess = true
            self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
        }else{
            let objJobDetailsVC = self.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
            objJobDetailsVC.isEdit = false
            objJobDetailsVC.jobList = self.jobList?[indexPath.row]
            objJobDetailsVC.StatusType = "0"
            self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
        }
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

extension JobHistory : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {       
        return serviceListData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imgURL = URL(string: serviceListData[indexPath.row]["service_image"] as? String ?? "")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCollectionViewCell", for: indexPath) as! CategoryCollectionViewCell
        cell.imgCategory.kf.setImage(with: imgURL, placeholder: nil)
        cell.lblCategoryName.text = serviceListData[indexPath.row]["name"] as? String
        if arrSelectedIds.contains(serviceListData[indexPath.row]["_id"] as! String){
            cell.imgSelected.isHidden = false
        }else{
            cell.imgSelected.isHidden = true
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
            crafterCollectionCategoy.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath)
    {
    }
}

//MARK:- Firebase
extension JobHistory{
    
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
                    self.crafterCollectionCategoy.reloadData()
                }
            }
            if serviceIds == ""{
                self.serviceListData = []
                APPDELEGATE!.serviceListData = self.serviceListData
                self.crafterCollectionCategoy.reloadData()
            }
            if self.serviceListData.count > 0{
                self.btnFilterCrafter.isHidden = false
                self.lblNoNearByJobsFilterCrafterSide.isHidden = true
                self.crafterCollectionCategoy.isHidden = false
            }else{
                self.btnFilterCrafter.isHidden = true
                self.lblNoNearByJobsFilterCrafterSide.isHidden = false
                self.crafterCollectionCategoy.isHidden = true
            }
        }
    }
    

    func getjobListingAll(myId:String,jobId:String,fromQue:Bool){
        APPDELEGATE?.addProgressView()
        var isLoad = true
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                if data != nil{
                    let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                    
                    var isAvail = false
                    var jobDetail:jobsAdded?
                    if conversion == nil{
                        return
                    }
                    for item in conversion ?? [] {

                        if item.jobdetailID == self.jobList?[self.selectedIndexpath]._id && item.job_id == "\(self.jobList?[self.selectedIndexpath]._id ?? "")\(self.jobList?[self.selectedIndexpath].handyman_id ?? "")"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    if isAvail {
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,fromQue:fromQue)
                    }
                }
            }else{
                let conversationId = fourDigitNumber
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                    self.addJobDetail(userId: "\(self.jobList?[self.selectedIndexpath].client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                }else if APPDELEGATE?.selectedUserType == .Client{
                    self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                    self.addJobDetail(userId: "\(self.jobList?[self.selectedIndexpath].handyman_id ?? "")",conversationId:conversationId, chat_option_status: "1")
                }
            }
            if isLoad{
                APPDELEGATE?.hideProgrssVoew()
                isLoad = false
            }
        }
    }
    
    func addJobDetail(userId:String,conversationId:String,chat_option_status:String){
        if APPDELEGATE?.selectedUserType == .Crafter{
            self.addJobs(userId: userId, jobId: "\(self.jobList?[self.selectedIndexpath]._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?[self.selectedIndexpath].client_id ?? "")")
        }else if APPDELEGATE?.selectedUserType == .Client{
            self.addJobs(userId: userId, jobId: "\(self.jobList?[self.selectedIndexpath]._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?[self.selectedIndexpath].client_id ?? "")")
        }
    }
    
    //Add Job
    func addJobs(userId:String,jobId:String,conversationId:String,chat_option_status:String,CrafterId:String,ClientID:String){
        let jobid = jobId + CrafterId
        let param = ["job_id":jobid,"lastmessage":"","lastmessagetime":"\(Date())","conversationId":"\(conversationId)","unreadMessageCount":0,"timeinterval":"\(getTimeInterval())","chat_option_status":"\(chat_option_status)","jobprice":"0", "isRead":"0","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))","CrafterId":CrafterId,"ClientId":ClientID,"service_image":"\(jobList?[self.selectedIndexpath].service_image ?? "no image")","service_description":"\(jobList?[self.selectedIndexpath].description ?? "")","jobdetailID":jobId] as [String : Any]
        FirebaseJobAPICall.firebaseAddJobs(myId: userId, jobId: jobid, jobDetail: param) { (status, error, data) in
            if status{
                print("Job added to Firebase")
            }
        }
    }
    
    func redirecttoChat(conversationId:String,jobId:String,chat_option_status:String,jobdetail:jobsAdded,fromQue:Bool){
        if isChat{
            isChat = false
            if (APPDELEGATE?.isChatViewcontroller)!{
                return
            }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
            APPDELEGATE?.isChatViewcontroller = true
            messages?.conversationId = conversationId
            messages?.jobId = jobId
            messages?.chat_option_status = chat_option_status
            messages?.service_image = jobList?[selectedIndexpath].service_image ?? ""
            messages?.profile_image = jobList?[selectedIndexpath].profile_image ?? ""
            messages?.fullname = jobList?[selectedIndexpath].full_name ?? ""
            messages?.CrafterID = jobList?[selectedIndexpath].handyman_id ?? ""
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            if fromQue{
                messages?.isOpenFromQue = true
            }
            self.navigationController?.pushViewController(messages!, animated: true)
        }
    }
    
    func getjobAllFirebase(myId:String,jobId:String,fromQue:Bool,jobData: JobHistoryData){
        var isUpdated = false
        APPDELEGATE?.addProgressView()
        var isLoad = true
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                if data != nil{
                    let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                    
                    var isAvail = false
                    var jobDetail:jobsAdded?
                    if conversion == nil{
                        return
                    }
                    self.chattedUser?.removeAll()
                    if !isUpdated{
                        isUpdated = true
                        for item in conversion ?? [] {
                            if item.jobdetailID == self.jobList?[self.selectedIndexpath]._id{
                                self.chattedUser?.append(item)
                                self.sendmessage(message: "Client cancelled the job.", sendNotif: true, IsSystemMessage: "1", userdata: item, jobsData: jobData)
                            }
                        }
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
    
    
    func sendmessage(message:String,sendNotif:Bool,isOnlyDisplayOnClientSide: String = "0", isCancelStatus: String = "0", cancelUserID: String = "0" ,IsSystemMessage: String = "0", userdata: jobsAdded, jobsData: JobHistoryData){
        let messageId = fourDigitNumber
        let timeinterval = getTimeInterval()
        let date = Date()
        var senderID = APPDELEGATE?.uerdetail?.user_id ?? ""
        let params = ["message":"\(message)","messageTime":"\(date)","senderId":senderID,"isRead":"\(0)","conversationId":userdata.conversationId,"messageid":"\(messageId)","timeinterval":"\(timeinterval)","isOnlyDisplayOnClientSide": isOnlyDisplayOnClientSide, "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? "", "isSystemMessage": IsSystemMessage]

        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: params, options: []) as AnyObject
            let data = try? JSONDecoder().decode(firebaseMessage.self, from: jsonObject as! Data)
            apiCallSendChatToServer(messageData: params as [String : Any], Crafter_id: userdata.CrafterId ?? "", job_id: jobsData.job_id ?? "", client_id: userdata.ClientId ?? "", message: data!)
        } catch  {
        }

        FirebaseAPICall.firebaseSendMessage(conversationId: userdata.conversationId ?? "", messageId: messageId, messsageDetail: params as [String : Any]) { (status, error, data) in
            if status{
                //Update user detail to Firebase
                self.addtoFirebase(conversationId: userdata.conversationId ?? "", userId: APPDELEGATE?.uerdetail?._id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID, jobChatID: userdata.job_id ?? "")
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addtoFirebase(conversationId: userdata.conversationId ?? "", userId: userdata.ClientId ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID, jobChatID: userdata.job_id ?? "")
                }else{
                    self.addtoFirebase(conversationId: userdata.conversationId ?? "", userId: userdata.CrafterId ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID, jobChatID: userdata.job_id ?? "")
                }
                
                //Update Last message read or not
                self.UpdateIsMessageReadOrNot(UserId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", isRead: "0", jobChatID: userdata.job_id ?? "")
                
                //Update  message count
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.updateMessageCounttojob(unreadMessageCountcount: userdata.unreadMessageCount ?? 0, userId: jobsData.client_id ?? "", jobChatID: userdata.job_id ?? "")
                }else{
                    self.updateMessageCounttojob(unreadMessageCountcount: userdata.unreadMessageCount ?? 0, userId: jobsData.handyman_id ?? "", jobChatID: userdata.job_id ?? "")
                }
            }
        }
    }
    
    func apiCallSendChatToServer(messageData: [String:Any],Crafter_id: String, job_id: String,client_id: String, message: firebaseMessage){
        var param = messageData
        param["job_id"] = job_id
        param["handyman_id"] = Crafter_id
        param["client_id"] = client_id
        
        WebService.Request.patch(url: saveChatData, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if (response!["data"] as? [String: Any]) != nil{
                    
                }
            }
        }
    }

    func addtoFirebase(conversationId:String,userId:String,timeinterval:String,time:Date,message:String, isCancelStatus: String = "0", cancelUserID: String = "0", jobChatID: String){
        
        let param = ["lastmessage":"\(message)","lastmessagetime":"\(time)","timeinterval":"\(timeinterval)","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? ""] as [String : Any]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userId, jobId: jobChatID, ChatuserDetail: param, completion:{ (status) in
            if status{
                
            }
        })
    }
    
    func UpdateIsMessageReadOrNot(UserId:String,isRead:String, jobChatID: String){
        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: jobChatID, detail: param, completion: { (status) in
            
        })
    }
    
    func updateMessageCounttojob(unreadMessageCountcount:Int,userId:String, jobChatID: String){
        let unreadMessageCount = unreadMessageCountcount + 1
        let param = ["unreadMessageCount":unreadMessageCount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobChatID, detail: param, completion: { (status) in
            
        })
    }
}

