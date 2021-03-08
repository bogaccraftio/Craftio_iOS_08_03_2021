//
//  NotificationListVC.swift
//  Craftio
//
//  Created by Youngbrainz Infotech on 15/02/19.
//  Copyright © 2019 Himesh Soni. All rights reserved.
//

import UIKit

class NotificationListVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var tblNotificList: UITableView!
    
    var NotiList: [NotificationListData]?
    var arrNew = NSMutableArray()
    var arrEarly = NSMutableArray()
    var notificationdata = [[String:Any]]()
    var isnotification = false
    var refreshControl = UIRefreshControl()
    var notificationjobID = String()
    var notificationCrafterID = String()

    
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
        
        if #available(iOS 10.0, *) {
            tblNotificList.refreshControl = refreshControl
        } else {
            tblNotificList.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshnotificationList(_:)), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        APPDELEGATE?.isfromChat()
        isnotification = false
        self.getNotificationListAPI(isLoaderHide: false)
    }
    
    @objc private func refreshnotificationList(_ sender: Any) {
        // Fetch Weather Data
        self.getNotificationListAPI(isLoaderHide: true)
    }

    
    func onLoadOperations()
    {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape        
    }
    
    //MARK: Button Tapped Events
    @IBAction func btnBack(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension NotificationListVC : UITableViewDelegate,UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            if arrNew.count > 0
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        if section == 1
        {
            return self.arrNew.count //?? 0
        }
        if section == 2
        {
            if self.arrEarly.count > 0
            {
                return 1
            }
            else
            {
                return 0
            }
        }
        else
        {
            return self.arrEarly.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        var identifier = ""
        switch indexPath.section
        {
            case 0:
                identifier = "Header"
            case 1:
                identifier = "Footer"
            case 2:
                identifier = "Header"
            case 3:
                identifier = "Footer"
            default:
                break
        }
        
        let cell = self.tblNotificList.dequeueReusableCell(withIdentifier:identifier) as! CellNotificationList
        if indexPath.section == 0
        {
            cell.lblHeader.text = ""
        }
        else if indexPath.section == 1
        {
            cell.viewMain.layer.masksToBounds = true
            cell.viewMain.layer.cornerRadius = 13.0
            cell.viewMain.clipsToBounds = false
            cell.viewMain.layer.shadowColor = UIColor.gray.cgColor
            cell.viewMain.layer.shadowOpacity = 0.3
            cell.viewMain.layer.shadowOffset = CGSize.zero
            cell.viewMain.layer.shadowRadius = 5
            let DataList = arrNew[indexPath.row] as? NotificationListData
            
            let imgURL = URL(string: DataList?.send_user_profile ?? "")
            cell.lblTitle.text = DataList?.message ?? ""
            
            let nm = DataList?.send_user_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: DataList?.send_user_name ?? "")
            if tempName.count >= 2{
                cell.lblName.text = "\(UName)."
            }else{
                cell.lblName.text = "\(UName)"
            }
            
            cell.lblName.textColor = UIColor(red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)
            let img = UIImage(named: "double_tick")?.withRenderingMode(.alwaysTemplate)
            cell.imgTick.image = img
            if DataList?.is_open == "1"{
                cell.imgTick.tintColor = UIColor(red: 50/255, green: 166/266, blue: 232/255, alpha: 1.0)
            }else{
                cell.imgTick.tintColor = UIColor.lightGray
            }

            if DataList?.type == "13"{
                cell.imgProfile.image = UIImage (named: "white background")
                if DataList?.jobs?.is_emergency_job == 1
                {
                    let myString = "Emergency job!"
                    cell.lblName.attributedText = myString.SetAttributed(location: 0, length: 14, font: "Cabin-Bold", size: 18.0)
                }
                else
                {
                    let myString = "Craftio"
                    cell.lblName.attributedText = myString.SetAttributed(location: 0, length: 0, font: "Cabin-Bold", size: 18.0)
                    cell.lblName.textColor = UIColor(red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                }
            }else{
                cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            }
            
            if DataList?.type == "22"{
                cell.imgProfile.image = UIImage (named: "white background")
                cell.lblName.text = "Deposit Funds Now"
            }
            
            if DataList?.type == "30"{
                cell.imgProfile.image = UIImage (named: "white background")
                cell.lblName.text = "Craftio"
            }
        }
        else if indexPath.section == 2
        {
            cell.lblHeader.text = ""
        }
        else
        {
            cell.viewMain.layer.masksToBounds = true
            cell.viewMain.layer.cornerRadius = 15.0
            cell.viewMain.clipsToBounds = false
            cell.viewMain.layer.shadowColor = UIColor.gray.cgColor
            cell.viewMain.layer.shadowOpacity = 0.5
            cell.viewMain.layer.shadowOffset = CGSize.zero
            cell.viewMain.layer.shadowRadius = 5
            
            let DataList = arrEarly[indexPath.row] as? NotificationListData
            let imgURL = URL(string: DataList?.send_user_profile ?? "")
            cell.lblTitle.text = DataList?.message ?? ""
            
            let nm = DataList?.send_user_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: DataList?.send_user_name ?? "")
            if tempName.count >= 2{
                cell.lblName.text = "\(UName)."
            }else{
                cell.lblName.text = "\(UName)"
            }
            //cell.lblName.text = DataList?.send_user_name ?? ""
            
            cell.lblName.textColor = UIColor(red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)
            let img = UIImage(named: "double_tick")?.withRenderingMode(.alwaysTemplate)
            cell.imgTick.image = img
            if DataList?.is_open == "1"{
                cell.imgTick.tintColor = UIColor(red: 50/255, green: 166/266, blue: 232/255, alpha: 1.0)
            }else{
                cell.imgTick.tintColor = UIColor.lightGray
            }


            if DataList?.type == "13"{
                cell.imgProfile.image = UIImage (named: "white background")
                if DataList?.jobs?.is_emergency_job == 1
                {
                    let myString = "Emergency job!"
                    cell.lblName.attributedText = myString.SetAttributed(location: 0, length: 14, font: "Cabin-Bold", size: 18.0)
                }
                else
                {
                    let myString = "Craftio"
                    cell.lblName.attributedText = myString.SetAttributed(location: 0, length: 0, font: "Cabin-Bold", size: 18.0)
                    cell.lblName.textColor = UIColor(red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)
                }
            }else{
                cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            }
            if DataList?.type == "22"{
                cell.imgProfile.image = UIImage (named: "white background")
                cell.lblName.text = "Deposit Funds Now"
            }
            
            if DataList?.type == "30"{
                cell.imgProfile.image = UIImage (named: "white background")
                cell.lblName.text = "Craftio"
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 || indexPath.section == 2{
            return 50
        }
        return 96
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        isnotification = true
        if indexPath.section == 1
        {
            let DataList = arrNew[indexPath.row] as? NotificationListData
            if DataList?.is_open == "0"{
                readNotification(notifID: DataList?._id ?? "")
            }
            navigate(navigateToType: (DataList?.type)!, notificationData: DataList!)
            arrEarly.insert(DataList as Any, at: 0)
            arrNew.removeObject(at: indexPath.row)
            tblNotificList.reloadData()
        }
        else
        {
            let DataList = arrEarly[indexPath.row] as? NotificationListData
            if DataList?.is_open == "0"{
                readNotification(notifID: DataList?._id ?? "")
            }
            navigate(navigateToType: (DataList?.type)!, notificationData: DataList!)
        }
    }

    //MARK :- Func Navigation
    func navigate(navigateToType: String, notificationData: NotificationListData)
    {
        if notificationData.type == "1" || notificationData.type == "5" || notificationData.type == "8" || notificationData.type == "9" || notificationData.type == "10" || notificationData.type == "21" || notificationData.type == "22" || notificationData.type == "23" || notificationData.type == "24" || navigateToType == "2" || navigateToType == "11"
        {
            if notificationData.jobs == nil{
                return
            }
            notificationjobID = notificationData.jobdetail_id ?? ""
            if APPDELEGATE?.selectedUserType == .Crafter{
                notificationCrafterID = notificationData.to_id ?? ""
                getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?.user_id ?? "")", jobId: notificationData.jobs?.job_id ?? "", fromQue: false,jobdetaildata: notificationData.jobs!)
            }else{
                if notificationData.type == "22" {
                    notificationCrafterID = notificationData.jobs?.handyman_id ?? ""
                }else{
                    notificationCrafterID = notificationData.from_id ?? ""
                }
                getjobListingAll(myId: "\(APPDELEGATE?.uerdetail?.user_id ?? "")", jobId: notificationData.jobs?.job_id ?? "", fromQue: false,jobdetaildata: notificationData.jobs!)
            }
        }else if navigateToType == "3" {
            if APPDELEGATE?.selectedUserType == .Crafter{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 2
                objProfileVC.strTag = "Crafter"
                objProfileVC.CrafterId = notificationData.to_id ?? ""
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }else{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.user_type = 1
                objProfileVC.strTag = "Client"
                objProfileVC.CrafterId = notificationData.to_id ?? ""
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }else if navigateToType == "7"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = notificationData.from_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "6"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 2
            objProfileVC.strTag = "Crafter"
            objProfileVC.CrafterId = notificationData.from_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "4"{
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = notificationData.to_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }else if navigateToType == "2" || navigateToType == "11" || notificationData.type == "25" || notificationData.type == "26" || notificationData.type == "27" || notificationData.type == "28"{
            if (notificationData.jobs?.booking_status != changeChatStatus.NotAny && notificationData.jobs?.handyman_id != APPDELEGATE?.uerdetail?.user_id ?? "" && APPDELEGATE?.selectedUserType == .Crafter)  {
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
            objJobDetailsVC.isEdit = false
            objJobDetailsVC.jobList = notificationData.jobs
            objJobDetailsVC.StatusType = "10"
            self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
        }else if navigateToType == "12"{
            if (notificationData.jobs?.booking_status != changeChatStatus.NotAny && notificationData.jobs?.handyman_id != APPDELEGATE?.uerdetail?.user_id ?? "" && APPDELEGATE?.selectedUserType == .Crafter)  {
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                return
            }
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
            objJobDetailsVC.jobList = notificationData.jobs
            self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
        }else if navigateToType == "13"{
            if (notificationData.jobs?.booking_status != changeChatStatus.NotAny && notificationData.jobs?.handyman_id != APPDELEGATE?.uerdetail?.user_id ?? "" && APPDELEGATE?.selectedUserType == .Crafter)  {
                APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message: "The Job has been assigned to other crafter.")
                return
            }
            if APPDELEGATE?.uerdetail?.user_id == notificationData.jobs?.handyman_id || APPDELEGATE?.uerdetail?.user_id == notificationData.jobs?.client_id{
                if notificationData.jobs?.booking_status == "4"{
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "CompletedJobDetailVC") as! CompletedJobDetailVC
                    objJobDetailsVC.jobList = notificationData.jobs
                self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
                }else{
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                    objJobDetailsVC.isEdit = false
                    objJobDetailsVC.jobList = notificationData.jobs
                    if notificationData.jobs?.booking_status == "2"{
                        objJobDetailsVC.StatusType = "10"
                    }else{
                        objJobDetailsVC.StatusType = "0"
                    }
                    self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
                }
            }else{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objJobDetailsVC = storyBoard.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
                objJobDetailsVC.isEdit = false
                objJobDetailsVC.jobList = notificationData.jobs
                if notificationData.jobs?.booking_status == "2"{
                    objJobDetailsVC.StatusType = "11"
                }else if notificationData.jobs?.booking_status == "4"{
                    objJobDetailsVC.StatusType = "12"
                }else{
                    objJobDetailsVC.StatusType = "0"
                }
                self.navigationController?.pushViewController(objJobDetailsVC, animated: true)
            }
        }else if navigateToType == "30"{
            if APPDELEGATE!.selectedUserType == .Crafter{
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let objProfileVC = storyBoard.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
                objProfileVC.strTag = "Crafter"
                objProfileVC.ProfileViewTag = 1
                objProfileVC.isFromSideMenu = true
                self.navigationController?.pushViewController(objProfileVC, animated: true)
            }
        }else
        {
            
        }
        
        if navigateToType == "12" || navigateToType == "13"{
            var userID = String()
            if APPDELEGATE?.selectedUserType == .Crafter{
                userID = notificationData.jobs?.client_id ?? ""
            }else{
                userID = notificationData.jobs?.handyman_id ?? ""
            }
            if userID != ""{
               isnotification = false
                    self.updateMessageCounttojob(unreadMessageCountcount: 0, userId: "\(APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? ""))", jobID: "\(notificationData.jobs?._id ?? "")")
                    
                    UpdateIsMessageReadOrNot(UserId: "\(userID)", jobID: "\(notificationData.jobs?._id ?? "")", isRead: "1")
            }
        }
    }
    
    func updateMessageCounttojob(unreadMessageCountcount:Int,userId:String,jobID:String){
        let param = ["unreadMessageCount":unreadMessageCountcount]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: userId, JobId: jobID, detail: param, completion: { (status) in
            
        })
    }

    func UpdateIsMessageReadOrNot(UserId:String,jobID:String,isRead:String){
        let param = ["isRead":isRead]
        FirebaseJobAPICall.FirebaseupdateMessageCountTOJob(UserID: UserId, JobId: jobID, detail: param, completion: { (status) in
            
        })
    }

    func getjobListingAll(myId:String,jobId:String,fromQue:Bool,jobdetaildata:JobHistoryData){
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
                        if item.jobdetailID == jobdetaildata._id && item.job_id == "\(self.notificationjobID)\(self.notificationCrafterID)"{
                            isAvail = true
                            jobDetail = item
                        }
                    }
                    self.redirecttoChat(conversationId: jobDetail?.conversationId ?? "", jobId: "\(jobDetail?.job_id  ?? "")", chat_option_status: "\(jobDetail?.chat_option_status  ?? "")",jobdetail:jobDetail!,fromQue:fromQue,jobdetaildata: jobdetaildata)
                }
            }else{
            }
            if isLoad{
                APPDELEGATE?.hideProgrssVoew()
                isLoad = false
            }
        }
    }
    
    func redirecttoChat(conversationId:String,jobId:String,chat_option_status:String,jobdetail:jobsAdded,fromQue:Bool,jobdetaildata:JobHistoryData){
        if isnotification{
            isnotification = false
            if (APPDELEGATE?.isChatViewcontroller)!{
                return
            }
            
            let storyboard = UIStoryboard(name: "Chat", bundle: nil)
            let messages = storyboard.instantiateViewController(withIdentifier: "ChatMessageVC") as? ChatMessageVC
            APPDELEGATE?.isChatViewcontroller = true
            messages?.conversationId = conversationId
            messages?.jobId = jobId
            messages?.chat_option_status = chat_option_status
            messages?.service_image = jobdetaildata.service_image ?? ""
            messages?.profile_image = jobdetaildata.profile_image ?? ""
            messages?.fullname = jobdetaildata.full_name ?? ""
            messages?.CrafterID = jobdetail.CrafterId ?? ""
            messages?.jobdetailID = jobdetail.jobdetailID ?? ""
            if fromQue{
                messages?.isOpenFromQue = true
            }
            self.navigationController?.pushViewController(messages!, animated: true)
        }
    }
}

extension NotificationListVC
{
    //MARK:- Call Profile API
    func getNotificationListAPI(isLoaderHide:Bool)
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
        WebService.Request.patch(url: getNotificationList, type: .post, parameter: params, callSilently: isLoaderHide, header: nil) { (response, error) in
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
                            self.NotiList = try? JSONDecoder().decode([NotificationListData].self, from: jsonData)
                            self.arrNew = NSMutableArray()
                            self.arrEarly = NSMutableArray()
                            for dataList in self.NotiList!
                            {
                                self.arrEarly.add(dataList)
                            }
                            self.tblNotificList.reloadData()
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
            self.refreshControl.endRefreshing()
        }
    }
    
    //MARK:- UnBlock User API
    func readNotification(notifID:String)
    {
        let params = ["notification_id": "\(notifID)", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","is_open":"1"]
        WebService.Request.patch(url: changeNotificationStatus, type: .post, parameter: params, callSilently: true, header: nil) { (response, error) in
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
