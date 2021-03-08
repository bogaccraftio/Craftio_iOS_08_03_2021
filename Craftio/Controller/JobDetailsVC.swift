
import UIKit
import Lightbox
import MBProgressHUD
import Photos
import IQKeyboardManagerSwift

class JobDetailsVC: UIViewController,UITextViewDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var txtViewDesc: UITextView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewcontent: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var btnViewProfile: UIButton!
    @IBOutlet weak var imgStar1: UIImageView!
    @IBOutlet weak var imgStar2: UIImageView!
    @IBOutlet weak var imgStar3: UIImageView!
    @IBOutlet weak var imgStar4: UIImageView!
    @IBOutlet weak var imgStar5: UIImageView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var btnSelectImages: UIButton!

    @IBOutlet weak var btnEditIcon: UIButton!
    @IBOutlet weak var btnhaveAQuestion: UIButton!
    @IBOutlet weak var btnEditDescription: UIButton!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnPaymentRequest: UIButton!
    @IBOutlet weak var btnCancelJob: UIButton!
    @IBOutlet weak var btnMakeOffer: UIButton!
    @IBOutlet weak var heighttextview: NSLayoutConstraint!//130
    @IBOutlet weak var topHideImage: NSLayoutConstraint!//188
    @IBOutlet weak var heightHaveAQue: NSLayoutConstraint!//50
    @IBOutlet weak var heightMakeOffer: NSLayoutConstraint!//50
    @IBOutlet weak var heightUpdate: NSLayoutConstraint!//50
    @IBOutlet weak var bottomHaveAQue: NSLayoutConstraint!//11
    @IBOutlet weak var imgService: UIImageView!
    @IBOutlet weak var lblcreationDate: UILabel!
    @IBOutlet weak var lblInactivate: UILabel!
    
    @IBOutlet weak var DescTopLabel: NSLayoutConstraint!//106 //38
    @IBOutlet weak var lblEmgrgHieght: NSLayoutConstraint!//106 //38
    
    @IBOutlet weak var btnChat: UIButton!
    @IBOutlet weak var btnViewLocation: UIButton!
    
    @IBOutlet weak var viewChatContainer: UIView!
    @IBOutlet weak var lblViewLIne: UIView!
    @IBOutlet weak var HeightChatContainer: NSLayoutConstraint!
    
    var categoryData = [String: Any]()
    var selectedMediaImages = [Any]()
    var jobList: JobHistoryData?
    var isFromPending = 0
    var isEdit = Bool()
    var isChat = false
    var StatusType = String()
    var isMakeOfferQuestion = false
    var ismakeoffer = false
    var isOpenFromListing = true
    
    var is_ask_que = false
    var isInProcess = Bool()
    var assets = [PHAsset]()
    var unreadMessageCount = 0
    var conversationId = String()
    var jobChatID = String()
    var arrAllMessages = [[String:Any]]()

    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        lblViewLIne.isHidden = true
        APPDELEGATE?.jobDetailImages = []
        for item in jobList?.media ?? []{
            APPDELEGATE?.jobDetailImages.append(item)
        }
        self.HeightChatContainer.constant = 0
        self.viewChatContainer.isHidden = true
        if isOpenFromListing{
                setContinerOther(VC: "ChatuserListViewController", storyboardName: "Chat", parent: self, container: viewChatContainer) { (vc) in
                    guard let fetchedVC = vc as? ChatuserListViewController else {
                        return
                    }
                    fetchedVC.jobID = self.jobList?._id ?? ""
                    fetchedVC.isFromJobDetail = true
                    fetchedVC.blockChatHeight = { (height, isShowLine) in
                        self.viewChatContainer.isHidden = false
                        self.HeightChatContainer.constant = (97 * height) + 40
                        fetchedVC.setTopHeight()
                        self.lblViewLIne.isHidden = isShowLine
                    }
            }
        }
        APPDELEGATE?.isfromChat()
        IQKeyboardManager.shared.enable = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.makeofferAfterLogin(notification:)), name: Notification.Name("isLogin"), object: nil)

        txtViewDesc.tintColor = UIColor (red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)

        if isEdit == true && self.StatusType == "0" && APPDELEGATE?.selectedUserType == .Client
        {
            self.btnEditIcon.isHidden = false
            self.btnEditDescription.isHidden = false
            self.btnUpdate.isHidden = false
            self.btnMakeOffer.isHidden = true
        }
        else
        {
            self.btnEditIcon.isHidden = true
            self.btnEditDescription.isHidden = true
            self.btnUpdate.isHidden = true
            self.btnMakeOffer.isHidden = false
        }
        onLoadOperations()
        
        if APPDELEGATE?.selectedUserType == .Crafter{
            btnMakeOffer.isHidden = false
            btnhaveAQuestion.isHidden = false
        }else{
            if isEdit == true{
                heightHaveAQue.constant = 0
                bottomHaveAQue.constant = 0
            }else{
                heightHaveAQue.constant = 0
                bottomHaveAQue.constant = 0
                heightUpdate.constant = 0
                heightMakeOffer.constant = 0
            }
            btnMakeOffer.isHidden = true
            btnhaveAQuestion.isHidden = true
        }
        
        if StatusType == "10"{
            self.btnUpdate.isHidden = true
            self.btnMakeOffer.isHidden = true
            btnhaveAQuestion.isHidden = true
            heightHaveAQue.constant = 0
            bottomHaveAQue.constant = 0
            heightUpdate.constant = 0
            heightMakeOffer.constant = 0
        }else if StatusType == "11" || StatusType == "12"{
            self.btnUpdate.isHidden = false
            self.btnUpdate.isEnabled = false
            self.btnMakeOffer.isHidden = true
            btnhaveAQuestion.isHidden = true
            heightHaveAQue.constant = 0
            bottomHaveAQue.constant = 0
            heightMakeOffer.constant = 50
            heightUpdate.constant = 50
            if StatusType == "11"{
                self.btnUpdate.setTitle("Assigned.", for: .normal)
            }else{
                self.btnUpdate.setTitle("Completed.", for: .normal)
            }
        }
        
        self.getjob(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(self.jobList?._id ?? "")", fromQue: false)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        heighttextview.constant = txtViewDesc.contentSize.height
        self.view.layoutIfNeeded()
        self.view.updateConstraints()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }

    @objc func makeofferAfterLogin(notification: Notification) {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
            return
        }
        isChat = true
        
        getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(jobList?._id ?? "")", fromQue: false)
    }

    func onLoadOperations()
    {
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
        //Crafter
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
        
        if self.StatusType == "0" && APPDELEGATE?.selectedUserType == .Client
        {
            self.imgProfile.isHidden = true
            self.lblName.isHidden = true
            self.viewRate.isHidden = true
            self.btnViewProfile.isHidden = true
            self.DescTopLabel.constant = 38
        }
        else
        {
            if self.jobList?.client_id == nil || self.jobList?.client_id == ""
            {
                self.imgProfile.isHidden = true
                self.lblName.isHidden = true
                self.viewRate.isHidden = true
                self.btnViewProfile.isHidden = true
                self.DescTopLabel.constant = 38
            }
            else
            {
                self.imgProfile.isHidden = false
                self.lblName.isHidden = false
                self.viewRate.isHidden = true
                self.btnViewProfile.isHidden = false
                
                self.DescTopLabel.constant = 106
            }
        }
      
        if self.jobList?.full_name == nil || self.jobList?.full_name == ""{
            self.lblName.text = "\(self.jobList?.first_name ?? "")"
        }else{
            let nm = self.jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobList?.full_name ?? "")
            if tempName.count >= 2{
                self.lblName.text = "\(UName)."
            }else{
                self.lblName.text = "\(UName)"
            }
        }
        
        let imgURL = URL(string: jobList?.client_profile_image ?? "")
        imgProfile.kf.setImage(with: imgURL, placeholder: nil)

        let imgURLService = URL(string: jobList?.service_image ?? "")
        imgService.kf.setImage(with: imgURLService, placeholder: nil)
        self.lblcreationDate.text = "Created: \(jobList?.booking_date ?? "")"
        var rate = jobList?.total_rating
        let rate1 = rate?.removeFirst()        
        //let rateData = Int(self.jobList?.total_rating ?? "")
        self.lblRate.text = "\(rate1 ?? "0").0"
        if self.lblRate.text == "0.0" || self.lblRate.text == "" || self.lblRate.text == "0"{
            self.lblRate.text = "NEW"
        }

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
        
        heighttextview.constant = txtViewDesc.contentSize.height
        self.view.layoutIfNeeded()
        self.view.updateConstraints()
        APPDELEGATE?.SelectedLocationAddress = self.jobList?.address ?? ""
        APPDELEGATE?.SelectedLocationCity = self.jobList?.city ?? ""
        APPDELEGATE?.SelectedLocationLat = Double(self.jobList?.client_latitude ?? "0.00")!
        APPDELEGATE?.SelectedLocationLong = Double(self.jobList?.client_longitude ?? "0.00")!
        let gradient = AlphaGradientView.init(frame: CGRect (x: 0.0, y: 0, width: UIScreen.main.bounds.size.width, height: 70))
        gradient.color = UIColor.white
        gradient.direction = GRADIENT_DOWN
        self.viewcontent.addSubview(gradient)
       // self.viewcontent.bringSubviewToFront(gradient)
        setupJobSatatusText()
    }
    
    func setupJobSatatusText()  {
        if self.jobList?.is_archive == "1" || (self.jobList?.cancellation_status == "1" && self.jobList?.cancelled_user_type == "1") || self.jobList?.cancellation_status == "2"{
            lblInactivate.text = "Client cancelled this job."
            btnEditIcon.isUserInteractionEnabled = false
            btnEditIcon.isHidden = true
            
            btnEditDescription.isUserInteractionEnabled = false
            btnEditDescription.isHidden = true
            
            btnMakeOffer.isUserInteractionEnabled = false
            btnhaveAQuestion.isUserInteractionEnabled = false
            btnUpdate.isUserInteractionEnabled = false
            btnViewLocation.isUserInteractionEnabled = false

            //            cell.btnEditChat.isUserInteractionEnabled = false
        }else if self.jobList?.cancellation_status == "1" && self.jobList?.cancelled_user_type == "2"{
            lblInactivate.text = "Crafter cancelled this job."
            btnEditIcon.isUserInteractionEnabled = false
            btnEditIcon.isHidden = true
            
            btnEditDescription.isUserInteractionEnabled = false
            btnEditDescription.isHidden = true
            
            btnMakeOffer.isUserInteractionEnabled = false
            btnhaveAQuestion.isUserInteractionEnabled = false
            btnUpdate.isUserInteractionEnabled = false
            btnViewLocation.isUserInteractionEnabled = false
        }else if self.jobList?.cancellation_status == "3"{
            if self.jobList?.is_acceptable == "1"{
                lblInactivate.text = " "
            }else{
                lblInactivate.text = "Job is under dispute."
            }
            
            btnEditIcon.isUserInteractionEnabled = false
            btnEditIcon.isHidden = true
            
            btnEditDescription.isUserInteractionEnabled = false
            btnEditDescription.isHidden = true
            
            btnMakeOffer.isUserInteractionEnabled = false
            btnhaveAQuestion.isUserInteractionEnabled = false
            btnUpdate.isUserInteractionEnabled = false
            btnViewLocation.isUserInteractionEnabled = false
        }else{
            lblInactivate.text = ""
            btnEditIcon.isUserInteractionEnabled = true
            btnEditDescription.isUserInteractionEnabled = true
            btnMakeOffer.isUserInteractionEnabled = true
            btnhaveAQuestion.isUserInteractionEnabled = true
            btnUpdate.isUserInteractionEnabled = true
            btnViewLocation.isUserInteractionEnabled = true
        }
        
        if self.jobList?.is_acceptable == "1"{
            btnEditIcon.isUserInteractionEnabled = false
            btnEditIcon.isHidden = true
            
            btnEditDescription.isUserInteractionEnabled = false
            btnEditDescription.isHidden = true
            
            btnMakeOffer.isUserInteractionEnabled = false
            btnhaveAQuestion.isUserInteractionEnabled = false
            btnUpdate.isUserInteractionEnabled = false
            btnViewLocation.isUserInteractionEnabled = false
            lblInactivate.text = " "
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.GetJobDetailAPI()
        isChat = false
        if isEdit{
            lblLocation.text = "\(APPDELEGATE?.SelectedLocationAddress ?? "")"
        }
        if APPDELEGATE?.jobDetailImages.count ?? 0 > 0{
            if let mediaData = APPDELEGATE?.jobDetailImages[0] as? media{
                let ext_url = mediaData.media_url!.components(separatedBy: ".").last
                if (mediaData.media_url?.contains(".mp4"))! || (mediaData.media_url?.contains(".mov"))!
                {
                    let url = URL(string: mediaData.media_url!)
                    self.btnSelectImages.isHidden = false

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
                    let imgURL = URL(string: mediaData.media_url!)
                    imgCategory.kf.setImage(with: imgURL, placeholder: nil)
                    btnSelectImages.isHidden = false
                }
            }else if let mediaImage = APPDELEGATE?.jobDetailImages[0] as? UIImage{
                imgCategory.image = mediaImage
            }else if let mediaURL = APPDELEGATE?.jobDetailImages[0] as? URL{
                if (mediaURL.absoluteString.contains(".mp4")) || (mediaURL.absoluteString.contains(".mov")){
                    let path = APPDELEGATE?.jobDetailImages[0] as? URL
                    DispatchQueue.global(qos: .background).async
                        {
                            if let thumbnailImage = generateThumbnail(path: path!)
                            {
                                DispatchQueue.main.async
                                    {
                                        self.imgCategory.image = thumbnailImage
                                }
                            }
                    }

                }else{
                    self.imgCategory.image = UIImage(contentsOfFile: mediaURL.path )
                }
            }else{
                let path = APPDELEGATE?.jobDetailImages[0] as? URL
                DispatchQueue.global(qos: .background).async
                    {
                        if let thumbnailImage = generateThumbnail(path: path!)
                        {
                            DispatchQueue.main.async
                                {
                                    self.imgCategory.image = thumbnailImage
                            }
                        }
                }
                

            }
            btnSelectImages.isHidden = false
        }else{
            imgCategory.image = UIImage (named: "placeholder.jpg")
            imgCategory.backgroundColor = UIColor(red: 101/255, green: 101/255, blue: 101/255, alpha: 0.3)
            btnSelectImages.isHidden = true
        }
    }

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
    
    func setBorderonTextView(color:UIColor){
        self.txtViewDesc.layer.cornerRadius = 8.0
        self.txtViewDesc.layer.borderWidth = 1.0
        self.txtViewDesc.layer.borderColor = color.cgColor
        self.txtViewDesc.layer.masksToBounds = true
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton){
        var assetlist = [PHAsset]()
        for item in assets{
            if (item.creationDate?.minutes(from: Date()))! <= (APPDELEGATE?.deleteImageTimerCounter ?? 0/60) {
                assetlist.append(item)
            }
        }
        if assetlist.count > 0{
            APPDELEGATE?.deletePhoto(assets: assetlist)
        }

        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnHaveQueAction(_ sender: UIButton){
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            let param = ["service_id":"\(jobList?.service_id ?? "")"]
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "makeoffer", data: param, image:[])
            return
        }
        ismakeoffer = false
        self.isChat = true
        self.getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(self.jobList?._id ?? "")", fromQue: true)
        self.is_ask_que = true
    }
    
    @IBAction func btnRedirecttoProfile(_ sender: UIButton)
    {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "", data: [:], image:[])
            return
        }
        
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = jobList?.client_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
    }

    @IBAction func btnMakeOfferAction(_ sender: UIButton)
    {
        if APPDELEGATE?.uerdetail?.user_id == "" ||  APPDELEGATE?.uerdetail?.user_id == nil
        {
            let param = ["service_id":"\(jobList?.service_id ?? "")"]
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "makeoffer", data: param, image:[])
            return
        }
        isChat = true
        ismakeoffer = true
        getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(jobList?._id ?? "")", fromQue: false)
    }
    
    @IBAction func btnMenuAction(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnEditImageAction(_ sender: UIButton)
    {
        showCamera()
    }
    
    @IBAction func btnViewImages(_ sender: UIButton)
    {
        if self.jobList?.media.count ?? 0 > 0 || selectedMediaImages.count > 0{
            let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            objCustomiseProfileVC.arrImages = self.jobList?.media
            objCustomiseProfileVC.arrPreview = self.selectedMediaImages
            objCustomiseProfileVC.OpenFrom = "detail"
            objCustomiseProfileVC.jobID = self.jobList?._id ?? ""
            if isEdit{
                objCustomiseProfileVC.showPreviewAs = .fromOwnJOb
                objCustomiseProfileVC.fromEdit = "yes"
            }else{
                objCustomiseProfileVC.showPreviewAs = .fromOther
            }

            objCustomiseProfileVC.blockCancel = {
            }
            objCustomiseProfileVC.modalPresentationStyle = .fullScreen
            self.present(objCustomiseProfileVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnRequestPayment(_ sender: UIButton){
        if btnPaymentRequest.titleLabel?.text == "REQUEST A PAYMENT"{
            requestForPayment()
        }else if btnPaymentRequest.titleLabel?.text == "ACCEPT CANCELLATION"{
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to accept the job cancellation request?", price: "", completion: { (status) in
                if status{
                    print(status)
                    self.view.isUserInteractionEnabled = false
                    self.cancelJob(cancelStatus: "1")
                }
            })
        }else if btnPaymentRequest.titleLabel?.text == "DEPOSIT FUNDS NOW"{
            initilizePaymentPopup(price: jobList?.remaining_amount ?? self.jobList?.booking_amount ?? "", paymentType: .showDepositView, jobReleasedAmount: "")
        }
    }
    
    @IBAction func btCancelJob(_ sender: UIButton){
        if btnCancelJob.titleLabel?.text == "CANCEL JOB"{
                    let displayPopup = self.displayCancelPopupView()
                    displayPopup.intiWithuserdetail()
                    displayPopup.frame = self.view.bounds
                    self.view.addSubview(displayPopup)
                    displayPopup.blockCancelOption = { option in
                        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to cancel the job?", price: "", completion: { (status) in
                            if status{
                                    self.changeJobStatusandAmount(bookingstatus: "5", amount: "\(self.jobList?.booking_amount ?? "")", isCompleted: false, cancellation_reason: "\(option)")
                            }
                        })
                    }
        }else if btnCancelJob.titleLabel?.text == "DECLINE CANCELLATION"{
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to decline the job cancellation request?", price: "", completion: { (status) in
                if status{
                    print(status)
                    self.getMessages(isPressDecline: true)
                }
            })
        }
    }
    
    func displayCancelPopupView() -> CancelJobPopupView{
        let infoWindow = CancelJobPopupView.instanceFromNib() as! CancelJobPopupView
        return infoWindow
    }
    
    @IBAction func btnEditDescAction(_ sender: UIButton)
    {
        if self.txtViewDesc.isEditable
        {
           self.txtViewDesc.isEditable = false
            self.setBorderonTextView(color:UIColor.clear)
        }
        else
        {
            self.txtViewDesc.isEditable = true
            self.setBorderonTextView(color:UIColor (red: 116.0/255.0, green: 122.0/255.0, blue: 130.0/255.0, alpha: 0.70))
        }
    }
    
    @IBAction func btnUpdateLocationAction(_ sender: UIButton)
    {
        if isEdit{
            let location = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchViewController") as? LocationSearchViewController
            location?.selectedLoc = self.lblLocation.text ?? ""
            self.navigationController?.pushViewController(location!, animated: false)
        }else{
            if (UIApplication.shared.canOpenURL(NSURL(string:"comgooglemaps://")! as URL)) {
                UIApplication.shared.open(URL(string:
                    "comgooglemaps://?saddr=&daddr=\(jobList?.client_latitude ?? ""),\(jobList?.client_longitude ?? "")&directionsmode=driving")!, options: [:], completionHandler: nil)
                
            } else {
                let urlString = "http://maps.google.com/?saddr=\(APPDELEGATE?.CurrentLocationLat ?? 0.00),\(APPDELEGATE?.CurrentLocationLong ?? 0.00)&daddr=\(jobList?.client_latitude ?? ""),\(jobList?.client_longitude ?? "")&directionsmode=driving"
                
                UIApplication.shared.open(URL(string:urlString)!, options: [:], completionHandler: nil)
            }
        }
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton)
    {
        var isdefault = 0
        for i in 0..<appDelegate.jobDetailImages.count{
            var isNew = false
            if let mediaImage = APPDELEGATE?.jobDetailImages[i] as? UIImage{
                isdefault += 1
            }else if let mediaURL = APPDELEGATE?.jobDetailImages[i] as? URL{
                    isdefault += 1
            }
        }
        if isdefault > 0{
            self.EditJobAPIWithImages()
        }else{
            self.EditJobAPI()
        }
    }
    
    @IBAction func btnChatTapped(_ sender: UIButton)
    {
        isChat = true
        getjobListingAllForChat(myId: "\(APPDELEGATE?.uerdetail?._id ?? "")", jobId: "\(jobList?._id ?? "")", fromQue: false)
    }
    
    //Textview DElegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        heighttextview.constant = txtViewDesc.contentSize.height + 10
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    func EditJobAPI()
    {
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "job_id":"\(self.jobList?._id ?? "")","service_id":"\(self.jobList?.service_id ?? "")","address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","longitude":"\(APPDELEGATE?.SelectedLocationLong ?? 0.00)" ,"description":self.txtViewDesc.text!,"is_emergency_job":"\(self.jobList?.is_emergency_job ?? 0)","job_created_date":"\(job_created_date)", "city": "\(APPDELEGATE?.SelectedLocationCity ?? "")"]
        
        WebService.Request.patch(url: createJob, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "jobdetail", message:"\(response?["msg"] as? String ?? "")")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                }
            }
        }
    }
    
    func EditJobAPIWithImages()
    {
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "job_id":"\(self.jobList?._id ?? "")","service_id":"\(self.jobList?.service_id ?? "")","address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","longitude":"\(APPDELEGATE?.SelectedLocationLong ?? 0.00)" ,"description":self.txtViewDesc.text!,"is_emergency_job":"\(self.jobList?.is_emergency_job ?? 0)","job_created_date":"\(job_created_date)", "city": "\(APPDELEGATE?.SelectedLocationCity ?? "")"]
        
        var isdefault = false
        if APPDELEGATE?.jobDetailImages.count ?? 0 > 0{
            if let mediaData = APPDELEGATE?.jobDetailImages[0] as? media{
                isdefault = false
            }else if let mediaImage = APPDELEGATE?.jobDetailImages[0] as? UIImage{
                isdefault = true
            }else if let mediaURL = APPDELEGATE?.jobDetailImages[0] as? URL{
                if (mediaURL.absoluteString.contains(".mp4")) || (mediaURL.absoluteString.contains(".mov")){
                    isdefault = false
                }else{
                    isdefault = true
                }
            }else{
                isdefault = true
            }
        }
        
        var intCount = 0
        var isVideo = false
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
                                self.uploadData(params: params, isDefault: isdefault)
                            }
                        }
                    }catch{}
                }
            }
        }
        if !isVideo{
            self.uploadData(params: params, isDefault: isdefault)
        }
    }
    
    func uploadData(params: [String: String],isDefault: Bool) {
        WebService.Request.uploadMultipleFiles(url: createJob, images : APPDELEGATE!.jobDetailImages, parameters:params, isDefaultImage: isDefault, isBackgroundPerform:false, headerForAPICall : ["Content-type": "multipart/form-data"]){ (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    var assetlist = [PHAsset]()
                    for item in self.assets{
                        if (item.creationDate?.minutes(from: Date()))! <= (APPDELEGATE?.deleteImageTimerCounter ?? 0/60) {
                            assetlist.append(item)
                        }
                    }
                    if assetlist.count > 0{
                        APPDELEGATE?.deletePhoto(assets: assetlist)
                    }
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "jobdetail", message:"\(response?["msg"] as? String ?? "")")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                }
            }
        }
    }
}


//MARK:- Custom Camera
extension JobDetailsVC{
    func showCamera(){
        if APPDELEGATE?.jobDetailImages.count ?? 0 >= 20{
            alertOk(title: "", message: "Only 20 media allowed for a post.")
            return
        }
        let objCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as? CameraVC
        objCamera?.imageSelectionLimit = 20 - (APPDELEGATE?.jobDetailImages.count ?? 0)
        objCamera?.blockCancel = { status in
            if status{
            }
        }
        objCamera?.modalPresentationStyle = .fullScreen
        self.present(objCamera!, animated: true, completion: nil)
    }
}

extension JobDetailsVC{
    func getjobListingAllForChat(myId:String,jobId:String,fromQue:Bool){
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
                        
                        if item.jobdetailID == self.jobList?._id && item.job_id == "\(self.jobList?._id ?? "")\(self.jobList?.handyman_id ?? "")"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    if isAvail {
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,fromQue:fromQue)
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
    
}

//MARK:- Firebase
extension JobDetailsVC{
    
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
                        if item.jobdetailID == self.jobList?._id && item.job_id == "\(self.jobList?._id ?? "")\(item.CrafterId ?? "")"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    if isAvail{
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",fromQue:fromQue,jobdetail:jobDetail!)
                    }else{
                        if fromQue {
                            self.MakeOfferAPI(makeoffer: "2")
                        }else{
                            self.MakeOfferAPI(makeoffer: "1")
                        }
                        let conversationId = fourDigitNumber
                        if APPDELEGATE?.selectedUserType == .Crafter{
                            self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                            self.addJobDetail(userId: "\(self.jobList?.client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                        }else if APPDELEGATE?.selectedUserType == .Client{
                            self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                            self.addJobDetail(userId: "\(self.jobList?.handyman_id ?? "")",conversationId:conversationId, chat_option_status: "1")
                        }
                    }
                }
            }else{
                if fromQue {
                    self.MakeOfferAPI(makeoffer: "2")
                }else{
                    self.MakeOfferAPI(makeoffer: "1")
                }

                let conversationId = fourDigitNumber
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addJobDetail(userId: myId,conversationId:conversationId,chat_option_status: "1")
                    self.addJobDetail(userId: "\(self.jobList?.client_id ?? "")",conversationId:conversationId, chat_option_status: "0")
                }else if APPDELEGATE?.selectedUserType == .Client{
                    self.addJobDetail(userId: myId,conversationId:conversationId, chat_option_status: "0")
                    self.addJobDetail(userId: "\(self.jobList?.handyman_id ?? "")",conversationId:conversationId, chat_option_status: "1")
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
            self.addJobs(userId: userId, jobId: "\(self.jobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?.client_id ?? "")")
        }else if APPDELEGATE?.selectedUserType == .Client{
            self.addJobs(userId: userId, jobId: "\(self.jobList?._id ?? "")", conversationId: conversationId, chat_option_status: chat_option_status, CrafterId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", ClientID: "\(jobList?.handyman_id ?? "")")
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


    func redirecttoChat(conversationId:String,jobId:String,chat_option_status:String,fromQue:Bool,jobdetail:jobsAdded){
        if isChat{
            isChat = false
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
            APPDELEGATE?.isChatViewcontroller = true
            messages?.conversationId = conversationId
            messages?.jobId = jobId
            messages?.isMakeOffer = ismakeoffer
            messages?.isOpenFromQue = fromQue
            messages?.chat_option_status = chat_option_status
            messages?.service_image = jobList?.service_image ?? ""
            messages?.profile_image = jobList?.profile_image ?? ""
            messages?.fullname = jobList?.full_name ?? ""
            if APPDELEGATE?.selectedUserType == .Crafter{
                messages?.CrafterID = APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? "")
            }else{
                messages?.CrafterID = jobList?.handyman_id ?? ""
            }
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            if fromQue{
                messages?.isOpenFromQue = true
            }
            messages?.iskeyboardOpen = false
            self.navigationController?.pushViewController(messages!, animated: true)
        }
    }
    
    //MAKE Offer
    func MakeOfferAPI(makeoffer:String)
    {
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","job_id":"\(jobList?._id ?? "")","handyman_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","is_invite":"","make_offer":makeoffer]
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
                    if fromQue{
                        self.MakeOfferAPI(makeoffer: "2")
                        self.getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(self.jobList?._id ?? "")", fromQue: false)
                    }else{
                        self.MakeOfferAPI(makeoffer: "1")
                        self.getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: "\(self.jobList?._id ?? "")", fromQue: false)
                    }
                } else
                {
                }
            }
        }
    }

}

extension JobDetailsVC{
    func displayPaymentPopupView() -> PaymentPopup{
        let infoWindow = PaymentPopup.instanceFromNib() as! PaymentPopup
        return infoWindow
    }

    func initilizePaymentPopup(price: String, paymentType: popupPaymentType, jobReleasedAmount: String)  {
            let type = PaymentType.depositNow
            let fundsType = type
            
            var paymentPrice = ""
            if paymentPrice == ""{
                paymentPrice = "0"
            }
            
            var booking_Amount = self.jobList?.remaining_amount ?? self.jobList?.booking_amount!
            
            if booking_Amount == ""{
                booking_Amount = self.jobList?.booking_amount!
            }
            
            if type == PaymentType.depositNow{
                booking_Amount = self.jobList?.booking_amount!
            }
            if self.btnPaymentRequest.titleLabel?.text == "DEPOSIT FUNDS NOW" && type == "1"{

                let storyboard = UIStoryboard(name: "Chat", bundle: nil)
                let objCehckout = storyboard.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController
                let strPrice = self.jobList?.booking_amount?.replacingOccurrences(of: " ", with: "")
                objCehckout?.payableAmount = strPrice ?? "0"
                objCehckout?.blockPaymentStatus = { (status, paymentType, transactionID) in
                    if status{
                        self.apiCallForUpdatePaymentStatus(booking_Amount: booking_Amount!, payable_amount: paymentPrice, job_id: (self.jobList?._id!)!, payment_tag: fundsType, Crafter_id: "\(self.jobList?.handyman_id ?? "")",paymentType: paymentType, transactionID: transactionID)
                    }
                }
                objCehckout?.modalPresentationStyle = .fullScreen
                self.present(objCehckout!, animated: true, completion: nil)
            }
    }
    
    
    func apiCallForUpdatePaymentStatus(booking_Amount: String, payable_amount: String, job_id: String, payment_tag: String, Crafter_id: String,paymentType: String = "", transactionID: String = ""){
        //0: none, 1: deposite, 2 : deposite later, 4: release all, 3: release some fund
        var param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")", "job_id":job_id, "user_type":"\(appDelegate.uerdetail?.user_type ?? "")", "payment_tag":payment_tag, "booking_amount":booking_Amount, "payable_amount":payable_amount, "handyman_id":Crafter_id]
        if payment_tag == "1" {
            param["payable_amount"] = booking_Amount
        }
        
        if payment_tag == "4" && (payable_amount == "" || payable_amount == "0") {
            param["payable_amount"] = booking_Amount
        }
        
        if paymentType != ""{
            param["paymentType"] = paymentType
        }
        if transactionID != ""{
            param["transaction_id"] = transactionID
        }

        WebService.Request.patch(url: setPaymentTags, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [String: Any]{
                    if let dataresponse = data["jobs"] as? [String: Any] {
                        do
                        {
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse, options: .prettyPrinted)
                            let JobData = try! JSONDecoder().decode(JobHistoryData.self, from: jsonData)
                            self.jobList = JobData
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.firebaseUpdatePaymentStatus(userId: self.jobList?.client_id ?? "", chatOptionStatus: "\(payment_tag)")
                                self.firebaseUpdatePaymentStatus(userId: APPDELEGATE?.uerdetail?._id ?? "", chatOptionStatus: "\(payment_tag)")
                            }else{
                                self.firebaseUpdatePaymentStatus(userId: APPDELEGATE?.uerdetail?._id ?? "", chatOptionStatus: "\(payment_tag)")
                                self.firebaseUpdatePaymentStatus(userId: self.jobList?.handyman_id ?? "", chatOptionStatus: "\(payment_tag)")
                            }
                            if payment_tag == PaymentType.depositNow{
                                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Your Funds has been deposited successfully.")
                            }else if payment_tag == PaymentType.depositLater{
                                
                            }else if payment_tag == PaymentType.releaseSomeFund{
                                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Your Fund has been released successfully.")
                            }else if payment_tag == PaymentType.releaseAll{
                                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "The whole fund has been released.")
                            }
                            if self.jobList?.payment_tag == PaymentType.depositNow || self.jobList?.payment_tag == PaymentType.releaseAll || self.jobList?.payment_tag == PaymentType.releaseSomeFund{
                                self.sendmessage(message: response!["msg"] as? String ?? "", sendNotif: false,IsSystemMessage: "1")
                            }
                            self.displayButtons()
                        }catch{
                            
                        }
                    }
                }
            }
        }
    }

    func sendmessage(message:String,sendNotif:Bool,isOnlyDisplayOnClientSide: String = "0", isCancelStatus: String = "0", cancelUserID: String = "0" ,IsSystemMessage: String = "0"){
        let messageId = fourDigitNumber
        let timeinterval = getTimeInterval()
        let date = Date()
        var senderID = APPDELEGATE?.uerdetail?.user_id ?? ""
        if isOnlyDisplayOnClientSide == "1" && APPDELEGATE?.selectedUserType == .Client{
            senderID = jobList?.handyman_id ?? ""
        }
        let params = ["message":"\(message)","messageTime":"\(date)","senderId":senderID,"isRead":"\(0)","conversationId":conversationId,"messageid":"\(messageId)","timeinterval":"\(timeinterval)","isOnlyDisplayOnClientSide": isOnlyDisplayOnClientSide, "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? "", "isSystemMessage": IsSystemMessage]

        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: params, options: []) as AnyObject
            let data = try? JSONDecoder().decode(firebaseMessage.self, from: jsonObject as! Data)
            apiCallSendChatToServer(messageData: params, Crafter_id: self.jobList?.handyman_id ?? "", job_id: self.jobList?.job_id ?? "", client_id: self.jobList?.client_id ?? "", message: data!)
        } catch  {
        }

        FirebaseAPICall.firebaseSendMessage(conversationId: conversationId, messageId: messageId, messsageDetail: params) { (status, error, data) in
            if status{
                //Update user detail to Firebase
                self.addtoFirebase(conversationId: self.conversationId, userId: APPDELEGATE?.uerdetail?._id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addtoFirebase(conversationId: self.conversationId, userId: self.jobList?.client_id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                }else{
                    self.addtoFirebase(conversationId: self.conversationId, userId: self.jobList?.handyman_id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                }
                
                //Update Last message read or not
                self.UpdateIsMessageReadOrNot(UserId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", isRead: "0")
                
                //Update  message count
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.updateMessageCounttojob(unreadMessageCountcount: self.unreadMessageCount, userId: self.jobList?.client_id ?? "")
                }else{
                    self.updateMessageCounttojob(unreadMessageCountcount: self.unreadMessageCount, userId: self.jobList?.handyman_id ?? "")
                }
            }
        }
    }
    
    func apiCallSendChatToServer(messageData: [String:Any],Crafter_id: String, job_id: String,client_id: String, message: firebaseMessage){
        var param = messageData
        param["message"] = createChatMessageToSendToServer(arrMessages: message)
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

    func createChatMessageToSendToServer(arrMessages: firebaseMessage) -> String {
        var dict = String()
        if arrMessages.senderId == "\(APPDELEGATE?.uerdetail?.user_id ?? "")"{
            let day = stringToDate(strDate: "\(arrMessages.messageTime ?? "\(Date())")")
            
            if arrMessages.isOnlyDisplayOnClientSide == "1" {
                if APPDELEGATE?.selectedUserType == .Client{
                    dict = "\(arrMessages.message ?? "") your job."
                }else{
                    
                    var Uname = ""
                    let nm = jobList?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobList?.full_name ?? "")
                    if tempName.count >= 2{
                        Uname = "\(UName)."
                    }else{
                        Uname = "\(UName)"
                    }
                    dict = "\(arrMessages.message ?? "") \(Uname)'s job."
                }
            }else if arrMessages.iscancellationType != "0" && arrMessages.iscancellationType != "" && arrMessages.iscancellationType != nil{
                dict = configureData(userType: "sender", message: arrMessages)
            }else{
                dict = arrMessages.message ?? ""
                var Uname = ""
                let nm = APPDELEGATE?.uerdetail?.user_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: APPDELEGATE?.uerdetail?.user_name ?? "")
                if tempName.count >= 2{
                    Uname = "\(UName)."
                }else{
                    Uname = "\(UName)"
                }
            }
        }else{
            let day = stringToDate(strDate: "\(arrMessages.messageTime ?? "\(Date())")")
            if arrMessages.isOnlyDisplayOnClientSide == "1" {
                if APPDELEGATE?.selectedUserType == .Client{
                    dict = "\(arrMessages.message ?? "") your job."
                }else{
                    var Uname = ""
                    let nm = jobList?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobList?.full_name ?? "")
                    if tempName.count >= 2{
                        Uname = "\(UName)."
                    }else{
                        Uname = "\(UName)"
                    }
                    dict = "\(arrMessages.message ?? "") \(Uname)'s job."
                }
            }else if arrMessages.iscancellationType != "0" && arrMessages.iscancellationType != "" && arrMessages.iscancellationType != nil{
                dict = configureData(userType: "receiver", message: arrMessages)
            }else{
                dict = arrMessages.message ?? ""
                var Uname = ""
                let nm = jobList?.full_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: jobList?.full_name ?? "")
                if tempName.count >= 2{
                    Uname = "\(UName)."
                }else{
                    Uname = "\(UName)"
                }
            }
        }
        return dict
    }

    func addtoFirebase(conversationId:String,userId:String,timeinterval:String,time:Date,message:String, isCancelStatus: String = "0", cancelUserID: String = "0"){
        
        let param = ["lastmessage":"\(message)","lastmessagetime":"\(time)","timeinterval":"\(timeinterval)","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? ""] as [String : Any]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userId, jobId: self.jobChatID, ChatuserDetail: param, completion:{ (status) in
            if status{
                
            }
        })
    }
    
    func UpdateIsMessageReadOrNot(UserId:String,isRead:String){
        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: self.jobChatID, detail: param, completion: { (status) in
            
        })
    }
    
    func updateMessageCounttojob(unreadMessageCountcount:Int,userId:String){
        
        self.unreadMessageCount += 1
        let param = ["unreadMessageCount":unreadMessageCountcount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobList?._id ?? "", detail: param, completion: { (status) in
            
        })
    }
    
    func firebaseUpdatePaymentStatus(userId:String,chatOptionStatus:String){
        
        let param = ["payment_tag":chatOptionStatus]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: self.jobChatID, detail: param, completion: { (status) in
            
        })
    }
    
    func getOponnentMessageCount(userId:String){
        
        FirebaseJobAPICall.firebaseGetJobDEtail(myId: userId, jobId: self.jobChatID, completion: { (status, error, data) in
            if status{
                let detail = data as? [String:Any]
                self.unreadMessageCount = detail?["unreadMessageCount"] as? NSInteger ?? 0
            }
        })
    }
    
    func getjob(myId:String,jobId:String,fromQue:Bool){
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
                        
                        if item.jobdetailID == self.jobList?._id && item.job_id == "\(self.jobList?._id ?? "")\(self.jobList?.handyman_id ?? "")"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    if isAvail{
                        self.conversationId = jobDetail?.conversationId ?? ""
                        self.jobChatID = jobDetail?.job_id ?? ""
                    }else{}
                }
            }else{
            }
            if isLoad{
                APPDELEGATE?.hideProgrssVoew()
                isLoad = false
            }
        }
    }

    func displayButtons() {
        btnCancelJob.isHidden = true
        btnPaymentRequest.isHidden = true
        if jobList?.booking_status == "2" || jobList?.booking_status == "3" || jobList?.booking_status == "4" || jobList?.booking_status == "5"
        {
            btnPaymentRequest.isHidden = false
            btnCancelJob.isHidden = false
            self.btnChat.isHidden = true
            self.btnUpdate.isHidden = true
            self.btnUpdate.isEnabled = true
            self.btnMakeOffer.isHidden = true
            btnhaveAQuestion.isHidden = true
            if APPDELEGATE?.selectedUserType == .Crafter{
                if jobList?.payment_array.count ?? 0 > 0{
                    heightHaveAQue.constant = 0
                    bottomHaveAQue.constant = 0
                    heightMakeOffer.constant = 50
                    heightUpdate.constant = 50
                    btnCancelJob.setTitle("CANCEL JOB", for: .normal)
                    btnPaymentRequest.isHidden = true
                    if jobList?.is_acceptable == "1"{
                        btnCancelJob.isHidden = true
                    }
                }else{
                    heightHaveAQue.constant = 50
                    bottomHaveAQue.constant = 11
                    heightMakeOffer.constant = 50
                    heightUpdate.constant = 50
                    btnCancelJob.setTitle("CANCEL JOB", for: .normal)
                    self.btnPaymentRequest.setTitle("REQUEST A PAYMENT", for: .normal)
                }
                if jobList?.cancelled_user_type == "1" && jobList?.cancellation_status == "2"{
                    btnPaymentRequest.isHidden = false
                    btnCancelJob.isHidden = false
                    heightHaveAQue.constant = 50
                    bottomHaveAQue.constant = 11
                    heightMakeOffer.constant = 50
                    heightUpdate.constant = 50
                    btnCancelJob.setTitle("DECLINE CANCELLATION", for: .normal)
                    self.btnPaymentRequest.setTitle("ACCEPT CANCELLATION", for: .normal)
                }else if jobList?.cancellation_status == "1" || jobList?.cancellation_status == "3"{
                    btnPaymentRequest.isHidden = true
                    btnCancelJob.isHidden = true
                    heightHaveAQue.constant = 0
                    bottomHaveAQue.constant = 0
                    heightMakeOffer.constant = 0
                    heightUpdate.constant = 0
                }
            }else{
                if jobList?.payment_array.count ?? 0 > 0{
                    heightHaveAQue.constant = 0
                    bottomHaveAQue.constant = 0
                    heightMakeOffer.constant = 50
                    heightUpdate.constant = 50
                    btnCancelJob.setTitle("CANCEL JOB", for: .normal)
                    btnPaymentRequest.isHidden = true
                }else{
                    heightHaveAQue.constant = 50
                    bottomHaveAQue.constant = 11
                    heightMakeOffer.constant = 50
                    heightUpdate.constant = 50
                    btnCancelJob.setTitle("CANCEL JOB", for: .normal)
                    self.btnPaymentRequest.setTitle("DEPOSIT FUNDS NOW", for: .normal)
                }
                
                if jobList?.cancellation_status == "1" || jobList?.cancellation_status == "2" || jobList?.cancellation_status == "3"{
                    btnPaymentRequest.isHidden = true
                    btnCancelJob.isHidden = true
                    heightHaveAQue.constant = 0
                    bottomHaveAQue.constant = 0
                    heightMakeOffer.constant = 0
                    heightUpdate.constant = 0
                }
            }
        }
        else
        {
            self.btnChat.isHidden = true
            if jobList?.cancellation_status == "1" || jobList?.cancellation_status == "2" || jobList?.cancellation_status == "3" || jobList?.is_archive == "1"{
                btnPaymentRequest.isHidden = true
                btnCancelJob.isHidden = true
                btnhaveAQuestion.isHidden = true
                btnMakeOffer.isHidden = true
                heightHaveAQue.constant = 0
                bottomHaveAQue.constant = 0
                heightMakeOffer.constant = 0
                heightUpdate.constant = 0
            }
        }
        if jobList?.is_acceptable == "1"{
            btnPaymentRequest.isHidden = true
            btnCancelJob.isHidden = true
            btnhaveAQuestion.isHidden = true
            btnMakeOffer.isHidden = true
            heightHaveAQue.constant = 0
            bottomHaveAQue.constant = 0
            heightMakeOffer.constant = 0
            heightUpdate.constant = 0
        }
        
        if jobList?.booking_status == "4"{
            btnPaymentRequest.isHidden = true
            btnCancelJob.isHidden = true
            btnhaveAQuestion.isHidden = true
            btnMakeOffer.isHidden = true
            heightHaveAQue.constant = 0
            bottomHaveAQue.constant = 0
            heightMakeOffer.constant = 0
            heightUpdate.constant = 0
        }
    }
    
    //Send Quote and CHnage Job Status
    func changeJobStatusandAmount(bookingstatus: String,amount:String,isCompleted:Bool, cancellation_reason: String = "0"){
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = formatter.string(from: Date())


        var param = ["job_id":"\(jobList?._id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","booking_status":"\(bookingstatus)","booking_amount":"\(amount)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","description": "\(getjobdesc())","complete_time": timeString,"cancellation_reason": cancellation_reason]
        if APPDELEGATE?.selectedUserType == .Crafter
        {
            param["handyman_id"] = "\(APPDELEGATE!.uerdetail?.user_id ?? "")"
        }else{
            param["handyman_id"] = self.jobList?.handyman_id
        }
        WebService.Request.patch(url: changeJobStatus, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let dataresponse = response!["data"] as? [String: Any]{
                    do
                    {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataresponse, options: .prettyPrinted)
                        let JobData = try! JSONDecoder().decode(JobHistoryData.self, from: jsonData)
                        self.jobList = JobData

                        var isCancelStatus = ""
                        var cancelUserID = appDelegate.uerdetail?._id ?? ""
                        
                        if bookingstatus == "5" && appDelegate.selectedUserType == .Crafter{
                            isCancelStatus = "1"
                            cancelUserID = appDelegate.uerdetail?._id ?? ""
                        }else if bookingstatus == "5" && appDelegate.selectedUserType == .Client{
                            if self.jobList?.payment_array.count ?? 0 > 0{
                                isCancelStatus = "2"
                            }else{
                                isCancelStatus = "1"
                            }
                        }
                        self.updateChatStatus(userid: self.jobList?.client_id ?? "", jobId: self.jobList?.job_id ?? "")
                        self.updateChatStatus(userid: self.jobList?.handyman_id ?? "", jobId: self.jobList?.job_id ?? "")

                        self.sendmessage(message: response!["msg"] as? String ?? "", sendNotif: false, isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                    }catch{
                        
                    }
                    self.displayButtons()
                }
            }
        }
    }

    //Get All Messages
    func getMessages(isPressDecline: Bool){
        if conversationId == ""{
            return
        }
        var declined = isPressDecline
        APPDELEGATE?.addProgressView()
        self.view.isUserInteractionEnabled = false
        FirebaseAPICall.firebaseGetMessages(conversationId: conversationId) { (status, error, data) in
            if status{
                if data != nil{
                    do
                    {
                        let arrmessages = try! JSONDecoder().decode([firebaseMessage].self, from: data! as! Data)
                        self.arrAllMessages = self.createArrayForPDF(arrMessages: arrmessages)
                     //   print(self.arrAllMessages)
                        if declined{
//                            self.arrAllMessages.append()
                            self.cancelJob(cancelStatus: "2")
                        }
                        declined = false
                    }
                }else{
                    self.view.isUserInteractionEnabled = true
                }
            }else{
                self.view.isUserInteractionEnabled = true
            }
        }
    }

    func convertToJsonString(from object:[[String:Any]]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    //Send Quote and CHnage Job Status
    func cancelJob(cancelStatus: String){
//        "cancellation_status" (1 : accept cancellation, 2 : declined cancellation)
        var param = ["job_id":"\(jobList?._id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","cancellation_status":"\(cancelStatus)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")"]
        if cancelStatus == "2"{
            if arrAllMessages.count > 0{
                var dict = [String:Any]()
                if cancelStatus == "2"{
                    dict["user_type"] = "\(APPDELEGATE?.uerdetail?.user_type ?? "")"
                    let day = stringToDate(strDate: "\(Date())")
                    dict["time"] = timeAgoSinceDate(day)
                    dict["message"] = crafterCancelJobCancellationForPDF
                    dict["name"] = "Craftio"
                    arrAllMessages.append(dict)
                }else if cancelStatus == "1"{
                    dict["user_type"] = "\(APPDELEGATE?.uerdetail?.user_type ?? "")"
                    let day = stringToDate(strDate: "\(Date())")
                    dict["time"] = timeAgoSinceDate(day)
                    dict["message"] = crafterAcceptJobCancellationForPDF
                    dict["name"] = "Craftio"
                    arrAllMessages.append(dict)
                }
                param["messages"] = "\(convertToJsonString(from: arrAllMessages) ?? "")"
            }else{
                return
            }
        }
        APPDELEGATE?.addProgressView()
        WebService.Request.patch(url: changeJobCancellationStatus, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let dataresponse = response!["data"] as? [String: Any]{
                    do
                    {
                        let jsonData = try JSONSerialization.data(withJSONObject: dataresponse, options: .prettyPrinted)
                        let JobData = try! JSONDecoder().decode(JobHistoryData.self, from: jsonData)
                        self.jobList = JobData
                        var isCancelStatus = ""
                        let cancelUserID = appDelegate.uerdetail?._id ?? ""
                        
                        if cancelStatus == "1" {
                            isCancelStatus = "4"
                            self.sendmessage(message: response!["msg"] as? String ?? "", sendNotif: false,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                        }else if cancelStatus == "2" {
                                isCancelStatus = "3"
                            let pdfUrl = response!["pdfUrl"] as? String
                            self.sendmessage(message: pdfUrl ?? "", sendNotif: false,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                        }
                        
                    }catch{
                        
                    }

                    self.displayButtons()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.view.isUserInteractionEnabled = true
                APPDELEGATE?.hideProgrssVoew()
            }
        }
    }
    func updateChatStatus(userid:String,jobId:String){
        let param = ["chat_option_status":"15"]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userid, jobId: jobId, ChatuserDetail: param) { (status) in
        }
    }
    func requestForPayment(){
        //        "cancellation_status" (1 : accept cancellation, 2 : declined cancellation)
        let param = ["job_id":"\(jobList?._id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")"]
        WebService.Request.patch(url: sendPaymentRequest, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Your request for payment successfully sent to client.")
                }
            }
        }
    }


    func getjobdesc() -> String{
        if jobList?.description?.count ?? 0 > 15 {
            return String((jobList?.description!.prefix(15))!)
        }else{
            return (jobList?.description!)!
        }
    }
    
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
        APPDELEGATE?.addProgressView()
//        self.view.isUserInteractionEnabled = false
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
                                self.heighttextview.constant = self.txtViewDesc.contentSize.height
                                self.view.layoutIfNeeded()
                                self.view.updateConstraints()
                                self.displayButtons()
                            }
                        }catch{
                            
                        }
                    }
                }
            }
            self.displayButtons()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                self.view.isUserInteractionEnabled = true
                APPDELEGATE?.hideProgrssVoew()
            }
        }
    }

    func createArrayForPDF(arrMessages: [firebaseMessage]) -> [[String:Any]] {
        var arrDict = [[String:Any]]()
        for item in arrMessages{
            var dict = [String:Any]()
            dict["user_type"] = item.senderUserType
            if item.senderId == "\(APPDELEGATE?.uerdetail?.user_id ?? "")"{
                let day = stringToDate(strDate: "\(item.messageTime ?? "\(Date())")")
                dict["time"] = timeAgoSinceDate(day)
                
                if item.isOnlyDisplayOnClientSide == "1" {
                    if APPDELEGATE?.selectedUserType == .Client{
                        dict["message"] = "\(item.message ?? "") your job."
                    }else{
                        
                        var Uname = ""
                        let nm = jobList?.full_name ?? ""
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: jobList?.full_name ?? "")
                        if tempName.count >= 2{
                            Uname = "\(UName)."
                        }else{
                            Uname = "\(UName)"
                        }
                        dict["message"] = "\(item.message ?? "") \(Uname)'s job."
                    }
                    dict["name"] = "Craftio"
                }else if item.iscancellationType != "0" && item.iscancellationType != "" && item.iscancellationType != nil{
                    dict["message"] = configureData(userType: "sender", message: item)
                    dict["name"] = "Craftio"
                }else{
                    dict["message"] = item.message
                    
                    var Uname = ""
                    let nm = APPDELEGATE?.uerdetail?.user_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: APPDELEGATE?.uerdetail?.user_name ?? "")
                    if tempName.count >= 2{
                        Uname = "\(UName)."
                    }else{
                        Uname = "\(UName)"
                    }
                    dict["name"] = Uname 
                }
                if item.isSystemMessage == "1"{
                    dict["name"] = "Craftio"
                }

            }else{
                let day = stringToDate(strDate: "\(item.messageTime ?? "\(Date())")")
                dict["time"] = timeAgoSinceDate(day)
                if item.isOnlyDisplayOnClientSide == "1" {
                    if APPDELEGATE?.selectedUserType == .Client{
                        dict["message"] = "\(item.message ?? "") your job."
                    }else{
                        var Uname = ""
                        let nm = jobList?.full_name ?? ""
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: jobList?.full_name ?? "")
                        if tempName.count >= 2{
                            Uname = "\(UName)."
                        }else{
                            Uname = "\(UName)"
                        }
                        dict["message"] = "\(item.message ?? "") \(Uname)'s job."
                    }
                    dict["name"] = "Craftio"
                }else if item.iscancellationType != "0" && item.iscancellationType != "" && item.iscancellationType != nil{
                    dict["message"] = configureData(userType: "receiver", message: item)
                    dict["name"] = "Craftio"
                }else{
                    dict["message"] = item.message
                    var Uname = ""
                    let nm = jobList?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobList?.full_name ?? "")
                    if tempName.count >= 2{
                        Uname = "\(UName)."
                    }else{
                        Uname = "\(UName)"
                    }
                    dict["name"] = Uname 
                }
                if item.isSystemMessage == "1"{
                    dict["name"] = "Craftio"
                }
            }
            arrDict.append(dict)
        }
        return arrDict
    }
    
    func configureData(userType: String, message: firebaseMessage) -> String {
        if userType == "sender"{
            if appDelegate.selectedUserType == .Crafter{
                if message.iscancellationType == "1" && message.senderUserType == Crafter{
                    return "You \(crafterCancelJobOwnMessage)"
                }else if message.iscancellationType == "1" && message.senderUserType == Client{
                    return "Client \(clientCancelJobCrafterMessage)"
                }else if message.iscancellationType == "2" && message.senderUserType == Client{
                    return "Client \(clientCancelJobAfterPaymentCrafterMessage)"
                }else if message.iscancellationType == "4" && message.senderUserType == Crafter{
                    return "You \(crafterAcceptJobCancellationOwnMessage)"
                }else if message.iscancellationType == "3" && message.senderUserType == Crafter{
                    return "You \(crafterCancelJobCancellationOwnMessage)"
                }
            }else{
                if message.iscancellationType == "1" && message.senderUserType == Crafter && self.jobList?.payment_array.count ?? 0 > 0{
                    return "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if message.iscancellationType == "1" && message.senderUserType == Crafter && self.jobList?.payment_array.count == 0{
                    return "Crafter \(crafterCancelJobClientMessage)"
                }else if message.iscancellationType == "1" && message.senderUserType == Client{
                    return "You \(clientCancelJobOwnMessage)"
                }else if message.iscancellationType == "2" && message.senderUserType == Client{
                    return "Your \(clientCancelJobAfterPaymentOwnMessage)"
                }else if message.iscancellationType == "4" && message.senderUserType == Crafter{
                    return "Crafter \(crafterAcceptJobCancellationClientMessage)"
                }else if message.iscancellationType == "3" && message.senderUserType == Crafter{
                    return "Crafter \(crafterCancelJobCancellationClientMessage) \(message.message ?? "")"
                }
            }
        }else if userType == "receiver"{
            if appDelegate.selectedUserType == .Crafter{
                if message.iscancellationType == "1" && message.senderUserType == Crafter{
                    return "You \(crafterCancelJobOwnMessage)"
                }else if message.iscancellationType == "1" && message.senderUserType == Client{
                    return "Client \(clientCancelJobCrafterMessage)"
                }else if message.iscancellationType == "2" && message.senderUserType == Client{
                    return "Client \(clientCancelJobAfterPaymentCrafterMessage)"
                }else if message.iscancellationType == "4" && message.senderUserType == Crafter{
                    return "You \(crafterAcceptJobCancellationOwnMessage)"
                }else if message.iscancellationType == "3" && message.senderUserType == Crafter{
                    return "You \(crafterCancelJobCancellationOwnMessage)"
                }
            }else{
                if message.iscancellationType == "1" && message.senderUserType == Crafter && jobList?.payment_array.count ?? 0 > 0{
                    return "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if message.iscancellationType == "1" && message.senderUserType == Crafter && jobList?.payment_array.count == 0{
                    return "Crafter \(crafterCancelJobClientMessage)"
                }else if message.iscancellationType == "1" && message.senderUserType == Client{
                    return "You \(clientCancelJobOwnMessage)"
                }else if message.iscancellationType == "2" && message.senderUserType == Client{
                    return "Your \(clientCancelJobAfterPaymentOwnMessage)"
                }else if message.iscancellationType == "4" && message.senderUserType == Crafter{
                    return "Crafter \(crafterAcceptJobCancellationClientMessage)"
                }else if message.iscancellationType == "3" && message.senderUserType == Crafter{
                    return "Crafter \(crafterCancelJobCancellationClientMessage) \(message.message ?? "")"
                }
            }
        }
        return ""
    }
}
