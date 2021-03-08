
import UIKit
import AVKit
import Photos

class PreviewVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var CollPreview: UICollectionView!
    @IBOutlet weak var btndelete: UIButton!
    @IBOutlet weak var btnMakeDefault: UIButton!
    @IBOutlet weak var btnPencil: UIButton!
    @IBOutlet weak var btnText: UIButton!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var viewContainerEdit: UIView!
    var arrPreview = [Any]()
    var arrassets = [PHAsset]()
    var arrImages: [media]?
    var DonwloadIndex = Int()
    @IBOutlet weak var lblPaging: UILabel!
    var OpenFrom = String()
    var currentindex = 0
    var fromEdit = "no"
    var isDefault = false
    var defaultImage: Any?
    var jobID = String()
    var isFirstTime = true
    var isEditingImage = false
    var isMarkDefault = false
    var editIMage : EditImageVC!
    var selectedIndex = 0
    var blockCancel: (() -> ())!
    var showPreviewAs: displayPreview = .fromOther
    
    enum displayPreview{
        case fromOwnJOb
        case fromOther
        case fromEditJOb
    }
    
    //MARK:- Default Methods
    override func viewDidLoad(){
        super.viewDidLoad()
        viewContainerEdit.isHidden = true
        btnPencil.isHidden = false
        btnText.isHidden = false
        checkMediaType()
        APPDELEGATE?.isfromChat()
        self.lblPaging.text = "\(1)/\(APPDELEGATE?.jobDetailImages.count ?? 0)"
    }
    
    func checkMediaType() {
        if showPreviewAs == .fromOwnJOb{
            if let mediaURL = APPDELEGATE?.jobDetailImages[currentindex] as? URL{
                if (mediaURL.absoluteString.contains(".mp4")) || (mediaURL.absoluteString.contains(".mov")){
                    self.hideShowButtons(isHidden: true)
                    btndelete.isHidden = false
                }else{
                    self.hideShowButtons(isHidden: false)
                }
            }else if let mediaURL = APPDELEGATE?.jobDetailImages[currentindex] as? media {
                if ((mediaURL.media_url?.contains(".mp4"))!) || ((mediaURL.media_url?.contains(".mov"))!){
                    self.hideShowButtons(isHidden: true)
                    btndelete.isHidden = false
                }else{
                    self.hideShowButtons(isHidden: false)
                }
            }else {
                self.hideShowButtons(isHidden: false)
            }
        }else{
            self.hideShowButtons(isHidden: true)
        }
    }
    
    @IBAction func btnEditImage(_ sender: UIButton){
        let visibleRect = CGRect(origin: CollPreview.contentOffset, size: CollPreview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = CollPreview.indexPathForItem(at: visiblePoint)
        currentindex = visibleIndexPath!.row
        let cell = CollPreview.cellForItem(at: visibleIndexPath!) as? CellPreview
        
        let editImageobj = self.storyboard?.instantiateViewController(withIdentifier: "EditImageVC") as? EditImageVC
        editImageobj?.selctedImage = (cell?.ImagePreview.image)!
        editImageobj?.completionImageEdit = {(status, imageURL) in
            if status!{
                APPDELEGATE?.jobDetailImages[self.currentindex] = imageURL!
                self.CollPreview.reloadData()
                self.CollPreview.scrollToItem(at: IndexPath (item: self.currentindex, section: 0), at: .centeredVertically, animated: false)
                //                self.CollPreview.reloadItems(at: [IndexPath (item: self.currentindex, section: 0)])
            }else{
                self.hideEditContainer()
            }
        }
        editImageobj?.modalPresentationStyle = .fullScreen
        self.present(editImageobj!, animated: false, completion: nil)
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnCloseTapped(_ sender: UIButton){
        if showPreviewAs == .fromOwnJOb{
            makeiMageDefault()
            if isEditingImage {
                isEditingImage = false
                if (self.editIMage != nil){
                    self.editIMage.removeFromParent()
                }
                self.isMarkDefault = false
                self.hideEditContainer()
                return
            }
        }
        if showPreviewAs == .fromOwnJOb{
            blockCancel!()
            presentingViewController?.dismiss(animated: true, completion: nil)
        }else{
            blockCancel!()
            presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:- Button Tapped Events
    @IBAction func btnDeleteImage(_ sender: UIButton)
    {
        let visibleRect = CGRect(origin: CollPreview.contentOffset, size: CollPreview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = CollPreview.indexPathForItem(at: visiblePoint)
        currentindex = visibleIndexPath!.row
        let currentcell = CollPreview.cellForItem(at: visibleIndexPath!) as? CellPreview
        currentcell?.player.stop()
        let nextcell = CollPreview.cellForItem(at: IndexPath (item: currentindex + 1, section: 0)) as? CellPreview
        let prevcell = CollPreview.cellForItem(at: IndexPath (item: currentindex - 1, section: 0)) as? CellPreview
        nextcell?.player.stop()
        prevcell?.player.stop()
        APPDELEGATE?.addalertTwoButtonPopup(viewcontroller: self, oprnfrom: "", message: "Are you sure you want to delete?", completion: { (status) in
            if status{
                if let imageDetail = APPDELEGATE?.jobDetailImages[self.currentindex] as? media{
                    self.UnblockUserAPI(imageID: imageDetail._id ?? "", index: self.currentindex)
                }else{
                    APPDELEGATE?.jobDetailImages.remove(at: self.currentindex)
                    self.AboutPreview()
                }
                if (self.editIMage != nil){
                    self.editIMage.removeFromParent()
                }
                self.isMarkDefault = false
                self.hideEditContainer()
                if self.currentindex == APPDELEGATE?.jobDetailImages.count{
                    self.lblPaging.text = "\(self.currentindex)/\((APPDELEGATE?.jobDetailImages.count ?? 0))"
                }else{
                    self.lblPaging.text = "\(self.currentindex + 1)/\((APPDELEGATE?.jobDetailImages.count ?? 0))"
                }
                self.CollPreview.reloadData()
            }else{
            }
        })
    }
    
    @IBAction func btnMakeDefault(_ sender: UIButton)
    {
        isMarkDefault = true
        selectedIndex = self.currentindex
        CollPreview.reloadData()
    }
    
    func makeiMageDefault(){
        if APPDELEGATE?.jobDetailImages.count ?? 0 > 0
        {
            let defaultJob = APPDELEGATE?.jobDetailImages.remove(at: self.selectedIndex)
            APPDELEGATE?.jobDetailImages.insert(defaultJob!, at: 0)
            CollPreview.reloadData()
        }
        if APPDELEGATE?.jobDetailImages.count ?? 0 > 0{
            if let imageDetail = APPDELEGATE?.jobDetailImages[0] as? media{
                self.makeImageDefaultAPiCall(imageID: imageDetail._id!)
            }
        }
    }
    
    func AboutPreview(){
        if APPDELEGATE?.jobDetailImages.count == 0{
            if showPreviewAs == .fromOwnJOb{
                makeiMageDefault()
                if isEditingImage {
                    isEditingImage = false
                    if (self.editIMage != nil){
                        self.editIMage.removeFromParent()
                    }
                    self.isMarkDefault = false
                    self.hideEditContainer()
                    return
                }
            }
            if showPreviewAs == .fromOwnJOb{
                blockCancel!()
                presentingViewController?.dismiss(animated: true, completion: nil)
            }else{
                blockCancel!()
                presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }

    //MARK:- MakeDefaultAPI CALL
    func makeImageDefaultAPiCall(imageID: String)
    {
        let params = ["job_id":"\(jobID)","image_id":"\(imageID)", "is_default_status": "1","loginuser_id": "\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")"]

        WebService.Request.patch(url: updateDefaultImage, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
            }
        }
    }

    //MARK:- DeleteImage
    func UnblockUserAPI(imageID:String,index:NSInteger)
    {
        let params = ["job_image_ids": "\(imageID)"]
        WebService.Request.patch(url: deleteJobImages, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true
                {
                    let dataresponse = response!["data"] as? [[String:Any]]
                    if dataresponse != nil
                    {
                        APPDELEGATE?.jobDetailImages.remove(at: self.currentindex)
                        self.lblPaging.text = "\(self.currentindex)/\(APPDELEGATE?.jobDetailImages.count ?? 0)"
                        if APPDELEGATE?.jobDetailImages.count == 0{
                            if self.fromEdit == "camera"{
                                self.dismiss(animated: true, completion: nil)
                            }else if APPDELEGATE?.jobDetailImages.count == 0{
                                let viewControllers = self.navigationController!.viewControllers
                                for aViewController in viewControllers
                                {
                                    if aViewController is JobDetailsVC
                                    {
                                        let aVC = aViewController as! JobDetailsVC
                                        aVC.selectedMediaImages = self.arrPreview
                                        // aVC.jobList?.media = arrImages ?? []
                                        _ = self.navigationController?.popToViewController(aVC, animated: true)
                                    }else if aViewController is LetsGetWorkVC{
                                        let aVC = aViewController as! LetsGetWorkVC
                                        aVC.selectedMediaImages = self.arrPreview
                                        _ = self.navigationController?.popToViewController(aVC, animated: true)
                                    }
                                }
                                return
                            }
                        }
                        self.CollPreview.reloadData()
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
    
    func displayEditContainer(withType: NSInteger){
        viewContainerEdit.isHidden = false
        btnPencil.isHidden = true
        btnText.isHidden = true
        let visibleRect = CGRect(origin: self.CollPreview.contentOffset, size: self.CollPreview.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        let visibleIndexPath = self.CollPreview.indexPathForItem(at: visiblePoint)
        self.currentindex = visibleIndexPath!.row
        let cell = self.CollPreview.cellForItem(at: visibleIndexPath!) as? CellPreview

        if __CGSizeEqualToSize(cell?.ImagePreview.image?.size ?? CGSize.zero, CGSize.zero){
            viewContainerEdit.isHidden = true
            btnPencil.isHidden = false
            btnText.isHidden = false
            self.isEditingImage = false
            self.alertOk(title: "", message: "Image not found")
            return
        }
        setContiner(VC: "EditImageVC", parent: self, container: self.viewContainerEdit, newController: { (VC) in
            guard let editImageVC = VC as? EditImageVC else { return }
            self.editIMage = editImageVC

            self.editIMage.selctedImage = (cell?.ImagePreview.image)!
            self.editIMage.selectionType = withType
            self.editIMage.completionImageEdit = {(status, imageURL) in
                if status!{
                    if (self.editIMage != nil){
                        self.editIMage.removeFromParent()
                    }

                    if self.isMarkDefault{
                        APPDELEGATE?.jobDetailImages[0] = imageURL!

                        self.CollPreview.reloadData()
                        self.CollPreview.scrollToItem(at: IndexPath (item: 0, section: 0), at: .centeredVertically, animated: false)
                    }else{
                        APPDELEGATE?.jobDetailImages[self.currentindex] = imageURL!
                        self.CollPreview.reloadData()
                        self.CollPreview.scrollToItem(at: IndexPath (item: self.currentindex, section: 0), at: .centeredVertically, animated: false)
                    }
                    self.isMarkDefault = false
                    self.hideEditContainer()
                }else{
                    if self.isMarkDefault{
                        self.makeiMageDefault()
                    }
                    if (self.editIMage != nil){
                        self.editIMage.removeFromParent()
                    }
                    self.isMarkDefault = false
                    self.hideEditContainer()
                }
                self.isEditingImage = false
            }
        })
    }
    
    func hideEditContainer(){
        viewContainerEdit.isHidden = true
        btnPencil.isHidden = false
        btnText.isHidden = false
    }
    
    @IBAction func btnPencil(sender: UIButton) {
        isEditingImage = true
        isMarkDefault = false
        displayEditContainer(withType: 1)
    }
    
    @IBAction func btnText(sender: UIButton) {
        isEditingImage = true
        isMarkDefault = false
        displayEditContainer(withType: 2)
    }
    
    func hideShowButtons(isHidden: Bool){
        btndelete.isHidden = isHidden
        self.btnEdit.isHidden = isHidden
        self.btnMakeDefault.isHidden = isHidden
        self.btnPencil.isHidden = isHidden
        self.btnText.isHidden = isHidden
    }
}

extension PreviewVC: UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout
{
    //MARK:- Collectionview Delegate & Data Source
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return APPDELEGATE?.jobDetailImages.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellPreview", for: indexPath) as! CellPreview
        cell.ImagePreview.isHidden = false
        cell.ViewSlider.isHidden = true
        if indexPath.row == selectedIndex{
            btnMakeDefault.setTitle("Main Photo", for: .normal)
        }else{
            btnMakeDefault.setTitle("Make Default", for: .normal)
        }

        if let imageDetail = APPDELEGATE?.jobDetailImages[indexPath.row] as? media{
            if (imageDetail.media_url?.contains(".mp4"))! || (imageDetail.media_url?.contains(".mov"))!{
                cell.ImagePreview.isHidden = true
                cell.ViewSlider.isHidden = false
                let imgURL = URL(string: imageDetail.media_url ?? "")
                cell.player.url = imgURL
                cell.player.playerDelegate = self
                cell.player.playbackDelegate = self
                cell.player.volume = 1.0
                cell.ViewSlider.addSubview(cell.player.view)
                if indexPath.row == 0 && isFirstTime{
                    cell.player.playFromBeginning()
                }
                cell.player.playbackLoops = false
                playBackgroundAudio()
            }else{
                cell.player.stop()
                let imgURL = URL(string: imageDetail.media_url ?? "")
                cell.ImagePreview.kf.setImage(with: imgURL, placeholder: nil)
            }
        }else if let mediaURL = APPDELEGATE?.jobDetailImages[indexPath.row] as? URL{
            if mediaURL.absoluteString.contains(".mp4") || mediaURL.absoluteString.contains(".mov"){
                cell.ImagePreview.isHidden = true
                cell.ViewSlider.isHidden = false
                cell.player.url = mediaURL
                cell.player.volume = 1.0
                cell.player.playerDelegate = self
                cell.player.playbackDelegate = self
                cell.ViewSlider.addSubview(cell.player.view)
                if indexPath.row == 0 && isFirstTime{
                    cell.player.playFromBeginning()
                }
                cell.player.playbackLoops = false
                playBackgroundAudio()
            }else{
                cell.ImagePreview.image = UIImage(contentsOfFile: mediaURL.path)
                cell.player.stop()
            }
        }else if let image = APPDELEGATE?.jobDetailImages[indexPath.row] as? UIImage{
            cell.ImagePreview.image = image
            cell.player.stop()
        }
        return cell
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isFirstTime = false
        var visibleRect = CGRect()
        visibleRect.origin = self.CollPreview.contentOffset
        visibleRect.size = self.CollPreview.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = self.CollPreview.indexPathForItem(at: visiblePoint) else { return }
        currentindex = indexPath.row
        
        let currentcell = CollPreview.cellForItem(at: indexPath) as? CellPreview
        currentcell?.player.stop()
        let nextcell = CollPreview.cellForItem(at: IndexPath (item: currentindex + 1, section: 0)) as? CellPreview
        let prevcell = CollPreview.cellForItem(at: IndexPath (item: currentindex - 1, section: 0)) as? CellPreview
        nextcell?.player.stop()
        prevcell?.player.stop()
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
    {
        var visibleRect = CGRect()
        visibleRect.origin = self.CollPreview.contentOffset
        visibleRect.size = self.CollPreview.bounds.size
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        guard let indexPath = self.CollPreview.indexPathForItem(at: visiblePoint) else { return }
        let cell = self.CollPreview.cellForItem(at: indexPath) as! CellPreview
        cell.player.stop()
        //CollPreview.reloadItems(at: [indexPath])
        self.DonwloadIndex = indexPath.row
        self.lblPaging.text = "\(indexPath.row + 1)/\(APPDELEGATE?.jobDetailImages.count ?? 0)"
        currentindex = indexPath.row
        let nextcell = CollPreview.cellForItem(at: IndexPath (item: currentindex + 1, section: 0)) as? CellPreview
        let prevcell = CollPreview.cellForItem(at: IndexPath (item: currentindex - 1, section: 0)) as? CellPreview
        let currentcell = CollPreview.cellForItem(at: IndexPath (item: currentindex, section: 0)) as? CellPreview
        nextcell?.player.stop()
        prevcell?.player.stop()

        if let imageDetail = APPDELEGATE?.jobDetailImages[currentindex] as? media{
            if (imageDetail.media_url?.contains(".mp4"))! || (imageDetail.media_url?.contains(".mov"))!{
                currentcell?.player.playFromBeginning()
            }
        }else if let mediaURL = APPDELEGATE?.jobDetailImages[currentindex] as? URL{
            if (mediaURL.absoluteString.contains(".mp4")) || (mediaURL.absoluteString.contains(".mov")){
                currentcell?.player.playFromBeginning()
            }
        }
        

        checkMediaType()
        if indexPath.row == selectedIndex{
            btnMakeDefault.setTitle("Main Photo", for: .normal)
        }else{
            btnMakeDefault.setTitle("Make Default", for: .normal)
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
//        return CollPreview.frame.size
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    func playBackgroundAudio()  {
        do {
            if #available(iOS 10.0, *) {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: .default, options: [])
            } else {
            }
        } catch let error as NSError {
            print(error)
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let error as NSError {
            print(error)
        }

    }
}

extension PreviewVC: PlayerDelegate
{
    func playerReady(_ player: Player)
    {
        print("\(#function) ready")
    }
    
    func playerPlaybackStateDidChange(_ player: Player)
    {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player)
    {
        
    }
    
    func playerBufferTimeDidChange(_ bufferTime: Double)
    {
        
    }
    
    func player(_ player: Player, didFailWithError error: Error?)
    {
        print("\(#function) error.description")
    }
}

extension PreviewVC: PlayerPlaybackDelegate
{
    func playerCurrentTimeDidChange(_ player: Player)
    {
        
    }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player)
    {
        
    }
    
    func playerPlaybackDidEnd(_ player: Player)
    {
        
    }
    
    func playerPlaybackWillLoop(_ player: Player)
    {
        
    }
}
