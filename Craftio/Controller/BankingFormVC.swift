
import UIKit
import Atributika
import IQKeyboardManagerSwift
let allowedCharactersdata = CharacterSet(charactersIn:"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvxyz").inverted

class BankingFormVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewDown: UIView!
    
    @IBOutlet weak var btnSuggetion: UIButton!
    @IBOutlet weak var btnPrivate: UIButton!
    @IBOutlet weak var btnBusiness: UIButton!
    @IBOutlet weak var btnIban: UIButton!
    @IBOutlet weak var btnUk: UIButton!
    @IBOutlet weak var btnSelectCountry: UIButton!
    @IBOutlet weak var btnAccept: UIButton!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCode1: UITextField!
    @IBOutlet weak var txtCode2: UITextField!
    @IBOutlet weak var txtCode3: UITextField!
    @IBOutlet weak var txtAccountNumber: UITextField!
    @IBOutlet weak var txtMobileNumber: UITextField!
    @IBOutlet weak var txtAddress: UITextField!
    @IBOutlet weak var txtPassCode: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var ibanNumber: UITextField!
    @IBOutlet weak var viewIbanNumber: UIView!
    @IBOutlet weak var lblIbanAndUK: UILabel!

    @IBOutlet weak var lblCountry: UILabel!
    @IBOutlet weak var viewSelectCountry: UIView!
    @IBOutlet weak var label: FRHyperLabel!
    
    @IBOutlet weak var codeLine1: UIImageView!
    @IBOutlet weak var codeLine2: UIImageView!
    @IBOutlet weak var codeLine3: UIImageView!
    @IBOutlet weak var codeLineIBAN: UIImageView!
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var txtIBANCode1: UITextField!
    @IBOutlet weak var txtIBANCode2: UITextField!
    @IBOutlet weak var txtIBANCode3: UITextField!
    @IBOutlet weak var txtIBANCode4: UITextField!
    @IBOutlet weak var txtIBANCode5: UITextField!
    @IBOutlet weak var imgAccountNumberLine: UIImageView!
    @IBOutlet weak var lblAccountNo: UILabel!
    @IBOutlet weak var topLblAccountNo: NSLayoutConstraint!//15
    @IBOutlet weak var toptxtAccountNo: NSLayoutConstraint!//10
    @IBOutlet weak var heightAccountNo: NSLayoutConstraint!//32
    @IBOutlet weak var topMobileNo: NSLayoutConstraint!//13

    @IBOutlet weak var lineFullName: UIImageView!
    @IBOutlet weak var lineIBAN1: UIImageView!
    @IBOutlet weak var lineIBAN2: UIImageView!
    @IBOutlet weak var lineIBAN3: UIImageView!
    @IBOutlet weak var lineIBAN4: UIImageView!
    @IBOutlet weak var lineIBAN5: UIImageView!
    @IBOutlet weak var lineMobileNumber: UIImageView!
    @IBOutlet weak var lineAddress: UIImageView!
    @IBOutlet weak var linePostCode: UIImageView!
    @IBOutlet weak var lineCity: UIImageView!
    @IBOutlet weak var lineCountry: UIImageView!

    
    var account_type = 2
    var bank_account_type = Int()
    var account_id = String()
    var isEdit = Bool()
    var activeField: UITextField?
    var ibanCount = 27
    let lineActiveColor = UIColor (red: 226.0/255.0, green: 226.0/255.0, blue: 226.0/255.0, alpha: 1.0)
    let lineInActiveColor = UIColor .red
    var offsetY:CGFloat = 0

    
    enum bankDetailOpenFrom {
        case chat
        case home
        case none
    }

    var openFrom:bankDetailOpenFrom = .none
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        setupLineColors()
        onLoadOperations()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide
    }
    
    func setupLineColors() {
        lineFullName.tintColor = lineActiveColor
        lineIBAN1.tintColor = lineActiveColor
        lineIBAN2.tintColor = lineActiveColor
        lineIBAN3.tintColor = lineActiveColor
        lineIBAN4.tintColor = lineActiveColor
        lineIBAN5.tintColor = lineActiveColor
        lineMobileNumber.tintColor = lineActiveColor
        lineAddress.tintColor = lineActiveColor
        linePostCode.tintColor = lineActiveColor
        lineCity.tintColor = lineActiveColor
        lineCountry.tintColor = lineActiveColor
    }
    
    func onLoadOperations()
    {
        viewIbanNumber.isHidden = true
        self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
       
        label.numberOfLines = 0;
        
        //Step 1: Define a normal attributed string for non-link texts
        let string = "By clicking on the button you agree with the Terms & Condition"
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                          NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: UIFont.TextStyle.headline)]
        label.attributedText = NSAttributedString(string: string, attributes: attributes)
        
        //Step 2: Define a selection handler block
        let handler = {
            (hyperLabel: FRHyperLabel?, substring: String?) -> Void in
            let objCommonContentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommonContentVC") as! CommonContentVC
            objCommonContentVC.strNavTitle = "TERMS OF SERVICE"
            objCommonContentVC.page_id = 1
            self.navigationController?.pushViewController(objCommonContentVC, animated: true)
        }
        
        //Step 3: Add link substrings
        label.setLinksForSubstrings(["Terms & Condition"], withLinkHandler: handler)
        //
        
        self.txtCode1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtCode2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtCode3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        
        self.txtIBANCode1.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtIBANCode2.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtIBANCode3.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtIBANCode4.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        self.txtIBANCode5.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: UIControl.Event.editingChanged)
        
        self.btnAccept.center = self.view.center
        self.btnAccept.layer.shadowColor = UIColor.gray.cgColor
        self.btnAccept.layer.shadowOpacity = 0.8
        self.btnAccept.layer.shadowOffset = CGSize.zero
        self.btnAccept.layer.shadowRadius = 2
        self.btnAccept.layer.cornerRadius  = 10
        self.GetBankDetailAPICall()
        self.setupSortOrIBAN()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(aNotification:)), name: UIResponder.keyboardWillHideNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(aNotification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {

         super.viewWillDisappear(animated)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)

        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)

    }
    
    func setupSortOrIBAN() {
        if self.account_type == 1{
            lblAccountNo.text = ""
            imgAccountNumberLine.isHidden = true
            lblAccountNo.isHidden = true
            txtAccountNumber.isHidden = true
            topLblAccountNo.constant = 0
            toptxtAccountNo.constant = 0
            heightAccountNo.constant = 0
        }else{
            lblAccountNo.text = "Account number"
            imgAccountNumberLine.isHidden = false
            lblAccountNo.isHidden = false
            txtAccountNumber.isHidden = false
            topLblAccountNo.constant = 15
            toptxtAccountNo.constant = 10
            heightAccountNo.constant = 32
        }
    }

    //MARK:- Button Tapped Events
    @IBAction func btnLinkTapped(_ sender: UIButton)
    {
        let objCommonContentVC = self.storyboard?.instantiateViewController(withIdentifier: "CommonContentVC") as! CommonContentVC
        objCommonContentVC.strNavTitle = "TERMS OF SERVICE"
        objCommonContentVC.page_id = 1
        self.navigationController?.pushViewController(objCommonContentVC, animated: true)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSuggetion(_ sender: UIButton)
    {
        
    }
    
    @IBAction func btnPrivate(_ sender: UIButton)
    {
        self.btnPrivate.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
        self.btnBusiness.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
        self.bank_account_type = 1
    }
    
    @IBAction func btnBusiness(_ sender: UIButton)
    {
        self.btnPrivate.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
        self.btnBusiness.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
        self.bank_account_type = 2
    }
    
    @IBAction func btnIban(_ sender: UIButton)
    {
        self.btnIban.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
        self.btnUk.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
        self.account_type = 1
        self.viewIbanNumber.isHidden = false
//        self.codeLineIBAN.isHidden = false
        self.lblIbanAndUK.text = "IBAN"
        self.txtCode1.isHidden = true
        self.codeLine1.isHidden = true
        self.txtCode2.isHidden = true
        self.codeLine2.isHidden = true
        self.txtCode3.isHidden = true
        self.codeLine3.isHidden = true
        self.setupSortOrIBAN()
    }
    
    @IBAction func btnUk(_ sender: UIButton)
    {
        self.btnIban.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
        self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
        self.account_type = 2
        self.viewIbanNumber.isHidden = true
        self.lblIbanAndUK.text = "UK Sort Code"
        self.txtCode1.isHidden = false
        self.codeLine1.isHidden = false
        self.txtCode2.isHidden = false
        self.codeLine2.isHidden = false
        self.txtCode3.isHidden = false
        self.codeLine3.isHidden = false
        self.setupSortOrIBAN()
    }
    
    @IBAction func btnSelectCountry(_ sender: UIButton){
        let countryList = self.storyboard?.instantiateViewController(withIdentifier: "CountryListVC") as! CountryListVC
        countryList.modalPresentationStyle = .fullScreen
        self.present(countryList,animated: true)
    }
    
    @IBAction func btnAccept(_ sender: UIButton)
    {
        if self.valid(){
            self.SaveBankDetailAPICall()
        }else{
            appDelegate.addAlertPopupviewWithCompletion(viewcontroller: self, oprnfrom: "fillBankDetail", message: "fill your bank details", completion: { (status) in
                if status{
                    self.isAllFilled()
                }
            })
        }
    }
    
    func valid()->Bool{
        if self.txtName.text?.isEmpty == true || self.txtName.text == ""{
            return false
        }else if self.bank_account_type == 0{
            return false
        }else if self.account_type == 1 && (self.txtIBANCode1.text?.isEmpty == true || self.txtIBANCode1.text == "" || self.txtIBANCode2.text?.isEmpty == true || self.txtIBANCode2.text == "" || self.txtIBANCode3.text?.isEmpty == true || self.txtIBANCode3.text == "" || self.txtIBANCode4.text?.isEmpty == true || self.txtIBANCode4.text == "" || self.txtIBANCode5.text?.isEmpty == true || self.txtIBANCode5.text == "" || self.txtIBANCode1.text == "GB"){
            return false
        } else if self.account_type == 2 && (self.txtCode1.text?.isEmpty == true || self.txtCode1.text == "" || self.txtCode2.text?.isEmpty == true || self.txtCode2.text == "" || self.txtCode3.text?.isEmpty == true || self.txtCode3.text == "" || self.txtAccountNumber.text?.isEmpty == true || self.txtAccountNumber.text == ""){
            return false
        }else if self.txtMobileNumber.text?.isEmpty == true || self.txtMobileNumber.text == ""{
            return false
        }else if self.txtAddress.text?.isEmpty == true || self.txtAddress.text == ""{
            return false
        }else if self.txtPassCode.text?.isEmpty == true || self.txtPassCode.text == ""{
            return false
        }else if self.txtCity.text?.isEmpty == true || self.txtCity.text == ""{
            return false
        }else{
            return true
        }
    }
    
    func isAllFilled()  {
        var firstTextField = UITextField()
        var isFirst = true
        if self.txtName.text?.isEmpty == true || self.txtName.text == ""{
            if isFirst{
                isFirst = false
               firstTextField = txtName
            }
            lineFullName.tintColor = lineInActiveColor
        }else{
            lineFullName.tintColor = lineActiveColor
        }
        
        if self.bank_account_type == 0{
        }
        
        if self.account_type == 1{
            if (self.txtIBANCode1.text?.isEmpty == true || self.txtIBANCode1.text == "" || self.txtIBANCode2.text?.isEmpty == true || self.txtIBANCode2.text == "" || self.txtIBANCode3.text?.isEmpty == true || self.txtIBANCode3.text == "" || self.txtIBANCode4.text?.isEmpty == true || self.txtIBANCode4.text == "" || self.txtIBANCode5.text?.isEmpty == true || self.txtIBANCode5.text == "" || self.txtIBANCode1.text == "GB"){
                if isFirst{
                    isFirst = false
                   firstTextField = txtIBANCode1
                }
                lineIBAN1.tintColor = lineInActiveColor
                lineIBAN2.tintColor = lineInActiveColor
                lineIBAN3.tintColor = lineInActiveColor
                lineIBAN4.tintColor = lineInActiveColor
                lineIBAN5.tintColor = lineInActiveColor
            }else{
                lineIBAN1.tintColor = lineActiveColor
                lineIBAN2.tintColor = lineActiveColor
                lineIBAN3.tintColor = lineActiveColor
                lineIBAN4.tintColor = lineActiveColor
                lineIBAN5.tintColor = lineActiveColor
            }
        }else if self.account_type == 2 {
            if (self.txtCode1.text?.isEmpty == true || self.txtCode1.text == "" || self.txtCode2.text?.isEmpty == true || self.txtCode2.text == "" || self.txtCode3.text?.isEmpty == true || self.txtCode3.text == ""){
                if isFirst{
                    isFirst = false
                   firstTextField = txtCode1
                }
                codeLine1.tintColor = lineInActiveColor
                codeLine2.tintColor = lineInActiveColor
                codeLine3.tintColor = lineInActiveColor
            }else{
                codeLine1.tintColor = lineActiveColor
                codeLine2.tintColor = lineActiveColor
                codeLine3.tintColor = lineActiveColor
            }
            
            if self.txtAccountNumber.text?.isEmpty == true || self.txtAccountNumber.text == ""{
                if isFirst{
                    isFirst = false
                   firstTextField = txtAccountNumber
                }
                imgAccountNumberLine.tintColor = lineInActiveColor
            }else{
                imgAccountNumberLine.tintColor = lineActiveColor
            }
        }
        
        if self.txtMobileNumber.text?.isEmpty == true || self.txtMobileNumber.text == ""{
            if isFirst{
                isFirst = false
               firstTextField = txtMobileNumber
            }
            lineMobileNumber.tintColor = lineInActiveColor
        }else{
            lineMobileNumber.tintColor = lineActiveColor
        }
        
        if self.txtAddress.text?.isEmpty == true || self.txtAddress.text == ""{
            if isFirst{
                isFirst = false
               firstTextField = txtAddress
            }
            lineAddress.tintColor = lineInActiveColor
        }else{
            lineAddress.tintColor = lineActiveColor
        }
        
        if self.txtPassCode.text?.isEmpty == true || self.txtPassCode.text == ""{
            if isFirst{
                isFirst = false
               firstTextField = txtPassCode
            }
            linePostCode.tintColor = lineInActiveColor
        }else{
            linePostCode.tintColor = lineActiveColor
        }
        
        if self.txtCity.text?.isEmpty == true || self.txtCity.text == ""{
            if isFirst{
                isFirst = false
               firstTextField = txtCity
            }
            lineCity.tintColor = lineInActiveColor
        }else{
            lineCity.tintColor = lineActiveColor
        }
        
        if !isFirst{
            firstTextField.becomeFirstResponder()
        }
    }
    
    func isEditing() {
        if activeField == txtName{
            lineFullName.tintColor = lineActiveColor
        }
        
        if self.account_type == 1{
            if activeField == txtIBANCode1{
                lineIBAN1.tintColor = lineActiveColor
            }
            if activeField == txtIBANCode2{
                lineIBAN2.tintColor = lineActiveColor
            }
            if activeField == txtIBANCode3{
                lineIBAN3.tintColor = lineActiveColor
            }
            if activeField == txtIBANCode4{
                lineIBAN4.tintColor = lineActiveColor
            }
            if activeField == txtIBANCode5{
                lineIBAN5.tintColor = lineActiveColor
            }

        }else if self.account_type == 2 {
            if activeField == txtCode1{
                codeLine1.tintColor = lineActiveColor
            }
            if activeField == txtCode2{
                codeLine2.tintColor = lineActiveColor
            }
            if activeField == txtCode3{
                codeLine3.tintColor = lineActiveColor
            }
            if activeField == txtAccountNumber{
                imgAccountNumberLine.tintColor = lineActiveColor
            }
        }
        
        if activeField == txtMobileNumber{
            lineMobileNumber.tintColor = lineActiveColor
        }
        
        if activeField == txtAddress{
            lineAddress.tintColor = lineActiveColor
        }
        
        if activeField == txtPassCode{
            linePostCode.tintColor = lineActiveColor
        }

        if activeField == txtCity{
            lineCity.tintColor = lineActiveColor
        }
    }
}

extension BankingFormVC : UITextFieldDelegate
{
    func formattedNumber(number: String) -> String {
        let cleanPhoneNumber = number.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        let mask = "XXXX XXXX XXXX XXXX XXXX XX"

        var result = ""
        var index = cleanPhoneNumber.startIndex
        for ch in mask where index < cleanPhoneNumber.endIndex {
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         textField.resignFirstResponder()

         return true

    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        isEditing()
        if textField == txtIBANCode1 || textField == txtIBANCode2 || textField == txtIBANCode3 || textField == txtIBANCode4 || textField == txtIBANCode5 || textField == txtCode1 || textField == txtCode2 || textField == txtCode3{
            
        }else{
            textField.frame.origin.y = textField.frame.origin.y - 150
             textField.frame.origin.x = 15
            let content: CGPoint = CGPoint (x: 0.0, y: textField.frame.origin.y)
            self.myScrollView.setContentOffset(content, animated: true)
        }
        if UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhones_4_4S{
            IQKeyboardManager.shared.enable = true
        }else{
            IQKeyboardManager.shared.enable = false
        }
        if textField == txtIBANCode1{
            if txtIBANCode1.text == ""{
                txtIBANCode1.text = "GB"
            }
        }
    }
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)

        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }

    @objc func textFieldDidChange(textField: UITextField){
        let text = textField.text
        if textField == txtCode1 || textField == txtCode2 || textField == txtCode3{
            if (text?.utf16.count)! >= 2 {
                switch textField {
                case txtCode1:
                    txtCode2.becomeFirstResponder()
                case txtCode2:
                    txtCode3.becomeFirstResponder()
                case txtCode3:
                    txtCode3.resignFirstResponder()
                default:
                    break
                }
            } else if text?.utf16.count == 0 {
                switch textField {
                case txtCode1:
                    txtCode2.resignFirstResponder()
                case txtCode2:
                    txtCode1.becomeFirstResponder()
                case txtCode3:
                    txtCode2.becomeFirstResponder()
                    
                default:
                    break
                }
            }
        }else{
            if textField == txtIBANCode5{
                if text?.utf16.count == 2 {
                    txtIBANCode5.resignFirstResponder()
                }else if text?.utf16.count == 0 {
                    txtIBANCode4.becomeFirstResponder()
                }
            }
            else if (text?.utf16.count)! >= 4 {
                switch textField {
                case txtIBANCode1:
                    txtIBANCode2.becomeFirstResponder()
                case txtIBANCode2:
                    txtIBANCode3.becomeFirstResponder()
                case txtIBANCode3:
                    txtIBANCode4.becomeFirstResponder()
                case txtIBANCode4:
                    txtIBANCode5.becomeFirstResponder()
                case txtIBANCode5:
                    txtIBANCode5.resignFirstResponder()
                default:
                    break
                }
            } else if text?.utf16.count == 0 {
                switch textField {
                case txtIBANCode1:
                    txtIBANCode2.resignFirstResponder()
                case txtIBANCode2:
                    txtIBANCode1.becomeFirstResponder()
                case txtIBANCode3:
                    txtIBANCode2.becomeFirstResponder()
                case txtIBANCode4:
                    txtIBANCode3.becomeFirstResponder()
                case txtIBANCode5:
                    txtIBANCode4.becomeFirstResponder()
                default:
                    break
                }
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        activeField = nil
    }
       

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == txtAccountNumber {
            let maxLength = 8
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }else if textField == txtIBANCode1 || textField == txtIBANCode2 || textField == txtIBANCode3 || textField == txtIBANCode4 || textField == txtIBANCode5{
            let components = string.components(separatedBy: allowedCharactersdata)
            let filtered = components.joined(separator: "")
            
            if string == filtered {
            } else {
                return false
            }
            if string == " "{
                return false
            }

            var maxLength = 4
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
                currentString.replacingCharacters(in: range, with: string) as NSString
            if textField == txtIBANCode1{
                if newString.length == 0 || textField.text?.isEmpty == true || textField.text == ""{
                    textField.text = "GB"
                    print("6")
                    return false
                }else if newString.length == 1{
                    textField.text = "GB"
                    return false
                }
            }else if textField == txtIBANCode5{
                maxLength = 2
            }
            return newString.length <= maxLength
        }else if textField == txtCode1 || textField == txtCode2 || textField == txtCode3{
            if string == " "{
                return false
            }
              let maxLength = 2
              let currentString: NSString = textField.text! as NSString
              let newString: NSString =
              currentString.replacingCharacters(in: range, with: string) as NSString
              return newString.length <= maxLength
        }else if textField == txtMobileNumber{
            let maxLength = 13
            let currentString: NSString = textField.text! as NSString
            let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
            return newString.length <= maxLength
        }else
        {
            return true
        }
    }
    
    @objc func keyboardWillBeHidden(aNotification: NSNotification) {
    }
    
    @objc func keyboardWillShow(aNotification: NSNotification) {
    }
}

extension BankingFormVC
{
    func SaveBankDetailAPICall()
    {
        var sort_code = ""
        var IBANCode = ""
        if self.account_type == 1{
            if  self.txtIBANCode1.text?.isEmpty == true || self.txtIBANCode1.text == "" || self.txtIBANCode2.text?.isEmpty == true || self.txtIBANCode2.text == "" || self.txtIBANCode3.text?.isEmpty == true || self.txtIBANCode3.text == "" || self.txtIBANCode4.text?.isEmpty == true || self.txtIBANCode4.text == "" || self.txtIBANCode5.text?.isEmpty == true || self.txtIBANCode5.text == "" || self.txtIBANCode1.text == "GB"{
                IBANCode = ""
            }else{
                IBANCode = "\(self.txtIBANCode1.text ?? "") \(self.txtIBANCode2.text ?? "") \(self.txtIBANCode3.text ?? "") \(self.txtIBANCode4.text ?? "") \(self.txtIBANCode5.text ?? "")"
            }
        }else{
            if  self.txtCode1.text?.isEmpty == true || self.txtCode1.text == "" || self.txtCode2.text?.isEmpty == true || self.txtCode2.text == "" || self.txtCode3.text?.isEmpty == true || self.txtCode3.text == ""{
                sort_code = ""
            }else{
                sort_code = "\(self.txtCode1.text ?? "") \(self.txtCode2.text ?? "") \(self.txtCode3.text ?? "")"
            }
        }

        var params = [String: Any]()
        params = ["loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","buisness_name": "\(self.txtName.text ?? "")", "account_type": "\(self.account_type)", "bank_account_type": "\(self.bank_account_type)","address": "\(self.txtAddress.text ?? "")","post_code":"\(self.txtPassCode.text ?? "")","city": "\(self.txtCity.text ?? "")","country_id": "\("247"/*"APPDELEGATE?.countryNameCode ?? "0""*/)","account_id":self.account_id,"mobile_no": self.txtMobileNumber.text ?? ""]
        if self.account_type == 1{
            params["iban_number"] = IBANCode
            params["uk_sort_code"] = ""
            params["account_number"] = ""
            self.txtCode1.text = ""
            self.txtCode2.text = ""
            self.txtCode3.text = ""
            self.txtAccountNumber.text = ""
        }else{
            params["iban_number"] = ""
            params["uk_sort_code"] = sort_code
            params["account_number"] = "\(self.txtAccountNumber.text ?? "")"
            self.txtIBANCode1.text = "GB"
            self.txtIBANCode2.text = ""
            self.txtIBANCode3.text = ""
            self.txtIBANCode4.text = ""
            self.txtIBANCode5.text = ""
        }
        WebService.Request.patch(url: savePersonalInformation, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    if let data = response!["data"] as? [String: Any]{
                        self.account_id = data["_id"] as? String ?? "0"
                        APPDELEGATE?.bankDetailNotFilled = .Yes
                        appDelegate.addAlertPopupviewWithCompletion(viewcontroller: self, oprnfrom: "fillBankDetail", message: "Congratulations!!! Your bank information has been saved successfully.") { (status) in
                            if self.openFrom == .chat{
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }else{
                    appDelegate.addAlertPopupview(viewcontroller: self, oprnfrom: "", message: "Something went wrong please try again later.")
                }
            }
        }
    }
    
    //
    func GetBankDetailAPICall()
    {
        var params = [String: Any]()
        params = ["loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")"]
        WebService.Request.patch(url: getPersonalInformation, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    if let data = response!["data"] as? [String: Any]{
                        self.txtName.text = data["buisness_name"] as? String
                        self.txtMobileNumber.text = data["mobile_no"] as? String ?? ""
                        self.txtAccountNumber.text = data["account_number"] as? String
                        self.txtAddress.text = data["address"] as? String
                        self.txtPassCode.text = data["post_code"] as? String
                        self.txtCity.text = data["city"] as? String
                        self.account_id = data["account_id"] as? String ?? "0"
                        
                        if data["account_type"] as! String == "1"
                        {
                            self.btnIban.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                            self.btnUk.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.account_type = 1
                            self.viewIbanNumber.isHidden = false
                            self.lblIbanAndUK.text = "IBAN"
                            self.txtCode1.isHidden = true
                            self.codeLine1.isHidden = true
                            self.txtCode2.isHidden = true
                            self.codeLine2.isHidden = true
                            self.txtCode3.isHidden = true
                            self.setupSortOrIBAN()
                        }
                        else if data["account_type"] as! String == "2"
                        {
                            self.btnIban.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                            self.account_type = 2
                            self.viewIbanNumber.isHidden = true
                            self.lblIbanAndUK.text = "UK Sort Code"
                            self.txtCode1.isHidden = false
                            self.codeLine1.isHidden = false
                            self.txtCode2.isHidden = false
                            self.codeLine2.isHidden = false
                            self.txtCode3.isHidden = false
                            self.codeLine3.isHidden = false
                            self.setupSortOrIBAN()
                        }
                        else
                        {
                            self.btnIban.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                            self.account_type = 2
                            self.viewIbanNumber.isHidden = true
                            self.lblIbanAndUK.text = "UK Sort Code"
                            self.txtCode1.isHidden = false
                            self.codeLine1.isHidden = false
                            self.txtCode2.isHidden = false
                            self.codeLine2.isHidden = false
                            self.txtCode3.isHidden = false
                            self.codeLine3.isHidden = false
                            self.setupSortOrIBAN()
                        }
                        
                        if data["bank_account_type"] as! String == "1"
                        {
                            self.btnPrivate.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                            self.btnBusiness.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.bank_account_type = 1
                        }
                        else if data["bank_account_type"] as! String == "2"
                        {
                            self.btnPrivate.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.btnBusiness.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                            self.bank_account_type = 2
                        }
                        else
                        {
                            self.btnBusiness.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.btnPrivate.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                            self.bank_account_type = 0
                        }
                        let iban = data["iban_number"] as? String ?? ""
                        self.ibanNumber.text = (iban).group(by: 4, separator: " ")
                        self.ibanCount = 27
                        
                        let myString: String = data["uk_sort_code"] as? String ?? ""
                        let myStringArr = myString.components(separatedBy: " ")
                        
                        if myStringArr.count > 0
                        {
                            if myStringArr.count == 1{
                                self.txtCode1.text = myStringArr[0]
                            }else if myStringArr.count == 2{
                                self.txtCode1.text = myStringArr[0]
                                self.txtCode2.text = myStringArr[1]
                            }else if myStringArr.count == 3{
                                self.txtCode1.text = myStringArr[0]
                                self.txtCode2.text = myStringArr[1]
                                self.txtCode3.text = myStringArr[2]
                            }
                        }
                        
                        let myIBANString: String = data["iban_number"] as? String ?? ""
                        let myIBANStringArr = myIBANString.components(separatedBy: " ")
                        
                        if myIBANStringArr.count > 0
                        {
                            if myIBANStringArr.count == 1{
                                self.txtIBANCode1.text = myIBANStringArr[0]
                            }else if myIBANStringArr.count == 2{
                                self.txtIBANCode1.text = myIBANStringArr[0]
                                self.txtIBANCode2.text = myIBANStringArr[1]
                            }else if myIBANStringArr.count == 3{
                                self.txtIBANCode1.text = myIBANStringArr[0]
                                self.txtIBANCode2.text = myIBANStringArr[1]
                                self.txtIBANCode3.text = myIBANStringArr[2]
                            }else if myIBANStringArr.count == 4{
                                self.txtIBANCode1.text = myIBANStringArr[0]
                                self.txtIBANCode2.text = myIBANStringArr[1]
                                self.txtIBANCode3.text = myIBANStringArr[2]
                                self.txtIBANCode4.text = myIBANStringArr[3]
                            }else if myIBANStringArr.count == 5{
                                self.txtIBANCode1.text = myIBANStringArr[0]
                                self.txtIBANCode2.text = myIBANStringArr[1]
                                self.txtIBANCode3.text = myIBANStringArr[2]
                                self.txtIBANCode4.text = myIBANStringArr[3]
                                self.txtIBANCode5.text = myIBANStringArr[4]
                            }
                        }

                        APPDELEGATE?.countryNameCode = data["country_id"] as? String ?? ""
                        self.getCountryListAPICall()
                    }
                    else{
                        self.btnIban.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                        self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                        self.account_type = 2
                        self.viewIbanNumber.isHidden = true
                        self.lblIbanAndUK.text = "UK Sort Code"
                        self.txtCode1.isHidden = false
                        self.codeLine1.isHidden = false
                        self.txtCode2.isHidden = false
                        self.codeLine2.isHidden = false
                        self.txtCode3.isHidden = false
                        self.codeLine3.isHidden = false
                        self.setupSortOrIBAN()
                    }
                }else{
                    self.btnIban.setImage(#imageLiteral(resourceName: "genderDeselected"), for: .normal)
                    self.btnUk.setImage(#imageLiteral(resourceName: "GenderSelectecd"), for: .normal)
                    self.account_type = 2
                    self.viewIbanNumber.isHidden = true
//                  self.codeLineIBAN.isHidden = true
                    self.lblIbanAndUK.text = "UK Sort Code"
                    self.txtCode1.isHidden = false
                    self.codeLine1.isHidden = false
                    self.txtCode2.isHidden = false
                    self.codeLine2.isHidden = false
                    self.txtCode3.isHidden = false
                    self.codeLine3.isHidden = false
                    self.setupSortOrIBAN()
                }
            }
        }
    }
    
    ///Get Service List API Call
    func getCountryListAPICall() {
        WebService.Request.patch(url: getAllCountry, type: .get, parameter: nil, callSilently: true, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    
                    let TempConutrinData = NSMutableArray()
                    TempConutrinData.addObjects(from: data)
                    
                    for i in 0...TempConutrinData.count - 1
                    {
                        let data = TempConutrinData[i] as? [String:Any]
                        if (data?["id"] as! String) == APPDELEGATE?.countryNameCode
                        {
                        }
                    }
                }
            }
        }
    }
}

extension String
{
    func group(by groupSize:Int=3, separator:String="-") -> String{
         if characters.count <= groupSize   { return self }
         let splitSize  = min(max(1,characters.count-1) , groupSize)
         let splitIndex = index(startIndex, offsetBy:splitSize)
         return substring(to:splitIndex)
              + separator
              + substring(from:splitIndex).group(by:groupSize, separator:separator)
      }
}
