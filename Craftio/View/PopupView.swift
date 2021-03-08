
import UIKit
import DropDown

enum PopUpType
{
    case ViewReview
    case ViewReportBlock
    case ViewLeaveReport
    case ViewWarning
    case ViewBlock
}


class PopupView: UIView
{
    @IBOutlet weak var imgInfo: UIImageView!
    @IBOutlet weak var lblWarningInfo: UILabel!
    @IBOutlet weak var ViewWarning: UIView!
    
    @IBOutlet weak var lblBlockInfo: UILabel!
    @IBOutlet weak var ViewBlock: UIView!
    
    @IBOutlet weak var ViewReportBlock: UIView!
    
    @IBOutlet weak var ViewLeaveReport: UIView!
    @IBOutlet weak var ViewReview: UIView!
    
    @IBOutlet weak var btnStar1: UIButton!
    @IBOutlet weak var btnStar2: UIButton!
    @IBOutlet weak var btnStar3: UIButton!
    @IBOutlet weak var btnStar4: UIButton!
    @IBOutlet weak var btnStar5: UIButton!
    
    @IBOutlet weak var btnReviewOption: UIButton!
    
    @IBOutlet weak var btnVBlock: UIButton!
    @IBOutlet weak var lblVBlock: UILabel!
    @IBOutlet weak var btnleaveReview: UIButton!
    @IBOutlet weak var btnVReport: UIButton!
    
    @IBOutlet weak var lblViewReportTitla: UILabel!
    @IBOutlet weak var heightLeaveReviewButton: NSLayoutConstraint!//50
    
    var rating = 0
    var isFrom = String()
    var userIDjob = String()
    var conversationId = String()
    var jobIDjob = String()
    var oponentUserID = String()
    var is_block = String()
    var isReviewAvail = String()
    var isAccepted = false
    var review_id = String()
    var isNotBlock = false
    
    let dropDownReviewOption = DropDown()
    var arrReviewOption: [String] = ["Great Job","Highly Recommend","Reliable","Punctual","Polite","Helpful"]
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PopupView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }

    
    func intiWithuserdetail(userdetail:[String:Any],displayPopUp:NSInteger,isfrom:String,userID:String,oponnentuserid:String,jobID:String,is_block:String,conversationIdJob:String,isReview:String,review_id:String="",isJobAccrpted:Bool = false){
        self.backgroundColor = UIColor.clear
        self.OnloadSetup()
        showView(index: displayPopUp)
        isFrom = isfrom
        userIDjob = userID
        jobIDjob = jobID
        oponentUserID = oponnentuserid
        conversationId = conversationIdJob
        isReviewAvail = isReview
        self.review_id = review_id
        isAccepted = isJobAccrpted

        print(userdetail)
        if isReviewAvail == "1"{
            lblViewReportTitla.text = "Report an issue?"
            btnleaveReview.isHidden = true
            heightLeaveReviewButton.constant = 0
        }else{
            lblViewReportTitla.text = "Leave a review or Report an issue?"
            btnleaveReview.isHidden = false
            heightLeaveReviewButton.constant = 50
        }
        self.is_block = is_block
        
        if APPDELEGATE!.selectedUserType == .Client
        {
            if is_block == "0" || is_block == ""
            {
                if isAccepted{
                    lblVBlock.text = "You can’t use block option for agreed jobs"
                }else{
                    lblVBlock.text = "BLOCK CRAFTER"
                }
                
            }
            else
            {
                lblVBlock.text = "UN_BLOCK CRAFTER"
            }
            
            btnVReport.setTitle("REPORT CRAFTER", for: .normal)
        }
        else
        {
            if is_block == "0" || is_block == ""
            {
                if isAccepted{
                    lblVBlock.text = "You can’t use block option for agreed jobs"
                }else{
                    lblVBlock.text = "BLOCK CLIENT"
                }
            }
            else
            {
                lblVBlock.text = "UN_BLOCK CLIENT"
            }
            btnVReport.setTitle("REPORT CLIENT", for: .normal)
        }
        
        self.DropDownReviewOption()
    }
    
    func DropDownReviewOption() {
        self.dropDownReviewOption.anchorView = self.btnReviewOption
        dropDownReviewOption.dataSource = self.arrReviewOption
        dropDownReviewOption.backgroundColor = UIColor.white
        dropDownReviewOption.selectionBackgroundColor = UIColor.white
        dropDownReviewOption.direction = .bottom
        dropDownReviewOption.textFont = (UIFont(name: "Cabin-Medium", size: 15.0) ?? nil)!
        dropDownReviewOption.plainView.cornerRadius = 12.0
        dropDownReviewOption.textColor = #colorLiteral(red: 0.3442644477, green: 0.3798936009, blue: 0.4242471457, alpha: 1)
        dropDownReviewOption.selectionAction = { [] (index: Int, item: String) in
        self.btnReviewOption.setTitle(item, for: .normal)
        self.dropDownReviewOption.hide()
        }
    }
    
    //MARK :- Button Actions
    @IBAction func btndismissView(_ sender: UIButton){
      //  self.removeFromSuperview()
    }

    //Warning
    @IBAction func btnCloseWarningAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        ViewWarning.isHidden = true
    }
    
    @IBAction func btnWarningAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        if !isNotBlock{
            findtopViewController()?.navigationController?.popViewController(animated: true)
        }
    }
    
    //Block
    @IBAction func btnCloseBlockAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        ViewBlock.isHidden = true
    }
    
    @IBAction func btnYesAction(_ sender: UIButton)
    {
        UnblockUserAPI(userIDjob, block_status: "1")
    }
    
    @IBAction func btnNoAction(_ sender: UIButton)
    {
        ViewBlock.isHidden = true
    }
    
    //ViewReportBlock
    @IBAction func btnCloseReportBlockAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.removeFromSuperview()
    }
    
    @IBAction func btnBlockAction(_ sender: UIButton)
    {
        if is_block == "0" || is_block == ""
        {
            if isAccepted{
                return
            }
            ViewBlock.isHidden = false
        }
        else
        {
            UnblockUserAPI(userIDjob, block_status: "2")
        }
    }
    
    @IBAction func btnReportAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "ReportAnIssueVC") as? ReportAnIssueVC
        review?.userId = userIDjob
        review?.jobID = jobIDjob
        findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
    }
    
    //ViewReview
    @IBAction func btnCloseViewReviewAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
         ViewReview.isHidden = true
    }
    
    @IBAction func btnAddReviewAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        if userIDjob == ""{
            let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as? AddReviewVC
            review?.to_user_id = userIDjob
            review?.rating = rating
            review?.job_id = jobIDjob
            findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
        }else{
            
            let storyBoard : UIStoryboard = UIStoryboard(name: "Chat", bundle:nil)
            let objCompletedJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
            objCompletedJobDetailsVC.to_user_id = userIDjob
            objCompletedJobDetailsVC.rating = rating
            objCompletedJobDetailsVC.job_id = jobIDjob
            findtopViewController()?.navigationController?.pushViewController(objCompletedJobDetailsVC, animated: true)
        }
    }
    
    @IBAction func btnReviewOptionAction(_ sender: UIButton)
    {
        self.dropDownReviewOption.show()
    }
    
    func gotoReview(){
        self.AddReviewAPI()
    }
    //
    func AddReviewAPI()
    {
        
        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","to_user_id":"\(self.userIDjob)","review_by":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","rating":"\(self.rating)","review_message":"","review_id":self.review_id,"job_id":"\(self.jobIDjob)"]
        print(params)
        WebService.Request.patch(url: AddReview, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let data = response?["data"] as! [String:Any]
                    
                    self.review_id = data["review_id"] as! String
                    
                    self.removeFromSuperview()
                    if self.userIDjob == ""{
                        let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as? AddReviewVC
                        review?.to_user_id = self.userIDjob
                        review?.rating = self.rating
                        review?.job_id = self.jobIDjob
                        review?.review_id = self.review_id
                        findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
                    }else{
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Chat", bundle:nil)
                        let objCompletedJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                        objCompletedJobDetailsVC.to_user_id = self.userIDjob
                        objCompletedJobDetailsVC.rating = self.rating
                        objCompletedJobDetailsVC.job_id = self.jobIDjob
                        objCompletedJobDetailsVC.review_id = self.review_id
                        findtopViewController()?.navigationController?.pushViewController(objCompletedJobDetailsVC, animated: true)
                    }
                    
                } else
                {
                    self.removeFromSuperview()
                    if self.userIDjob == ""{
                        let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as? AddReviewVC
                        review?.to_user_id = self.userIDjob
                        review?.rating = self.rating
                        review?.job_id = self.jobIDjob
                        findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
                    }else{
                        
                        let storyBoard : UIStoryboard = UIStoryboard(name: "Chat", bundle:nil)
                        let objCompletedJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                        objCompletedJobDetailsVC.to_user_id = self.userIDjob
                        objCompletedJobDetailsVC.rating = self.rating
                        objCompletedJobDetailsVC.job_id = self.jobIDjob
                        findtopViewController()?.navigationController?.pushViewController(objCompletedJobDetailsVC, animated: true)
                    }
                }
            }
        }
    }
    //
    @IBAction func btnStar1Action(_ sender: UIButton)
    {
        rating = 1
        giveRating(rate: 1)
        self.gotoReview()
    }
    
    @IBAction func btnStar2kAction(_ sender: UIButton)
    {
        rating = 2
        giveRating(rate: 2)
        self.gotoReview()
    }
    
    @IBAction func btnStar3Action(_ sender: UIButton)
    {
        rating = 3
        giveRating(rate: 3)
        self.gotoReview()
    }
    
    @IBAction func btnStar4Action(_ sender: UIButton)
    {
        rating = 4
        giveRating(rate: 4)
        self.gotoReview()
    }
    
    @IBAction func btnStar5Action(_ sender: UIButton)
    {
        rating = 5
        giveRating(rate: 5)
        self.gotoReview()
    }
    
    //LeaveReportView
    @IBAction func btnCloseViewLeaveReviewAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        ViewLeaveReport.isHidden = true
    }
    
    @IBAction func btnLeaveReviewAction(_ sender: UIButton)
    {
        if isFrom == "review"{
            self.removeFromSuperview()
        }else{
            ViewLeaveReport.isHidden = true
            ViewReview.isHidden = false
        }
    }
    
    @IBAction func btnReportIssueAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "ReportAnIssueVC") as? ReportAnIssueVC
        review?.userId = userIDjob
        review?.jobID = jobIDjob
        findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
    }
    
    func OnloadSetup()
    {
        giveRating(rate: 0)
        //Warning
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.ViewWarning.frame
        rectShape.position = self.ViewWarning.center
        let frame = CGRect (x: 0, y: self.ViewWarning.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.ViewWarning.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.ViewWarning.layer.mask = rectShape
        
        //Block
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = self.ViewBlock.frame
        rectShape1.position = self.ViewBlock.center
        let frame1 = CGRect (x: 0, y: self.ViewBlock.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.ViewBlock.bounds.size.height)
        rectShape1.path = UIBezierPath(roundedRect: frame1, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.ViewBlock.layer.mask = rectShape1
     
        
        //ViewReportBlock
        let rectShape2 = CAShapeLayer()
        rectShape2.bounds = self.ViewReportBlock.frame
        rectShape2.position = self.ViewReportBlock.center
        let frame2 = CGRect (x: 0, y: self.ViewReportBlock.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.ViewReportBlock.bounds.size.height)
        rectShape2.path = UIBezierPath(roundedRect: frame2, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.ViewReportBlock.layer.mask = rectShape2
        
        //ViewLeaveReport
        let rectShape3 = CAShapeLayer()
        rectShape3.bounds = self.ViewLeaveReport.frame
        rectShape3.position = self.ViewLeaveReport.center
        let frame3 = CGRect (x: 0, y: self.ViewLeaveReport.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.ViewLeaveReport.bounds.size.height)
        rectShape3.path = UIBezierPath(roundedRect: frame3, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.ViewLeaveReport.layer.mask = rectShape3
        
        //ViewReview
        let rectShape4 = CAShapeLayer()
        rectShape4.bounds = self.ViewReview.frame
        rectShape4.position = self.ViewReview.center
        let frame4 = CGRect (x: 0, y: self.ViewReview.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.ViewReview.bounds.size.height)
        rectShape4.path = UIBezierPath(roundedRect: frame4, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.ViewReview.layer.mask = rectShape4
        
        let reateImage = UIImage(named: "starbig")?.withRenderingMode(.alwaysTemplate)
        self.btnStar1.setImage(reateImage, for: .normal)
        self.btnStar1.tintColor = UIColor.gray
        self.btnStar2.setImage(reateImage, for: .normal)
        self.btnStar2.tintColor = UIColor.gray
        self.btnStar3.setImage(reateImage, for: .normal)
        self.btnStar3.tintColor = UIColor.gray
        self.btnStar4.setImage(reateImage, for: .normal)
        self.btnStar4.tintColor = UIColor.gray
        self.btnStar5.setImage(reateImage, for: .normal)
        self.btnStar5.tintColor = UIColor.gray
    }
    
    //Hide Show View
    func showView(index:NSInteger){
        if index == 1{//REport and Block user popup display
            ViewReportBlock.isHidden = false
            ViewWarning.isHidden = true
            ViewBlock.isHidden = true
            ViewReview.isHidden = true
            ViewLeaveReport.isHidden = true
        }else if index == 2{//Block crafter / Client
            ViewReportBlock.isHidden = true
            ViewWarning.isHidden = true
            ViewBlock.isHidden = false
            ViewReview.isHidden = true
            ViewLeaveReport.isHidden = true
        }else if index == 3{// Display Messsage Popup
            ViewReportBlock.isHidden = true
            ViewWarning.isHidden = false
            ViewBlock.isHidden = true
            ViewReview.isHidden = true
            ViewLeaveReport.isHidden = true
        }else if index == 4{// Display Review Popup
            ViewReportBlock.isHidden = true
            ViewWarning.isHidden = true
            ViewBlock.isHidden = true
            ViewReview.isHidden = false
            ViewLeaveReport.isHidden = true
        }else if index == 5{//Display Report issue
            ViewReportBlock.isHidden = true
            ViewWarning.isHidden = true
            ViewBlock.isHidden = true
            ViewReview.isHidden = true
            ViewLeaveReport.isHidden = false
        }else if index == 6{// Hide all
            ViewReportBlock.isHidden = true
            ViewWarning.isHidden = true
            ViewBlock.isHidden = true
            ViewReview.isHidden = true
            ViewLeaveReport.isHidden = true
        }
    }
    
    //MARK:- UnBlock User API
    func UnblockUserAPI(_ user_id:String,block_status:String)
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
        self.isNotBlock = false
        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","from_user_type":"\(user_type)","to_user_id":"\(user_id)","block_status":"\(block_status)","job_id":"\(jobIDjob)"]
        WebService.Request.patch(url: blockUnblockUser, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    self.ViewWarning.isHidden = false
                    self.lblWarningInfo.text = response!["msg"] as? String ?? ""
                } else
                {
                    self.isNotBlock = true
                    self.ViewWarning.isHidden = false
                    self.lblWarningInfo.text = response!["msg"] as? String ?? ""
                }
            }
        }
    }

    
    //MARK:- UnBlock User API
    func leaveAReview(user_id:String)
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

        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","from_user_type":"\(user_type)","to_user_id":"\(user_id)","block_status":"1"]
        WebService.Request.patch(url: blockUnblockUser, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    self.ViewWarning.isHidden = false
                    self.lblWarningInfo.text = response!["msg"] as? String ?? ""
                } else
                {
                    //self.toastError("Something went wrong, please try again later")
                }
            }
        }
    }
    

    func giveRating(rate:Int){
        let starImg = UIImage(named: "starbig")?.withRenderingMode(.alwaysTemplate)
        if rate == 0
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = UIColor.gray
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = UIColor.gray
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = UIColor.gray
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = UIColor.gray
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = UIColor.gray
        }
        else if rate == 1
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = APPDELEGATE?.appGreenColor
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = UIColor.gray
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = UIColor.gray
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = UIColor.gray
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = UIColor.gray
        }
        else if rate == 2
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = APPDELEGATE?.appGreenColor
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = APPDELEGATE?.appGreenColor
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = UIColor.gray
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = UIColor.gray
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = UIColor.gray
        }
        else if rate == 3
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = APPDELEGATE?.appGreenColor
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = APPDELEGATE?.appGreenColor
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = APPDELEGATE?.appGreenColor
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = UIColor.gray
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = UIColor.gray
        }
        else if rate == 4
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = APPDELEGATE?.appGreenColor
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = APPDELEGATE?.appGreenColor
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = APPDELEGATE?.appGreenColor
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = APPDELEGATE?.appGreenColor
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = UIColor.gray
        }
        else if rate == 5
        {
            btnStar1.setImage(starImg, for: .normal)
            btnStar1.tintColor = APPDELEGATE?.appGreenColor
            btnStar2.setImage(starImg, for: .normal)
            btnStar2.tintColor = APPDELEGATE?.appGreenColor
            btnStar3.setImage(starImg, for: .normal)
            btnStar3.tintColor = APPDELEGATE?.appGreenColor
            btnStar4.setImage(starImg, for: .normal)
            btnStar4.tintColor = APPDELEGATE?.appGreenColor
            btnStar5.setImage(starImg, for: .normal)
            btnStar5.tintColor = APPDELEGATE?.appGreenColor
        }
    }
    
    func changeJobChatStatus(myID:String,OpponentId:String,statusForClient:String,statusForCrafter:String,conversationId:String){
        if APPDELEGATE?.selectedUserType == .Crafter{
            self.addtoFirebase(conversationId: "\(conversationId)", myid: myID, fromId: OpponentId, chat_option_status: "1")
            self.addtoFirebase(conversationId: "\(conversationId)", myid: OpponentId, fromId: myID, chat_option_status: "0")
        }else if APPDELEGATE?.selectedUserType == .Client{
            self.addtoFirebase(conversationId: "\(conversationId)", myid: myID, fromId: OpponentId, chat_option_status: "0")
            self.addtoFirebase(conversationId: "\(conversationId)", myid: OpponentId, fromId: myID, chat_option_status: "1")
        }
    }
    
    func addtoFirebase(conversationId:String,myid:String,fromId:String,chat_option_status:String){
        let param = ["user_id":fromId,"lastmessage":"","lastmessagetime":"\(Date())","conversationId":"\(conversationId)","unreadMessageCount":0,"timeinterval":"\(getTimeInterval())","activeJobID":"0","chat_option_status":"\(chat_option_status)","jobprice":"0"] as [String : Any]
        FirebaseAPICall.FirebaseupdateLastMessage(MyuserId: myid, OponnentUserID: fromId, ChatuserDetail: param) { (status) in
            if status{
                print("success")
            }
        }
    }
}
