
import UIKit

class SettingsVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var lbltitlename: UILabel!
    
    @IBOutlet weak var tblSettings: UITableView!
    var arrSetings:[[String:Any]] = [["sc_title": "NOTIFICATIONS"],["sc_title": "BLOCK LIST"],["sc_title": "SHARE CRAFTIO"]]
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        onLoadOperations()
        getContentAPI()
        if APPDELEGATE!.selectedUserType == .Crafter {
            self.arrSetings.insert(["sc_title": "BANKING"], at: 0)
        }
    }
    
    func onLoadOperations() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SettingsVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrSetings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellSelectJobTitle", for: indexPath) as! CellSelectJobTitle
        let data = self.arrSetings[indexPath.row]
        cell.lblTitle.text = data["sc_title"] as? String ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                let objNotifySettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "BankingFormVC") as! BankingFormVC
                self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
            }
            else
            {
                let objNotifySettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsVC") as! NotificationSettingsVC
                self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
            }
        }
        else if indexPath.row == 1
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                let objNotifySettingsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationSettingsVC") as! NotificationSettingsVC
                self.navigationController?.pushViewController(objNotifySettingsVC, animated: true)
            }
            else
            {
                let objUnblockRehireVC = self.storyboard?.instantiateViewController(withIdentifier: "UnblockRehireVC") as! UnblockRehireVC
                self.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
            }
        }
        else if indexPath.row == 2
        {
            if APPDELEGATE!.selectedUserType == .Crafter
            {
                let objUnblockRehireVC = self.storyboard?.instantiateViewController(withIdentifier: "UnblockRehireVC") as! UnblockRehireVC
                self.navigationController?.pushViewController(objUnblockRehireVC, animated: true)
            }
            else
            {
                getsharableURL()
            }
        }
        else if indexPath.row == 3
        {
            if APPDELEGATE!.selectedUserType == .Crafter{
                getsharableURL()
            }else{
                let objCommonContentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommonContentVC") as! CommonContentVC
                objCommonContentVC.pageDetail = self.arrSetings[indexPath.row]
                objCommonContentVC.page_id = 2
                self.navigationController?.pushViewController(objCommonContentVC, animated: true)
            }
        }
        else
        {
            let objCommonContentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommonContentVC") as! CommonContentVC
            let aObj = self.arrSetings[indexPath.row]
            objCommonContentVC.pageDetail = self.arrSetings[indexPath.row]
            objCommonContentVC.page_id = aObj["sc_id"] as? Int ?? 0
            self.navigationController?.pushViewController(objCommonContentVC, animated: true)
        }
    }
    //Get Service List API Call
    
    func getsharableURL()
    {
        WebService.Request.patch(url: getSettingData, type: .get, parameter: nil, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [String: Any] {
                    let text = "\(data["share_text"] as? String ?? "") \(data["share_url"] as? String ?? "")"
                    let activityItems = [text] as [Any]
                    let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    activityController.popoverPresentationController?.sourceView = self.view
                    activityController.popoverPresentationController?.sourceRect = self.view.frame
                    self.present(activityController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func getContentAPI()
    {
        let params = ["loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")"]
        WebService.Request.patch(url: getStaticPage, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                    if dataresponse != nil
                    {
                        for item in dataresponse ?? []{
                            self.arrSetings.append(item)
                        }
                        self.tblSettings.reloadData()
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
