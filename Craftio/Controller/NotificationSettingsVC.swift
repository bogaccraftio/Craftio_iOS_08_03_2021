
import UIKit

class NotificationSettingsVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var lbltitlename: UILabel!
    @IBOutlet weak var tblNotify: UITableView!
    
    var arrSection = ["Email Notifications","Push Notifications"]
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        onLoadOperations()
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
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackTapped(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func SwitchChangeTapped(_ sender: UISwitch)
    {
        var status = String()
        if sender.isOn == true
        {
            status = "1"
        }
        else
        {
            status = "0"
        }
        if sender.tag == 1{
            APPDELEGATE?.uerdetail?.email_status = status
        }else if sender.tag == 2{
            APPDELEGATE?.uerdetail?.notification_status = status
        }else if sender.tag == 3{
            APPDELEGATE?.uerdetail?.message_status = status
        }
        self.SetNotifyAPI(status, status_type: "\(sender.tag)")
    }
    
}

extension NotificationSettingsVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if APPDELEGATE!.selectedUserType == .Client
        {
            return self.arrSection[1]
        }
        return self.arrSection[section]
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        if APPDELEGATE!.selectedUserType == .Client
        {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let myLabel = UILabel()
        myLabel.frame = CGRect(x: 14, y: 8, width: 320, height: 24)
        myLabel.font = UIFont(name: "Cabin", size: 15.0)
        myLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        myLabel.textColor = UIColor.lightGray//(red: 247/255, green: 212/255, blue: 186/255, alpha: 1.0)
        myLabel.text = self.tableView(tableView, titleForHeaderInSection: section)
        
        let headerView = UIView()
        headerView.addSubview(myLabel)
        
        return headerView
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if section == 0
        {
            return 1
        }
        else
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                return 2
            }
            else
            {
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellNotifySettings", for: indexPath) as! CellNotifySettings
        if indexPath.section == 0
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                cell.lbltitle.text = "New jobs"
                cell.btnSwitch.tag = 1
                
                if APPDELEGATE?.uerdetail?.email_status == "0" || APPDELEGATE?.uerdetail?.email_status == ""{
                    cell.btnSwitch.setOn(false, animated: true)
                }else{
                    cell.btnSwitch.setOn(true, animated: true)
                }
            }
            else
            {
                cell.lbltitle.text = "New Message"
                cell.btnSwitch.tag = 3
            }            
        }
        else
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                if indexPath.row == 0
                {
                    cell.lbltitle.text = "New jobs"
                    if APPDELEGATE?.uerdetail?.notification_status == "0" || APPDELEGATE?.uerdetail?.notification_status == ""{
                        cell.btnSwitch.setOn(false, animated: true)
                    }else{
                        cell.btnSwitch.setOn(true, animated: true)
                    }
                    cell.btnSwitch.tag = 2
                }
                else
                {
                    cell.lbltitle.text = "New Message"
                    if APPDELEGATE?.uerdetail?.message_status == "0" || APPDELEGATE?.uerdetail?.message_status == ""{
                        cell.btnSwitch.setOn(false, animated: true)
                    }else{
                        cell.btnSwitch.setOn(true, animated: true)
                    }
                    cell.btnSwitch.tag = 3
                }
            }
            else
            {
                cell.lbltitle.text = "New Message"
                if APPDELEGATE?.uerdetail?.message_status == "0" || APPDELEGATE?.uerdetail?.message_status == ""{
                    cell.btnSwitch.setOn(false, animated: true)
                }else{
                    cell.btnSwitch.setOn(true, animated: true)
                }
                cell.btnSwitch.tag = 3
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}

extension NotificationSettingsVC
{
    /*     
     status_type : 1- Email, 2- Notification, 3- Message
     */
    
    func SetNotifyAPI(_ status:String,status_type:String)
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

        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "user_type":"\(user_type)", "status":status, "status_type":status_type]
        WebService.Request.patch(url: changeStatus, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        
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
