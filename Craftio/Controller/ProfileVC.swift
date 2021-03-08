
import UIKit

class ProfileVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblReview: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var btnCrafterChat: UIButton!
    @IBOutlet weak var btnCrafterRehire: UIButton!
    @IBOutlet weak var tblHeight: NSLayoutConstraint!
    @IBOutlet weak var lblJobsCount: UILabel!
    @IBOutlet weak var lblratingCount: UILabel!
    @IBOutlet weak var lblContent: UILabel!
    @IBOutlet weak var lblRemaining: UILabel!
    @IBOutlet weak var viewCongratulations: UIView!
    @IBOutlet weak var heightViewCongratulations: NSLayoutConstraint!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var JobTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!

    @IBOutlet weak var viewMainRehire: UIView!
    @IBOutlet weak var viewSubRehire: UIView!
    
    @IBOutlet weak var viewProblemMainRehire: UIView!
    @IBOutlet weak var viewProblemSubRehire: UIView!
    @IBOutlet weak var lblJobTitleRehire: UILabel!
    @IBOutlet weak var lblNoanyReview: UILabel!
    
    @IBOutlet weak var imgRate1: UIImageView!
    @IBOutlet weak var imgRate2: UIImageView!
    @IBOutlet weak var imgRate3: UIImageView!
    @IBOutlet weak var imgRate4: UIImageView!
    @IBOutlet weak var imgRate5: UIImageView!
    
    var strTag = String()
    var arrLiked = NSMutableArray()
    var arrlikeCount = NSMutableArray()
    var user_type = Int()
    var CrafterId = String()
    var isfromClient = Bool()
    var profile: UserData?
    
    var ProfileViewTag = Int()
    var SelectjobList: JobHistoryData?
    var isRehire = Bool()
    
    var isFromSideMenu = false
    var isRehireGo = false
    var timer = Timer()
    var int = 0
    var lastLikeindex = 0
    var reviewCount = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        self.tblReview.sizeToFit()
        onLoadOperations()
        
        if APPDELEGATE!.selectedUserType == .Crafter && self.ProfileViewTag == 1
        {
            self.lblTitle.text = "My profile"
            self.btnCrafterChat.isHidden = false
        }
        else if APPDELEGATE!.selectedUserType == .Client && self.ProfileViewTag == 2
        {
            self.lblTitle.text = "My profile"
            self.btnCrafterChat.isHidden = false
        }
        else
        {
            self.lblTitle.text = ""
            self.btnCrafterChat.isHidden = true
        }
        
        if (APPDELEGATE!.selectedUserType == .Crafter && self.user_type == 2) || self.strTag == "Crafter"
        {
            if self.strTag == "Crafter" && self.isfromClient ==  true
            {
                self.btnCrafterChat.isHidden = true
                self.btnCrafterRehire.isHidden = false
                self.isRehire = true
            }
            else
            {
                self.btnCrafterRehire.isHidden = true
                self.isRehire = false
            }
            
            //self.lblTitle.text = "My profile"
            self.lblJobTitle.text = ""//Plumber"
            self.lblCount.text = "Jobs completed"
            self.lblReview.text = "Client reviews"
            self.lblRating.text = "Completion Rate"
        }
        else if (APPDELEGATE!.selectedUserType == .Client && self.user_type == 1) || self.strTag == "Client"
        {
            self.btnCrafterRehire.isHidden = true
            //self.lblTitle.text = "My profile"
            self.lblJobTitle.text = ""
            self.JobTitleHeight.constant = 0
            self.lblCount.text = "Work requests"
            self.lblReview.text = "Reviews"
            self.lblRating.text = "Rating"
            self.isRehire = false
        }
        
        lblNoanyReview.isHidden = true
        self.setUpDetail()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
        APPDELEGATE?.isProfileOpen = false
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "reloadProfile"), object: nil)
    }

    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    func onLoadOperations()
    {
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.viewSubRehire.frame
        rectShape2.position = self.viewSubRehire.center
        let frame2 = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewSubRehire.bounds.size.height)
        rectShape2.path = UIBezierPath(roundedRect: frame2, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewSubRehire.layer.mask = rectShape2
        
        let rectShape3 = CAShapeLayer()
        rectShape3.bounds = self.viewProblemSubRehire.frame
        rectShape3.position = self.viewProblemSubRehire.center
        let frame3 = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewProblemSubRehire.bounds.size.height)
        rectShape3.path = UIBezierPath(roundedRect: frame3, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewProblemSubRehire.layer.mask = rectShape3
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.incereaseChatCounter(notification:)), name: NSNotification.Name(rawValue: "updateCounter"), object: nil)
    }
    
    @objc func updateTimer() {
        if int == 0{
            getProfileDetails(callSilently: true)
        }else{
            getProfileDetails(callSilently: true)
        }
        int += 1
    }

    @objc func incereaseChatCounter(notification: NSNotification){
        let data = notification.userInfo as? [String:Any]
        if (data?["user_id"] as? String != nil) == (((APPDELEGATE?.uerdetail?._id) != nil) || ((APPDELEGATE?.uerdetail?.user_id) != nil)){
            if profile?.reviews?.count ?? 0 > 0{
                var index = 0
                for item in profile!.reviews!{
                    var itemget = item
                    if data?["_id"] as? String == itemget._id{
                        itemget.total_like = "\(NSInteger(item.total_like!)! + 1)"
                    }
                    profile?.reviews?[index] = itemget
                    index += 1
                }
            }
            self.tblReview.reloadData()
        }
    }
    
    
    @objc func reloadProfile() {
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        getProfileDetails(callSilently: false)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadProfile), name: NSNotification.Name(rawValue: "reloadProfile"), object: nil)

        APPDELEGATE?.isProfileOpen = true
        timer = Timer.scheduledTimer(timeInterval: 2, target: self,   selector: (#selector(updateTimer)), userInfo: nil, repeats: true)

        self.isRehireGo = false
        
        if SelectjobList == nil
        {
            self.lblJobTitleRehire.text = "Please select a job"//"Job Title"
        }
        else
        {
            self.lblJobTitleRehire.text = SelectjobList?.service_name
        }
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton)
    {
        self.strTag = ""
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCrafterChatAction(_ sender: UIButton)
    {
        let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "CustomiseProfileVC") as! CustomiseProfileVC
        self.navigationController?.pushViewController(objCustomiseProfileVC, animated: true)
    }
    
    @IBAction func btnCrafterRehireAction(_ sender: UIButton)
    {
        self.viewMainRehire.isHidden = false
    }
    
    @IBAction func btnCrafterRehireHideAction(_ sender: UIButton)
    {
        self.viewMainRehire.isHidden = true
    }
    
    @IBAction func btnCrafterRehireYesAction(_ sender: UIButton)
    {
        self.viewMainRehire.isHidden = true
        self.viewProblemMainRehire.isHidden = false
    }
    
    @IBAction func btnProblemCrafterRehireHideAction(_ sender: UIButton)
    {
        self.viewProblemMainRehire.isHidden = true
        self.viewMainRehire.isHidden = false
    }
    
    @IBAction func btnCrafterRehireSelectJobAction(_ sender: UIButton)
    {
        let selectJobVC = self.storyboard?.instantiateViewController(withIdentifier: "SelectJobTitleVC") as! SelectJobTitleVC
        self.navigationController?.pushViewController(selectJobVC, animated: true)
    }

    
    @IBAction func btnCrafterRehireInviteAction(_ sender: UIButton)
    {
        
        self.isRehireGo = true
        
        if SelectjobList == nil || self.lblJobTitleRehire.text == "Please select a job"//"Job Title"
        {
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "For hire this crafter please select any job from the pending jobs.")
        }
        else
        {
            self.viewProblemMainRehire.isHidden = true
            self.viewMainRehire.isHidden = true
            
            if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
            {
                APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
                return
            }
            self.MakeOfferAPI()
            self.getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? "")", jobId: "\(self.SelectjobList?._id ?? "")", fromQue: false)
        }
    }
    @IBAction func btnViewLikeReview(_ sender: UIButton){
        let objList = self.storyboard?.instantiateViewController(withIdentifier: "LikeListVC") as? LikeListVC
        objList?.reviewID = self.profile?.reviews?[sender.tag]._id ?? ""
        self.navigationController?.pushViewController(objList!, animated: true)
    }

    @IBAction func btnLikeReview(_ sender: UIButton)
    {
            if self.profile?.reviews?[sender.tag].from_user_id == APPDELEGATE?.uerdetail?._id{
                return
            }else{
                if self.arrLiked[sender.tag] as? String == "1"{
                    let intlike = arrlikeCount[sender.tag] as? NSInteger
                    self.arrlikeCount.replaceObject(at: sender.tag, with: (intlike ?? 1) - 1)
                    self.arrLiked.replaceObject(at: sender.tag, with: "0")
                }else{
                    let intlike = arrlikeCount[sender.tag] as? NSInteger
                    self.arrlikeCount.replaceObject(at: sender.tag, with: (intlike ?? 0) + 1)
                    self.arrLiked.replaceObject(at: sender.tag, with: "1")
                }
                tblReview.reloadRows(at: [IndexPath (row: sender.tag, section: 0)], with: .none)
                self.viewWillLayoutSubviews()
                var userID = String()
                if self.profile?.reviews?[sender.tag].to_user_id == APPDELEGATE?.uerdetail?._id {
                    userID = self.profile?.reviews?[sender.tag].from_user_id ?? ""
                }else if self.profile?.reviews?[sender.tag].from_user_id == APPDELEGATE?.uerdetail?._id{
                    userID = self.profile?.reviews?[sender.tag].to_user_id ?? ""
                }else{
                    userID = self.profile?.reviews?[sender.tag].to_user_id ?? ""
                }
                self.likeUserReview(reviewId: "\(self.profile?.reviews?[sender.tag]._id ?? "")", like_status: self.arrLiked[sender.tag] as? String ?? "0", likeById: "\(self.profile?.reviews?[sender.tag].from_user_id ?? "")",to_user_id:userID)
            }
    }
}

extension ProfileVC: UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrLiked.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reviewCell", for: indexPath) as? reviewCell
        
        var Uname = ""
        let nm = self.profile?.reviews?[indexPath.row].from_user_name ?? ""
        let tempName = nm.split(separator: " ")
        let UName = setUserName(name: self.profile?.reviews?[indexPath.row].from_user_name ?? "")
        if tempName.count >= 2{
            Uname = "\(UName)."
        }else{
            Uname = "\(UName)"
        }
        cell?.lblReviewBy.text = "Review by \(Uname)"
        
        cell?.lblTitle.text = self.profile?.reviews?[indexPath.row].review_message ?? ""
        cell?.btnLike.tag = indexPath.row
        cell?.btnviewLiked.tag = indexPath.row
        if self.arrLiked[indexPath.row] as? String == "1"{
            cell?.btnLike.setImage(UIImage (named: "heartFill"), for: .normal)
        }else{
            cell?.btnLike.setImage(UIImage (named: "heart"), for: .normal)
        }
        if self.arrlikeCount[indexPath.row] as? NSInteger == 0{
            cell?.lblLikeCount.text = ""
        }else{
            cell?.lblLikeCount.text = "\(self.arrlikeCount[indexPath.row] as? NSInteger ?? 0)"
        }
        self.viewWillLayoutSubviews()
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}

extension ProfileVC
{
    func setUpDetail()  {
        if APPDELEGATE!.selectedUserType == .Client && self.ProfileViewTag == 2{
            heightViewCongratulations.constant = 0
            viewCongratulations.isHidden = true
        }else if APPDELEGATE!.selectedUserType == .Crafter && self.ProfileViewTag == 1{
            if self.profile?.remainingQuote == "" || self.profile?.remainingQuote == "0" || self.profile?.remainingQuote?.count == 0{
                heightViewCongratulations.constant = 0
                viewCongratulations.isHidden = true
            }else{
                if (self.profile?.quoteQty == "" || self.profile?.quoteQty == "0" || self.profile?.quoteQty?.count == 0) && (self.profile?.quoteExpireDate != "" ||  self.profile?.quoteExpireDate?.count != 0){
                    self.lblContent.text = "Your account qualifies to send unlimited fee-free quotes to jobs until \(self.profile?.quoteExpireDate ?? "")"
                    self.lblRemaining.text = "\(self.profile?.remainingQuote ?? "")"
                }else if (self.profile?.quoteQty != "" || self.profile?.quoteQty != "0" || self.profile?.quoteQty?.count != 0) && (self.profile?.quoteExpireDate != "" ||  self.profile?.quoteExpireDate?.count != 0){
                    self.lblContent.text = "Your account qualifies to send \(self.profile?.quoteQty ?? "") fee-free quotes to jobs until \(self.profile?.quoteExpireDate ?? "")"
                    self.lblRemaining.text = "\(self.profile?.remainingQuote ?? "")"
                }else if (self.profile?.quoteQty != "" || self.profile?.quoteQty != "0" || self.profile?.quoteQty?.count != 0) && (self.profile?.quoteExpireDate == "" ||  self.profile?.quoteExpireDate?.count == 0){
                    self.lblContent.text = "Your account qualifies to send \(self.profile?.quoteQty ?? "") fee-free quotes to jobs."
                    self.lblRemaining.text = "\(self.profile?.remainingQuote ?? "")"
                }else{
                    heightViewCongratulations.constant = 0
                    viewCongratulations.isHidden = true
                }
            }
        }else{
            heightViewCongratulations.constant = 0
            viewCongratulations.isHidden = true
        }
        
        if APPDELEGATE?.uerdetail?._id == self.profile?._id{
            if (self.profile?.first_name == "") || (self.profile?.last_name == "")
            {
                self.lblName.text = "\(self.profile?.user_name ?? "")"
            }
            else
            {
                self.lblName.text = "\(self.profile?.first_name ?? "") \(self.profile?.last_name ?? "")"
            }
        }else{
            if (self.profile?.first_name == "") || (self.profile?.last_name == "")
            {
                let nm = self.profile?.user_name ?? ""
                let tempName = nm.split(separator: " ")
                let name = setUserName(name: self.profile?.user_name ?? "")
                if tempName.count >= 2{
                    self.lblName.text = "\(name)."
                }else{
                    self.lblName.text = "\(name)"
                }
            }
            else
            {
                self.lblName.text = "\(self.profile?.first_name ?? "") \(self.profile?.last_name?.first ?? " ")."
            }
        }
        
        self.lblJobTitle.text = "\(self.profile?.user_services ?? "")"
        if self.profile?.work_details ?? 0 > 0{
            self.lblJobsCount.text = "\(self.profile?.work_details ?? 0)"
        }else{
            self.lblJobsCount.text = "New"
        }
        //job_ratio
        var rate = self.profile?.total_rating
        let rate1 = rate?.removeFirst()
        
        if (APPDELEGATE!.selectedUserType == .Crafter && self.user_type == 2) || self.strTag == "Crafter"{
            if self.profile?.job_ratio == "" || self.profile?.job_ratio == "0" || self.profile?.job_ratio == "0.00"{
                self.lblratingCount.text = "New"
            }
            else{
                self.lblratingCount.text = "\(self.profile?.job_ratio ?? "0") %"
            }
        }
        else{
            if rate1 == "0"{
                self.lblratingCount.text = "New"
            }else{
                self.lblratingCount.text = "\(rate1 ?? "0").0"
            }
        }

        let imgURL = URL(string: self.profile?.profile_image ?? "")
        self.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
        
        if profile?.reviews == nil{
            lblNoanyReview.isHidden = false
        }else if profile?.reviews?.count == 0{
            lblNoanyReview.isHidden = false
        }else{
            lblNoanyReview.isHidden = true
        }
        
        let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        if rate1 == "0"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = UIColor.white
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = UIColor.white
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = UIColor.white
            self.imgRate4.image = starImg
            self.imgRate4.tintColor = UIColor.white
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "1"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = UIColor.white
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = UIColor.white
            self.imgRate4.tintColor = UIColor.white
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "2"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = UIColor.white
            self.imgRate4.image = starImg
            self.imgRate4.tintColor = UIColor.white
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "3"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate4.image = starImg
            self.imgRate4.tintColor = UIColor.white
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "4"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate4.image = starImg
            self.imgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "5"
        {
            self.imgRate1.image = starImg
            self.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate2.image = starImg
            self.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate3.image = starImg
            self.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate4.image = starImg
            self.imgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.imgRate5.image = starImg
            self.imgRate5.tintColor = APPDELEGATE?.appGreenColor
        }
        //
    }
    
    //MARK:- Call Profile API
    func getProfileDetails(callSilently: Bool)
    {
        var params = [String:String]()
        
        if self.isRehire == true
        {
            params = ["user_id": "\(self.CrafterId)", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_required":"1","user_type":Crafter,"is_own_profile": "0"]
        }
        else
        {
            if self.strTag == "Crafter" && self.user_type == 2
            {
                params = ["user_id": "\(self.CrafterId)", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_required":"1","user_type":Client,"is_own_profile": "0"]
            }
            else if self.strTag == "Client" && self.user_type == 1
            {
                params = ["user_id": "\(self.CrafterId)", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_required":"1","user_type":Crafter,"is_own_profile": "0"]
            }
            else
            {
                params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_required":"1","user_type":Client,"is_own_profile":"1"]
                if APPDELEGATE?.selectedUserType == .Crafter{
                    params["user_type"] = Crafter
                }else{
                    params["user_type"] = Client
                }
            }
        }
        WebService.Request.patch(url: getUserProfile, type: .post, parameter: params, callSilently: callSilently, header: nil) { (response, error) in
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
                                self.profile = try? JSONDecoder().decode(UserData.self, from: jsonData)

                                self.arrLiked.removeAllObjects()
                                self.arrlikeCount.removeAllObjects()
                                for item in self.profile?.reviews ?? []{
                                    self.arrlikeCount.add(NSInteger((item.total_like ?? "0")) ?? 0)
                                    self.arrLiked.add(item.is_like ?? "0")
                                }
                                self.setUpDetail()
                                self.tblReview.reloadData()
                                if self.reviewCount < self.arrLiked.count{
                                    self.reviewCount = self.arrLiked.count
                                    self.view.layoutIfNeeded()
                                    self.view.updateConstraintsIfNeeded()
                                    self.tblHeight.constant = self.tblReview.contentSize.height + 20
                                }
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
            }
        }
    }
    
    //Like Review
    func likeUserReview(reviewId:String,like_status:String,likeById:String,to_user_id:String)
    {
        var params = [String:String]()
        params = ["like_by": "\(APPDELEGATE?.uerdetail?._id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_id":"\(reviewId)","like_status":"\(like_status)","to_user_id":to_user_id]
        WebService.Request.patch(url: giveReviewLike, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
}

//MARK:- Firebase
extension ProfileVC{
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
                        

                        if item.jobdetailID == self.SelectjobList?._id && item.job_id == "\(self.SelectjobList?._id ?? "")\(self.CrafterId)"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    if isAvail{
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",fromQue:fromQue,jobdetail:jobDetail!)
                    }else{
                        let conversationId = fourDigitNumber
                        if APPDELEGATE?.selectedUserType == .Crafter{
                            self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                            self.addJobDetail(userId: "\(self.SelectjobList?.client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                        }else if APPDELEGATE?.selectedUserType == .Client{
                            self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                            self.addJobDetail(userId: "\(self.profile?._id ?? (self.profile?.user_id ?? ""))",conversationId:conversationId, chat_option_status: "1")
                        }
                    }
                }
            }else{
                let conversationId = fourDigitNumber
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                    self.addJobDetail(userId: "\(self.SelectjobList?.client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                }else if APPDELEGATE?.selectedUserType == .Client{
                    self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                    self.addJobDetail(userId: "\(self.profile?._id ?? (self.profile?.user_id ?? ""))",conversationId:conversationId, chat_option_status: "1")
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if isLoad{
                    APPDELEGATE?.hideProgrssVoew()
                    isLoad = false
                }
            }
        }
    }
    
    func addJobDetail(userId:String,conversationId:String,chat_option_status:String){
        if APPDELEGATE?.selectedUserType == .Crafter{
            self.addJobs(userId: userId, jobId: "\(self.SelectjobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(SelectjobList?.client_id ?? "")")
        }else if APPDELEGATE?.selectedUserType == .Client{
            self.addJobs(userId: userId, jobId: "\(self.SelectjobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(profile?._id ?? (profile?.user_id ?? ""))", ClientID: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
        }
    }
    
    //Add Job
    func addJobs(userId:String,jobId:String,conversationId:String,chat_option_status:String,CrafterId:String,ClientID:String){
        let jobid = jobId + CrafterId
        let param = ["job_id":jobid,"lastmessage":"","lastmessagetime":"\(Date())","conversationId":"\(conversationId)","unreadMessageCount":0,"timeinterval":"\(getTimeInterval())","chat_option_status":"\(chat_option_status)","jobprice":"0", "isRead":"0","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))","CrafterId":CrafterId,"ClientId":ClientID,"service_image":"\(SelectjobList?.service_image ?? "no image")","service_description":"\(SelectjobList?.description ?? "")","jobdetailID":jobId] as [String : Any]
        FirebaseJobAPICall.firebaseAddJobs(myId: userId, jobId: jobid, jobDetail: param) { (status, error, data) in
            if status{
                print("Job added to Firebase")
            }
        }
    }
    
    
    func redirecttoChat(conversationId:String,jobId:String,chat_option_status:String,fromQue:Bool,jobdetail:jobsAdded){
        if isRehire{
            isRehire = false
            if (APPDELEGATE?.isChatViewcontroller)!{
                return
            }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
            APPDELEGATE?.isChatViewcontroller = true
            messages?.conversationId = conversationId
            messages?.jobId = jobId
            messages?.chat_option_status = chat_option_status
            messages?.service_image = SelectjobList?.service_image ?? ""
            messages?.profile_image = SelectjobList?.profile_image ?? ""
            messages?.fullname = SelectjobList?.full_name ?? ""
            messages?.CrafterID = self.profile?._id ?? ""
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            if fromQue{
                messages?.isOpenFromQue = true
            }
            self.navigationController?.pushViewController(messages!, animated: true)
        }
    }

    
    //MAKE Offer
    func MakeOfferAPI()
    {
        
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","job_id":"\(SelectjobList?._id ?? "")","handyman_id":"\(profile?.user_id ?? "")","is_invite":"1","make_offer":"1"]
        WebService.Request.patch(url: makeOffer, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                    if dataresponse != nil
                    {
                        do
                        {
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
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
            }
        }
    }
}



//MARK:- Review Cell
class reviewCell: UITableViewCell
{
    @IBOutlet weak var lblReviewBy: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var btnviewLiked: UIButton!
    @IBOutlet weak var lblLikeCount: UILabel!
}
