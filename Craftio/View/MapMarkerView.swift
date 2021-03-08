
import UIKit

protocol MapMarkerDelegate: class
{
    func didTapInfoButton(data: NSDictionary)
}

class MapMarkerView: UIView {

    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblJobTitle: UILabel!
    @IBOutlet weak var lblJobDate: UILabel!
    
    weak var delegate: MapMarkerDelegate?
    var spotData: NSDictionary?
    var jobviewVC  = UIViewController()
    var detail:JobHistoryData?
    
   /* @IBAction func didTapInfoButton(_ sender: UIButton) {
        delegate?.didTapInfoButton(data: spotData!)
    }*/
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "MapMarkerView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func setupData()
    {
        let imgURL = URL(string: detail?.service_image ?? "")
        imgProfile.kf.setImage(with: imgURL, placeholder: nil)
        lblJobTitle.text = detail?.service_name ?? ""
        lblJobDate.text = detail?.booking_date ?? ""
    }
    
    @IBAction func btnJobCatTapped(_ sender: UIButton)
    {
        let objJobDetailsVC = jobviewVC.storyboard?.instantiateViewController(withIdentifier: "JobDetailsVC") as! JobDetailsVC
        objJobDetailsVC.jobList = detail
        jobviewVC.navigationController?.pushViewController(objJobDetailsVC, animated: true)
    }
}
