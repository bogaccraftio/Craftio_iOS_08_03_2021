
import UIKit

class AlertPopup: UIView
{
    
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnClick: UIButton!
    @IBOutlet weak var lblTwobuttonMessaje: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var alertWithTwoButton: UIView!
    
    var jobdata = String()
    var openFrom = String()
    var selectedButton = false
    
    enum popupType{
        case oneButton
        case TwoButton
    }
    var displayPopup: popupType = .oneButton
    var completion: (()->())?
    
    class func instanceFromNib() -> UIView
    {
        return UINib(nibName: "AlertPopup", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func initAlertPopupView(viewopenFrom:String,UserData:String,price: String)
    {
        selectedButton = false
        self.backgroundColor = UIColor.clear
        if displayPopup == .TwoButton{
            if price == ""{
                lblPrice.text = ""
            }else{
                lblPrice.text = "£\(price)"
            }
            self.lblTwobuttonMessaje.text = UserData
        }else{
            self.lblMessage.text = UserData
        }
        openFrom = viewopenFrom
        showView(type: "alert")
    }
    
    
     //Hide and Show View
     func showView(type: String)
     {
        if displayPopup == .TwoButton{
            if type == "alert"
            {
                alertWithTwoButton.isHidden = false
            }
            else
            {
                alertWithTwoButton.isHidden = true
            }
            viewAlert.isHidden = true
        }else{
            if type == "alert"
            {
                viewAlert.isHidden = false
            }
            else
            {
                viewAlert.isHidden = true
            }
            alertWithTwoButton.isHidden = true
        }
     }
    
    
    //MARK:- Button Click Events
    @IBAction func btnOkAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        if openFrom == "job"{
            let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
        }else if openFrom == "jobdetail"{
            findtopViewController()?.navigationController?.popViewController(animated: true)
        }else if openFrom == "review"{
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let forgotPass = storyboard.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
            findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
        }else if openFrom == "webservice"{
            if ((findtopViewController() as? OnBoardingVC) != nil){
                return
            }else{
                if ((findtopViewController() as? UIAlertController) != nil){
                    let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                    let nextViewController = storyBoard.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
                    
                    APPDELEGATE?.navigationController = UINavigationController(rootViewController: nextViewController)
                    APPDELEGATE?.navigationController.navigationBar.isHidden = true
                    APPDELEGATE?.window!.rootViewController = APPDELEGATE?.navigationController
                }else{
                    if ((findtopViewController() as? OnBoardingVC) != nil){
                        return
                    }
                    let nextViewController = findtopViewController()!.storyboard?.instantiateViewController(withIdentifier: "OnBoardingVC") as! OnBoardingVC
                    findtopViewController()!.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        }else if openFrom == "releaseAll" || openFrom == "depositAll"{
            self.removeFromSuperview()
            completion!()
        }else if openFrom == "fillBankDetail"{
            self.removeFromSuperview()
            completion!()
        }else if openFrom == "insertQuote"{
            self.removeFromSuperview()
            completion!()
        } else{
            self.removeFromSuperview()
            NotificationCenter.default.post(name: .txtBecomeFirst, object: nil, userInfo: nil)
        }
    }
    
    @IBAction func btnNoAction(_ sender: UIButton) {
        self.removeFromSuperview()
        selectedButton = false
        completion!()
    }
    
    @IBAction func btnYesAction(_ sender: UIButton) {
        self.removeFromSuperview()
        selectedButton = true
        completion!()
    }
}
