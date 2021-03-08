
import UIKit
import IQKeyboardManagerSwift

class ForgotPasswordVC: UIViewController,UITextFieldDelegate {

    //MARK :- Outlets
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    @IBOutlet weak var btnbackBlur: UIButton!
    var message = String()

    var txtTag = Int()
    //MARK :- variable Declarations
    
    //MARK :- View Controller LifeCycle
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    override func viewDidLoad(){
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        IQKeyboardManager.shared.enable = true
        viewAlert.isHidden = true
        btnbackBlur.isHidden = true
        txtEmail.delegate = self
        self.onLoadOperations()
    
        self.txtEmail.attributedPlaceholder = NSAttributedString(string: "Enter email",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)])
        
        self.txtEmail.textColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)
        
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(becomeFirst),
            name: .txtBecomeFirst,
            object: nil
        )
    }
    
    @objc func becomeFirst(notification: NSNotification){
        if self.txtTag == 1{
            self.txtEmail.becomeFirstResponder()
        }
    }
    
    func onLoadOperations() {
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    //RetrievePassword API Call
    func RetrievePasswordAPICall(email: String) {
        var params = [String: Any]()
        params = ["email_id": email]
        WebService.Request.patch(url: forgotPasswordAPI, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    self.lblMessage.text = response!["msg"] as? String ?? ""
                    self.viewAlert.isHidden = false
                    self.btnbackBlur.isHidden = false                    
                }else{
                    self.txtEmail.becomeFirstResponder()
                    self.txtTag = 1
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response!["msg"] as? String ?? "")
                }
            }
        }
    }
    
//MARK :- Button Actions
    @IBAction func btnRetrievePasswordAction(_ sender: UIButton) {
        if txtEmail.text == "" {
            //txtEmail.becomeFirstResponder()
            self.view.endEditing(true)
            self.txtTag = 1
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Email Can not be blank.")
        }
        else if Validate.isValidEmail(testStr: txtEmail.text!) {
            self.view.endEditing(true)
            RetrievePasswordAPICall(email: txtEmail.text!)
        } else {
            //txtEmail.becomeFirstResponder()
            self.view.endEditing(true)
            self.txtTag = 1
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please insert valid Email.")
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOk(_ sender: Any) {
        let forgotPass = findtopViewController()?.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as? HomeVC
        findtopViewController()?.navigationController?.pushViewController(forgotPass!, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtEmail.resignFirstResponder()
        return false
    }
}
