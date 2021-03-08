
import UIKit
import AVFoundation

class SelectJobTitleVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblJobList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    
    var jobList: [JobHistoryData]?
    var tag = Int()
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        onLoadOperations()
        self.getJobListAPICall()
        self.tblJobList.isHidden = true
        
        self.tag = 0
        let nib = UINib.init(nibName: "CellWorkHistory", bundle: nil)
        self.tblJobList.register(nib, forCellReuseIdentifier: "CellWorkHistory")
    }
    
    func onLoadOperations()
    {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        let frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton)
    {
        self.navigationController?.popViewController(animated: true)
    }
}

extension SelectJobTitleVC:UITableViewDelegate,UITableViewDataSource
{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 276 //+ 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return jobList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellWorkHistory", for: indexPath) as! CellWorkHistory
        cell.viewInprogress.isHidden = true
        
        if self.jobList?[indexPath.row].is_archive == "1"{
            cell.lblInactivated.isHidden = false
            cell.viewMain.layer.borderColor = UIColor.lightGray.cgColor
            cell.viewMain.layer.borderWidth = 2.0
        }else{
            cell.lblInactivated.isHidden = true
            cell.viewMain.layer.borderColor = UIColor.clear.cgColor
            cell.viewMain.layer.borderWidth = 0.0
        }

        let imgURL = URL(string: jobList?[indexPath.row].service_image ?? "")
        cell.imgService.kf.setImage(with: imgURL, placeholder: nil)
        
        let imgURL2 = URL(string: jobList?[indexPath.row].profile_image ?? "")
        cell.imgProfile.kf.setImage(with: imgURL2, placeholder: nil)
        
        cell.lblName.isHidden = true
        cell.lblLocation.text = jobList?[indexPath.row].address
        cell.lblDescInProgress.text = jobList?[indexPath.row].description
        cell.lblPrice.text = "£ \(jobList?[indexPath.row].booking_amount ?? "0.0")"
        cell.lblInprogressDesc.text = jobList?[indexPath.row].description
            
        var rate = jobList?[indexPath.row].total_rating
        let rate1 = rate?.removeFirst()

        cell.lblRate.text = "\(rate1 ?? "0").0"
        let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        if rate1 == "0"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = UIColor.white
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = UIColor.white
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = UIColor.white
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = UIColor.white
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "1"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = UIColor.white
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = UIColor.white
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = UIColor.white
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "2"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = UIColor.white
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = UIColor.white
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "3"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = UIColor.white
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "4"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = UIColor.white
        }
        else if rate1 == "5"
        {
            cell.imgRate1.image = starImg
            cell.imgRate1.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate2.image = starImg
            cell.imgRate2.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate3.image = starImg
            cell.imgRate3.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate4.image = starImg
            cell.imgRate4.tintColor = APPDELEGATE?.appGreenColor
            cell.imgRate5.image = starImg
            cell.imgRate5.tintColor = APPDELEGATE?.appGreenColor
            
        }
        cell.btnDelete.tag = indexPath.row
        cell.btnEditChat.tag = indexPath.row
        cell.btnJobIcon.tag = indexPath.row
        cell.btnProfile.tag = indexPath.row
        
        cell.btnDelete.isHidden = true
        cell.btnEditChat.isHidden = true
        
        if self.tag == 0
        {
            cell.viewProfile.isHidden = true
            let img = UIImage(named: "edit")
            cell.btnEditChat.setImage(img, for: .normal)
        }
        else if self.tag == 1
        {
            cell.viewProfile.isHidden = false
            let img = UIImage(named: "chat")
            cell.btnEditChat.setImage(img, for: .normal)
            cell.viewInprogress.isHidden = false
        }
        else if self.tag == 2
        {
            cell.viewProfile.isHidden = false
            let img = UIImage(named: "chat")
            cell.btnEditChat.setImage(img, for: .normal)
            cell.viewInprogress.isHidden = false
            if (jobList?[indexPath.row].reported_client == 1 || jobList?[indexPath.row].reported_handyman == 1) && jobList?[indexPath.row].is_block == "0"{
                cell.btnEditChat.isHidden = false
            }else{
                cell.btnEditChat.isHidden = true
            }
        }
        
        cell.Arrimg = jobList?[indexPath.row].media ?? []
        cell.pageController.numberOfPages = jobList?[indexPath.row].media.count ?? 0
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if self.jobList?[indexPath.row].is_archive == "1"{
        }else{
            let viewControllers = self.navigationController!.viewControllers
            for aViewController in viewControllers
            {
                if aViewController is ProfileVC
                {
                    let aVC = aViewController as! ProfileVC
                    aVC.SelectjobList = self.jobList?[indexPath.row]
                    _ = self.navigationController?.popToViewController(aVC, animated: true)
                }
            }
        }

    }

    func getThumbnailImage_2(forUrl url: URL) -> UIImage?
    {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }
        catch let error
        {
            print(error)
        }
        
        return nil
    }

}

extension SelectJobTitleVC
{
    //Get Service List API Call
    func getJobListAPICall()
    {
        let params = ["user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "service_id": "", "job_status": "0", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"2"]//,"booking_status":"0"
        
        WebService.Request.patch(url: getJobListing, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    
                    if response!["status"] as? Bool == true {
                        let dataresponse = response!["data"] as? [[String:Any]]
                        
                        if dataresponse != nil
                        {
                            do
                            {
                                let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                                self.jobList = try? JSONDecoder().decode([JobHistoryData].self, from: jsonData)
                                self.tblJobList.reloadData()
                                self.tblJobList.isHidden = false
                            }
                            catch
                            {
                                self.jobList = nil
                                print(error.localizedDescription)
                            }
                        }
                        else
                        {
                            self.jobList = nil
                        }
                    } else
                    {
                        self.jobList = nil
                    }
                }
            }
        }
    }
}
