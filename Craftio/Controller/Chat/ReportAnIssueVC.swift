
import UIKit
import IQKeyboardManagerSwift

class ReportAnIssueVC: UIViewController,UITextViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var txtissue: UITextView!
    @IBOutlet weak var imgUserProfile: UIImageView!
    
    var userId = String()
    var jobID = String()
    var jobList: JobHistoryData?
    var isfromChat = false
    
    var tap = UIGestureRecognizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtissue.becomeFirstResponder()
        GetJobDetailAPI()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        self.txtissue.autocorrectionType = .no
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.view.addGestureRecognizer(self.tap)
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    

     @objc func handleTap(sender: UITapGestureRecognizer? = nil)
     {
        self.view.endEditing(true)
     }
    
    @IBAction func btnBack(_ sender: Any) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSend(_ sender: Any) {
        self.view.endEditing(true)
        if txtissue.text == "Write an issue"{
            report(user_id: userId ,msj: "")
        }else{
            report(user_id: userId ,msj: "\(txtissue.text ?? "")")
        }
        getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobId: jobID, fromQue: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.txtissue.tintColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)

        if txtissue.text == "Write an issue"{
            txtissue.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtissue.text == ""{
            txtissue.text = "Write an issue"
        }
    }

    //Get Job Detail API
    func GetJobDetailAPI()
    {
        var userType = String()
        var CrafterId = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            userType = Crafter
            CrafterId = APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? "")
        }
        else
        {
            userType = Client
            CrafterId = userId
        }

        let params = ["job_id":"\(jobID)","handyman_id":CrafterId,"loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)"]
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
                                let imgURL = URL(string: JobData?[0].profile_image ?? "")
                                
                                self.imgUserProfile?.kf.setImage(with: imgURL, placeholder: nil)
                                self.jobList = JobData?[0]
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

    //Report Issue
    func report(user_id:String,msj:String)
    {
        var user_type = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            user_type = "2"
        }
        else
        {
            user_type = "1"
        }
        
        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","to_user_id":"\(user_id)","reason":msj,"job_id":"\(jobID)","user_type":"\(user_type)"]
        WebService.Request.patch(url: reportUser, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    if APPDELEGATE?.selectedUserType == .Crafter{
                        APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "jobdetail", message:"Your client is now being reviewed by our team.")
                    }else{
                        APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "jobdetail", message:"Your crafter is now being reviewed by our team.")
                    }
                } else
                {
                }
            }
        }
    }

}

//MARK:- Firebase
extension ReportAnIssueVC{
    
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
                        
                        if item.jobdetailID == self.jobList?._id && item.job_id == "\(self.jobList?._id ?? "")\(APPDELEGATE?.uerdetail?._id ?? "")"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                  //  self.updateChatStatus(userid: "\(self.jobList?.handyman_id ?? "")", jobId: jobDetail?.job_id ?? "")
                  //  self.updateChatStatus(userid: "\(self.jobList?.client_id ?? "")", jobId: jobDetail?.job_id ?? "")
                    if isAvail{
                        self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,fromQue:fromQue)
                    }
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
        
            var Uname = ""
            let nm = jobList?.full_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: jobList?.full_name ?? "")
            if tempName.count >= 2{
                Uname = "\(UName)."
            }else{
                Uname = "\(UName)"
            }
            messages?.fullname = Uname  
            messages?.CrafterID = userId
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            if fromQue{
                messages?.isOpenFromQue = true
            }
            self.navigationController?.pushViewController(messages!, animated: true)
    }
}
