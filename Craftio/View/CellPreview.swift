
import UIKit

class CellPreview: UICollectionViewCell
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var ViewSlider: UIView!    
    public var player = Player()
    @IBOutlet weak var ImagePreview: UIImageView!
    
    //MARK:- Default Methods
    override func awakeFromNib()
    {
        
    }
    
}
