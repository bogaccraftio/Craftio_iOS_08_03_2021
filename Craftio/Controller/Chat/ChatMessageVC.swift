
import UIKit
import IQKeyboardManagerSwift
import AVKit

class ChatMessageVC: UIViewController,UITextViewDelegate, UIGestureRecognizerDelegate
{
    @IBOutlet weak var imgprofile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var tblChat: UITableView!
    @IBOutlet weak var txtMessage: UITextView!
    @IBOutlet weak var viewaccept: UIView!
    @IBOutlet weak var viewquote: UIView!
    @IBOutlet weak var viewacceptDecline: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var viewComplete: UIView!
    @IBOutlet weak var heightViewbottom: NSLayoutConstraint!//73 (- 66)
    @IBOutlet weak var heightMessageview: NSLayoutConstraint!//54 (+ 16)
    @IBOutlet weak var heightoppUps: NSLayoutConstraint!//66 (+ 16)
    @IBOutlet weak var bottomconstraint: NSLayoutConstraint!//54 (+ 16)
    @IBOutlet weak var btnQuote: UIButton!
    @IBOutlet weak var btnyesIAccept: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnCounter: UIButton!
    @IBOutlet weak var btnDepositFundsNow: UIButton!
    @IBOutlet weak var viewPopups: UIView!
    @IBOutlet weak var lblPriceSymbol: UILabel!

    @IBOutlet weak var btnViewProfile: UIButton!
    @IBOutlet weak var btnOption: UIButton!
    @IBOutlet weak var btnJobOption: UIButton!
    @IBOutlet weak var btnSendMessage: UIButton!
    @IBOutlet weak var btnMessageViewGiveQuote: UIButton!
    @IBOutlet weak var btnMessageViewAccept: UIButton!
    @IBOutlet weak var imgViewjob: UIImageView!

    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var ImgRate1: UIImageView!
    @IBOutlet weak var ImgRate2: UIImageView!
    @IBOutlet weak var ImgRate3: UIImageView!
    @IBOutlet weak var ImgRate4: UIImageView!
    @IBOutlet weak var ImgRate5: UIImageView!
    @IBOutlet weak var lblJobs: UILabel!
    @IBOutlet weak var lblJobDescription: UILabel!
    @IBOutlet weak var lblJobPrice: UILabel!
    @IBOutlet weak var imgDefaultJob: UIImageView!
    
    @IBOutlet weak var tblReleasedFund: UITableView!
    @IBOutlet weak var viewReleasedFund: UIView!
    @IBOutlet weak var heightviewReleasedFund: NSLayoutConstraint!//40
    @IBOutlet weak var lblReleasedFund: UILabel!
    @IBOutlet weak var heightTblReleaseFundConstraint: NSLayoutConstraint!// Cell height 40
    
    @IBOutlet weak var viewClientCancel: UIView!
    @IBOutlet weak var btnAcceptCancellation: UIButton!
    @IBOutlet weak var btnDeclineCancellation: UIButton!
    @IBOutlet weak var btnCancellationMessage: UIButton!
    @IBOutlet weak var lblSendQuote: UILabel!
    @IBOutlet weak var TrailingOfView: NSLayoutConstraint!
    @IBOutlet weak var TrailingbtnMessageViewAccept: NSLayoutConstraint!

    


    var jobDetail: JobHistoryData?
    var conversationId = String()
    var arrmessages = [firebaseMessage]()
    var chat_option_status = String()
    var jobId = String()
    var jobdetailID = String()
    var quoteSelected = false
    var isaccepted = false
    var isCounterSelected = false
    var jobprice = String()
    var unreadMessageCount = 0
    var isBlocked = false
    var jobdesc = String()
    var jobConversionId = String()
    var isSendNotification = true
    var Servicename = String()
    var isOpenFromQue = false
    var is_block = String()
    var opponentUserid = String()
    var currentUserId = String()
    var jobaddedDetail: jobsAdded?
    var service_image = String()
    var profile_image = String()
    var fullname = String()
    var username = String()
    var JobStatus = String()
    var CrafterID = String()
    var isMakeOffer = false
    var isFirstTime = false
    var fundsType:String = PaymentType.none
    var isSummaryTapped = true
    var iskeyboardOpen = false
    var CrafterPayableAmount = "0.99"
    var deviceToken = String()
    var oponentsTotalChatCount = 0
    var isAlreadyPendingToRead = false
    var arrAllMessages = [[String:Any]]()
    var badgeCountOponnent = 0
    var sendQuoteLabel = "To send your Quote, a fee of £0.99 is applied. Do you accept?"
    var unlimitedFreeQuoteText = "UNLIMITED"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isFirstTime = true
        viewClientCancel.isHidden = true
        txtMessage.text = APPDELEGATE?.ChatMessage_PlaceHolder
        btnMessageViewAccept.backgroundColor = APPDELEGATE?.appGreenColor
        btnCancellationMessage.backgroundColor = APPDELEGATE?.appGreenColor
        heightTblReleaseFundConstraint.constant = 0
        heightviewReleasedFund.constant = 0
        viewReleasedFund.isHidden = true
        hideDepositFundButton(isHide: true)
        currentUserId = "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))"
        if self.iskeyboardOpen == true
        {
            self.txtMessage.becomeFirstResponder()
        }
        tblChat.keyboardDismissMode = .interactive
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        txtMessage.keyboardType =  UIKeyboardType.alphabet
        self.isBlocked = false
         inAppInitialization()
        //Keyboard Hide/Show
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
        NotificationCenter.default.addObserver(self, selector: #selector(self.JobNotificationPayment(_:)), name: NSNotification.Name(rawValue: "JobNotificationPayment"), object: nil)

        let imgURL = URL(string: profile_image)
        
        self.imgprofile?.kf.setImage(with: imgURL, placeholder: nil)
        
        if fullname == ""{
            if username == ""{
                self.lblName.text = ""
            }else{
                let nm = username
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: username)
                if tempName.count >= 2{
                    self.lblName.text = "\(UName)."
                }else{
                    self.lblName.text = "\(UName)"
                }
            }
        }else{
            let nm = fullname
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: fullname)
            if tempName.count >= 2{
                self.lblName.text = "\(UName)."
            }else{
                self.lblName.text = "\(UName)"
            }
        }
        
        let imgURLservice = URL(string: service_image)
        self.imgViewjob?.kf.setImage(with: imgURLservice, placeholder: nil)

        
        APICallchangeNotificationCount()

        //Display Quote,Accept popup as Per it's Tag
        self.setPopups()
        
        //Get Current chat status
        self.getJObChatStatus()
        
        self.onLoadOperations()
        
        //add Tap gesture for Hide Keyboard on Table view
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        tap.numberOfTapsRequired = 2
        self.tblChat.addGestureRecognizer(tap)
        if isMakeOffer{
            setPopups()
        }else{
            txtMessage.keyboardType = .alphabet
            btnMessageViewGiveQuote.backgroundColor = APPDELEGATE?.appGreenColor
            btnQuote.backgroundColor = UIColor.white
        }
        self.txtMessage.autocorrectionType = .yes
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APPDELEGATE?.ChatjobID = jobId
        APPDELEGATE?.selectedChatUser = conversationId
    }
    
    @objc func JobNotificationPayment(_ notification: NSNotification) {
        GetJobDetailAPI()
    }

    @objc func handleTap(sender: UITapGestureRecognizer? = nil)
    {
        self.view.endEditing(true)
    }

    func onLoadOperations()
    {
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "JobNotificationPayment"), object: nil)
        updateMessageCounttojob(unreadMessageCountcount: 0, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
        self.UpdateIsMessageReadOrNot(UserId: self.opponentUserid, isRead: "1")
        APICallchangeNotificationCount()
        APPDELEGATE?.ChatjobID = ""
        APPDELEGATE?.selectedChatUser = ""
        APPDELEGATE?.freequoteExpireDate = ""
        APPDELEGATE?.freequoteQty = 0
        APPDELEGATE?.freeremainingQuote = "0"
        self.readChatNotification()
    }
    
    @IBAction func btnback(_ sender: Any) {
        self.view.endEditing(true)
        APPDELEGATE?.isfromChat()
        APPDELEGATE?.freequoteExpireDate = ""
        APPDELEGATE?.freequoteQty = 0
        APPDELEGATE?.freeremainingQuote = "0"
        updateMessageCounttojob(unreadMessageCountcount: 0, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
        self.UpdateIsMessageReadOrNot(UserId: self.opponentUserid, isRead: "1")
        self.navigationController?.popViewController(animated: true)
    }
    
    func deletedata(userID:String){
        FirebaseJobAPICall.firebasedelete(myId: userID, jobId: jobId) { (status) in
            
        }
    }
    
    @IBAction func btnViewProfile(_ sender: UIButton)
    {
        if APPDELEGATE!.selectedUserType == .Crafter
        {//OPEN Client Profile
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = jobDetail?.client_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
        else
        {//OPEN Crafter Profile
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 2
            objProfileVC.strTag = "Crafter"
            objProfileVC.CrafterId = self.opponentUserid
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
    }
    
    @IBAction func btnViewJob(_ sender: Any) {
        if chat_option_status == changeChatStatus.Decline || chat_option_status == changeChatStatus.Completed || chat_option_status == changeChatStatus.done{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let objJobDetailsVC = storyboard.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
                objJobDetailsVC.jobList = self.jobDetail
                objJobDetailsVC.isOpenFromListing = false
                self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                
                let objJobDetailsVC = storyboard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                objJobDetailsVC.isEdit = false
                objJobDetailsVC.jobList = self.jobDetail
                objJobDetailsVC.StatusType = "10"
                objJobDetailsVC.isOpenFromListing = false
                self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
            }
    }
    
    @IBAction func btnBlock(_ sender: Any) {
        let displayPopup = displayPopupView()
        var popupOption = 0
        var isJobAccrpted = false
        if chat_option_status == changeChatStatus.Decline || chat_option_status == changeChatStatus.Completed || chat_option_status == changeChatStatus.done{
            popupOption = 5
        }else{
            popupOption = 1

            if chat_option_status == changeChatStatus.Accept{
                isJobAccrpted = true
            }
        }
        if APPDELEGATE?.selectedUserType == .Crafter{
            displayPopup.intiWithuserdetail(userdetail: [:], displayPopUp: popupOption, isfrom: "", userID: "\(jobDetail?.client_id ?? "")", oponnentuserid: opponentUserid, jobID: jobdetailID, is_block: self.is_block, conversationIdJob: conversationId, isReview: jobDetail?.is_review ?? "",isJobAccrpted: isJobAccrpted)
        }else{
            displayPopup.intiWithuserdetail(userdetail: [:], displayPopUp: popupOption, isfrom: "", userID: opponentUserid, oponnentuserid: opponentUserid, jobID: jobdetailID, is_block: self.is_block, conversationIdJob: conversationId, isReview: jobDetail?.is_review ?? "",isJobAccrpted: isJobAccrpted)
        }
        displayPopup.frame = self.view.bounds
        self.view.addSubview(displayPopup)
        self.view.endEditing(true)
    }
    
    func displayPopupView() -> PopupView{
        let infoWindow = PopupView.instanceFromNib() as! PopupView
        return infoWindow
    }

    @IBAction func btnsendMessage(_ sender: Any) {
        if self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
            return
        }
        sendmessageTOFIrebase()
    }
    
    func sendmessageTOFIrebase(){
        iskeyboardOpen = false
        if quoteSelected == true{// For Quote from Crafter
            if isaccepted || self.jobDetail?.chat_option_status == "1"{
                if self.chat_option_status == changeChatStatus.NotAny || self.jobDetail?.chat_option_status == "1"{
                    if txtMessage.text == "" || self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
                    }else{
                        self.txtMessage.resignFirstResponder()
                        self.jobprice = self.txtMessage.text ?? "£"
                        self.txtMessage.text = ""
                        self.lblPriceSymbol.text = ""
                        WebService.Loader.show()
                        sendQuoteNotification(notification_tag: "1",quote: jobprice){ (status) in
                            self.quoteSelected = false
                            self.isaccepted = false
                            self.setPopups()

                            //Update Job Status
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.NotAny)")
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Accept_Decline_Counter)", isHideProgress: true)
                            }else{
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.NotAny)")
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Accept_Decline_Counter)", isHideProgress: true)
                            }
                            
                            //Update Quote
                           self.updateQuoteFirebase(userId: self.currentUserId, quote: self.jobprice)
                            self.updateQuoteFirebase(userId: self.opponentUserid, quote: self.jobprice)
                            
                            //Send Message
                            self.sendmessage(message: "I can do this job for £\(self.jobprice )",sendNotif:true)
                            self.txtMessage.keyboardType =  UIKeyboardType.alphabet
                        }
                    }
                }
            }else{
                if txtMessage.text == "" || self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
                    return
                }
                txtMessage.resignFirstResponder()
                if (APPDELEGATE?.bankDetailNotFilled == .No || APPDELEGATE?.bankDetailNotFilled == bankDetailFilled.none) && APPDELEGATE!.selectedUserType == .Crafter{
                    APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Your bank details not filled fully please fill it by pressing YES.", completion: { (status) in
                        if status{
                        let storyboard = UIStoryboard(name: "Main", bundle: nil)
                        let objNotifySettingsVC = storyboard.instantiateViewController(withIdentifier: "BankingFormVC") as! BankingFormVC
                            objNotifySettingsVC.openFrom = .chat
                        self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
                            
                        }else{
                        }
                    })
                    return
                }
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please first accept our condition regarding fees.")
                self.chat_option_status = changeChatStatus.YesIAccept
                setPopups()
            }
        }else if isCounterSelected{// For Counter Quote from Client and Crafter
            if txtMessage.text == "" || self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
            }else{
                self.chat_option_status = changeChatStatus.NotAny
                jobprice = txtMessage.text ?? "£"
                self.txtMessage.text = ""
                self.lblPriceSymbol.text = ""
                WebService.Loader.show()
                self.txtMessage.resignFirstResponder()
                sendQuoteNotification(notification_tag: "2",quote: jobprice){ (status) in
                    //Change job status
                    self.isCounterSelected = false
                    self.setPopups()

                    if APPDELEGATE?.selectedUserType == .Crafter{
                        self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.NotAny)")
                        self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Counter)", isHideProgress: true)
                    }else{
                        self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Counter)")
                        self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.NotAny)", isHideProgress: true)
                    }
                    
                    
                    //Update Quote
                    self.updateQuoteFirebase(userId: self.currentUserId, quote: self.jobprice)
                    self.updateQuoteFirebase(userId: self.opponentUserid, quote: self.jobprice)
                    
                    //Send Message
                    if APPDELEGATE?.selectedUserType == .Crafter{
                        self.sendmessage(message: "I can do this job for £\(self.jobprice ) ,instead?",sendNotif:true)
                    }else{
                        self.sendmessage(message: "Can you do this job for £\(self.jobprice ) ,instead?",sendNotif:true)
                    }
                    self.btnCounter.backgroundColor = UIColor.clear
                    self.txtMessage.keyboardType =  UIKeyboardType.alphabet
                    self.txtMessage.becomeFirstResponder()
                }
            }
        }else{
            if txtMessage.text == ""{
                
            }else{
                sendmessage(message: txtMessage.text ?? "",sendNotif:true)
                txtMessage.text = ""
            }
        }
    }
    
    func inAppInitialization(){
        IAPHandler.shared.fetchAvailableProducts()
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            if type == .purchased {
                let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    self?.isaccepted = true
                    self?.chat_option_status = changeChatStatus.NotAny
                    self?.setPopups()
                    self?.sendmessageTOFIrebase()
                })
                alertView.addAction(action)
                strongSelf.present(alertView, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func btnYesAccept(_ sender: Any) {
        if (APPDELEGATE?.bankDetailNotFilled == .No || APPDELEGATE?.bankDetailNotFilled == bankDetailFilled.none) && APPDELEGATE!.selectedUserType == .Crafter{
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Your bank details not filled fully please fill it by pressing YES.", completion: { (status) in
                if status{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let objNotifySettingsVC = storyboard.instantiateViewController(withIdentifier: "BankingFormVC") as! BankingFormVC
                    objNotifySettingsVC.openFrom = .chat
                self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
                    
                }else{
                }
            })
            return
        }
        
        if txtMessage.text == "" || self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
            txtMessage.resignFirstResponder()
            APPDELEGATE?.addAlertPopupviewWithCompletion(viewcontroller: self, oprnfrom: "insertQuote", message: "Please insert your quote to accept our conditions regarding fees.", completion: { (status) in
                self.txtMessage.becomeFirstResponder()
            })
            return
        }
        
        if Int(APPDELEGATE?.freeremainingQuote ?? "0") ?? 0 > 0 || APPDELEGATE?.freeremainingQuote == unlimitedFreeQuoteText{
            if APPDELEGATE?.freeremainingQuote != unlimitedFreeQuoteText{
                APPDELEGATE?.freeremainingQuote = "\(Int(APPDELEGATE?.freeremainingQuote ?? "0") ?? 0 - 1)"
            }
            if Int(APPDELEGATE?.freeremainingQuote ?? "0") ?? 0 <= 0 && APPDELEGATE?.freeremainingQuote != unlimitedFreeQuoteText{
                self.lblSendQuote.text = sendQuoteLabel
            }else{
                self.lblSendQuote.text = "To send your quote, You have a \(APPDELEGATE!.freeremainingQuote) fee-free quote available. Do you accept?"
            }
            self.apiCallForCrafterQuote(booking_Amount: self.CrafterPayableAmount, job_id: self.jobdetailID,paymentType: "", transactionID: "", is_free_quote: "1")

            appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Thank you!!! We are now sending your quote to client.")
            self.isaccepted = true
            self.chat_option_status = changeChatStatus.NotAny
            self.sendmessageTOFIrebase()
            return
        }
        let objCehckout = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController
        objCehckout?.payableAmount = CrafterPayableAmount
        objCehckout?.blockPaymentStatus = { (status, paymentType, transactionID) in
            if status{
                self.apiCallForCrafterQuote(booking_Amount: self.CrafterPayableAmount, job_id: self.jobdetailID,paymentType: paymentType, transactionID: transactionID)

                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Thank you!!! We are now sending your quote to client.")
                self.isaccepted = true
                self.chat_option_status = changeChatStatus.NotAny
                self.sendmessageTOFIrebase()
            }
        }
        objCehckout?.modalPresentationStyle = .fullScreen
        self.present(objCehckout!, animated: true, completion: nil)
    }
    
    @IBAction func btnQuote(_ sender: Any) {
        txtMessage.text = ""
        lblPriceSymbol.text = "£"

        isOpenFromQue = false
        isMakeOffer = false
        quoteSelected = true
        btnQuote.backgroundColor = APPDELEGATE?.appGreenColor
        btnMessageViewGiveQuote.backgroundColor = .clear
        txtMessage.keyboardType =  UIKeyboardType.numberPad
        txtMessage.reloadInputViews()
    }
    
    @IBAction func btnAcceptJob(_ sender: Any) {
        self.view.endEditing(true)
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to Accept the offer?",price: self.jobprice, completion: { (status) in
            if status{
                self.chat_option_status = changeChatStatus.Accept
                APPDELEGATE?.addProgressView()
                self.changeJobStatusandAmount(bookingstatus: "2", amount: "\(self.jobprice)", isCompleted: false){(status) in
                    if status{
                        APPDELEGATE?.addProgressView()
                        self.setPopups()
                        //Send Amount to Server
                        if self.jobaddedDetail?.jobprice == "" || self.jobprice == ""{
                            //Change job status
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.GiveAQuote)")
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.NotAny)", isHideProgress: true)
                            }else{
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.GiveAQuote)")
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.NotAny)", isHideProgress: true)
                            }
                            self.chat_option_status = changeChatStatus.GiveAQuote
                            self.setPopups()
                        }else{
                            //Change job status
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Accept)")
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Accept)", isHideProgress: true)
                            }else{
                                self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Accept)")
                                self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Accept)", isHideProgress: true)
                            }
                            
                            //Update Quote
                            self.updateQuoteFirebase(userId: self.currentUserId, quote: self.jobprice)
                            self.updateQuoteFirebase(userId: self.opponentUserid, quote: self.jobprice)

                            //Send Message
                            if APPDELEGATE?.uerdetail?.last_name == ""{
                                self.sendmessage(message: "\(APPDELEGATE?.uerdetail?.first_name  ?? "") accepted the offer for £\(self.jobprice)",sendNotif:true)
                            }else{
                                let lName = APPDELEGATE?.uerdetail?.last_name?.first ?? " "
                                self.sendmessage(message: "\(APPDELEGATE?.uerdetail?.first_name  ?? "") \(lName). accepted the offer for £\(self.jobprice )",sendNotif:true)
                            }
                            
                            if APPDELEGATE?.selectedUserType == .Client{
                                self.initilizePaymentPopup(price: self.jobprice, paymentType: .showDepositView, jobReleasedAmount: "")
                                
                                if self.jobDetail?.last_name == ""{
                                    self.sendmessage(message: "\(self.jobDetail?.first_name  ?? "") is waiting for deposit payment to begin",sendNotif:true,isOnlyDisplayOnClientSide: "1")
                                }else{
                                    let lName = self.jobDetail?.last_name?.first ?? " "
                                    self.sendmessage(message: "\(self.jobDetail?.first_name ?? "") \(lName). is waiting for deposit payment to begin",sendNotif:true,isOnlyDisplayOnClientSide: "1")
                                }
                            }else{
                                let lName = APPDELEGATE?.uerdetail?.last_name?.first ?? " "
                                self.sendmessage(message: "\(APPDELEGATE?.uerdetail?.first_name  ?? "") \(lName). is waiting for deposit payment to begin",sendNotif:true,isOnlyDisplayOnClientSide: "1")
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            appDelegate.hideProgrssVoew()
                        }
                    }
                }
            }else{
            }
        })
    }
    @IBAction func btnCounter(_ sender: Any) {
        btnCounter.backgroundColor = APPDELEGATE?.appGreenColor
        btnMessageViewAccept.backgroundColor = .clear
        txtMessage.text = ""
        isCounterSelected = true
        txtMessage.keyboardType =  UIKeyboardType.numberPad
        txtMessage.reloadInputViews()
        txtMessage.becomeFirstResponder()
        lblPriceSymbol.text = "£"
    }
    
    @IBAction func btnMessageFromGiveQuote(_ sender: Any) {
        isOpenFromQue = false
        isMakeOffer = false
        quoteSelected = false
        btnMessageViewGiveQuote.backgroundColor = APPDELEGATE?.appGreenColor
        btnQuote.backgroundColor = UIColor.clear
        txtMessage.keyboardType =  UIKeyboardType.alphabet
        txtMessage.reloadInputViews()
        txtMessage.text = ""
        lblPriceSymbol.text = ""
    }
    
    @IBAction func btnMessageFromAccept(_ sender: Any) {
        isCounterSelected = false
        btnCounter.backgroundColor = UIColor.clear
        btnMessageViewAccept.backgroundColor = APPDELEGATE?.appGreenColor
        txtMessage.keyboardType =  UIKeyboardType.alphabet
        txtMessage.reloadInputViews()
        txtMessage.text = ""
        lblPriceSymbol.text = ""
    }

    @IBAction func btnDecline(_ sender: Any) {
        self.view.endEditing(true)
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to Decline?", completion: { (status) in
            if status{
                APPDELEGATE?.addProgressView()
                self.chat_option_status = changeChatStatus.Decline
                //Send Amount to Server
                self.changeJobStatusandAmount(bookingstatus: "3", amount: "", isCompleted: true){ (status) in
                    if status{
                        self.setPopups()

                        //Change job status
                        if APPDELEGATE?.selectedUserType == .Crafter{
                            self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Decline)")
                            self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Decline)", isHideProgress: true)
                        }else{
                            self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Decline)")
                            self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Decline)", isHideProgress: true)
                        }
                        
                        //Send Message
                        if self.jobDetail?.last_name == ""{
                            self.sendmessage(message: "The job \("\(self.getjobdesc())") has been Decline by \(self.jobDetail?.first_name ?? "").",sendNotif:true)
                        }else{
                            let lName = self.jobDetail?.last_name?.first ?? " "
                            self.sendmessage(message: "The job \("\(self.getjobdesc())") has been Decline by \(self.jobDetail?.first_name ?? "") \(lName).",sendNotif:true)
                        }
                    }
                }
            }else{
            }
        })
    }
    
    @IBAction func btnMarkasComplete(_ sender: Any) {
        self.view.endEditing(true)
        if self.fundsType == PaymentType.depositNow{
            appDelegate.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to Mark job as completed and release all agreed amount?") { (status) in
                if status{
                    self.releaseAllAmount()
                }
            }
        }else{
            if btnDepositFundsNow.titleLabel?.text == "Deposit Funds Now"{
                appDelegate.addAlertPopupviewWithCompletion(viewcontroller: self, oprnfrom: "depositAll", message: "To mark a job as complete you must first deposit your agreed fund.") { (status) in
                    self.initilizePaymentPopup(price: self.jobDetail?.remaining_amount ?? self.jobprice, paymentType: .showDepositView, jobReleasedAmount: "")
                }
            }else if btnDepositFundsNow.titleLabel?.text == "Release Some Fund"{
                initilizePaymentPopup(price: jobDetail?.remaining_amount ?? self.jobprice, paymentType: .showReleaseView, jobReleasedAmount: jobDetail?.booking_amount ?? "0")
            }
        }
    }
    
    @IBAction func btnDepositFundsNow(_ sender: Any) {
        if btnDepositFundsNow.titleLabel?.text == "Deposit Funds Now"{
            let type = PaymentType.depositNow
            let fundsType = type
            
            var paymentPrice = ""
            if paymentPrice == ""{
                paymentPrice = "0"
            }
            
            var booking_Amount = self.jobDetail?.remaining_amount ?? self.jobprice
            
            if booking_Amount == ""{
                booking_Amount = self.jobprice
            }
            
            if type == PaymentType.depositNow{
                booking_Amount = self.jobprice
            }

            let objCehckout = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController
            let strPrice = booking_Amount.replacingOccurrences(of: " ", with: "")
            objCehckout?.payableAmount = strPrice ?? "0"
            objCehckout?.blockPaymentStatus = { (status, paymentType, transactionID) in
                if status{
                   self.fundsType = type
                    self.apiCallForUpdatePaymentStatus(booking_Amount: booking_Amount, payable_amount: paymentPrice, job_id: self.jobdetailID, payment_tag: self.fundsType, Crafter_id: "\(self.jobDetail?.handyman_id ?? self.CrafterID)",paymentType: paymentType, transactionID: transactionID){ (status) in
                        if status{
                            self.view.isUserInteractionEnabled = true
                            self.displayPaymentStatusButton()
                        }
                    }
                }
            }
            objCehckout?.modalPresentationStyle = .fullScreen
            self.present(objCehckout!, animated: true, completion: nil)
        }else if btnDepositFundsNow.titleLabel?.text == "Release Some Fund"{
            initilizePaymentPopup(price: jobDetail?.remaining_amount ?? self.jobprice, paymentType: .showReleaseView, jobReleasedAmount: jobDetail?.booking_amount ?? "0")
        }
    }
    
    @IBAction func btnAcceptCancellation(_ sender: Any) {
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to accept the job cancellation request?", price: "", completion: { (status) in
            if status{
                print(status)
                self.view.isUserInteractionEnabled = false
                self.cancelJob(cancelStatus: "1")
            }
        })
    }
    
    @IBAction func btnDeclineCancellation(_ sender: Any) {
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to decline the job cancellation request?", price: "", completion: { (status) in
            if status{
                print(status)
                self.view.isUserInteractionEnabled = false
                self.arrAllMessages = self.createArrayForPDF(arrMessages: self.arrmessages)
                self.cancelJob(cancelStatus: "2")
            }
        })
    }

    @IBAction func btnCancellationMessage(_ sender: Any) {
    }

    
    //MARK:- Textview DElegate
    @objc func keyboardWillShow(notification: NSNotification) {
        viewReleasedFund.isHidden = true
        tblReleasedFund.isHidden = true
        heightviewReleasedFund.constant = 0
        heightTblReleaseFundConstraint.constant = 0
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhones_4_4S{
            iskeyboardOpen = true
            setPopups()
        }
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomconstraint.constant = keyboardSize.height
            scrollToBottom(count:arrmessages.count)
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraintsIfNeeded()
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        iskeyboardOpen = false
        setPopups()
        displayPaymentStatusButton()
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            bottomconstraint.constant = 0
            scrollToBottom(count:arrmessages.count)
        }
        self.view.layoutIfNeeded()
        self.view.updateConstraintsIfNeeded()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView){
        textView.autocorrectionType = .yes
        self.txtMessage.tintColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)
        if self.txtMessage.text == "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"{
            self.txtMessage.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if self.txtMessage.text == ""{
            self.txtMessage.text = "\(APPDELEGATE?.ChatMessage_PlaceHolder ?? "")"
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if quoteSelected || isCounterSelected{
            let numberFormatter = NumberFormatter()
            numberFormatter.groupingSeparator = ","
            numberFormatter.groupingSize = 3
            numberFormatter.usesGroupingSeparator = true
            numberFormatter.decimalSeparator = "."
            numberFormatter.numberStyle = .decimal
            numberFormatter.maximumFractionDigits = 2
            numberFormatter.locale = Locale (identifier: "en_UK")
            if textView.text!.count >= 1 {
               let number = Double(txtMessage.text!.replacingOccurrences(of: ",", with: ""))
                let result = numberFormatter.string(from: NSNumber(value: number!))
                textView.text = result!
            }
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if quoteSelected || isCounterSelected{
            let str = txtMessage.text + text
            if str.first == "0"{
                txtMessage.text = ""
                return false
            }
            lblPriceSymbol.text = "£"
        }
        heightMessageview.constant = txtMessage.contentSize.height + 16
        if heightMessageview.constant > 120{
            heightMessageview.constant = 120
        }
        heightViewbottom.constant = 20 + heightMessageview.constant
        if quoteSelected || isCounterSelected{
            if textView == self.txtMessage
            {
                let maxLength = 7
                let currentString: NSString = textView.text! as NSString
                let newString: NSString =
                    currentString.replacingCharacters(in: range, with: text) as NSString
                return newString.length <= maxLength
            }else {
                return true
            }
        }
        return true
    }
    
    //Scroll Table bottom
    func scrollToBottom(count:NSInteger){
        DispatchQueue.main.async {
            if count > 0{
                let indexPath = IndexPath(row: count-1, section: 0)
                if indexPath.row < self.arrmessages.count{
                    self.tblChat.scrollToRow(at: indexPath, at: .bottom, animated: false)
                }
            }
        }
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension ChatMessageVC: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == tblReleasedFund{
            return jobDetail?.payment_array.count ?? 0
        }
        return arrmessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == tblReleasedFund{
            return 40
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tblReleasedFund{
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            let lblDetail = cell.contentView.viewWithTag(1) as? UILabel
            lblDetail?.text = jobDetail?.payment_array[indexPath.row].message ?? "-"
            return cell
        }

        if arrmessages[indexPath.row].senderId == "\(APPDELEGATE?.uerdetail?.user_id ?? "")"{
            let cell = tableView.dequeueReusableCell(withIdentifier: "SenderCell", for: indexPath) as? SenderCell
            let imgURL = URL(string: APPDELEGATE?.uerdetail?.profile_image ?? "")
            cell?.imgProfile?.kf.setImage(with: imgURL, placeholder: nil)
            
            let day = stringToDate(strDate: "\(arrmessages[indexPath.row].messageTime ?? "\(Date())")")
            cell?.lblTime.text = timeAgoSinceDate(day)
            if arrmessages[indexPath.row].isOnlyDisplayOnClientSide == "1" {
                if APPDELEGATE?.selectedUserType == .Client{
                    cell?.lblMessage.text = "\(arrmessages[indexPath.row].message ?? "") your job."
                }else{
                    var name = ""
                    if fullname == ""{
                        if username == ""{
                            name = ""
                        }else{
                            let nm = username
                            let tempName = nm.split(separator: " ")
                            let UName = setUserName(name: username)
                            if tempName.count >= 2{
                                self.lblName.text = "\(UName)."
                            }else{
                                self.lblName.text = "\(UName)"
                            }
                        }
                    }else{
                        let nm = fullname
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: fullname)
                        if tempName.count >= 2{
                            self.lblName.text = "\(UName)."
                        }else{
                            self.lblName.text = "\(UName)"
                        }
                    }
                    cell?.lblMessage.text = "\(arrmessages[indexPath.row].message ?? "") \(name)'s job."
                }
                cell?.imgProfile.image = UIImage (named: "imageMain")
                cell?.imgProfile.backgroundColor = UIColor.white
            }else if arrmessages[indexPath.row].iscancellationType != "0" && arrmessages[indexPath.row].iscancellationType != "" && arrmessages[indexPath.row].iscancellationType != nil{
                cell?.imgProfile.image = UIImage (named: "imageMain")
                configureCell(cell: cell!, indexPath: indexPath)
            }else{
                let imgURL = URL(string: APPDELEGATE?.uerdetail?.profile_image ?? "")
                cell?.imgProfile?.kf.setImage(with: imgURL, placeholder: nil)
                cell?.lblMessage.text = arrmessages[indexPath.row].message
            }
            
            if arrmessages[indexPath.row].isSystemMessage == "1"{
                cell?.imgProfile.image = UIImage (named: "imageMain")
                cell?.imgProfile.backgroundColor = UIColor.white
            }
            cell?.lblMessage.tag = indexPath.row
            return cell!
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReceiverCell", for: indexPath) as? ReceiverCell
            let day = stringToDate(strDate: "\(arrmessages[indexPath.row].messageTime ?? "\(Date())")")
            cell?.lblTime.text = timeAgoSinceDate(day)
            if arrmessages[indexPath.row].isOnlyDisplayOnClientSide == "1" {
                if APPDELEGATE?.selectedUserType == .Client{
                    cell?.lblMessage.text = "\(arrmessages[indexPath.row].message ?? "") your job."
                }else{
                    var name = ""
                    if fullname == ""{
                        if username == ""{
                            name = ""
                        }else{
                            let nm = username
                            let tempName = nm.split(separator: " ")
                            let UName = setUserName(name: username)
                            if tempName.count >= 2{
                                self.lblName.text = "\(UName)."
                            }else{
                                self.lblName.text = "\(UName)"
                            }
                        }
                    }else{
                        let nm = fullname
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: fullname)
                        if tempName.count >= 2{
                            self.lblName.text = "\(UName)."
                        }else{
                            self.lblName.text = "\(UName)"
                        }
                    }
                    cell?.lblMessage.text = "\(arrmessages[indexPath.row].message ?? "") \(name)'s job."
                    //cell?.lblMessage.text = "\(arrmessages[indexPath.row].message ?? "") \(fullname)'s job."
                }
                cell?.imgProfile.image = UIImage (named: "imageMain")
                cell?.imgProfile.backgroundColor = UIColor.white
            }else if arrmessages[indexPath.row].iscancellationType != "0" && arrmessages[indexPath.row].iscancellationType != "" && arrmessages[indexPath.row].iscancellationType != nil{
                cell?.imgProfile.image = UIImage (named: "imageMain")
                configureCell(cell: cell!, indexPath: indexPath)
            }else{
                let imgURL = URL(string: jobDetail?.profile_image ?? "")
                cell?.imgProfile?.kf.setImage(with: imgURL, placeholder: nil)
                cell?.lblMessage.text = arrmessages[indexPath.row].message
            }
            cell?.lblMessage.tag = indexPath.row
            if arrmessages[indexPath.row].isSystemMessage == "1"{
                cell?.imgProfile.image = UIImage (named: "imageMain")
                cell?.imgProfile.backgroundColor = UIColor.white
            }
            return cell!
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell is SenderCell{
            if arrmessages[indexPath.row].isOnlyDisplayOnClientSide == "1"{
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        if tableView == tblReleasedFund{
        }else{
            if arrmessages[indexPath.row].iscancellationType == "3" && arrmessages[indexPath.row].senderUserType == Crafter{
                let urlstr = arrmessages[indexPath.row].message?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                guard let url = URL(string: urlstr!) else { return }
                UIApplication.shared.open(url)
            }
        }
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        if let cellSender = cell as? SenderCell{
            if appDelegate.selectedUserType == .Crafter{
                if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellSender.lblMessage.text = "You \(crafterCancelJobOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Client{
                    cellSender.lblMessage.text = "Client \(clientCancelJobCrafterMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "2" && arrmessages[indexPath.row].senderUserType == Client{
                    cellSender.lblMessage.text = "Client \(clientCancelJobAfterPaymentCrafterMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "4" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellSender.lblMessage.text = "You \(crafterAcceptJobCancellationOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "3" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellSender.lblMessage.text = "You \(crafterCancelJobCancellationOwnMessage)"
                }
            }else{
                if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter && jobDetail?.payment_array.count ?? 0 > 0{
                    cellSender.lblMessage.text = "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter && jobDetail?.payment_array.count == 0{
                    cellSender.lblMessage.text = "Crafter \(crafterCancelJobClientMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Client{
                    cellSender.lblMessage.text = "You \(clientCancelJobOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "2" && arrmessages[indexPath.row].senderUserType == Client{
                    cellSender.lblMessage.text = "Your \(clientCancelJobAfterPaymentOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "4" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellSender.lblMessage.text = "Crafter \(crafterAcceptJobCancellationClientMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "3" && arrmessages[indexPath.row].senderUserType == Crafter{
                        let pdfURL = arrmessages[indexPath.row].message ?? ""
                        let message = "Crafter \(crafterCancelJobCancellationClientMessage) \(arrmessages[indexPath.row].message ?? "")"
                    cellSender.lblMessage.attributedText = setDifferentColor(string: message, location: "Crafter \(crafterCancelJobCancellationClientMessage)".count + 1, length: pdfURL.count)
                }
            }
        }else if let cellreceiver = cell as? ReceiverCell{
            if appDelegate.selectedUserType == .Crafter{
                if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellreceiver.lblMessage.text = "You \(crafterCancelJobOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Client{
                    cellreceiver.lblMessage.text = "Client \(clientCancelJobCrafterMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "2" && arrmessages[indexPath.row].senderUserType == Client{
                    cellreceiver.lblMessage.text = "Client \(clientCancelJobAfterPaymentCrafterMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "4" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellreceiver.lblMessage.text = "You \(crafterAcceptJobCancellationOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "3" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellreceiver.lblMessage.text = "You \(crafterCancelJobCancellationOwnMessage)"
                }
            }else{
                if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter && jobDetail?.payment_array.count ?? 0 > 0{
                    cellreceiver.lblMessage.text = "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Crafter && jobDetail?.payment_array.count == 0{
                    cellreceiver.lblMessage.text = "Crafter \(crafterCancelJobClientMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "1" && arrmessages[indexPath.row].senderUserType == Client{
                    cellreceiver.lblMessage.text = "You \(clientCancelJobOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "2" && arrmessages[indexPath.row].senderUserType == Client{
                    cellreceiver.lblMessage.text = "Your \(clientCancelJobAfterPaymentOwnMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "4" && arrmessages[indexPath.row].senderUserType == Crafter{
                    cellreceiver.lblMessage.text = "Crafter \(crafterAcceptJobCancellationClientMessage)"
                }else if arrmessages[indexPath.row].iscancellationType == "3" && arrmessages[indexPath.row].senderUserType == Crafter{
                        let pdfURL = arrmessages[indexPath.row].message ?? ""
                        let message = "Crafter \(crafterCancelJobCancellationClientMessage) \(arrmessages[indexPath.row].message ?? "")"
                    cellreceiver.lblMessage.attributedText = setDifferentColor(string: message, location: "Crafter \(crafterCancelJobCancellationClientMessage)".count + 1, length: pdfURL.count)
                }
            }
        }
    }
}


//MARK:- Firebase
extension ChatMessageVC{
    func sendmessage(message:String,sendNotif:Bool,isOnlyDisplayOnClientSide: String = "0",IsSystemMessage: String = "0"){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }
        if sendNotif{
            sendNotification(messgae: message)
        }
        if self.arrmessages.count == 0{
            apiCallIsChatWithClient(Crafter_id: "\(self.jobDetail?.handyman_id ?? self.CrafterID)",job_id: self.jobdetailID, client_id: self.jobDetail?.client_id ?? "")
        }
        
        let messageId = fourDigitNumber
        let timeinterval = getTimeInterval()
        let date = Date()
        var senderID = APPDELEGATE?.uerdetail?.user_id ?? ""
        if isOnlyDisplayOnClientSide == "1" && APPDELEGATE?.selectedUserType == .Client{
            senderID = jobDetail?.handyman_id ?? ""
        }
        let params = ["message":"\(message)","messageTime":"\(date)","senderId":senderID,"isRead":"\(0)","conversationId":conversationId,"messageid":"\(messageId)","timeinterval":"\(timeinterval)","isOnlyDisplayOnClientSide": isOnlyDisplayOnClientSide, "senderUserType": appDelegate.uerdetail?.user_type ?? "", "isSystemMessage": IsSystemMessage]
        

        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: params, options: []) as AnyObject
            let data = try? JSONDecoder().decode(firebaseMessage.self, from: jsonObject as! Data)
            self.arrmessages.append(data!)
            apiCallSendChatToServer(messageData: params, Crafter_id: "\(self.CrafterID)", job_id: self.jobdetailID, client_id: self.jobDetail?.client_id ?? "", message: data!)
            tblChat.reloadData()
            scrollToBottom(count: self.arrmessages.count)
        } catch  {
        }
        
        FirebaseAPICall.firebaseSendMessage(conversationId: conversationId, messageId: messageId, messsageDetail: params) { (status, error, data) in
            if status{
                //Update user detail to Firebase
                self.addtoFirebase(conversationId: self.conversationId, userId: self.currentUserId, timeinterval: timeinterval, time: date, message: message)
                self.addtoFirebase(conversationId: self.conversationId, userId: self.opponentUserid, timeinterval: timeinterval, time: date, message: message)
                
                //Update Last message read or not
                self.UpdateIsMessageReadOrNot(UserId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", isRead: "0")
                
                //Update  message count
                self.updateMessageCounttojob(unreadMessageCountcount: self.unreadMessageCount, userId: self.opponentUserid)
            }
        }
    }
    
    func getMessages()
    {
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

//        APPDELEGATE?.addProgressView()
        FirebaseAPICall.firebaseGetMessages(conversationId: conversationId) { (status, error, data) in
            if status{
                if data != nil{
                    do
                    {
                        self.arrmessages = try! JSONDecoder().decode([firebaseMessage].self, from: data! as! Data)
                        self.tblChat.reloadData()
                        if self.arrmessages.count > 0{
                            
                            self.scrollToBottom(count: self.arrmessages.count)
                            if appDelegate.selectedUserType == .Crafter{
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                                    if self.arrmessages[self.arrmessages.count - 1].iscancellationType == "2" && self.arrmessages[self.arrmessages.count - 1].senderUserType == Client{
                                        self.hideView(index: 15)
                                    }else{
                                    }
                                })
                            }
                        }
                    }
                }
            }
//            APPDELEGATE?.hideProgrssVoew()
        }
    }
    
    func addtoFirebase(conversationId:String,userId:String,timeinterval:String,time:Date,message:String){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        let param = ["lastmessage":"\(message)","lastmessagetime":"\(time)","timeinterval":"\(timeinterval)","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))"] as [String : Any]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userId, jobId: jobId, ChatuserDetail: param, completion:{ (status) in
            if status{

            }
        })
    }

    func UpdateIsMessageReadOrNot(UserId:String,isRead:String){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: jobId, detail: param, completion: { (status) in
            
        })
    }
    
    func getJObChatStatus(){
        FirebaseJobAPICall.firebaseGetJob(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", completion:  { (status, error, data) in
            if status{
                if data != nil{
                    do
                    {
                        let arrfromFirebase = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                        var isAvail = false
                        var jobDetail:jobsAdded?
                        if arrfromFirebase == nil{
                            return
                        }
                        for item in arrfromFirebase ?? [] {
                            if item.job_id == self.jobId{
                                isAvail = true
                                jobDetail = item
                                self.jobaddedDetail = jobDetail
                            }
                        }
                        if isAvail{
                            self.chat_option_status = jobDetail?.chat_option_status ?? ""
                            self.jobdetailID = jobDetail?.jobdetailID ?? ""
                            self.jobprice = jobDetail?.jobprice ?? self.jobprice
                            self.setPopups()
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.opponentUserid = self.jobaddedDetail?.ClientId ?? ""
                            }else{
                                self.opponentUserid = self.jobaddedDetail?.CrafterId ?? ""
                            }
                            self.getOponnentMessageCount(userId: self.opponentUserid)
                            if self.isFirstTime{
                                self.getMessages()
                                self.getjobListingAllForOponent(oponentUserID: self.opponentUserid)
                                self.GetJobDetailAPI(callSilently: false)
                                self.readChatNotification()
                                self.isFirstTime = false
                            }
                            self.fundsType = self.jobaddedDetail?.payment_tag ?? "0"
                            self.displayPaymentStatusButton()
                        }
                    }
                }
            }
        })
    }
    
    func getOponnentMessageCount(userId:String){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        FirebaseJobAPICall.firebaseGetJobDEtail(myId: userId, jobId: jobId, completion: { (status, error, data) in
            if status{
                let detail = data as? [String:Any]
                self.unreadMessageCount = detail?["unreadMessageCount"] as? NSInteger ?? 0
            }
        })
    }

    func changeJobChatStatus(userId:String,chatOptionStatus:String,isHideProgress: Bool = false){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }
        var isProgress = isHideProgress
        let param = ["chat_option_status":chatOptionStatus]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobId, detail: param, completion: { (status) in
            if isHideProgress{
                isProgress = false
                APPDELEGATE?.hideProgrssVoew()
            }
        })
    }
    
    func updateQuoteFirebase(userId:String,quote:String)
    {
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        var param = [String:Any]()
        if quote == ""{
            param = ["jobprice":"\(0)"]
        }else{
            param = ["jobprice":"\(quote)"]
        }
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobId, detail: param, completion: { (status) in
            
        })
    }
    
    //Update message Count to Job
    func updateMessageCounttojob(unreadMessageCountcount:Int,userId:String){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        self.unreadMessageCount += 1
//        self.getJObChatStatus()
        let param = ["unreadMessageCount":unreadMessageCountcount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobId, detail: param, completion: { (status) in
            
        })
    }
    
    //Send Quote and CHnage Job Status
    func changeJobStatusandAmount(bookingstatus: String,amount:String,isCompleted:Bool, cancellation_reason: String = "0",completion: ((Bool)->())?){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timeString = formatter.string(from: Date())

        var param = ["job_id":"\(jobdetailID)","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","booking_status":"\(bookingstatus)","booking_amount":"\(amount)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","description": "\(getjobdesc())","complete_time":timeString,"cancellation_reason": cancellation_reason]
        if APPDELEGATE?.selectedUserType == .Crafter
        {
            param["handyman_id"] = "\(APPDELEGATE!.uerdetail?.user_id ?? "")"
        }else{
            param["handyman_id"] = self.opponentUserid
        }
        APPDELEGATE?.addProgressView()
        self.view.isUserInteractionEnabled = false
        WebService.Request.patch(url: changeJobStatus, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    completion!(true)
                }else{
                    completion!(false)
                }
            }else{
                completion!(false)
            }
            APPDELEGATE?.hideProgrssVoew()
            self.view.isUserInteractionEnabled = true
        }
    }

    func sendNotification(messgae:String)  {
        if !self.isSendNotification{
            return
        }
        
        let nm = "\(APPDELEGATE?.uerdetail?.first_name ?? "") \(APPDELEGATE?.uerdetail?.last_name ?? "")"
        let tempName = nm.split(separator: " ")
        let UName = setUserName(name: "\(APPDELEGATE?.uerdetail?.first_name ?? "") \(APPDELEGATE?.uerdetail?.last_name ?? "")")
        let notifTitle = "\(UName)."

        var data = [String:Any]()
        data["user_id"] = "\(APPDELEGATE?.uerdetail?._id ?? "")"
        data["job_id"] = jobId
        data["conversationId"] = conversationId
        data["jobdetailID"] = jobdetailID
        data["first_name"] = "\(APPDELEGATE?.uerdetail?.first_name ?? "")"
        data["last_name"] = "\(APPDELEGATE?.uerdetail?.last_name ?? "")"
        data["user_name"] = "\(APPDELEGATE?.uerdetail?.user_name ?? "")"
        data["full_name"] = "\(APPDELEGATE?.uerdetail?.first_name ?? "") \(APPDELEGATE?.uerdetail?.last_name ?? "")"
        data["device_token"] = "\(APPDELEGATE?.uerdetail?.device_token ?? "")"
        data["_id"] = "\(APPDELEGATE?.uerdetail?._id ?? "")"
        data["profile_image"] = "\(APPDELEGATE?.uerdetail?.profile_image ?? "")"
        data["service_image"] = "\(jobDetail?.service_image ?? "")"
        var toUserType = String()
        var userType = String()
        if APPDELEGATE?.selectedUserType == .Crafter{
            data["CrafterId"] = "\(APPDELEGATE?.uerdetail?._id ?? "")"
            toUserType = Client
            userType = Crafter
        }else{
            data["CrafterId"] = self.opponentUserid
            toUserType = Crafter
            userType = Client
        }
        var badgeNumber = "\(oponentsTotalChatCount)"
        if !isAlreadyPendingToRead{
            badgeNumber = "\(oponentsTotalChatCount + 1)"
        }
        
        let param = ["loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)","to_user_id": "\(self.opponentUserid)","jobdetail_id": jobdetailID, "to_user_type": toUserType, "message": messgae, "title": notifTitle, "data": convertJsonString(from: data)] as [String : Any]
        WebService.Request.patch(url: sendChatNotification, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                
            }
        }
    }
    
    func readChatNotification()  {
        var userType = String()
        if APPDELEGATE?.selectedUserType == .Crafter{
            userType = Crafter
        }else{
            userType = Client
        }
        
        let param = ["loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)","from_user_id": "\(self.opponentUserid)","jobdetail_id": jobdetailID] as [String : Any]
        WebService.Request.patch(url: deleteChatNotification, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                
            }
        }
    }

    //Get Job Detail API
    func GetJobDetailAPI(callSilently: Bool = true){
        var userType = String()
        var habdymanId = String()
        if APPDELEGATE!.selectedUserType == .Crafter{
            userType = Crafter
            habdymanId = APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? "")
        }else{
            userType = Client
            habdymanId = CrafterID
        }
        APPDELEGATE?.ChatjobID = jobdetailID
        let params = ["job_id":"\(jobdetailID)","handyman_id":habdymanId,"loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)"]
        APPDELEGATE?.addProgressView()
        WebService.Request.patch(url: getJobDetail, type: .post, parameter: params, callSilently: callSilently, header: nil) { (response, error) in
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
                         
                            if (JobData?.count)! > 0{
                                self.jobDetail = JobData?[0]
                                self.setDetail()
                            }else{
                                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                                self.fundsType = PaymentType.none
                                self.hideView(index: 10)
                            }
                            
                            //Update Message Count and Last messaeg read or not
                            self.updateMessageCounttojob(unreadMessageCountcount: self.unreadMessageCount, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
                            self.UpdateIsMessageReadOrNot(UserId: self.opponentUserid, isRead: "1")
                            self.getMessages()
                        }
                        catch
                        {
                            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                            self.fundsType = PaymentType.none
                            self.hideView(index: 10)
                            print(error.localizedDescription)
                        }
                    }
                    else
                    {
                        APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                        self.fundsType = PaymentType.none
                        self.hideView(index: 10)
                    }
                } else
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                    self.fundsType = PaymentType.none
                    self.hideView(index: 10)
                }
            }else{
                self.fundsType = PaymentType.none
                self.hideView(index: 10)
            }
            APPDELEGATE?.hideProgrssVoew()
            self.displayPaymentStatusButton()
        }
    }
    
    func setDetail(){
        self.jobdesc = "\(self.jobDetail?.description ?? "")"
        self.JobStatus = "\(self.jobDetail?.booking_status ?? "0")"
        self.is_block = "\(self.jobDetail?.is_block ?? "")"
        if self.jobDetail?.is_block == "0"{
            self.isBlocked = false
            self.btnViewProfile.isUserInteractionEnabled = true
        }else{
            self.isBlocked = true
            self.btnViewProfile.isUserInteractionEnabled = false
        }
        if self.jobDetail?.message_status ?? "0" == "1"{
            self.isSendNotification = true
        }else{
            self.isSendNotification = false
        }
        self.Servicename =  self.jobDetail?.service_name ?? ""
        self.setPopups()
        let imgURL = URL(string: self.jobDetail?.profile_image ?? "")
        
        self.imgprofile?.kf.setImage(with: imgURL, placeholder: nil)
        
        if self.jobDetail?.full_name == nil || self.jobDetail?.full_name == ""{
            self.lblName.text = self.jobDetail?.first_name ?? ""
        }else{
            let nm = self.jobDetail?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.jobDetail?.full_name ?? "")
            if tempName.count >= 2{
                self.lblName.text = "\(UName)."
            }else{
                self.lblName.text = "\(UName)"
            }
        }
        
        let imgURLservice = URL(string: self.jobDetail?.service_image ?? "")
        self.imgViewjob?.kf.setImage(with: imgURLservice, placeholder: nil)
        if self.jobDetail?.is_acceptable == "1"{
            heightviewReleasedFund.constant = 0
            viewReleasedFund.isHidden = true
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
            self.hideView(index: 10)
        }
        
        self.SetupUserRatings(rating: Int(Float(self.jobDetail?.total_rating ?? "0.0") ?? 0))
        if APPDELEGATE!.selectedUserType == .Crafter{
            if self.jobDetail?.total_jobs == "0" || self.jobDetail?.total_jobs?.count == 0{
                self.lblJobs.text = "Jobs Created: NEW"
            }else{
                self.lblJobs.text = "Jobs Created: \(self.jobDetail?.total_jobs ?? "0")"
            }
        }else{
            if self.jobDetail?.total_jobs == "0" || self.jobDetail?.total_jobs?.count == 0{
                self.lblJobs.text = "Jobs Completed: NEW"
            }else{
                self.lblJobs.text = "Jobs Completed: \(self.jobDetail?.total_jobs ?? "0")"
            }
        }
        if self.jobDetail?.is_emergency_job == 1
        {
            let str = self.jobDetail?.description ?? ""
            let trimmedString = str.trimmingCharacters(in: .whitespaces)
            let myString = "Emergency! " + " \(trimmedString)"
            self.lblJobDescription.attributedText = myString.SetAttributed(location: 0, length: 10, font: "Cabin-Regular", size: 15.0)
        }
        else
        {
            self.lblJobDescription.text = self.jobDetail?.description ?? ""
        }
        if self.jobDetail?.booking_amount != "" && self.jobDetail?.booking_amount?.count != 0 && self.jobDetail?.booking_amount != "0.00"{
            self.lblJobPrice.text = "Amount: £ \(self.jobDetail?.booking_amount ?? "")"
        }
        if self.jobDetail?.media.count ?? 0 > 0{
            if let mediaData = self.jobDetail?.media[0]{
                let ext_url = mediaData.media_url!.components(separatedBy: ".").last
                if (mediaData.media_url?.contains(".mp4"))! || (mediaData.media_url?.contains(".mov"))!
                {
                    let url = URL(string: mediaData.media_url!)
                    
                    DispatchQueue.global(qos: .background).async
                        {
                            if let thumbnailImage = self.getThumbnailImage_2(forUrl: url!)
                            {
                                DispatchQueue.main.async
                                    {
                                        self.imgDefaultJob.image = thumbnailImage
                                        
                                        appDelegate.imgDefault = thumbnailImage
                                }
                            }
                    }
                }else{
                    let imgURL = URL(string: mediaData.media_url!)
                    self.imgDefaultJob.kf.setImage(with: imgURL, placeholder: nil)
                    
                    appDelegate.imgDefault = self.imgDefaultJob.image
                }
            }
        }
        self.fundsType = self.jobDetail?.payment_tag ?? "0"
        self.deviceToken = self.jobDetail?.device_token ?? ""
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

    func SetupUserRatings(rating: Int)
    {
        let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        if rating == 0
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = UIColor.white
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = UIColor.white
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.white
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.white
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.white
        }
        else if rating == 1
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = UIColor.white
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.white
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.white
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.white
        }
        else if rating == 2
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.white
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.white
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.white
        }
        else if rating == 3
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.white
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.white
        }
        else if rating == 4
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.white
        }
        else if rating == 5
        {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = APPDELEGATE?.appGreenColor
        }
    }

    //Change notification is read or not
    func APICallchangeNotificationCount(){
        let param = ["job_id":"\(jobdetailID)","user_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")"]
        WebService.Request.patch(url: changeNotificationCount, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                let dataresponse = response!["data"] as? [String:Any]
                if dataresponse != nil
                {
                    APPDELEGATE?.notificationCount = (dataresponse! as NSDictionary).value(forKey: "total_unread") as! Int
                    APPDELEGATE?.chatCount = (dataresponse! as NSDictionary).value(forKey: "total_unread") as! Int
                    APPDELEGATE?.freequoteQty = Int((dataresponse! as NSDictionary).value(forKey: "quoteQty") as? String ?? "0") ?? 0
                    APPDELEGATE?.freequoteExpireDate = (dataresponse! as NSDictionary).value(forKey: "quoteExpireDate") as? String ?? ""
                    APPDELEGATE?.freeremainingQuote = (dataresponse! as NSDictionary).value(forKey: "remainingQuote") as? String ?? ""

                    UIApplication.shared.applicationIconBadgeNumber = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                    
                    APPDELEGATE?.totalConut = (APPDELEGATE?.notificationCount)! + (APPDELEGATE?.chatCount)!
                    if Int(APPDELEGATE?.freeremainingQuote ?? "0") ?? 0 > 0 || APPDELEGATE?.freeremainingQuote == self.unlimitedFreeQuoteText{
                        self.lblSendQuote.text = "To send your quote, You have a \(APPDELEGATE!.freeremainingQuote) fee-free quote available. Do you accept?"
                    }
                }
                else
                {
                    
                }

            }
        }
    }
    
    //Send Quote and Counter Notification
    func sendQuoteNotification(notification_tag:String,quote: String,completion: ((Bool)->())?){//(1: Quote, 2: Counter)
        var param = ["job_id":"\(jobdetailID)","user_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","notification_tag":"\(notification_tag)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")","counter_amount":"£\(quote)","description": "\(getjobdesc())"]
        if appDelegate.selectedUserType == .Crafter{
            param["receiver_id"] = self.jobDetail?.client_id
        }else{
            param["receiver_id"] = opponentUserid
        }
        WebService.Request.patch(url: sendNotificationForQuote, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    completion!(true)
                }else{
                    completion!(false)
                }
            }else{
                completion!(false)
            }
        }
    }
    
    func getjobdesc() -> String{
        if jobdesc.count > 15 {
            return String(jobdesc.prefix(15))
        }else{
            return jobdesc
        }
    }
    
    func getjobListingAllForOponent(oponentUserID:String){
//        APPDELEGATE?.addProgressView()
        FirebaseJobAPICall.firebaseGetJob(myId: oponentUserID) { (status, error, data) in
            if status{
//                APPDELEGATE?.hideProgrssVoew()
                self.isAlreadyPendingToRead = false
                if data != nil{
                    do{
                        let conversion = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                        var count = 0
                        for item in conversion ?? [] {
                            if item.unreadMessageCount ?? 0 > 0{
                                count += 1
                            }
                            if item.job_id == self.jobId{
                                self.isAlreadyPendingToRead = true
                            }
                        }
                        self.oponentsTotalChatCount = count
                        if self.oponentsTotalChatCount == 0 {
                            self.oponentsTotalChatCount = 1
                        }
                    }
                }
            }else{
            }
        }
    }
}

//MARK:- Display default messages
extension ChatMessageVC{
    func setPopups(){
        if isBlocked{
            hideView(index: 10)
            return
        }else if jobDetail?.is_acceptable == "1"{
            hideView(index: 10)
            return
        }
        if iskeyboardOpen{
            hideView(index: 10)
            return
        }
        print("chat option status ::",chat_option_status)

        if self.jobDetail?.is_archive == "1" || (self.jobDetail?.cancellation_status == "1" && self.jobDetail?.cancelled_user_type == "1") || self.jobDetail?.cancellation_status == "2" {
            lblJobDescription.text = "Client cancelled this job."
            if self.jobDetail?.payment_array.count ?? 0 > 0 && APPDELEGATE?.selectedUserType == .Crafter && self.jobDetail?.cancellation_status == "2"{
                hideView(index: 15)
                return
            }else if self.jobDetail?.payment_array.count ?? 0 > 0 && APPDELEGATE?.selectedUserType == .Crafter && self.jobDetail?.cancellation_status == "1"{
                txtMessage.isUserInteractionEnabled = false
                btnQuote.isUserInteractionEnabled = false
                btnAccept.isUserInteractionEnabled = false
                btnCounter.isUserInteractionEnabled = false
                btnyesIAccept.isUserInteractionEnabled = false
                btnOption.isUserInteractionEnabled = false
                btnJobOption.isUserInteractionEnabled = false
                btnSendMessage.isUserInteractionEnabled = false
                hideView(index: 10)
                return

            }else if self.jobDetail?.payment_array.count ?? 0 > 0 && APPDELEGATE?.selectedUserType == .Client && self.jobDetail?.cancellation_status == "2"{
                hideView(index: 0)
                return
            }else if self.jobDetail?.payment_array.count ?? 0 > 0 && APPDELEGATE?.selectedUserType == .Client && self.jobDetail?.cancellation_status == "1"{
                txtMessage.isUserInteractionEnabled = false
                btnQuote.isUserInteractionEnabled = false
                btnAccept.isUserInteractionEnabled = false
                btnCounter.isUserInteractionEnabled = false
                btnyesIAccept.isUserInteractionEnabled = false
                btnOption.isUserInteractionEnabled = false
                btnJobOption.isUserInteractionEnabled = false
                btnSendMessage.isUserInteractionEnabled = false
                hideView(index: 10)
                return
            } else{
                txtMessage.isUserInteractionEnabled = false
                btnQuote.isUserInteractionEnabled = false
                btnAccept.isUserInteractionEnabled = false
                btnCounter.isUserInteractionEnabled = false
                btnyesIAccept.isUserInteractionEnabled = false
                btnOption.isUserInteractionEnabled = false
                btnJobOption.isUserInteractionEnabled = false
                btnSendMessage.isUserInteractionEnabled = false
                hideView(index: 10)
                return
            }
        }else if self.jobDetail?.cancellation_status == "1" && self.jobDetail?.cancelled_user_type == "2"{
            txtMessage.isUserInteractionEnabled = false
            btnQuote.isUserInteractionEnabled = false
            btnAccept.isUserInteractionEnabled = false
            btnCounter.isUserInteractionEnabled = false
            btnyesIAccept.isUserInteractionEnabled = false
            btnOption.isUserInteractionEnabled = false
            btnJobOption.isUserInteractionEnabled = false
            btnSendMessage.isUserInteractionEnabled = false
            lblJobDescription.text = "Crafter cancelled this job."
            hideView(index: 10)
            return
        }else if self.jobDetail?.cancellation_status == "3"{
            txtMessage.isUserInteractionEnabled = false
            btnQuote.isUserInteractionEnabled = false
            btnAccept.isUserInteractionEnabled = false
            btnCounter.isUserInteractionEnabled = false
            btnyesIAccept.isUserInteractionEnabled = false
            btnOption.isUserInteractionEnabled = false
            btnJobOption.isUserInteractionEnabled = false
            btnSendMessage.isUserInteractionEnabled = false
            lblJobDescription.text = "Job is under dispute."
            hideView(index: 10)
            return
        }else{
            txtMessage.isUserInteractionEnabled = true
            btnQuote.isUserInteractionEnabled = true
            btnAccept.isUserInteractionEnabled = true
            btnCounter.isUserInteractionEnabled = true
            btnyesIAccept.isUserInteractionEnabled = true
            btnOption.isUserInteractionEnabled = true
            btnJobOption.isUserInteractionEnabled = true
            btnSendMessage.isUserInteractionEnabled = true
        }

        if APPDELEGATE?.selectedUserType == .Client{
            if chat_option_status == changeChatStatus.NotAny {
                hideView(index: 0)
            }else if chat_option_status == changeChatStatus.Accept_Decline_Counter || chat_option_status == changeChatStatus.Counter{
                hideView(index: 3)
            }else if chat_option_status == changeChatStatus.Accept{
                hideView(index: 5)
            }else if chat_option_status == changeChatStatus.Decline || chat_option_status == changeChatStatus.Completed || chat_option_status == changeChatStatus.done{
                hideView(index: 6)
            }else if chat_option_status == changeChatStatus.report{
                hideView(index: 3)
            } else{
                hideView(index: NSInteger(chat_option_status) ?? 0)
            }
        }else{
            if chat_option_status == changeChatStatus.NotAny {
                hideView(index: 0)
            }else if chat_option_status == changeChatStatus.GiveAQuote{
                hideView(index: 1)
            }else if chat_option_status == changeChatStatus.YesIAccept{
                hideView(index: 2)
            }else if chat_option_status == changeChatStatus.Accept_Decline_Counter || chat_option_status == changeChatStatus.Counter{
                hideView(index: 3)
            }else if chat_option_status == changeChatStatus.Accept{
                hideView(index: 5)
            }else if chat_option_status == changeChatStatus.Decline || chat_option_status == changeChatStatus.Completed || chat_option_status == changeChatStatus.done{
                hideView(index: 6)
            }else if chat_option_status == changeChatStatus.report{
                hideView(index: 1)
            }else{
                hideView(index: NSInteger(chat_option_status) ?? 0)
            }
        }
    }

    func hideView(index:NSInteger){
        var intIndex = index
        if iskeyboardOpen{
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            heightoppUps.constant = 0
            viewPopups.isHidden = true
         //   return
        }
        
        if chat_option_status == changeChatStatus.GiveAQuote{
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = false
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            if isOpenFromQue{
                quoteSelected = false
                isMakeOffer = false
                lblPriceSymbol.text = ""
                txtMessage.keyboardType = .alphabet
                btnMessageViewGiveQuote.backgroundColor = APPDELEGATE?.appGreenColor
                btnQuote.backgroundColor = UIColor.white
                txtMessage.becomeFirstResponder()
            }else if isMakeOffer{
                quoteSelected = true
                isMakeOffer = true
                lblPriceSymbol.text = "£"
                btnQuote.backgroundColor = APPDELEGATE?.appGreenColor
                btnMessageViewGiveQuote.backgroundColor = .white
//                    txtMessage.resignFirstResponder()
                txtMessage.keyboardType =  UIKeyboardType.numberPad
                txtMessage.becomeFirstResponder()
            }
            
            if self.jobDetail?.is_archive == "1" {
                self.viewaccept.isHidden = true
                self.viewquote.isHidden = true
                self.viewComplete.isHidden = true
                self.viewacceptDecline.isHidden = true
                heightViewbottom.constant = 0
                heightoppUps.constant = 0
                viewPopups.isHidden = true
                viewBottom.isHidden = true
                self.view.endEditing(true)
            }

          //  return
        }

        self.viewaccept.isHidden = true
        self.viewquote.isHidden = true
        self.viewComplete.isHidden = true
        self.viewacceptDecline.isHidden = true
        heightoppUps.constant = 66
        heightViewbottom.constant = 73
        viewBottom.isHidden = false
        viewPopups.isHidden = false
        self.viewClientCancel.isHidden = true
        if intIndex == 0 {// Hide all
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            heightoppUps.constant = 0
            viewPopups.isHidden = true
            lblPriceSymbol.text = ""
//            self.view.endEditing(true)
        }else if intIndex == 1 || intIndex == 9{//Display Give a Quote Option
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = false
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            
            if chat_option_status == changeChatStatus.report && APPDELEGATE?.selectedUserType == .Crafter{
               //self.btnQuote.isHidden = false
               // self.btnQuote.backgroundColor = APPDELEGATE?.appGreenColor
              //  self.TrailingbtnMessageViewAccept.constant = -126
           }
            if isOpenFromQue{
                lblPriceSymbol.text = ""
            }else if isMakeOffer{
                lblPriceSymbol.text = "£"
            }
        }else if intIndex == 2{// Display Yes I accept option
            self.viewaccept.isHidden = false
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
        }else if intIndex == 3 || intIndex == 4{// Display Accept/Decline and Counter Option
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = false
            if chat_option_status == changeChatStatus.report && APPDELEGATE?.selectedUserType == .Client{
                //self.btnAccept.isHidden = true
               // self.btnCounter.isHidden = true
               // self.TrailingOfView.constant = -180
             //   heightoppUps.constant = 0
             //   self.btnMessageViewAccept.isHidden = true
            }
            
            if isCounterSelected{
                lblPriceSymbol.text = "£"
            }else{
                lblPriceSymbol.text = ""
            }
        }else if intIndex == 5{// Display Mark as completed option
            if APPDELEGATE?.selectedUserType == .Client{//Client can mark job as completed
                self.viewaccept.isHidden = true
                self.viewquote.isHidden = true
                self.viewComplete.isHidden = false
                self.viewacceptDecline.isHidden = true
            }else{//Crafter Can not mark job as completed
                self.viewaccept.isHidden = true
                self.viewquote.isHidden = true
                self.viewComplete.isHidden = true
                self.viewacceptDecline.isHidden = true
                heightoppUps.constant = 0
                viewPopups.isHidden = true
            }
            lblPriceSymbol.text = ""
        }else if intIndex == 6 || intIndex == 8 || intIndex == 7{//Hide Options and Message
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            heightViewbottom.constant = 0
            heightoppUps.constant = 0
            viewPopups.isHidden = true
            viewBottom.isHidden = true
            self.view.endEditing(true)
        }else if intIndex == 10{//Blocked
            self.viewaccept.isHidden = true
            self.viewquote.isHidden = true
            self.viewComplete.isHidden = true
            self.viewacceptDecline.isHidden = true
            heightViewbottom.constant = 0
            heightoppUps.constant = 0
            viewPopups.isHidden = true
            viewBottom.isHidden = true
            self.view.endEditing(true)
        }else if intIndex == 15{// Client Cancel after Deposit
            self.viewClientCancel.isHidden = false
        }
        if chat_option_status == changeChatStatus.GiveAQuote{
            if self.jobDetail?.is_archive == "1" {
                self.viewaccept.isHidden = true
                self.viewquote.isHidden = true
                self.viewComplete.isHidden = true
                self.viewacceptDecline.isHidden = true
                heightViewbottom.constant = 0
                heightoppUps.constant = 0
                viewPopups.isHidden = true
                viewBottom.isHidden = true
                self.view.endEditing(true)
            }
        }

    }
}

//MARK:- Payment Options
extension ChatMessageVC{
    func initilizePaymentPopup(price: String, paymentType: popupPaymentType, jobReleasedAmount: String)  {
            let type = "1"
            var paymentPrice = price
            if paymentPrice == ""{
                paymentPrice = "0"
            }
            
            var booking_Amount = self.jobDetail?.remaining_amount ?? self.jobprice

            if booking_Amount == ""{
                booking_Amount = self.jobprice
            }
            
            if type == PaymentType.depositNow{
                booking_Amount = self.jobprice
            }
            
                let objCehckout = self.storyboard?.instantiateViewController(withIdentifier: "CheckoutViewController") as? CheckoutViewController
                let strPrice = booking_Amount.replacingOccurrences(of: " ", with: "")
                objCehckout?.payableAmount = strPrice ?? "0"
                objCehckout?.blockPaymentStatus = { (status, paymentType, transactionID) in
                    if status{
                       self.fundsType = type
                        self.apiCallForUpdatePaymentStatus(booking_Amount: booking_Amount, payable_amount: paymentPrice, job_id: self.jobdetailID, payment_tag: self.fundsType, Crafter_id: "\(self.jobDetail?.handyman_id ?? self.CrafterID)",paymentType: paymentType, transactionID: transactionID){ (status) in
                            if status{
                                self.view.isUserInteractionEnabled = true
                                self.displayPaymentStatusButton()
                            }
                        }
                    }
                }
                objCehckout?.modalPresentationStyle = .fullScreen
                self.present(objCehckout!, animated: true, completion: nil)
    }
    
    func releaseAllAmount() {
        var paymentPrice = self.jobprice
        if paymentPrice == ""{
            paymentPrice = "0"
        }
        
        var booking_Amount = self.jobDetail?.remaining_amount ?? self.jobprice

        if booking_Amount == ""{
            booking_Amount = self.jobprice
        }
        self.fundsType = PaymentType.releaseAll
        self.apiCallForUpdatePaymentStatus(booking_Amount: booking_Amount, payable_amount: paymentPrice, job_id: self.jobdetailID, payment_tag: self.fundsType, Crafter_id: "\(self.jobDetail?.handyman_id ?? self.CrafterID)") { (status) in
            if status{
            self.view.isUserInteractionEnabled = true
                APPDELEGATE?.addAlertPopupviewWithCompletion(viewcontroller: self, oprnfrom: "releaseAll", message: "Great! job has been completed!!!") { (status) in
                    if status{
                        APPDELEGATE?.addProgressView()
                        self.txtMessage.resignFirstResponder()
                        self.changeJobStatusandAmount(bookingstatus: "4", amount: "", isCompleted: true){ (status) in
                            if status{
                                APPDELEGATE?.addProgressView()
                                self.displayPaymentStatusButton()
                                self.chat_option_status = changeChatStatus.Completed
                                self.setPopups()
                                //Send Amount to Server
                                
                                //Change job status
                                if APPDELEGATE?.selectedUserType == .Crafter{
                                    self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Completed)")
                                    self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Completed)", isHideProgress: true)
                                }else{
                                    self.changeJobChatStatus(userId: self.opponentUserid, chatOptionStatus: "\(changeChatStatus.Completed)")
                                    self.changeJobChatStatus(userId: self.currentUserId, chatOptionStatus: "\(changeChatStatus.Completed)", isHideProgress: true)
                                }

                                let displayPopup = self.displayPopupView()
                                displayPopup.intiWithuserdetail(userdetail: [:], displayPopUp: 4, isfrom: "",userID:"\(self.jobDetail?.handyman_id ?? "")", oponnentuserid: "\(self.opponentUserid)",jobID:"\(self.jobDetail?._id ?? "")", is_block: "", conversationIdJob: "", isReview: self.jobDetail?.is_review ?? "")
                                displayPopup.frame = self.view.bounds
                                self.view.addSubview(displayPopup)
                                self.view.endEditing(true)
                                //Send Message
                                self.sendmessage(message: "Great! job has been completed!!!",sendNotif:false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func hideDepositFundButton(isHide: Bool)  {
        btnDepositFundsNow.isHidden = isHide
    }
    
    func displayPaymentStatusButton() {
        
        if appDelegate.selectedUserType == .Crafter{
            hideDepositFundButton(isHide: true)
            if self.fundsType == PaymentType.depositNow || self.fundsType == PaymentType.releaseSomeFund{
                if self.jobDetail?.is_acceptable == "1"{
                    viewReleasedFund.isHidden = true
                    heightviewReleasedFund.constant = 0
                }else{
                    viewReleasedFund.isHidden = false
                    heightviewReleasedFund.constant = 40
                }
                
               
                if appDelegate.selectedUserType == .Crafter{
                    let nm = jobDetail?.client_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobDetail?.client_name ?? "")
                    if tempName.count >= 2{
                        lblReleasedFund.text = "\(UName). deposited all agreed amount of £\(jobprice)"
                    }else{
                        lblReleasedFund.text = "\(UName) deposited all agreed amount of £\(jobprice)"
                    }
                }else{
                    lblReleasedFund.text = "You deposited all agreed amount of £\(jobprice)"
                }
            }else if self.fundsType == PaymentType.releaseAll{
                if appDelegate.selectedUserType == .Crafter{
                    let nm = jobDetail?.client_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobDetail?.client_name ?? "")
                    if tempName.count >= 2{
                        lblReleasedFund.text = "\(UName). released all agreed amount of £\(jobprice)"
                    }else{
                        lblReleasedFund.text = "\(UName) released all agreed amount of £\(jobprice)"
                    }
                }else{
                    lblReleasedFund.text = "You released all agreed amount of £\(jobprice)"
                }
                viewReleasedFund.isHidden = false
                heightviewReleasedFund.constant = 40
            }
            return
        }
        if self.fundsType == PaymentType.none || self.fundsType == "" {
            if (self.fundsType == PaymentType.none || self.fundsType == "") && chat_option_status == changeChatStatus.Accept{
                hideDepositFundButton(isHide: false)
                btnDepositFundsNow.setTitle("Deposit Funds Now", for: .normal)
            }else{
                hideDepositFundButton(isHide: true)
            }
            viewReleasedFund.isHidden = true
            heightviewReleasedFund.constant = 0
        }else if self.fundsType == PaymentType.depositNow{
            hideDepositFundButton(isHide: true)
            btnDepositFundsNow.setTitle("Release Some Fund", for: .normal)
            if appDelegate.selectedUserType == .Crafter{
                let nm = jobDetail?.client_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: jobDetail?.client_name ?? "")
                if tempName.count >= 2{
                    lblReleasedFund.text = "\(UName). deposited all agreed amount of £\(jobprice)"
                }else{
                    lblReleasedFund.text = "\(UName) deposited all agreed amount of £\(jobprice)"
                }
            }else{
                lblReleasedFund.text = "You deposited all agreed amount of £\(jobprice)"
            }
            viewReleasedFund.isHidden = false
            heightviewReleasedFund.constant = 40
        }else if self.fundsType == PaymentType.depositLater{
            hideDepositFundButton(isHide: false)
            btnDepositFundsNow.setTitle("Deposit Funds Now", for: .normal)
        }else if self.fundsType == PaymentType.releaseSomeFund{
            hideDepositFundButton(isHide: true)
            btnDepositFundsNow.setTitle("Release Some Fund", for: .normal)
            if appDelegate.selectedUserType == .Crafter{
                let nm = jobDetail?.client_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: jobDetail?.client_name ?? "")
                if tempName.count >= 2{
                    lblReleasedFund.text = "\(UName). deposited all agreed amount of £\(jobprice)"
                }else{
                    lblReleasedFund.text = "\(UName) deposited all agreed amount of £\(jobprice)"
                }
            }else{
                lblReleasedFund.text = "You deposited all agreed amount of £\(jobprice)"
            }
            viewReleasedFund.isHidden = false
            heightviewReleasedFund.constant = 40
        }else if self.fundsType == PaymentType.releaseAll{
            hideDepositFundButton(isHide: true)
            btnDepositFundsNow.setTitle("All Funds Released", for: .normal)
            if appDelegate.selectedUserType == .Crafter{
                let nm = jobDetail?.client_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: jobDetail?.client_name ?? "")
                if tempName.count >= 2{
                    lblReleasedFund.text = "\(UName). released all agreed amount of £\(jobprice)"
                }else{
                    lblReleasedFund.text = "\(UName) released all agreed amount of £\(jobprice)"
                }
            }else{
                lblReleasedFund.text = "You released all agreed amount of £\(jobprice)"
            }
            viewReleasedFund.isHidden = false
            heightviewReleasedFund.constant = 40
        }
        tblReleasedFund.reloadData()
    }
    
    func displayPaymentPopupView() -> PaymentPopup{
        let infoWindow = PaymentPopup.instanceFromNib() as! PaymentPopup
        return infoWindow
    }
    
    @IBAction func btnViewSummary(_ sender: Any) {
        if isSummaryTapped{
            isSummaryTapped = false
            if CGFloat((jobDetail?.payment_array.count ?? 0) * 40) > 300{
                heightTblReleaseFundConstraint.constant = 300
            }else{
                heightTblReleaseFundConstraint.constant = CGFloat((jobDetail?.payment_array.count ?? 0) * 40)
            }
            tblReleasedFund.reloadData()
            tblReleasedFund.isHidden = false
        }else{
            isSummaryTapped = true
            heightTblReleaseFundConstraint.constant = 0
        }
        UIView.animate(withDuration: 1.0, animations: {
            self.view.layoutIfNeeded()
            self.view.updateConstraintsIfNeeded()
        })
    }
    
    func apiCallIsChatWithClient(Crafter_id: String, job_id: String, client_id: String){
        let param = ["loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")", "user_type":"\(appDelegate.uerdetail?.user_type ?? "")", "job_id":job_id, "client_id":client_id]
       
        WebService.Request.patch(url: saveUserChatData, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if (response!["data"] as? [String: Any]) != nil{
                    
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
    
    func apiCallForUpdatePaymentStatus(booking_Amount: String, payable_amount: String, job_id: String, payment_tag: String, Crafter_id: String,paymentType: String = "", transactionID: String = "", completionBlock : ((Bool)->())?){
        //0: none, 1: deposite, 2 : deposite later, 4: release all, 3: release some fund
        var param = ["user_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")", "job_id":job_id, "user_type":"\(appDelegate.uerdetail?.user_type ?? "")", "payment_tag":payment_tag, "booking_amount":booking_Amount, "payable_amount":payable_amount, "handyman_id":Crafter_id]
        
        if payment_tag == "1"{
            param["payable_amount"] = booking_Amount
        }
        
        if payment_tag == "2"{
            param["booking_amount"] = self.jobprice
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
        APPDELEGATE?.addProgressView()
        self.view.isUserInteractionEnabled = false
        WebService.Request.patch(url: setPaymentTags, type: .post, parameter: param, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [String: Any]{
                    if let dataresponse = data["jobs"] as? [String: Any] {
                        do
                        {
                            APPDELEGATE?.addProgressView()
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse, options: .prettyPrinted)
                            let JobData = try! JSONDecoder().decode(JobHistoryData.self, from: jsonData)
                            self.jobDetail = JobData
                            if APPDELEGATE?.selectedUserType == .Crafter{
                                self.firebaseUpdatePaymentStatus(userId: self.currentUserId, chatOptionStatus: "\(payment_tag)")
                                self.firebaseUpdatePaymentStatus(userId: self.opponentUserid, chatOptionStatus: "\(payment_tag)")
                            }else{
                                self.firebaseUpdatePaymentStatus(userId: self.opponentUserid, chatOptionStatus: "\(payment_tag)")
                                self.firebaseUpdatePaymentStatus(userId: self.currentUserId, chatOptionStatus: "\(payment_tag)")
                            }
                            self.tblReleasedFund.reloadData()
                            if payment_tag == PaymentType.depositNow{
                                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Your Funds has been deposited successfully.")
                            }else if payment_tag == PaymentType.depositLater{
                                
                            }else if payment_tag == PaymentType.releaseSomeFund{
                                appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Your Fund has been released successfully.")
                            }else if payment_tag == PaymentType.releaseAll{
                            }
                            self.fundsType = self.jobDetail?.payment_tag ?? "0"
                            self.tblReleasedFund.reloadData()
                            self.displayPaymentStatusButton()
                            if self.jobDetail?.payment_tag == PaymentType.depositNow || self.jobDetail?.payment_tag == PaymentType.releaseAll || self.jobDetail?.payment_tag == PaymentType.releaseSomeFund{
                                if self.jobDetail?.payment_tag == PaymentType.depositNow || self.jobDetail?.payment_tag == PaymentType.releaseSomeFund{
                                    self.sendmessage(message: response!["msg"] as? String ?? "", sendNotif: false ,IsSystemMessage: "1")
                                }else if self.jobDetail?.payment_tag == PaymentType.releaseAll{
                                    self.fundsType = PaymentType.releaseAll
                                    
                                    var Uname = ""
                                    let nm = APPDELEGATE?.uerdetail?.user_name ?? ""
                                    let tempName = nm.split(separator: " ")
                                    let UName = setUserName(name: APPDELEGATE?.uerdetail?.user_name ?? "")
                                    if tempName.count >= 2{
                                        Uname = "\(UName)."
                                    }else{
                                        Uname = "\(UName)"
                                    }
                                    
                                    self.sendmessage(message: "\(Uname) released all agreed amount of £\(self.jobDetail?.booking_amount ?? "")", sendNotif: false ,IsSystemMessage: "1")
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                APPDELEGATE?.hideProgrssVoew()
                            }
                            completionBlock!(true)
                        }catch{
                            completionBlock!(false)
                        }
                    }else{
                        completionBlock!(false)
                    }
                }else{
                    completionBlock!(false)
                }
            }else{
                completionBlock!(false)
            }
        }
    }
    
    func apiCallForCrafterQuote(booking_Amount: String, job_id: String, paymentType: String = "", transactionID: String = "", is_free_quote: String = "0"){
        //0: none, 1: deposite, 2 : deposite later, 4: release all, 3: release some fund
        var param = ["loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token ?? "")", "job_id":job_id, "user_type":"\(appDelegate.uerdetail?.user_type ?? "")", "booking_amount":booking_Amount, "is_free_quote":is_free_quote ]
        
        if paymentType != ""{
            param["paymentType"] = paymentType
        }
        if transactionID != ""{
            param["transaction_id"] = transactionID
        }
        
        WebService.Request.patch(url: addPaymentForCrafter, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [String: Any]{
                }
            }
        }
    }

    func firebaseUpdatePaymentStatus(userId:String,chatOptionStatus:String){
        if jobId != jobaddedDetail?.job_id || conversationId != jobaddedDetail?.conversationId{
            return
        }
        
        let param = ["payment_tag":chatOptionStatus]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobId, detail: param, completion: { (status) in
            
        })
    }
}

extension ChatMessageVC{
    //Send Quote and CHnage Job Status
    func cancelJob(cancelStatus: String){
//        "cancellation_status" (1 : accept cancellation, 2 : declined cancellation)
        
        var param = ["job_id":"\(jobdetailID)","loginuser_id":"\(APPDELEGATE!.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE!.uerdetail?.session_token  ?? "")","cancellation_status":"\(cancelStatus)","user_type":"\(APPDELEGATE?.uerdetail?.user_type ?? "")"]
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
                        self.jobDetail = JobData
                        self.setDetail()
                        var isCancelStatus = ""
                        let cancelUserID = appDelegate.uerdetail?._id ?? ""
                        self.displayPaymentStatusButton()
                        if cancelStatus == "1" {
                            isCancelStatus = "4"
                            self.sendmessageCancel(message: response!["msg"] as? String ?? "", sendNotif: false,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                        }else if cancelStatus == "2" {
                                isCancelStatus = "3"
                            let pdfUrl = response!["pdfUrl"] as? String
                            self.sendmessageCancel(message: pdfUrl ?? "", sendNotif: false,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                        }
                    }catch{
                        
                    }
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.view.isUserInteractionEnabled = true
                APPDELEGATE?.hideProgrssVoew()
            }
            self.displayPaymentStatusButton()
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
                    let nm = jobDetail?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobDetail?.full_name ?? "")
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
                    let nm = jobDetail?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobDetail?.full_name ?? "")
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
                let nm = jobDetail?.full_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: jobDetail?.full_name ?? "")
                if tempName.count >= 2{
                    Uname = "\(UName)."
                }else{
                    Uname = "\(UName)"
                }
            }
        }
        return dict
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
                        let nm = jobDetail?.full_name ?? ""
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: jobDetail?.full_name ?? "")
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
            }else{
                let day = stringToDate(strDate: "\(item.messageTime ?? "\(Date())")")
                dict["time"] = timeAgoSinceDate(day)
                if item.isOnlyDisplayOnClientSide == "1" {
                    if APPDELEGATE?.selectedUserType == .Client{
                        dict["message"] = "\(item.message ?? "") your job."
                    }else{
                        var Uname = ""
                        let nm = jobDetail?.full_name ?? ""
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: jobDetail?.full_name ?? "")
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
                    let nm = jobDetail?.full_name ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: jobDetail?.full_name ?? "")
                    if tempName.count >= 2{
                        Uname = "\(UName)."
                    }else{
                        Uname = "\(UName)"
                    }
                    dict["name"] = Uname 
                }
            }
            arrDict.append(dict)
        }
        return arrDict
    }
    
    func convertToJsonString(from object:[[String:Any]]) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
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
                if message.iscancellationType == "1" && message.senderUserType == Crafter && jobDetail?.payment_array.count ?? 0 > 0{
                    return "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if message.iscancellationType == "1" && message.senderUserType == Crafter && jobDetail?.payment_array.count == 0{
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
                if message.iscancellationType == "1" && message.senderUserType == Crafter && jobDetail?.payment_array.count ?? 0 > 0{
                    return "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if message.iscancellationType == "1" && message.senderUserType == Crafter && jobDetail?.payment_array.count == 0{
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
    
    func sendmessageCancel(message:String,sendNotif:Bool,isOnlyDisplayOnClientSide: String = "0", isCancelStatus: String = "0", cancelUserID: String = "0"){
        let messageId = fourDigitNumber
        let timeinterval = getTimeInterval()
        let date = Date()
        var senderID = APPDELEGATE?.uerdetail?.user_id ?? ""
        if isOnlyDisplayOnClientSide == "1" && APPDELEGATE?.selectedUserType == .Client{
            senderID = jobDetail?.handyman_id ?? ""
        }
        let params = ["message":"\(message)","messageTime":"\(date)","senderId":senderID,"isRead":"\(0)","conversationId":conversationId,"messageid":"\(messageId)","timeinterval":"\(timeinterval)","isOnlyDisplayOnClientSide": isOnlyDisplayOnClientSide, "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? ""]


        FirebaseAPICall.firebaseSendMessage(conversationId: conversationId, messageId: messageId, messsageDetail: params) { (status, error, data) in
            if status{
                //Update user detail to Firebase
                self.addtoFirebaseCancel(conversationId: self.conversationId, userId: APPDELEGATE?.uerdetail?._id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.addtoFirebaseCancel(conversationId: self.conversationId, userId: self.jobDetail?.client_id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                }else{
                    self.addtoFirebaseCancel(conversationId: self.conversationId, userId: self.jobDetail?.handyman_id ?? "", timeinterval: timeinterval, time: date, message: message,isCancelStatus: isCancelStatus, cancelUserID: cancelUserID)
                }
                
                //Update Last message read or not
                self.UpdateIsMessageReadOrNot(UserId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", isRead: "0")
                
                //Update  message count
                if APPDELEGATE?.selectedUserType == .Crafter{
                    self.updateMessageCounttojobCancel(unreadMessageCountcount: self.unreadMessageCount, userId: self.jobDetail?.client_id ?? "")
                }else{
                    self.updateMessageCounttojobCancel(unreadMessageCountcount: self.unreadMessageCount, userId: self.jobDetail?.handyman_id ?? "")
                }
            }
        }
    }
    
    func addtoFirebaseCancel(conversationId:String,userId:String,timeinterval:String,time:Date,message:String, isCancelStatus: String = "0", cancelUserID: String = "0"){
        
        let param = ["lastmessage":"\(message)","lastmessagetime":"\(time)","timeinterval":"\(timeinterval)","senderId":"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", "iscancellationType": isCancelStatus, "isCancelledUser": cancelUserID, "senderUserType": appDelegate.uerdetail?.user_type ?? ""] as [String : Any]
        FirebaseJobAPICall.FirebaseupdateLastMessage(MyuserId: userId, jobId: self.jobId, ChatuserDetail: param, completion:{ (status) in
            if status{
                
            }
        })
    }
    
    func UpdateIsMessageReadOrNotCancel(UserId:String,isRead:String){
        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: self.jobId, detail: param, completion: { (status) in
            
        })
    }
    
    func updateMessageCounttojobCancel(unreadMessageCountcount:Int,userId:String){
        
        self.unreadMessageCount += 1
        let param = ["unreadMessageCount":unreadMessageCountcount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobId, detail: param, completion: { (status) in
            
        })
    }
}











