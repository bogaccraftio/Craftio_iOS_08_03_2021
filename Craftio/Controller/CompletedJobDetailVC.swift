

import UIKit
import Lightbox

class CompletedJobDetailVC: UIViewController,UITextViewDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var txtViewDesc: UITextView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var lbldate: UILabel!
    @IBOutlet weak var lbltitlename: UILabel!
    @IBOutlet weak var lblprice: UILabel!
    @IBOutlet weak var lblWorkCOmpleteBottom: UILabel!
    @IBOutlet weak var lblReceiptbottom: UILabel!
    @IBOutlet weak var viewcontent: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgServiceCat: UIImageView!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    @IBOutlet weak var imgStar4: UIImageView!
    @IBOutlet weak var imgStar5: UIImageView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var viewlocation: UIView!
    @IBOutlet weak var viewReceipt: UIView!
    @IBOutlet weak var lblCost: UILabel!
    @IBOutlet weak var lblSubtotal: UILabel!
    @IBOutlet weak var lblCharges: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    @IBOutlet weak var lblCommision: UILabel!
    @IBOutlet weak var lblWillPayYou: UILabel!
    @IBOutlet weak var lblCommisionTitle: UILabel!
    @IBOutlet weak var lblWillPayYouTitle: UILabel!
    @IBOutlet weak var lblCostOfJob: UILabel!
    @IBOutlet weak var lblClientPaidOrSubTotal: UILabel!
    @IBOutlet weak var lblAmountReceiverOrQuoteFee: UILabel!
    @IBOutlet weak var lblTotalAmountReceived: UILabel!

    @IBOutlet weak var btnWorkComplete: UIButton!
    @IBOutlet weak var btnReceipt: UIButton!
    @IBOutlet weak var btnrateUser: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnreportIssue: UIButton!
    @IBOutlet weak var btnViewProfile: UIButton!
    @IBOutlet weak var heighttextview: NSLayoutConstraint!//130 set height 30 if receipt selected
    @IBOutlet weak var heightleaveReview: NSLayoutConstraint!//50
    @IBOutlet weak var heighttotalAmountReceived: NSLayoutConstraint!//50
    @IBOutlet weak var topTotalAmountREceived: NSLayoutConstraint!//50
    @IBOutlet weak var topOurCommision: NSLayoutConstraint!//50
    @IBOutlet weak var heightlblCommisionTitle: NSLayoutConstraint!//50
    @IBOutlet weak var heightLblWillPayYouTitle: NSLayoutConstraint!//50
    @IBOutlet weak var heightReportIssue: NSLayoutConstraint!//50
    @IBOutlet weak var bottomlocation: NSLayoutConstraint!//23
    @IBOutlet weak var heightPaymentTable: NSLayoutConstraint! // 40
    @IBOutlet weak var lblEmgrgHieght: NSLayoutConstraint!//106 //38
    @IBOutlet weak var tblReleasedFund: UITableView!
    
    @IBOutlet weak var HieghtChatContainer: NSLayoutConstraint!
    @IBOutlet weak var viewChatContainer: UIView!
    
    var categoryData = [String: Any]()
    var jobList: JobHistoryData?
    var isChat = false
    var isEdit = Bool()
    var paymentCount = 5
    var isOpenFromListing = true
    var totRating = 0
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        onLoadOperations()
        if APPDELEGATE!.selectedUserType == .Crafter{
            GetCommissionData()
        }
        self.HieghtChatContainer.constant = 0

        if jobList?.is_block == "0" || jobList?.is_block == nil{
            self.btnUpdate.isHidden = false
            self.btnViewProfile.isUserInteractionEnabled = true
        }else{
            self.btnUpdate.isHidden = true
            self.btnViewProfile.isUserInteractionEnabled = false
        }
        heightleaveReview.constant = 50
        bottomlocation.constant = 12
        btnUpdate.isHidden = true
        
        if APPDELEGATE?.selectedUserType == .Crafter{
            btnreportIssue.isHidden = true
            heightReportIssue.constant = 0
            btnUpdate.setTitle("REQUEST A PAYMENT", for: .normal)
        }else{
            btnUpdate.setTitle("MAKE A PAYMENT", for: .normal)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }

    func onLoadOperations()
    {
        viewReceipt.isHidden = true

        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        var frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
        
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = self.viewBottom.frame
        rectShape1.position = self.viewBottom.center
        frame = CGRect (x: 0, y: self.viewBottom.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.viewBottom.bounds.size.height)
        rectShape1.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewBottom.layer.mask = rectShape1
       
        if self.jobList?.full_name == nil || self.jobList?.full_name == ""{
            self.lblName.text = "You rated \(self.jobList?.first_name ?? "")"
        }else{
            let nm = self.jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobList?.full_name ?? "")
            if tempName.count >= 2{
                self.lblName.text = "You rated \(UName)."
            }else{
                self.lblName.text = "You rated \(UName)"
            }
        }
        
        self.txtViewDesc.text = self.jobList?.description
        self.lblLocation.text = self.jobList?.address
       
        if self.jobList?.is_emergency_job == 1
        {
            self.lblEmgrgHieght.constant = 18
        }
        else
        {
            self.lblEmgrgHieght.constant = 0
        }
        
        if jobList?.review_tag == "" || self.jobList?.review_tag == "0"{
            self.lblName.isHidden = true
            btnrateUser.isHidden = false
            
            let nm = self.jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobList?.full_name ?? "")
            if tempName.count >= 2{
                self.btnrateUser.setTitle("Rate \(UName).", for: .normal)
            }else{
                self.btnrateUser.setTitle("Rate \(UName)", for: .normal)
            }
        }else if jobList?.review_tag == "1"{
            self.lblName.isHidden = true
            btnrateUser.isHidden = false
            
            let nm = self.jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobList?.full_name ?? "")
            if tempName.count >= 2{
                self.btnrateUser.setTitle("Review \(UName).", for: .normal)
            }else{
                self.btnrateUser.setTitle("Review \(UName)", for: .normal)
            }
        }else{
            self.lblName.isHidden = false
            btnrateUser.isHidden = true
        }
        
        var rate = jobList?.job_review
        let rate1 = "\(rate?.removeFirst() ?? "0")"
        self.totRating = Int(rate1) ?? 0
        
        self.lblRate.text = "\(rate1).0"
        if self.lblRate.text == "0.0" || self.lblRate.text == "" || self.lblRate.text == "0" || self.lblRate.text == "0.00"{
            self.lblRate.text = "NEW"
        }

        self.lbldate.text = self.jobList?.complete_time
        
        if APPDELEGATE!.selectedUserType == .Crafter
        {
             var Uname = ""
             let nm = self.jobList?.full_name ?? ""
             let tempName = nm.split(separator: " ")
             let UName = setUserName(name: self.jobList?.full_name ?? "")
             if tempName.count >= 2{
                 Uname = "\(UName)."
             }else{
                 Uname = "\(UName)"
             }
            self.lbltitlename.text = "Your client: \(Uname)"
        }
        else
        {
            var Uname = ""
            let nm = self.jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobList?.full_name ?? "")
            if tempName.count >= 2{
                Uname = "\(UName)."
            }else{
                Uname = "\(UName)"
            }
            self.lbltitlename.text = "Your crafter: \(Uname)"
        }
        self.lblprice.text = "£ \(self.jobList?.booking_amount ?? "0.0")"
        
        
        if jobList?.media.count ?? 0 > 0{
            if (jobList?.media[0].media_url?.contains(".mp4"))! || (jobList?.media[0].media_url?.contains(".mov"))!
            {
                let url = URL(string: (jobList?.media[0].media_url!)!)
                
                DispatchQueue.global(qos: .background).async{
                    if let thumbnailImage = generateThumbnail(path: url!)
                    {
                        DispatchQueue.main.async
                            {
                                self.imgCategory.image = thumbnailImage
                        }
                    }
                }
            }else{
                let imgURL = URL(string: jobList?.media[0].media_url ?? "")
                imgCategory.kf.setImage(with: imgURL, placeholder: nil)
                appDelegate.imgDefault = imgCategory.image
            }
        }
        else
        {
            imgCategory.image = UIImage (named: "placeholder.jpg")
            imgCategory.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.3)
            appDelegate.imgDefault = imgCategory.image
        }
        
        let imgURL = URL(string: jobList?.profile_image ?? "")
        imgProfile.kf.setImage(with: imgURL, placeholder: nil)
        
        let imgURLService = URL(string: jobList?.service_image ?? "")
        imgServiceCat.kf.setImage(with: imgURLService, placeholder: nil)
        let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        if rate1 == "0"
        {
            imgStar1.image = starImg
            imgStar1.tintColor = UIColor.lightGray
            imgStar2.image = starImg
            imgStar2.tintColor = UIColor.lightGray
            imgStar3.image = starImg
            imgStar3.tintColor = UIColor.lightGray
            imgStar4.image = starImg
            imgStar4.tintColor = UIColor.lightGray
            imgStar5.image = starImg
            imgStar5.tintColor = UIColor.lightGray
        }
        else if rate1 == "1"
        {
            imgStar2.image = starImg
            imgStar2.tintColor = UIColor.lightGray
            imgStar3.image = starImg
            imgStar3.tintColor = UIColor.lightGray
            imgStar4.image = starImg
            imgStar4.tintColor = UIColor.lightGray
            imgStar5.image = starImg
            imgStar5.tintColor = UIColor.lightGray
        }
        else if rate1 == "2"
        {
            imgStar3.image = starImg
            imgStar3.tintColor = UIColor.lightGray
            imgStar4.image = starImg
            imgStar4.tintColor = UIColor.lightGray
            imgStar5.image = starImg
            imgStar5.tintColor = UIColor.lightGray
        }
        else if rate1 == "3"
        {
            imgStar4.image = starImg
            imgStar4.tintColor = UIColor.lightGray
            imgStar5.image = starImg
            imgStar5.tintColor = UIColor.lightGray
        }
        else if rate1 == "4"
        {
            imgStar5.image = starImg
            imgStar5.tintColor = UIColor.lightGray
        }
        else if rate1 == "5"
        {
            
        }
        
        self.view.updateConstraintsIfNeeded()
        heighttextview.constant = txtViewDesc.contentSize.height
        APPDELEGATE?.SelectedLocationAddress = self.jobList?.address ?? ""
        APPDELEGATE?.SelectedLocationLat = Double(self.jobList?.client_latitude ?? "0.00")!
        APPDELEGATE?.SelectedLocationLong = Double(self.jobList?.client_longitude ?? "0.00")!
        lblCost.text = "£\(jobList?.booking_amount ?? "0.00")"
        lblSubtotal.text = "£\(jobList?.booking_amount ?? "0.00")"
        let amount = jobList?.booking_amount
        let totalAmount = Float(amount ?? "0")
        
        self.lblTotalAmountReceived.isHidden = true
        self.lblAmount.isHidden = true

        if APPDELEGATE?.selectedUserType == .Crafter{
            self.lblClientPaidOrSubTotal.text = "Client Paid"
            self.lblAmountReceiverOrQuoteFee.text = "Quote Fee"
            if self.jobList?.isFreeQuote == "1"{
                self.lblCharges.text = "Free"
            }else{
                self.lblCharges.text = "£0.99"
            }
        }else{
            self.lblClientPaidOrSubTotal.text = "Subtotal"
            self.lblAmountReceiverOrQuoteFee.text = "Total amount received"
            self.lblCharges.text = "£\(jobList?.booking_amount ?? "0.00")"
        }
        
        let gradient = AlphaGradientView.init(frame: CGRect (x: 0.0, y: 0, width: UIScreen.main.bounds.size.width, height: 70))
        gradient.color = UIColor.white
        gradient.direction = GRADIENT_DOWN
        self.viewcontent.addSubview(gradient)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isChat = false
        lblLocation.text = "\(APPDELEGATE?.SelectedLocationAddress ?? "")"
        self.GetJobDetailAPI()
    }
    
    func setBorderonTextView(color:UIColor)
    {
        self.txtViewDesc.layer.cornerRadius = 8.0
        self.txtViewDesc.layer.borderWidth = 1.0
        self.txtViewDesc.layer.borderColor = color.cgColor
        self.txtViewDesc.layer.masksToBounds = true
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnWorkComplete(_ sender: UIButton)
    {
        self.view.updateConstraintsIfNeeded()
        heighttextview.constant = txtViewDesc.contentSize.height
        viewlocation.isHidden = false
        viewReceipt.isHidden = true
        sender.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0), for: .normal)
        self.lblWorkCOmpleteBottom.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
        self.btnReceipt.setTitleColor(UIColor(red: 197/255, green: 199/255, blue: 202/255, alpha: 1.0), for: .normal)
        self.lblReceiptbottom.backgroundColor = UIColor.clear //(red: 197/255, green: 199/255, blue: 202/255, alpha: 1.0)
    }
    
    @IBAction func btnReceipt(_ sender: UIButton)
    {
        self.view.updateConstraintsIfNeeded()
        if APPDELEGATE!.selectedUserType == .Crafter{
            heightlblCommisionTitle.constant = 19
            heightLblWillPayYouTitle.constant = 19
            heighttotalAmountReceived.constant = 0
            topTotalAmountREceived.constant = 0
            topOurCommision.constant = 3
            heighttextview.constant = CGFloat(152 + (NSInteger(jobList?.payment_array.count ?? 0) * 22))
        }else{
            lblCommision.isHidden = true
            lblCommisionTitle.isHidden = true
            lblWillPayYou.isHidden = true
            lblWillPayYouTitle.isHidden = true
            heightlblCommisionTitle.constant = 0
            heightLblWillPayYouTitle.constant = 0
            heighttextview.constant = CGFloat(100 + (NSInteger(jobList?.payment_array.count ?? 0) * 22))
        }

        heightPaymentTable.constant = 0

        //viewlocation.isHidden = true
        viewReceipt.isHidden = false
        sender.setTitleColor(UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0), for: .normal)
        self.lblReceiptbottom.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1.0)
        self.btnWorkComplete.setTitleColor(UIColor(red: 197/255, green: 199/255, blue: 202/255, alpha: 1.0), for: .normal)
        self.lblWorkCOmpleteBottom.backgroundColor = UIColor.clear
    }
    
    @IBAction func btnRedirecttoProfile(_ sender: UIButton)
    {
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            print(sender.tag)
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = jobList?.client_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
        else
        {
            print(sender.tag)
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 2
            objProfileVC.strTag = "Crafter"
            objProfileVC.CrafterId = jobList?.handyman_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
    }
    
    @IBAction func btnMenuAction(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnViewImages(_ sender: UIButton)
    {
        if self.jobList?.media.count == 0{
            return
        }
        let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
        objCustomiseProfileVC.arrImages = self.jobList?.media
        APPDELEGATE?.jobDetailImages = self.jobList?.media ?? []
        objCustomiseProfileVC.OpenFrom = "detail"
        objCustomiseProfileVC.jobID = self.jobList?._id ?? ""
        objCustomiseProfileVC.showPreviewAs = .fromOther
        
        objCustomiseProfileVC.blockCancel = {
        }
        objCustomiseProfileVC.modalPresentationStyle = .fullScreen
        self.present(objCustomiseProfileVC, animated: true, completion: nil)
    }
    
    @IBAction func btnUpdateLocationAction(_ sender: UIButton)
    {
        if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {// Open Google map
            UIApplication.shared.open(URL(string:
                "comgooglemaps://?saddr=&daddr=\(jobList?.client_latitude ?? ""),\(jobList?.client_longitude ?? "")&directionsmode=driving")!, options: [:], completionHandler: nil)
            
        } else {// Open in webview(SAFARI)
            let urlString = "http://maps.google.com/?saddr=\(APPDELEGATE?.CurrentLocationLat ?? 0.00),\(APPDELEGATE?.CurrentLocationLong ?? 0.00)&daddr=\(jobList?.client_latitude ?? ""),\(jobList?.client_longitude ?? "")&directionsmode=driving"
            
            UIApplication.shared.open(URL(string:urlString)!, options: [:], completionHandler: nil)
        }
    }
    
    @IBAction func btnreportIssue(_ sender: UIButton)
    {
        var userId = String()
        if APPDELEGATE?.selectedUserType == .Crafter{
            userId = jobList?.client_id ?? ""
        }else{
            userId = jobList?.handyman_id ?? ""
        }
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let review = storyboard.instantiateViewController(withIdentifier: "ReportAnIssueVC") as? ReportAnIssueVC
        review?.userId = userId
        review?.jobID = jobList?._id ?? ""
        findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
    }

    @IBAction func btnPayment(_ sender: UIButton)
    {
        
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton)
    {
        if self.jobList?.review_tag == "" || self.jobList?.review_tag == "0"{
            var userId = String()
            if APPDELEGATE?.selectedUserType == .Crafter{
                userId = jobList?.client_id ?? ""
            }else{
                userId = jobList?.handyman_id ?? ""
            }
            
            let displayPopup = displayPopupView()
            displayPopup.intiWithuserdetail(userdetail: [:], displayPopUp: 4, isfrom: "",userID:"\(userId)", oponnentuserid: "\(jobList?.client_id ?? "")",jobID:"\(jobList?._id ?? "")", is_block: "", conversationIdJob: "", isReview: jobList?.is_review ?? "",review_id:jobList?.review_id ?? "")
            displayPopup.frame = self.view.bounds
            self.view.addSubview(displayPopup)
            
        }else if self.jobList?.review_tag == "1"{
            var userId = String()
            if APPDELEGATE?.selectedUserType == .Crafter{
                userId = jobList?.client_id ?? ""
            }else{
                userId = jobList?.handyman_id ?? ""
            }
            
            if userId == ""{
                let review = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "AddReviewVC") as? AddReviewVC
                review?.to_user_id = userId
                review?.rating = self.totRating
                review?.job_id = "\(jobList?._id ?? "")"
                review?.review_id = "\(jobList?.review_id ?? "")"
                findtopViewController()?.navigationController?.pushViewController(review!, animated: true)
            }else{
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Chat", bundle:nil)
                let objCompletedJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "AddReviewVC") as! AddReviewVC
                objCompletedJobDetailsVC.to_user_id = userId
                objCompletedJobDetailsVC.rating = self.totRating
                objCompletedJobDetailsVC.job_id = "\(jobList?._id ?? "")"
                objCompletedJobDetailsVC.review_id = "\(jobList?.review_id ?? "")"
                findtopViewController()?.navigationController?.pushViewController(objCompletedJobDetailsVC, animated: true)
            }
        }
        self.view.endEditing(true)
        
    }

    func displayPopupView() -> PopupView{
        let infoWindow = PopupView.instanceFromNib() as! PopupView
        return infoWindow
    }
}

//MARK:- Firebase
extension CompletedJobDetailVC{
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
                        
                        if item.jobdetailID == self.jobList?._id{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    self.updateChatStatus(userid: "\(self.jobList?.handyman_id ?? "")", jobId: jobDetail?.jobdetailID ?? "")
                    self.updateChatStatus(userid: "\(self.jobList?.client_id ?? "")", jobId: jobDetail?.jobdetailID ?? "")

                    self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,fromQue:fromQue)
                }
            }else{
                let conversationId = fourDigitNumber
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                    self.addJobDetail(userId: "\(self.jobList?.client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                }else if APPDELEGATE?.selectedUserType == .Client{
                    self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                    self.addJobDetail(userId: "\(self.jobList?.handyman_id ?? "")",conversationId:conversationId, chat_option_status: "1")
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
            self.addJobs(userId: userId, jobId: "\(self.jobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?.client_id ?? "")")
        }else if APPDELEGATE?.selectedUserType == .Client{
            self.addJobs(userId: userId, jobId: "\(self.jobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?.client_id ?? "")")
        }
    }

    //Add Job
    func addJobs(userId:String,jobId:String,conversationId:String,chat_option_status:String,CrafterId:String,ClientID:String){
        let jobid = jobId + CrafterId
        let param = ["job_id":jobid,"lastmessage":"","lastmessagetime":"\(Date())","conversationId":"\(conversationId)","unreadMessageCount":0,"timeinterval":"\(getTimeInterval())","chat_option_status":"\(chat_option_status)","jobprice":"0", "isRead":"0","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))","CrafterId":CrafterId,"ClientId":ClientID,"service_image":"\(jobList?.service_image ?? "no image")","service_description":"\(jobList?.description ?? "")","jobdetailID":jobId] as [String : Any]
        FirebaseJobAPICall.firebaseAddJobs(myId: userId, jobId: jobid, jobDetail: param) { (status, error, data) in
            if status{
                print("Job added to Firebase")
            }
        }
    }
    
    func updateChatStatus(userid:String,jobId:String){
        let param = ["chat_option_status":changeChatStatus.report]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userid, jobId: jobId, ChatuserDetail: param) { (status) in
            
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
            messages?.service_image = jobList?.service_image ?? ""
            messages?.profile_image = jobList?.profile_image ?? ""
            messages?.fullname = jobList?.full_name ?? ""
            messages?.CrafterID = jobList?.handyman_id ?? ""
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
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","job_id":"\(jobList?._id ?? "")","handyman_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","is_invite":"","make_offer":"1"]
        WebService.Request.patch(url: makeOffer, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true{
                } else{
                }
            }
        }
    }
    
    //Send Quote and CHnage Job Status
    func changeJobStatusandAmount(bookingstatus: String,amount:String, cancellation_reason: String = "0"){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = formatter.string(from: Date())

        var param = ["job_id":"\(jobList?._id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","booking_status":"\(bookingstatus)","booking_amount":"\(amount)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","complete_time": timeString,"cancellation_reason": cancellation_reason]
        if APPDELEGATE?.selectedUserType == .Crafter
        {
            param["handyman_id"] = "\(APPDELEGATE!.uerdetail?.user_id ?? "")"
        }else{
            param["handyman_id"] = "\(jobList?.handyman_id ?? "")"
        }
        WebService.Request.patch(url: changeJobStatus, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
            }
        }
    }
    
    //MARK:- UnBlock User API
    func UnblockUserAPI(_ user_id:String,fromQue:Bool)
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

        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","from_user_type":"\(user_type)","to_user_id":"\(user_id)","block_status":"2"]
        WebService.Request.patch(url: blockUnblockUser, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
    
    //
    func GetJobDetailAPI(){
        var userType = String()
        var CrafterId = String()
        if APPDELEGATE!.selectedUserType == .Crafter{
            userType = Crafter
            CrafterId = APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? "")
        }else{
            userType = Client
            CrafterId = jobList?.handyman_id ?? ""
        }
        APPDELEGATE?.ChatjobID = jobList?._id ?? ""
        let params = ["job_id":"\(jobList?._id ?? "")","handyman_id":CrafterId,"loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)"]
        WebService.Request.patch(url: getJobDetail, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
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
                            let JobData = try! JSONDecoder().decode([JobHistoryData]?.self, from: jsonData)
                            
                            if (JobData?.count)! > 0
                            {
                                self.jobList = JobData?[0]
                               
                                if self.jobList?.review_tag == "" || self.jobList?.review_tag == "0"{
                                    self.lblName.isHidden = true
                                    self.btnrateUser.isHidden = false
                                    let nm = self.jobList?.full_name ?? ""
                                    let tempName = nm.split(separator: " ")
                                    let UName = setUserName(name: self.jobList?.full_name ?? "")
                                    if tempName.count >= 2{
                                        self.btnrateUser.setTitle("Rate \(UName).", for: .normal)
                                    }else{
                                        self.btnrateUser.setTitle("Rate \(UName)", for: .normal)
                                    }
                                }else if self.jobList?.review_tag == "1"{
                                    self.lblName.isHidden = true
                                    self.btnrateUser.isHidden = false
                                    
                                    let nm = self.jobList?.full_name ?? ""
                                    let tempName = nm.split(separator: " ")
                                    let UName = setUserName(name: self.jobList?.full_name ?? "")
                                    if tempName.count >= 2{
                                        self.btnrateUser.setTitle("Review \(UName).", for: .normal)
                                    }else{
                                        self.btnrateUser.setTitle("Review \(UName)", for: .normal)
                                    }
                                }else{
                                    self.lblName.isHidden = false
                                    self.btnrateUser.isHidden = true
                                }
                                
                                
                                var rate = self.jobList?.job_review
                                let rate1 = "\(rate?.removeFirst() ?? "0")"
                                self.totRating = Int(rate1) ?? 0
                                // self.displayButtons()
                            }
                        }catch{
                            
                        }
                    }
                }
            }
        }
    }
    
    func GetCommissionData(){
        var userType = String()
        if APPDELEGATE!.selectedUserType == .Crafter{
            userType = Crafter
        }else{
            return
        }
        APPDELEGATE?.ChatjobID = jobList?._id ?? ""
        let params = ["job_id":"\(jobList?._id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)"]
        WebService.Request.patch(url: getCommissionData, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        self.lblWillPayYou.text = "£ \(dataresponse?["total_amount"] as? String ?? "0.0")"
                        self.lblCommision.text = "%\(dataresponse?["commission"] as? String ?? "0.0")"
                    }
                }
            }
        }
    }

}

//MARK:- TableView Delegate and Datasource Methods
extension CompletedJobDetailVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jobList?.payment_array.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 22
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let lblDetail = cell.contentView.viewWithTag(1) as? UILabel
        lblDetail?.text = jobList?.payment_array[indexPath.row].message ?? "-"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
    }
}
