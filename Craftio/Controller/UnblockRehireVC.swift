
import UIKit

class UnblockRehireVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    
    var BlockList: [UserBlockList]?
    var RehireList: [CrafterHireListData]?
    var isfrom = String()
    
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
        self.tblList.isHidden = true
        if isfrom == "client"
        {
            self.lblTitle.text = "Re-Hire"
            self.GetCrafterRehireListAPI()
        }
        else
        {
            self.lblTitle.text = "Unblock"
            self.getBlockListAPI()
        }
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
    @IBAction func btnBackAction(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMenuAction(_ sender: UIButton)
    {
        APPDELEGATE?.presentSideMenu(viewController: self)
    }
    
    @IBAction func btnUnblockRehireAction(_ sender: UIButton)
    {
        if isfrom == "client"
        {
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.strTag = "Crafter"
            objProfileVC.isfromClient = true
            objProfileVC.CrafterId = self.RehireList?[sender.tag].handyman_id ?? ""
            self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
        else
        {
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Do you want to unblock the user?", completion: { (status) in
                if status{
                    let id = self.BlockList?[sender.tag].user_id ?? ""
                    self.UnblockUserAPI(id, index: sender.tag)
                }else{
                }
            })
        }
    }
}

extension UnblockRehireVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if isfrom == "client"
        {
            return self.RehireList?.count ?? 0 //return 7 //
        }
        else
        {
            return self.BlockList?.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tblList.dequeueReusableCell(withIdentifier: "CellUnblockRehire") as! CellUnblockRehire
        if isfrom == "client"
        {
            cell.btnTitle.setImage(UIImage(named: "re-hire"), for: .normal)
            cell.btnTitle.tag = indexPath.row
            
            let imgURL = URL(string: self.RehireList?[indexPath.row].profile_image ?? "")
            cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            
            if (self.RehireList?[indexPath.row].first_name == "") || (self.RehireList?[indexPath.row].last_name == "")
            {
                let nm = self.RehireList?[indexPath.row].user_name ?? ""
                let tempName = nm.split(separator: " ")
                let UName = setUserName(name: self.RehireList?[indexPath.row].user_name ?? "")
                if tempName.count >= 2{
                    cell.lblName.text = "\(UName)."
                }else{
                    cell.lblName.text = "\(UName)"
                }
            }
            else
            {
                cell.lblName.text = "\(self.RehireList?[indexPath.row].first_name ?? "") \(self.RehireList?[indexPath.row].last_name?.first ?? " ")."
            }
            cell.lblTitle.text = self.RehireList?[indexPath.row].user_services ?? ""
            
        }
        else
        {
            cell.btnTitle.setImage(UIImage(named: "unblock"), for: .normal)
            cell.btnTitle.tag = indexPath.row
            
            let imgURL = URL(string: self.BlockList?[indexPath.row].profile_image ?? "")
            cell.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
            
            let nm = self.BlockList?[indexPath.row].user_name ?? ""
            let tempName = nm.split(separator: " ")
            let UName = setUserName(name: self.BlockList?[indexPath.row].user_name ?? "")
            if tempName.count >= 2{
                cell.lblName.text = "\(UName)."
            }else{
                cell.lblName.text = "\(UName)"
            }
            cell.lblTitle.text = self.BlockList?[indexPath.row].user_services ?? ""
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
    }
}

extension UnblockRehireVC
{
    //MARK:- Call Profile API
    func getBlockListAPI()
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

        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")"]
        WebService.Request.patch(url: getBlockUserList, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
                            self.BlockList = try? JSONDecoder().decode([UserBlockList].self, from: jsonData)
                            self.tblList.reloadData()
                            if (self.BlockList?.count)! > 0
                            {
                                self.tblList.isHidden = false
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
    
    //MARK:- UnBlock User API
    func UnblockUserAPI(_ user_id:String,index:NSInteger)
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
                    let dataresponse = response!["data"] as? [[String:Any]]
                    self.BlockList?.remove(at: index)
                    self.tblList.reloadData()
                } else
                {
                }
            }
        }
    }
    
    //getHireCrafterList API
    func GetCrafterRehireListAPI()
    {
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")"]
        WebService.Request.patch(url: getHireCrafterList, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
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
                            self.RehireList = try? JSONDecoder().decode([CrafterHireListData].self, from: jsonData)
                            self.tblList.reloadData()
                            if (self.RehireList?.count)! > 0
                            {
                                self.tblList.isHidden = false
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
}
