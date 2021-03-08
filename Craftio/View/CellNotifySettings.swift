
import UIKit

class CellNotifySettings: UITableViewCell
{
    //MARK:- Variabls & Outlets
    @IBOutlet weak var lbltitle: UILabel!
    @IBOutlet weak var btnSwitch: UISwitch!
    
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
