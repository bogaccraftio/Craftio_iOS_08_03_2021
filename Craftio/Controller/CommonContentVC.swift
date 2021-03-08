
import UIKit

class CommonContentVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var lbltitlename: UILabel!
    @IBOutlet weak var txtViewContent: UITextView!
    
    var strNavTitle = String()
    var page_id = Int()
    var pageDetail = [String:Any]()
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APPDELEGATE?.addProgressView()
        txtViewContent.isHidden = true
        onLoadOperations()
        self.lbltitlename.text = pageDetail["sc_title"] as? String ?? ""
    }
    
    func onLoadOperations()
    {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
        getContentAPI()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        let htmlText = pageDetail["sc_content"] as? String ?? ""
        self.txtViewContent.attributedText = htmlText.htmlAttributed(family: "Cabin Medium", size: 0.0)
    }
    override func viewDidAppear(_ animated: Bool) {
        txtViewContent.setContentOffset(.zero, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.txtViewContent.isHidden = false
            APPDELEGATE?.hideProgrssVoew()
        }
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackTapped(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension CommonContentVC
{
    func getContentAPI()
    {
        let params = ["loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "page_id":"\(self.page_id)"]
        WebService.Request.patch(url: getStaticPage, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                    if dataresponse != nil
                    {
                        for item in dataresponse ?? []{
                            if item["sc_id"] as? String == "\(self.page_id)"{
                                self.lbltitlename.text = item["sc_title"] as? String
                               let htmlText = item["sc_content"] as! String
                            self.txtViewContent.attributedText = htmlText.htmlAttributed(family: "Cabin Medium", size: 0.0)
                            }
                        }
                        
                        //self.lbltitlename.text = dataresponse?["sc_title"] as? String
                      //  let htmlText = dataresponse?["sc_content"] as! String
                     //   self.txtViewContent.attributedText = htmlText.htmlAttributed(family: "Cabin Medium", size: 0.0)                        
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
