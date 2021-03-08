
import UIKit
import IQKeyboardManagerSwift
import DropDown

class AddReviewVC: UIViewController,UITextViewDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    
    @IBOutlet weak var ImgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var ImgRate1: UIImageView!
    @IBOutlet weak var ImgRate2: UIImageView!
    @IBOutlet weak var ImgRate3: UIImageView!
    @IBOutlet weak var ImgRate4: UIImageView!
    @IBOutlet weak var ImgRate5: UIImageView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var txtDesc: UITextView!
    @IBOutlet weak var lblExp: UILabel!
    @IBOutlet weak var btnAboutExp: UIButton!
    
    @IBOutlet weak var lblJobDescription: UILabel!
    @IBOutlet weak var imgDefaultJob: UIImageView!
    @IBOutlet weak var collReview: UICollectionView!
    @IBOutlet weak var heightCollview: NSLayoutConstraint!
    var arrIndex = NSMutableArray()
    var arrTemp = NSMutableArray()
    var JobData: [JobHistoryData]?
    
    var to_user_id = String()
    var rating = Int()
    var review_id = String()
    var job_id = String()
    var userdetail = [String:Any]()
    let dropDownReviewOption = DropDown()
    var arrReviewOption: [String] = ["Great Job","Helpful","Reliable","Punctual","Polite","Highly Recommend"]
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.previousNextDisplayMode = .alwaysHide

        APPDELEGATE?.isfromChat()
        self.SetupUserDetails()
        self.GetJobDetailAPI()
        self.txtDesc.autocorrectionType = .yes
        
        if APPDELEGATE?.selectedUserType == .Crafter
        {
            self.lblTitle.text = "Review your Client"
        }
        else
        {
            self.lblTitle.text = "Review your Crafter"
        }
        
        self.txtDesc.text = APPDELEGATE?.AddReview_PlaceHolder
        DropDownReviewOption()
    }
    
    func DropDownReviewOption() {
        self.dropDownReviewOption.anchorView = self.btnAboutExp
        dropDownReviewOption.dataSource = self.arrReviewOption
        dropDownReviewOption.backgroundColor = UIColor.white
        dropDownReviewOption.selectionBackgroundColor = UIColor.white
        dropDownReviewOption.direction = .bottom
        dropDownReviewOption.textFont = (UIFont(name: "Cabin-Medium", size: 15.0) ?? nil)!
        dropDownReviewOption.plainView.cornerRadius = 12.0
        dropDownReviewOption.textColor = #colorLiteral(red: 0.3442644477, green: 0.3798936009, blue: 0.4242471457, alpha: 1)
        dropDownReviewOption.selectionAction = { [] (index: Int, item: String) in
            self.lblExp.text = item
//            self.lblExp.setTitle(item, for: .normal)
            self.dropDownReviewOption.hide()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.heightCollview.constant = self.collReview.contentSize.height
        self.collReview.layoutIfNeeded()
    }
    
    //Setup Details
    func SetupUserDetails()
    {
        let starImg = UIImage(named: "star")?.withRenderingMode(.alwaysTemplate)
        self.lblRate.text = "\(self.rating).0"
        if self.rating == 0 {
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = UIColor.gray
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = UIColor.gray
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.gray
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.gray
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.gray
        } else if self.rating == 1{
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = UIColor.gray
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.gray
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.gray
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.gray
        }else if self.rating == 2{
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = UIColor.gray
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.gray
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.gray
        }else if self.rating == 3{
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = UIColor.gray
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.gray
        }else if self.rating == 4{
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = UIColor.gray
        }else if self.rating == 5{
            self.ImgRate1.image = starImg
            self.ImgRate1.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate2.image = starImg
            self.ImgRate2.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate3.image = starImg
            self.ImgRate3.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate4.image = starImg
            self.ImgRate4.tintColor = APPDELEGATE?.appGreenColor
            self.ImgRate5.image = starImg
            self.ImgRate5.tintColor = APPDELEGATE?.appGreenColor
        }
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton){
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnInfoAction(_ sender: UIButton){
        let displayPopup = displayPopupView()
        displayPopup.intiWithuserdetail(userdetail: userdetail, displayPopUp: 1,isfrom:"review", userID: "", oponnentuserid: "", jobID: "", is_block: "", conversationIdJob: "", isReview: "")
        displayPopup.frame = self.view.bounds
        self.view.addSubview(displayPopup)
    }
    
    func displayPopupView() -> PopupView{
        let infoWindow = PopupView.instanceFromNib() as! PopupView
        return infoWindow
    }
    
    @IBAction func btnEditAction(_ sender: UIButton)
    {
        
    }
    
    @IBAction func btnAboutExperience(_ sender: UIButton){
        self.dropDownReviewOption.show()
    }
    
    @IBAction func btnViewAction(_ sender: UIButton)
    {
        
    }
    
    @IBAction func btnPushReviewAction(_ sender: UIButton)
    {
            self.AddReviewAPI()
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        self.txtDesc.tintColor = UIColor(red: 70/255, green: 78/255, blue: 89/255, alpha: 1.0)
        if txtDesc.text == APPDELEGATE?.AddReview_PlaceHolder{
            txtDesc.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if txtDesc.text == ""{
            txtDesc.text = APPDELEGATE?.AddReview_PlaceHolder
        }
    }
    
    //Textview DElegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension AddReviewVC
{
    func AddReviewAPI()
    {
        var strOption = ""
        if self.arrTemp.count > 0{
            strOption = self.arrTemp.componentsJoined(by: ". ")
        }else{
            strOption = ""
        }
        
        var strDesc = ""
        if txtDesc.text == APPDELEGATE?.AddReview_PlaceHolder{
            strDesc = ""
        }else{
            strDesc = txtDesc.text
        }
        
        var strFinale = ""
        if strOption == "" && strDesc == ""{
            strFinale = ""
        }else if strOption == ""{
            strFinale = "\(self.txtDesc.text ?? "")."
        }else if strDesc == ""{
            strFinale = "\(strOption)."
        }else{
            strFinale = "\(strOption). \(self.txtDesc.text ?? "")."
        }
        
        let params = ["from_user_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")","to_user_id":"\(self.to_user_id)","review_by":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","rating":"\(self.rating)","review_message":strFinale,"review_id":self.review_id,"job_id":"\(self.job_id)"]
        print(params)
        WebService.Request.patch(url: AddReview, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)

                if response!["status"] as? Bool == true
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "review", message:response!["msg"] as? String ?? "Review added successfully!")

                } else
                {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:response!["msg"] as? String ?? "Something went wrong!, Please try again later.")
                    self.txtDesc.text = APPDELEGATE?.AddReview_PlaceHolder
                }
            }
        }
    }
    
    //Get Job Detail API
    func GetJobDetailAPI()
    {
        var userType = String()
        var habdymanId = String()
        if APPDELEGATE!.selectedUserType == .Crafter
        {
            userType = Crafter
            habdymanId = APPDELEGATE?.uerdetail?._id ?? (APPDELEGATE?.uerdetail?.user_id ?? "")
        }
        else
        {
            userType = Client
            habdymanId = to_user_id
        }

        let params = ["job_id":"\(self.job_id)","handyman_id":habdymanId,"loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","session_token":"\(APPDELEGATE?.uerdetail?.session_token ?? "")","user_type":"\(userType)"]
        WebService.Request.patch(url: getJobDetail, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                    if dataresponse != nil
                    {
                        do
                        {
                            let jsonData = try JSONSerialization.data(withJSONObject: dataresponse!, options: .prettyPrinted)
                            self.JobData = try! JSONDecoder().decode([JobHistoryData]?.self, from: jsonData)                            
                           
                            if (self.JobData?.count)! > 0
                            {
                                let imgURL = URL(string: self.JobData?[0].profile_image ?? "")
                                self.ImgProfile.kf.setImage(with: imgURL, placeholder: nil)
                                
                                if (self.JobData?[0].first_name == "") || (self.JobData?[0].last_name == "")
                                {
                                    self.lblName.text = "\(self.JobData?[0].user_name ?? "")"
                                }
                                else
                                {
                                    let fName = "\(self.JobData?[0].first_name ?? "")"
                                    let lName = "\(self.JobData?[0].last_name ?? "")"
                                    let lname = lName.first
                                    self.lblName.text = "\(fName) \(lname ?? " ")."
                                }
                                
                                self.lblDesc.text = "\(self.JobData?[0].description ?? "")"
                                self.lblInfo.text = "Completed \(self.JobData?[0].complete_time ?? "\(Date())")"
                                self.imgDefaultJob.image = appDelegate.imgDefault
                                self.lblJobDescription.text = "\(self.JobData?[0].description ?? "")"
                            }
                        }
                        catch
                        {
                            print(error.localizedDescription)
                        }
                    }
                    else
                    {
                        
                    }
                } else
                {
                    //self.toastError("Something went wrong, please try again later")
                }
            }
        }
    }
}


extension AddReviewVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return arrReviewOption.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellReview", for: indexPath) as! cellReview
        cell.lblText.text = self.arrReviewOption[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if arrIndex.contains(indexPath.item){
            arrIndex.remove(indexPath.item)
            self.arrTemp.remove(self.arrReviewOption[indexPath.item])
            let cell = self.collReview.cellForItem(at: indexPath) as! cellReview
            cell.viewBack.backgroundColor = .white
        }else{
            arrIndex.add(indexPath.item)
            self.arrTemp.add(self.arrReviewOption[indexPath.item])
            let cell = self.collReview.cellForItem(at: indexPath) as! cellReview
            cell.viewBack.backgroundColor = appDelegate.appGreenColor
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let str = self.arrReviewOption[indexPath.item]
        let cellWidth = str.size(withAttributes:[.font: UIFont.systemFont(ofSize:14.0)]).width + 30.0
        return CGSize(width: cellWidth, height: 30.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
}
