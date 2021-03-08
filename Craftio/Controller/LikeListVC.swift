
import UIKit

class LikeListVC: UIViewController {
    
    @IBOutlet weak var tbluserList: UITableView!
    
    var arrUserList = [[String:Any]]()
    var reviewID = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        getReviewLikesList()
    }
    
    @IBAction func btnback(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func getReviewLikesList()
    {
        var params = [String:String]()
        params = ["review_id": reviewID, "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "user_type": "\(APPDELEGATE?.uerdetail?.user_type ?? "")"]
        WebService.Request.patch(url: getReviewList, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    if let dataresponse = response!["data"] as? [[String:Any]]
                    {
                        self.arrUserList = dataresponse
                        self.tbluserList.reloadData()
                    }
                } else
                {
                }
            }
        }
    }
}

extension LikeListVC : UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.arrUserList.count //?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tbluserList.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let data = self.arrUserList[indexPath.row]
        let lblname = cell.contentView.viewWithTag(2) as? UILabel
        
        var Uname = ""
        let nm = data["user_name"] as? String ?? ""
        let tempName = nm.split(separator: " ")
        let UName = setUserName(name: data["user_name"] as? String ?? "")
        if tempName.count >= 2{
            Uname = "\(UName)."
        }else{
            Uname = "\(UName)"
        }
        lblname?.text = Uname
        
        let imgPro = cell.contentView.viewWithTag(1) as? UIImageView
        let imgURL = URL(string: data["profile_image"] as? String ?? "")
        imgPro?.kf.setImage(with: imgURL, placeholder: nil)

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 87
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let data = self.arrUserList[indexPath.row]
        if data["user_type"] as? String == "1"
        {
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 1
            objProfileVC.strTag = "Client"
            objProfileVC.CrafterId = data["user_id"] as? String ?? ""
        self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
        else
        {
            let objProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
            objProfileVC.user_type = 2
            objProfileVC.strTag = "Crafter"
            objProfileVC.CrafterId = data["user_id"] as? String ?? ""
         self.navigationController?.pushViewController(objProfileVC, animated: true)
        }
    }
}
