
import UIKit

class ChatuserCell: UITableViewCell {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblLastMessage: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblNotifCount: UILabel!
    @IBOutlet weak var lblJobCat: UILabel!
    @IBOutlet weak var imgIsread: UIImageView!
    @IBOutlet weak var lblLastMessageTime: UILabel!
    @IBOutlet weak var widthimgisRead: NSLayoutConstraint!
    @IBOutlet weak var leadingIsRead: NSLayoutConstraint!
    @IBOutlet weak var imgService: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
