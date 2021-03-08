
import UIKit

class NeedHelpVC: UIViewController, UIGestureRecognizerDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var lbltitlename: UILabel!
    @IBOutlet weak var txtViewQue: UITextView!
    var tap = UIGestureRecognizer()
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        onLoadOperations()
    }
    
    func onLoadOperations()
    {
        self.txtViewQue.text = APPDELEGATE?.NeedHelpVC_PlaceHolder
        self.txtViewQue.textColor = UIColor.lightGray
        self.txtViewQue.autocapitalizationType = .sentences
        //self.txtViewQue.autocorrectionType = .no
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
   
        self.tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
   
    }
   
    @objc func handleTap(sender: UITapGestureRecognizer? = nil)
    {
        self.view.endEditing(true)
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnCancelTapped(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSendTapped(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if self.txtViewQue.text == APPDELEGATE?.NeedHelpVC_PlaceHolder || self.txtViewQue.text == ""
        {
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please type message.")
        }
        else if (self.txtViewQue.text.replacingOccurrences(of: "\n", with: "") == "")
        {
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please type message.")
        }
        else
        {
            self.Ask_Que_API()
        }
    }
}

extension NeedHelpVC: UITextViewDelegate
{
    func textViewDidBeginEditing(_ textView: UITextView)
    {
        if self.txtViewQue.text == APPDELEGATE?.NeedHelpVC_PlaceHolder
        {
            self.txtViewQue.text = ""
            self.txtViewQue.textColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)
            self.txtViewQue.tintColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        if self.txtViewQue.text == ""
        {
            self.txtViewQue.text = APPDELEGATE?.NeedHelpVC_PlaceHolder
            self.txtViewQue.textColor = UIColor.lightGray
        }
    }
    
    func Ask_Que_API()
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

        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "user_type":"\(user_type)","description":"\(self.txtViewQue.text ?? "")"]
        WebService.Request.patch(url: getNeedHelp, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "jobdetail", message: response!["msg"] as! String)
                } else
                {
                    
                }
            }
        }
    }
}
