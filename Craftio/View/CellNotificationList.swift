
import UIKit

class CellNotificationList: UITableViewCell
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var lblHeader: UILabel!
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblQuote: UILabel!
    
    @IBOutlet weak var imgTick: UIImageView!
    
    //MARK:- Default Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
}
