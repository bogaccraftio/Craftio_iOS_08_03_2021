
import UIKit

class AlertController: UIViewController {

    @IBOutlet weak var viewAlert: UIView!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var btnOk: UIButton!
    var message = String()

    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        lblMessage.text = APPDELEGATE!.alertMessage
    }
    
    override func viewDidLayoutSubviews() {
    }

    @IBAction func btnOk(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        NotificationCenter.default.post(name: Notification.Name("forgotPasssuccess"), object: nil)
    }
    
    @IBAction func btnDismiss(_ sender: Any) {
    }
}
