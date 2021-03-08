
import UIKit
import IQKeyboardManagerSwift
import AVKit

class ChatuserListViewController: UIViewController {

    @IBOutlet weak var tblChatlist: UITableView!
    @IBOutlet weak var viewSearch: UIView!
    @IBOutlet weak var txtSearch: UITextField!
    @IBOutlet weak var lblWaitingForNetwork: UILabel!
    @IBOutlet weak var heightWaitingForNetwork: NSLayoutConstraint!//19
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var lblNoanyMessages: UILabel!
    @IBOutlet weak var heighttopNav: NSLayoutConstraint!
    @IBOutlet weak var heightSearch: NSLayoutConstraint!
    @IBOutlet weak var topWaitingForNetwork: NSLayoutConstraint!//21
    @IBOutlet weak var topSearch: NSLayoutConstraint!//8
    @IBOutlet weak var topTableVIew: NSLayoutConstraint!//8
    
    var arrfromFirebase: [jobsAdded]!
    var arrJobsserver = [[String:Any]]()
    var arrfinal = NSMutableArray()
    var searchData = NSMutableArray()
    var search:String=""
    var refreshControl = UIRefreshControl()
    var isGoChat = false
    var arrUnreadCount = NSMutableArray()
    var arrCurrentJobChat = NSMutableArray()
    var blockChatHeight: ((CGFloat, Bool) -> ())! = nil
    var isFromJobDetail = false
    var jobID = String()
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tblChatlist.keyboardDismissMode = .interactive
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide

        APPDELEGATE?.isfromChat()
        networkAvailable()
        onLoadOperations()
        APPDELEGATE?.addProgressView()
        if APPDELEGATE?.selectedUserType == .Client{
            lblNoanyMessages.text = "There are no any messages because crafter couldn't make any offers yet."
        }else{
            lblNoanyMessages.text = "To being seeing your messages, please make an offer to the client."
        }
        if #available(iOS 10.0, *) {
            tblChatlist.refreshControl = refreshControl
        } else {
            tblChatlist.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshChatList(_:)), for: .valueChanged)
    }
    
    func setTopHeight() {
        topSearch.constant = 0
        topTableVIew.constant = 0
        topWaitingForNetwork.constant = 0
        heighttopNav.constant = 0
        heightSearch.constant = 0
        viewNavigate.isHidden = true
        viewSearch.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APPDELEGATE?.isfromChat()
        self.lblNoanyMessages.isHidden = true
        self.isGoChat = true
        getjobListingAll(myId:"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
    }
    
    @objc private func refreshChatList(_ sender: Any) {
        self.lblNoanyMessages.isHidden = true
        self.isGoChat = true
        getjobListingAll(myId:"\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))")
    }

    //Set Corner
    func onLoadOperations(){
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    //CHeck Network Availability
    func networkAvailable(){
        if ConnectivityNew.isConnectedToInternet(){
            heightWaitingForNetwork.constant = 0
        }else{
            heightWaitingForNetwork.constant = 24
        }
    }

    @IBAction func btnBack(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- TableView Delegate and Datasource Methods
extension ChatuserListViewController: UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 97
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatuserCell", for: indexPath) as? ChatuserCell
        
        //Get lable by Tag
        cell?.lblNotifCount?.layer.cornerRadius = 11.0
        cell?.lblNotifCount?.layer.masksToBounds = true

        let data = searchData[indexPath.row] as? [String:Any]
        let messagedetail = data!["jobData"] as? jobsAdded
        
        let day = stringToDate(strDate: "\(messagedetail?.lastmessagetime ?? "\(Date())")")
        if messagedetail?.iscancellationType != "0" && messagedetail?.iscancellationType != "" && messagedetail?.iscancellationType != nil{
            configureCell(cell: cell!, indexPath: indexPath)
        }else{
            cell?.lblLastMessage?.text = "\(messagedetail?.lastmessage ?? "")"
        }
   
        if messagedetail?.iscancellationType == "1" || messagedetail?.iscancellationType == "2" || messagedetail?.iscancellationType == "3" || messagedetail?.chat_option_status == "5" || messagedetail?.chat_option_status == "7"{
            
            if data!["full_name"] as? String == nil || data!["full_name"] as? String == ""{
                    if data!["user_name"] as? String == nil || data!["user_name"] as? String == ""{
                        cell?.lblName?.text = ""
                    }else{
                        let nm = data!["user_name"] as? String ?? ""
                        let tempName = nm.split(separator: " ")
                        let UName = setUserName(name: data!["user_name"] as? String ?? "")
                        if tempName.count >= 2{
                            cell?.lblName?.text = "\(UName)."
                        }else{
                            cell?.lblName?.text = "\(UName)"
                        }
                    }
            }else{
                let nm = data!["full_name"] as? String ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: data!["full_name"] as? String ?? "")
                if tempName.count >= 2{
                    cell?.lblName?.text = "\(UName)."
                }else{
                    cell?.lblName?.text = "\(UName)"
                }
            }
        }else{
            if data!["full_name"] as? String == nil || data!["full_name"] as! String == ""{
                if data!["user_name"] as? String == nil || data!["user_name"] as? String == ""{
                    cell?.lblName?.text = ""
                }else{
                    let nm = data!["user_name"] as? String ?? ""
                    let tempName = nm.split(separator: " ")
                    let UName = setUserName(name: data!["user_name"] as? String ?? "")
                    if tempName.count >= 2{
                        cell?.lblName?.text = "\(UName)."
                    }else{
                        cell?.lblName?.text = "\(UName)"
                    }
                }
            }else{
                let nm = data!["full_name"] as? String ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: data!["full_name"] as? String ?? "")
                if tempName.count >= 2{
                    cell?.lblName?.text = "\(UName)."
                }else{
                    cell?.lblName?.text = "\(UName)"
                }
            }
        }
        cell?.lblLastMessageTime?.text = "\(timeAgoSinceDate(day))"
        cell?.lblJobCat.text = "\(data!["job_description"] as? String ?? "")"
        cell?.imgProfile?.isHidden = true
        let imgURL = data!["job_image"] as? String ?? ""
        print("URL->",imgURL)
        if (imgURL.contains(".mp4")) || (imgURL.contains(".mov")){
            let path = URL(string:imgURL)
            DispatchQueue.global(qos: .background).async
                {
                    if let thumbnailImage = self.getThumbnailImage_2(forUrl: path!)
                    {
                        DispatchQueue.main.async
                            {
                                cell?.imgProfile?.image = thumbnailImage
                                cell?.imgProfile?.isHidden = false
                        }
                    }
            }
        }else{
            cell?.imgProfile?.isHidden = false
            let imgURL1 = URL(string: data!["job_image"] as? String ?? "")
            cell?.imgProfile?.kf.setImage(with: imgURL1, placeholder: nil)
        }
        
        let imgservice = URL(string: messagedetail?.service_image ?? "")
        cell?.imgService?.kf.setImage(with: imgservice, placeholder: nil)
        let messageCount = messagedetail?.unreadMessageCount ?? 0
        if messageCount <= 0
        {
            cell?.lblNotifCount?.isHidden = true
        }
        else
        {
            cell?.lblNotifCount?.isHidden = false
            cell?.lblNotifCount?.text = "\(messageCount)"
        }
        
        if messagedetail?.senderId == APPDELEGATE?.uerdetail?._id{
            cell?.imgIsread.isHidden = false
            cell?.widthimgisRead.constant = 16
            cell?.leadingIsRead.constant = 8
            if messagedetail?.isRead == "1"{
                let img = UIImage(named: "double_tick")?.withRenderingMode(.alwaysTemplate)
                cell?.imgIsread.image = img
                cell?.imgIsread.tintColor = UIColor(red: 50/255, green: 166/266, blue: 232/255, alpha: 1.0)
            }else if messagedetail?.isRead == "0"{
                let img = UIImage(named: "double_tick")?.withRenderingMode(.alwaysTemplate)
                cell?.imgIsread.image = img
                cell?.imgIsread.tintColor = UIColor.gray
            }else{
                cell?.imgIsread.isHidden = true
                cell?.widthimgisRead.constant = 0
                cell?.leadingIsRead.constant = 0
            }
        }else{
            cell?.imgIsread.isHidden = true
            cell?.widthimgisRead.constant = 0
            cell?.leadingIsRead.constant = 0
        }

        return cell!
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

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (APPDELEGATE?.isChatViewcontroller)!{
            return
        }
        
        let userdata = searchData[indexPath.row] as? [String:Any]
        let jobdetail = userdata?["jobData"] as? jobsAdded
        let storyboard = UIStoryboard(name: "Chat", bundle: nil)
        let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
        APPDELEGATE?.isChatViewcontroller = true
        messages?.conversationId = jobdetail?.conversationId ?? ""
        messages?.jobId = jobdetail?.job_id ?? ""
        messages?.chat_option_status = jobdetail?.chat_option_status ?? ""
        messages?.service_image = jobdetail?.service_image ?? ""
        messages?.profile_image = userdata?["profile_image"] as? String ?? ""
        messages?.fullname = userdata?["full_name"] as? String ?? ""
        messages?.username = userdata?["user_name"] as? String ?? ""
        messages?.CrafterID = jobdetail?.CrafterId ?? ""
        messages?.jobdetailID = jobdetail?.jobdetailID ?? ""
        self.navigationController?.pushViewController(messages!, animated: true)
    }
    
    func configureCell(cell: UITableViewCell, indexPath: IndexPath) {
        if let cellSender = cell as? ChatuserCell{
            let data = searchData[indexPath.row] as? [String:Any]
            let messagedetail = data!["jobData"] as? jobsAdded
            if appDelegate.selectedUserType == .Crafter{
                if messagedetail?.iscancellationType == "1" && messagedetail?.senderUserType == Crafter{
                    cellSender.lblLastMessage.text = "You \(crafterCancelJobOwnMessage)"
                }else if messagedetail?.iscancellationType == "1" && messagedetail?.senderUserType == Client{
                    cellSender.lblLastMessage.text = "Client \(clientCancelJobCrafterMessage)"
                }else if messagedetail?.iscancellationType == "2" && messagedetail?.senderUserType == Client{
                    cellSender.lblLastMessage.text = "Client \(clientCancelJobAfterPaymentCrafterMessage)"
                }else if messagedetail?.iscancellationType == "4" && messagedetail?.senderUserType == Crafter{
                    cellSender.lblLastMessage.text = "You \(crafterAcceptJobCancellationOwnMessage)"
                }else if messagedetail?.iscancellationType == "3" && messagedetail?.senderUserType == Crafter{
                    cellSender.lblLastMessage.text = "You \(crafterCancelJobCancellationOwnMessage)"
                }
            }else{
                let arrPaymentCount = data?["payment_array"] as? [[String:Any]]
                if messagedetail?.iscancellationType == "1" && messagedetail?.senderUserType == Crafter && arrPaymentCount?.count ?? 0 > 0{
                    cellSender.lblLastMessage.text = "Crafter \(crafterCancelJobClientMessageAfterPayment)"
                }else if messagedetail?.iscancellationType == "1" && messagedetail?.senderUserType == Crafter && arrPaymentCount?.count ?? 0 == 0{
                    cellSender.lblLastMessage.text = "Crafter \(crafterCancelJobClientMessage)"
                }else if messagedetail?.iscancellationType == "1" && messagedetail?.senderUserType == Client{
                    cellSender.lblLastMessage.text = "You \(clientCancelJobOwnMessage)"
                }else if messagedetail?.iscancellationType == "2" && messagedetail?.senderUserType == Client{
                    cellSender.lblLastMessage.text = "Your \(clientCancelJobAfterPaymentOwnMessage)"
                }else if messagedetail?.iscancellationType == "4" && messagedetail?.senderUserType == Crafter{
                    cellSender.lblLastMessage.text = "Crafter \(crafterAcceptJobCancellationClientMessage)"
                }else if messagedetail?.iscancellationType == "3" && messagedetail?.senderUserType == Crafter{
                    cellSender.lblLastMessage.text = "Crafter \(crafterCancelJobCancellationClientMessage) \(messagedetail?.lastmessage ?? "")"
                }
            }
        }
    }

}

//MARK:- Firebase
extension ChatuserListViewController
{
    func getjobListingAll(myId:String){
        var isLoad = true
        APPDELEGATE?.addProgressView()
        FirebaseJobAPICall.firebaseGetJob(myId: myId) { (status, error, data) in
            if status{
                if data != nil{
                    do
                    {
                        let arr = try? JSONDecoder().decode([jobsAdded].self, from: data! as! Data)
                        var Ids = String()
                        var jobIds = String()
                        self.arrfromFirebase = []
                        for item in arr ?? []{
                            if item.lastmessage == "" || item.lastmessage == nil{
                                
                            }else{
                                self.arrfromFirebase.append(item)
                                if APPDELEGATE?.selectedUserType == .Crafter{
                                    if Ids == ""{
                                        Ids = item.ClientId ?? ""
                                        jobIds = item.jobdetailID ?? ""
                                    }else{
                                        if item.ClientId != nil{
                                            Ids = Ids + "," + (item.ClientId ?? "")
                                            jobIds = jobIds + "," + (item.jobdetailID ?? "")
                                        }
                                    }
                                }else{
                                    if Ids == ""{
                                        Ids = item.CrafterId ?? ""
                                        jobIds = item.jobdetailID ?? ""
                                    }else{
                                        if item.CrafterId != nil{
                                            Ids = Ids + "," + (item.CrafterId ?? "")
                                            jobIds = jobIds + "," + (item.jobdetailID ?? "")
                                        }
                                    }
                                }
                            }
                        }
                        
                        if Ids != ""{
                            self.getJobsFromServer(jobIds: jobIds, userIDs: Ids,isLoad: isLoad)
                            self.isGoChat = false
                            isLoad = false
                        }
                    }
                    self.displayNomessageLabel()
                }else{
                    self.displayNomessageLabel()
                }
            }else{
                self.displayNomessageLabel()
            }
            if self.arrfromFirebase == nil{
                if isLoad{
                    APPDELEGATE?.hideProgrssVoew()
                }
                self.refreshControl.endRefreshing()
            }else if self.arrfromFirebase.count == 0{
                if isLoad{
                    APPDELEGATE?.hideProgrssVoew()
                }
                self.refreshControl.endRefreshing()
            }
        }
    }

    func displayNomessageLabel(){
        if self.arrfromFirebase == nil{
            self.lblNoanyMessages.isHidden = false
            self.tblChatlist.isHidden = true
        }else if self.arrfromFirebase.count == 0{
            self.lblNoanyMessages.isHidden = false
            self.tblChatlist.isHidden = true
        }else{
            self.lblNoanyMessages.isHidden = true
            self.tblChatlist.isHidden = false
        }
    }

    func getJobsFromServer(jobIds:String ,userIDs: String, isLoad: Bool)
    {
        var userType = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            userType = Crafter
        }
        else
        {
            userType = Client
        }

        let params = ["user_ids":"\(userIDs)","loginuser_id":"\(APPDELEGATE!.uerdetail?._id ?? (APPDELEGATE!.uerdetail?.user_id ?? ""))","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)","job_ids":"\(jobIds)"]
        WebService.Request.patch(url: getUserInfo, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    if let data = response!["data"] as? [[String: Any]] {
                        print(data)
                        if data.count > 0 {
                            self.arrJobsserver = data
                            self.arrfinal = NSMutableArray()
                            for item in self.arrfromFirebase{
                                for var data in self.arrJobsserver{
                                    if APPDELEGATE?.selectedUserType == .Crafter{
                                        if data["job_id"] as? String == item.jobdetailID{
                                            data["jobData"] = item
                                            data["description"] = "\(item.service_description ?? "")"
                                            self.arrfinal.add(data)
                                        }
                                    }else{
                                        if data["job_id"] as? String == item.jobdetailID && item.job_id == "\(data["job_id"] as? String ?? "")\(data["_id"] as? String ?? "")"{
                                            data["jobData"] = item
                                            data["description"] = "\(item.service_description ?? "")"
                                            self.arrfinal.add(data)
                                        }
                                    }
                                }
                            }
                        }else{
                            self.arrfinal = NSMutableArray()
                        }
                        var arr = NSMutableArray()
                        if self.isFromJobDetail{
                            for item in self.arrfinal{
                                let data = item as? [String:Any]
                                if self.jobID == data?["job_id"] as? String{
                                    arr.add(item)
                                }
                            }
                            self.searchData = arr
                        }else{
                            self.searchData = self.arrfinal
                        }
                        self.tblChatlist.reloadData()
                        if self.isFromJobDetail{
                            self.blockChatHeight!(CGFloat(self.searchData.count),self.searchData.count == 0 ? true : false)
                        }
                        
                    }
                } else{
                }
            }
            if isLoad{
                APPDELEGATE?.hideProgrssVoew()
            }
            self.refreshControl.endRefreshing()
        }
    }
}

//MARK:- textfield Search
extension ChatuserListViewController:UITextFieldDelegate{
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        if string.isEmpty{
            search = String(search.dropLast())
        }else{
            search=textField.text!+string
        }
        
        print(search)
        let predicate=NSPredicate(format: "SELF.full_name CONTAINS[cd] %@ OR description CONTAINS[cd] %@", search, search)
        let arr=(arrfinal as NSArray).filtered(using: predicate)
        
        if arr.count > 0{
            searchData = NSMutableArray()
            searchData.addObjects(from: arr)
        }else{
            searchData = NSMutableArray()
        }
        
        if search == ""{
            searchData=arrfinal
        }
        tblChatlist.reloadData()
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == txtSearch{
            txtSearch.resignFirstResponder()
        }
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        let predicate=NSPredicate(format: "SELF.full_name CONTAINS[cd] %@ OR description CONTAINS[cd] %@", search, search)
        let arr=(arrfinal as NSArray).filtered(using: predicate)
        
        if arr.count > 0{
            searchData = NSMutableArray()
            searchData.addObjects(from: arr)
        }else{
            searchData = NSMutableArray()
        }
        
        if search == ""{
            searchData=arrfinal
        }
        tblChatlist.reloadData()
    }
}
