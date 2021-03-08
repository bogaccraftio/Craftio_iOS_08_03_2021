

import UIKit

class CellUnblockRehire: UITableViewCell
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnTitle: UIButton!
    
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
