
import UIKit

class CancelJobPopupView: UIView {

    @IBOutlet weak var viewCancelOption: UIView!
    var
    blockCancelOption : ((Int)->())?
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CancelJobPopupView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func intiWithuserdetail(){
        self.backgroundColor = UIColor.clear
        
        //ViewReview
        let rectShape4 = CAShapeLayer()
        rectShape4.bounds = self.viewCancelOption.frame
        rectShape4.position = self.viewCancelOption.center
        let frame4 = CGRect (x: 0, y: self.viewCancelOption.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.viewCancelOption.bounds.size.height)
        rectShape4.path = UIBezierPath(roundedRect: frame4, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewCancelOption.layer.mask = rectShape4
    }
    
    //ViewReview
    @IBAction func btnClosePopupAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        viewCancelOption.isHidden = true
    }
    
    @IBAction func btnWrongQuoteAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.blockCancelOption!(1)
        
    }
    
    @IBAction func btnByMistakeAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.blockCancelOption!(2)
    }
    
    @IBAction func btnOtherAction(_ sender: UIButton)
    {
        self.removeFromSuperview()
        self.blockCancelOption!(3)
    }
}
