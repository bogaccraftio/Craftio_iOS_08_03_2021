
import UIKit

enum popupPaymentType{
    case showDepositView
    case showReleaseView
    case none
}


class PaymentPopup: UIView,UITextFieldDelegate {

    //MARK:- Variables & Outlets
    @IBOutlet weak var viewDeposit: UIView!
    @IBOutlet weak var btnDepositNow: UIButton!
    @IBOutlet weak var btnDepositLater: UIButton!
    
    @IBOutlet weak var viewRelease: UIView!
    @IBOutlet weak var btnReleasePayment: UIButton!
    @IBOutlet weak var lblReleasedAmount: UILabel!
    @IBOutlet weak var btnReleaseAmount: UIButton!
    
    @IBOutlet weak var viewInsertReleaseAmount: UIView!
    @IBOutlet weak var lblReleaseAmount: UILabel!
    @IBOutlet weak var lblReleasedTotalAmount: UILabel!
    @IBOutlet weak var txtAmount: UITextField!
    @IBOutlet weak var bottomViewInsertReleaseAmount: NSLayoutConstraint!

    var displayPopup: popupPaymentType = .none
    var displayPaymentType: ((String, String) -> ())?
    var jobTotalPrice = String()
    
    class func instanceFromNib() -> UIView
    {
        return UINib(nibName: "PaymentPopup", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func initPaymentPopupView(viewopenFrom:String,UserData:String, popupDisplayType: popupPaymentType, jobPrice: String, jobReleasedAmount: String)
    {
        jobTotalPrice = jobPrice
        self.backgroundColor = UIColor.clear
        self.OnloadSetup(self.viewDeposit)
        self.OnloadSetup(self.viewRelease)
        self.OnloadSetup(self.viewInsertReleaseAmount)
        self.viewInsertReleaseAmount.isHidden = true
        if popupDisplayType == .showDepositView{
            self.viewDeposit.isHidden = false
            self.viewRelease.isHidden = true
        }else if popupDisplayType == .showReleaseView{
            self.viewDeposit.isHidden = true
            self.viewRelease.isHidden = false
            btnReleasePayment.setTitle("RELEASE WHOLE PAYMENT OF £\(jobTotalPrice)", for: .normal)
            lblReleaseAmount.text = "Release payment from total fund of £\(jobTotalPrice)"
            let price = Float(jobPrice)!
            let releasedPrice = Float(jobReleasedAmount) ?? 0.0
            let price1 = releasedPrice - price
            if price1 > 0 && price1 != releasedPrice && price1 <= releasedPrice{
                lblReleasedAmount.text = "You already released £\(price1)"
                lblReleasedTotalAmount.text = "You already released £\(price1)"
            }else{
                lblReleasedAmount.text = ""
                lblReleasedTotalAmount.text = ""
            }
        }
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func OnloadSetup(_ viewCorner:UIView)
    {
        let rectShape = CAShapeLayer()
        rectShape.bounds = viewCorner.frame
        rectShape.position = viewCorner.center
        let frame = CGRect (x: 0, y: viewCorner.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: viewCorner.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        viewCorner.layer.mask = rectShape
    }
        
    //MARK:- Button Click Events
    @IBAction func btnDepositNowTapped(_ sender: UIButton)
    {
        displayPaymentType?(PaymentType.depositNow, "")
        self.removeFromSuperview()
    }
    
    @IBAction func btnDepositLaterTapped(_ sender: UIButton)
    {
        displayPaymentType?(PaymentType.depositLater, "")
        self.removeFromSuperview()
    }
    
    @IBAction func btnCloseDepositAction(_ sender: UIButton)
    {
        displayPaymentType?(PaymentType.depositLater, "")
        self.removeFromSuperview()
    }
    
    @IBAction func btnReleasePaymentTapped(_ sender: UIButton)
    {
        displayPaymentType?(PaymentType.releaseAll, jobTotalPrice)
        self.removeFromSuperview()
    }
    
    @IBAction func btnReleaseAmountTapped(_ sender: UIButton)
    {
        self.viewInsertReleaseAmount.isHidden = false
    }
    
    @IBAction func btnCloseReleaseAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
    }
    
    @IBAction func btnCloseInsertReleaseAmount(_ sender: UIButton)
    {
        self.endEditing(true)
        self.bottomViewInsertReleaseAmount.constant = 0
        UIView.animate(withDuration: 1.0, animations: {
            self.layoutIfNeeded()
            self.updateConstraintsIfNeeded()
        })
        self.viewInsertReleaseAmount.isHidden = true
    }

    @IBAction func btnInsertedReleaseAmount(_ sender: UIButton)
    {
        displayPaymentType?(PaymentType.releaseSomeFund, txtAmount.text ?? "0")
        self.removeFromSuperview()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = txtAmount.text! + string
        if Float(str)! > Float(jobTotalPrice)! {
            return false
        }
        else
        {
            return true
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.bottomViewInsertReleaseAmount.constant = keyboardSize.height
            
            UIView.animate(withDuration: 1.0, animations: {
                self.layoutIfNeeded()
                self.updateConstraintsIfNeeded()
            })
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            self.bottomViewInsertReleaseAmount.constant = 0
            
            UIView.animate(withDuration: 1.0, animations: {
                self.layoutIfNeeded()
                self.updateConstraintsIfNeeded()
            })
        }
    }
}
