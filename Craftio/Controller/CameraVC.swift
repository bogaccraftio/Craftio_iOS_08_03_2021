
import UIKit
import Photos

class CameraVC: SwiftyCamViewController, SwiftyCamViewControllerDelegate {
    @IBOutlet weak var captureButton: SwiftyRecordButton!
    @IBOutlet weak var flashButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var stackView: CustomeStackView!
    @IBOutlet weak var collectionImages: UICollectionView!
    @IBOutlet var slideUpView: UIView!
    @IBOutlet var heightSlideUp: NSLayoutConstraint!
    @IBOutlet var viewAccesories: UIView!
    @IBOutlet var lblSnapIt: UILabel!
    @IBOutlet var btnDone: UIButton!
    @IBOutlet var lblVideoCounter: UILabel!
    @IBOutlet var overlayCamera: UIView!
    
    var initialTouchPoint: CGPoint = CGPoint(x: 0,y: 0)
    var isVideo = false
    var configuration = Configuration()
    var assetsa = [Any]()
    var selectedAssets = [Any]()
    var isOpen = false
    var margin = CGFloat()
    var topMargin = CGFloat()
    var blockSelectedMedia: (([Any]) -> ())!
    var blockCancel: ((Bool) -> ())!
    var timer = Timer()
    var imageSelectionLimit = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        videoCounter(isHidden: true)
        self.view.isUserInteractionEnabled = false
        shouldPrompToAppSettings = true
        cameraDelegate = self
        
        maximumVideoDuration = 20.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = false
        audioEnabled = true
        flashMode = .auto
        flashButton.setImage(#imageLiteral(resourceName: "AUTO"), for: UIControl.State())
        captureButton.buttonEnabled = false
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandle(gesture:)))
        slideUpView.addGestureRecognizer(gesture)
        gesture.delegate = self

        fetchPhotos { (assets) in
            self.assetsa = assets
            self.collectionImages.reloadData()
            self.showSnapItLabel()
            self.stackView.reloadViews(images: self.selectedAssets)
            print(self.assetsa.count)
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
    }
    
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
        self.view.isUserInteractionEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
        self.view.isUserInteractionEnabled = true
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        if self.selectedAssets.count >= self.imageSelectionLimit{
            alertOk(title: "", message: "Only 20 media allowed for a post.")
            return
        }
        assetsa.insert(photo, at: 0)
        self.selectedAssets.append(photo)
        self.stackView.reloadViews(images: self.selectedAssets)
        collectionImages.reloadData()
        showSnapItLabel()
    }
    
    func showSnapItLabel(){
        if self.selectedAssets.count > 0{
            btnDone.setTitle("DONE", for: .normal)
            self.lblSnapIt.isHidden = true
        }else{
            btnDone.setTitle("SKIP", for: .normal)
            self.lblSnapIt.isHidden = false
        }
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        videoCounter(isHidden: false)
        captureButton.growButton()
        hideButtons()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        videoCounter(isHidden: true)
        captureButton.shrinkButton()
        showButtons()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        if self.selectedAssets.count >= self.imageSelectionLimit{
            alertOk(title: "", message: "Only 20 media allowed for a post.")
            return
        }
        self.assetsa.insert(url, at: 0)
        self.selectedAssets.append(url)
        self.stackView.reloadViews(images: self.selectedAssets)
        collectionImages.reloadData()
        showSnapItLabel()
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera did change to \(camera.rawValue)")
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }
    
    func getURL(ofPhotoWith mPhasset: PHAsset, completionHandler : @escaping ((_ responseURL : URL?) -> Void)) {
        
        if mPhasset.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            mPhasset.requestContentEditingInput(with: options, completionHandler: { (contentEditingInput, info) in
                completionHandler(contentEditingInput!.fullSizeImageURL)
            })
        } else if mPhasset.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl = urlAsset.url
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
        
    }

    
    @IBAction func doneTapped(_ sender: Any) {
        APPDELEGATE?.addProgressView()
        if selectedAssets.count > 0{
            var itemNo = 0
            for i in 0..<selectedAssets.count{
                let item = selectedAssets[i]
                if ((item as? PHAsset) != nil){
                    getAssetsURL(asset: item as! PHAsset) { (assetURL) in
                        itemNo += 1
                        APPDELEGATE?.jobDetailImages.append(assetURL)
                        if itemNo == self.selectedAssets.count{
                            self.dismissViewController(status: true)
                        }
                    }
                }else if ((item as? URL) != nil){
                    itemNo += 1
                    APPDELEGATE?.jobDetailImages.append(item)
                    if itemNo == self.selectedAssets.count{
                        self.dismissViewController(status: true)
                    }
                }else if ((item as? UIImage) != nil){
                    itemNo += 1
                    APPDELEGATE?.jobDetailImages.append(item)
                    if itemNo == self.selectedAssets.count{
                        self.dismissViewController(status: true)
                    }
                }
            }
        }else{
            self.dismissViewController(status: true)
        }
    }
    
    func dismissViewController(status: Bool){
        DispatchQueue.main.async {
            APPDELEGATE?.hideProgrssVoew()
            self.blockCancel!(status)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }
    
    @IBAction func stackViewTapped(_ sender: Any) {
        if selectedAssets.count > 0{
            var itemNo = 0
            for i in 0..<selectedAssets.count{
                let item = selectedAssets[i]
                if ((item as? PHAsset) != nil){
                    getAssetsURL(asset: item as! PHAsset) { (assetURL) in
                        itemNo += 1
                        APPDELEGATE?.jobDetailImages.append(assetURL)
                        if itemNo == self.selectedAssets.count{
                            self.redirectToPreview()
                        }
                    }
                }else if ((item as? URL) != nil){
                    itemNo += 1
                    APPDELEGATE?.jobDetailImages.append(item)
                    if itemNo == self.selectedAssets.count{
                        self.redirectToPreview()
                    }
                }else if ((item as? UIImage) != nil){
                    itemNo += 1
                    APPDELEGATE?.jobDetailImages.append(item)
                    if itemNo == self.selectedAssets.count{
                        self.redirectToPreview()
                    }
                }
            }
        }
    }
    
    func redirectToPreview() {
        DispatchQueue.main.async {
            let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            objCustomiseProfileVC.arrImages = []
            objCustomiseProfileVC.arrPreview = self.selectedAssets
            objCustomiseProfileVC.OpenFrom = "CreateJob"
            objCustomiseProfileVC.jobID = ""
            objCustomiseProfileVC.fromEdit = "yes"
            objCustomiseProfileVC.showPreviewAs = .fromOwnJOb
            objCustomiseProfileVC.blockCancel = {
                self.dismissViewController(status: true)
            }
            objCustomiseProfileVC.modalPresentationStyle = .fullScreen
            self.present(objCustomiseProfileVC, animated: true, completion: nil)
        }
    }

    private func getAssetsURL(asset: PHAsset, completion: @escaping (URL) -> ()) {
        var updatedIndex = index
        AssetManager.requestURL(asset) { (url) in
            if let url = url {
                completion(url)
            }
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        self.dismissViewController(status: false)
    }
    
    @IBAction func mediaTypeTapped(_ sender: Any) {
        if isVideo{
            self.videoCounter(isHidden: true)
            self.stopVideoRecording()
            isVideo = false
            isVideoRecordingStart = false
            isCaptureImage = false
            videoButton.setImage(#imageLiteral(resourceName: "video"), for: .normal)
            captureButton.shrinkButton()
            showButtons()
        }else{
            videoCounter(isHidden: true)
            isVideo = true
            isVideoRecordingStart = true
            isCaptureImage = true
            videoButton.setImage(#imageLiteral(resourceName: "photo-camera"), for: .normal)
        }
    }
    
    func videoCounter(isHidden: Bool) {
        lblVideoCounter.isHidden = isHidden
        if isHidden{
            timer.invalidate()
        }else{
            var timeCount:NSInteger = NSInteger(maximumVideoDuration)
            self.lblVideoCounter.text = "00:00:\(timeCount)"
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timerVal) in
                timeCount -= 1
                if timeCount == 0{
                    self.videoCounter(isHidden: true)
                    self.stopVideoRecording()
                }
                if timeCount >= 10{
                   self.lblVideoCounter.text = "00:00:\(timeCount)"
                }else{
                    self.lblVideoCounter.text = "00:00:0\(timeCount)"
                }
            })
        }
    }

    @objc func panGestureHandle(gesture: UIPanGestureRecognizer) {
        let touchPoint = gesture.location(in: self.view?.window)
        if gesture.state == UIGestureRecognizer.State.began {
            isOpen = true
            initialTouchPoint = touchPoint
        }
        else if gesture.state == UIGestureRecognizer.State.changed {
            if touchPoint.y < (self.view.frame.size.height - self.heightSlideUp.constant) + 50 {
                if UIDevice.current.screenType == .iPhone_XR || UIDevice.current.screenType == .iPhones_X_XS {
                    self.margin = 105
                    self.topMargin = 135
                } else {
                    self.margin = 50
                    self.topMargin = 100
                }
                if self.heightSlideUp.constant < ((self.view.frame.size.height - self.viewAccesories.frame.maxY) - self.topMargin) && self.heightSlideUp.constant >= 50 {
                    self.heightSlideUp.constant = ((self.view.frame.size.height - touchPoint.y) - self.margin)
                    self.view.layoutIfNeeded()
                }
                if initialTouchPoint.y < touchPoint.y &&
                    self.heightSlideUp.constant != 50 {
                    if self.heightSlideUp.constant >= 50 {
                        self.heightSlideUp.constant = ((self.view.frame.size.height - touchPoint.y) - self.margin)
                        self.view.layoutIfNeeded()
                    }
                }
            }
        }
        else if gesture.state == UIGestureRecognizer.State.ended || gesture.state == UIGestureRecognizer.State.cancelled {
            if (initialTouchPoint.y - touchPoint.y) > 10  {
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightSlideUp.constant = ((self.view.frame.size.height - self.viewAccesories.frame.maxY) - self.topMargin)
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightSlideUp.constant = 50
                    self.view.layoutIfNeeded()
                })
            }
            if (initialTouchPoint.y - touchPoint.y) < -10 {
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightSlideUp.constant = 50
                    self.view.layoutIfNeeded()
                })
            } else {
                UIView.animate(withDuration: 0.3, animations: {
                    self.heightSlideUp.constant = ((self.view.frame.size.height - self.viewAccesories.frame.maxY) - self.topMargin)
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
}

// UI Animations
extension CameraVC {
    
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "Line"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto {
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "ON"), for: UIControl.State())
        }else if flashMode == .on {
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "OFF"), for: UIControl.State())
        }else if flashMode == .off {
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "AUTO"), for: UIControl.State())
        }
    }
}

extension CameraVC {
    func fetchPhotos(_ completion: (([PHAsset]) -> ())? = nil) {
        configuration.maxVideoInterval = 20
        configuration.fetchType = .all
        AssetManager.getLibraryMedia(withConfiguration: configuration) { assets in
            completion?(assets)
        }
    }
}

extension CameraVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    struct CollectionView {
        static let reusableIdentifier = "imageCell"
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetsa.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionView.reusableIdentifier,
                                                      for: indexPath) as? imageCell
        
        if let image = assetsa[indexPath.row] as? UIImage {
            cell?.configureCell(img: image)
            if self.selectedAssets.contains(where: { $0 as? UIImage == image }) {
                cell?.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                cell?.selectedImageView.alpha = 1
                cell?.selectedImageView.transform = CGAffineTransform.identity
            } else {
                cell?.selectedImageView.image = nil
            }
            cell?.duration = 0
        }else if ((assetsa[indexPath.row] as? PHAsset) != nil){
            let asset = assetsa[(indexPath as NSIndexPath).row] as? PHAsset
            
            AssetManager.resolveAsset(asset!, size: CGSize(width: 160, height: 240)) { image in
                if let image = image {
                    cell?.configureCell(img: image)
                    if self.selectedAssets.contains(where: { $0 as? PHAsset == asset }) {
                        cell?.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                        cell?.selectedImageView.alpha = 1
                        cell?.selectedImageView.transform = CGAffineTransform.identity
                    } else {
                        cell?.selectedImageView.image = nil
                    }
                    cell?.duration = asset?.duration
                }
            }
        }else if let avAsset = assetsa[indexPath.row] as? URL{
            if avAsset.absoluteString.contains(".mp4") || avAsset.absoluteString.contains(".mov"){
                if let image = AssetManager.generateThumbnail(path: avAsset){
                    cell?.configureCell(img: image)
                    if self.selectedAssets.contains(where: { $0 as? URL == avAsset }) {
                        cell?.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                        cell?.selectedImageView.alpha = 1
                        cell?.selectedImageView.transform = CGAffineTransform.identity
                    } else {
                        cell?.selectedImageView.image = nil
                    }
                    let av = AVAsset (url: avAsset)
                    cell?.duration = av.duration.seconds
                }
            }
        }
        return cell!
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = CGFloat(((self.view.frame.height - 180) / 3) + 2)
        let width = CGFloat((self.collectionImages.frame.size.width / 2) - 10)
        return CGSize(width: width, height: height)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 5.0, bottom: 10.0, right: 5.0)
    }
    
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath)
            as? imageCell else { return }
        if let image = assetsa[indexPath.row] as? UIImage{
            if cell.selectedImageView.image != nil {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.selectedImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }, completion: { _ in
                    cell.selectedImageView.image = nil
                })
                self.selectedAssets.removeAll(where: { $0 as? UIImage == image })
                self.stackView.reloadViews(images: self.selectedAssets)
            } else {
                if self.selectedAssets.count >= self.imageSelectionLimit{
                    alertOk(title: "", message: "Only 20 media allowed for a post.")
                    return
                }
                cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                cell.selectedImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
                UIView.animate(withDuration: 0.2, animations: {
                    cell.selectedImageView.transform = CGAffineTransform.identity
                })
                self.selectedAssets.append(image)
                self.stackView.reloadViews(images: self.selectedAssets)
            }
            self.showSnapItLabel()
        }else if ((assetsa[indexPath.row] as? PHAsset) != nil){
            let asset = assetsa[(indexPath as NSIndexPath).row] as? PHAsset
            
            AssetManager.resolveAsset(asset!, size: CGSize(width: 100, height: 100)) { image in
                guard image != nil else { return }
                
                if cell.selectedImageView.image != nil {
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.selectedImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    }, completion: { _ in
                        cell.selectedImageView.image = nil
                    })
                    self.selectedAssets.removeAll(where: { $0 as? PHAsset == asset })
                    self.stackView.reloadViews(images: self.selectedAssets)
                } else {
                    
                    if self.selectedAssets.count >= self.imageSelectionLimit{
                        self.alertOk(title: "", message: "Only 20 media allowed for a post.")
                        return
                    }

                    cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                    cell.selectedImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.selectedImageView.transform = CGAffineTransform.identity
                    })
                    self.selectedAssets.append(asset)
                    self.stackView.reloadViews(images: self.selectedAssets)
                }
                self.showSnapItLabel()
            }
        }else if let avAsset = assetsa[indexPath.row] as? URL{
            if cell.selectedImageView.image != nil {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.selectedImageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                }, completion: { _ in
                    cell.selectedImageView.image = nil
                })
                self.selectedAssets.removeAll(where: { $0 as? URL == avAsset })
                self.stackView.reloadViews(images: self.selectedAssets)
            } else {
                if self.selectedAssets.count >= self.imageSelectionLimit{
                    alertOk(title: "", message: "Only 20 media allowed for a post.")
                    return
                }
                cell.selectedImageView.image = AssetManager.getImage("selectedImageGallery")
                cell.selectedImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
                UIView.animate(withDuration: 0.2, animations: {
                    cell.selectedImageView.transform = CGAffineTransform.identity
                })
                self.selectedAssets.append(AssetManager.generateThumbnail(path: avAsset)!)
                self.stackView.reloadViews(images: self.selectedAssets)
            }
            self.showSnapItLabel()
        }
    }
}


class imageCell: UICollectionViewCell{
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    @IBOutlet weak var videoInfoView: UIView!
    @IBOutlet weak var lblDuration: UILabel!
    private let videoInfoBarHeight: CGFloat = 15
    func configureCell(img: UIImage) {
        imgView.image = img
    }
    
    var duration: TimeInterval? {
        didSet {
            if let duration = duration, duration > 0 {
                lblDuration.text = dateFormatter.string(from: duration)
                self.videoInfoView.isHidden = false
            } else {
                self.videoInfoView.isHidden = true
            }
        }
    }
    
    private lazy var dateFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.zeroFormattingBehavior = .pad
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        return formatter
    }()
}
