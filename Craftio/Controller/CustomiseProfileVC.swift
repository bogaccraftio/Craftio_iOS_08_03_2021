
import UIKit
import IQKeyboardManagerSwift
import Photos
import Lightbox
class CustomiseProfileVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    
    @IBOutlet weak var txtFname: UITextField!
    @IBOutlet weak var txtLname: UITextField!
    @IBOutlet weak var txtPhone: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var tbnMale: UIButton!
    @IBOutlet weak var btnFemale: UIButton!
    
    var imagePicker = UIImagePickerController()
    var Gender = String()    
    var isEdit = Bool()
    var isImageSelected = false
    
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
        self.setUpProfile()
        getProfileDetails()
        self.txtFname.autocapitalizationType = .words
        
        IQKeyboardManager.shared.enable = true
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
        self.view.endEditing(true)
        if self.isEdit == true
        {
            APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Please press the save button. Otherwise your information will be lost", completion: { (status) in
                if status{
                    
                    if self.validateRequiredField()
                    {
                        if self.isImageSelected{
                            self.UpdateProfile()
                        }else{
                            self.UpdateProfileWothoutIMage()
                        }
                    }
                }else{
                    self.navigationController?.popViewController(animated: true)
                }
            })
        }
        else
        {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func btnMaleAction(_ sender: UIButton)
    {
        self.Gender = "1"
        tbnMale.setImage(UIImage (named: "GenderSelectecd"), for: .normal)
        btnFemale.setImage(UIImage (named: "genderDeselected"), for: .normal)
        self.isEdit = true
    }
    
    @IBAction func btnFemaleAction(_ sender: UIButton)
    {
        self.Gender = "2"
        tbnMale.setImage(UIImage (named: "genderDeselected"), for: .normal)
        btnFemale.setImage(UIImage (named: "GenderSelectecd"), for: .normal)
        self.isEdit = true
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton)
    {
        //showCamera()
        self.isEdit = true
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.modalPresentationStyle = .fullScreen
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func btnUpdateAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        if validateRequiredField()
        {
            if isImageSelected{
                self.UpdateProfile()
            }else{
                UpdateProfileWothoutIMage()
            }
        }
    }
}

extension CustomiseProfileVC: UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField)
    {
        self.isEdit = true
        textField.autocorrectionType = .no
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == txtEmail{
            if txtEmail.text == APPDELEGATE?.uerdetail?.email_id{
                
            }else{
                if txtEmail.text == ""{
                    
                }else if !Validate.isValidEmail(testStr: txtEmail.text!) {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please insert valid Email.")
                }else{
                    CheckEmailRegistered()
                }
            }
        }
    }

    // Textfield Delegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == self.txtFname || textField == self.txtLname
        {
            do {
                let regex = try NSRegularExpression(pattern: ".*[^A-Za-z].*", options: [])
                if regex.firstMatch(in: string, options: [], range: NSMakeRange(0, string.count)) != nil {
                    return false
                }
            }
            catch {
                print("ERROR")
            }
            return true
        }
        else if textField == self.txtPhone
        {
            let maxLength = 13
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            return newString.length <= maxLength
        }else if textField == self.txtAge
        {
            let maxLength = 3
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            
            return newString.length <= maxLength
        }else
        {
            return true
        }
    }
    
    //Image Picker Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            isImageSelected = true
            self.imgProfile.image = selectedImage
        }
        dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        dismiss(animated: true)
    }
}

extension CustomiseProfileVC
{
    func setUpProfile(){
        
        self.txtFname.text =  "\(APPDELEGATE?.uerdetail?.first_name ?? "")"//"\(APPDELEGATE?.uerdetail?.first_name ?? "")"
        self.txtLname.text = "\(APPDELEGATE?.uerdetail?.last_name ?? "")"
        self.txtPhone.text = "\(APPDELEGATE?.uerdetail?.mobile_no ?? "")"
        self.txtEmail.text = "\(APPDELEGATE?.uerdetail?.email_id ?? "")"
        self.txtPassword.text = "\(APPDELEGATE?.uerdetail?.password ?? "")"
        self.txtAge.text = "\(APPDELEGATE?.uerdetail?.age ?? "")"
        
        if APPDELEGATE?.uerdetail?.gender == "1"
        {
            self.Gender = "1"
            self.tbnMale.setImage(UIImage (named: "GenderSelectecd"), for: .normal)
        }
        else if APPDELEGATE?.uerdetail?.gender == "2"
        {
            self.Gender = "2"
            self.btnFemale.setImage(UIImage (named: "GenderSelectecd"), for: .normal)
        }
        else
        {
            tbnMale.setImage(UIImage (named: "genderDeselected"), for: .normal)
            btnFemale.setImage(UIImage (named: "genderDeselected"), for: .normal)
        }
        
        let imgURL = URL(string: APPDELEGATE?.uerdetail?.profile_image ?? "")
        self.imgProfile.kf.setImage(with: imgURL, placeholder: nil)
    }
    
    //CheckEmailRegistered
    func CheckEmailRegistered()
    {
        var param = ["email_id":"\(txtEmail.text ?? "")"]
        if APPDELEGATE?.selectedUserType == .Crafter{
            param["user_type"] = Crafter
        }else{
            param["user_type"] = Client
        }
        WebService.Request.patch(url: emailCheck, type: .post, parameter: param, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                } else
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response!["msg"] as? String ?? "")
                }
            }
        }
    }

    
    //Get Profile
    func getProfileDetails()
    {
        var params = [String:String]()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            params = ["user_id": "2", "loginuser_id": "2", "session_token": "P@8ADeIFME"]
        }
        else
        {
            params = ["user_id": "1", "loginuser_id": "1", "session_token": "P@8ADeIFME"]
        }
        params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","review_required":"0","user_type":APPDELEGATE?.uerdetail?.user_type ?? "","is_own_profile": "1"]
        WebService.Request.patch(url: getUserProfile, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [String:Any]
                    if dataresponse != nil
                    {
                        do
                        {
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                            APPDELEGATE?.uerdetail = try? JSONDecoder().decode(UserData.self, from: jsonData)
                            UserDefaults.standard.set(jsonData, forKey: "login_data")
                            UserDefaults.standard.synchronize()
                            self.setUpProfile()
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
    
    func UpdateProfileWothoutIMage()
    {
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "first_name":"\(self.txtFname.text ?? "")","last_name":"\(self.txtLname.text ?? "")","mobile_no":"\(self.txtPhone.text ?? "")","email_id":"\(self.txtEmail.text ?? "")" ,"password":"\(self.txtPassword.text ?? "")","age":"\(self.txtAge.text ?? "")","gender":"\(self.Gender)","user_name": "\(self.txtFname.text ?? "") \(self.txtLname.text ?? "")"]
        WebService.Request.patch(url: updateUserProfile, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response?["status"] as? Bool == true{
                    self.isEdit = false
                    self.getProfileDetails()
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response?["msg"] as? String ?? "")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response?["msg"] as? String ?? "")
                }
            }
        }
    }

    
    //Update Profile
    func UpdateProfile()
    {
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "first_name":"\(self.txtFname.text ?? "")","last_name":"\(self.txtLname.text ?? "")","mobile_no":"\(self.txtPhone.text ?? "")","email_id":"\(self.txtEmail.text ?? "")" ,"password":"\(self.txtPassword.text ?? "")","age":"\(self.txtAge.text ?? "")","gender":"\(self.Gender)","user_name": "\(self.txtFname.text ?? "") \(self.txtLname.text ?? "")"]
        
        WebService.Request.uploadSingleFiles(url: updateUserProfile, images : self.imgProfile.image ?? UIImage(named: "Oval 3")! , parameters:params, isBackgroundPerform:false, headerForAPICall : ["Content-type": "multipart/form-data"]){ (response, error) in
            if error == nil {
                print(response!)
                if response?["status"] as? Bool == true{
                    self.isEdit = false
                    self.getProfileDetails()
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response?["msg"] as? String ?? "")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response?["msg"] as? String ?? "")
                }
            }
        }
    }
    
    //Validation
    func validateRequiredField() -> Bool
    {
        if txtFname.text == "" {
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"First name cannot be blank")
            return false
        }
        else
        {
            return true
        }
    }
}

