
import UIKit
import Lightbox
import Speech
import IQKeyboardManagerSwift
import Photos

class LetsGetWorkVC: UIViewController,UITextViewDelegate {

    @IBOutlet weak var imgCategory: UIImageView!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var viewNavigate: UIView!
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var heighttextview: NSLayoutConstraint!//130
    @IBOutlet weak var btnSpeech: UIButton!
    @IBOutlet weak var btnselectImages: UIButton!
    @IBOutlet weak var topHideImage: NSLayoutConstraint!//188
    @IBOutlet weak var imgSpeech: UIImageView!
    @IBOutlet weak var btnAddJobImage: UIButton!

    var categoryData = [String: Any]()
    var selectedMediaImages = [Any]()
    var isSaved = false
    let pulsator = Pulsator()
    var isDictionRecord = false
    var assets = [PHAsset]()
    var isJobCreated = false

    //For Speech To Text
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    let audioEngine = AVAudioEngine()
    var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))  //1

    var strDescr = String()
    
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        APPDELEGATE?.isfromChat()
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.disabledToolbarClasses = [LetsGetWorkVC.self]
        NotificationCenter.default.addObserver(self, selector: #selector(self.loginSuccess(_:)), name: NSNotification.Name(rawValue: "loginsuccess"), object: nil)
        lblDescription.tintColor = UIColor (red: 70.0/255.0, green: 78.0/255.0, blue: 89.0/255.0, alpha: 1.0)

        onLoadOperations()
        initilizeSpeechtotext()
//        APPDELEGATE?.SelectedLocationAddress = APPDELEGATE?.CurrentLocationAddress ?? ""
//        APPDELEGATE?.SelectedLocationLat = APPDELEGATE?.CurrentLocationLat ?? 0.0
//        APPDELEGATE?.SelectedLocationLong = APPDELEGATE?.CurrentLocationLong ?? 0.0
        lblLocation.text = "\(APPDELEGATE?.CurrentLocationAddress ?? "")"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        if (APPDELEGATE?.jobDetailImages.count)! > 0{
            if ((APPDELEGATE?.jobDetailImages[0] as? UIImage) != nil){
                imgCategory.image = APPDELEGATE?.jobDetailImages[0] as? UIImage
            }else if let mediaURL = APPDELEGATE?.jobDetailImages[0] as? URL{
                if (mediaURL.absoluteString.contains(".mp4")) || (mediaURL.absoluteString.contains(".mov")){
                    let path = selectedMediaImages[0] as? URL
                    //                    DispatchQueue.global(qos: .background).async {
                    self.imgCategory.image = previewImageForLocalVideo(url:path!)
                }else{
                    self.imgCategory.image = UIImage(contentsOfFile: mediaURL.path )
                }
            }
            btnselectImages.isHidden = false
        }else{
            imgCategory.image = UIImage (named: "placeholder.jpg")
            btnselectImages.isHidden = true
        }
        lblLocation.text = "\(APPDELEGATE?.SelectedLocationAddress ?? "")"
    }
    
    @objc func loginSuccess(_ notification: NSNotification) {
    }

    func onLoadOperations() {
        let rectShape = CAShapeLayer()
        rectShape.bounds = self.viewNavigate.frame
        rectShape.position = self.viewNavigate.center
        var frame = CGRect (x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: self.viewNavigate.bounds.size.height)
        rectShape.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.bottomLeft , .bottomRight], cornerRadii: CGSize(width: 20, height: 20)).cgPath
        self.viewNavigate.layer.mask = rectShape
        let rectShape1 = CAShapeLayer()
        rectShape1.bounds = self.viewBottom.frame
        rectShape1.position = self.viewBottom.center
        frame = CGRect (x: 0, y: self.viewBottom.bounds.origin.y, width: UIScreen.main.bounds.size.width, height: self.viewBottom.bounds.size.height)
        rectShape1.path = UIBezierPath(roundedRect: frame, byRoundingCorners: [.topLeft , .topRight], cornerRadii: CGSize(width: 19, height: 19)).cgPath
        self.viewBottom.layer.mask = rectShape1

        lblDescription.text = APPDELEGATE?.LetsGetWork_PlaceHolder
    }
    
    //MARK :- Button Actions
    
    @IBAction func btnLetsFixProblemAction(_ sender: UIButton) {
        if isJobCreated{
            return
        }
        if lblDescription.text == APPDELEGATE?.LetsGetWork_PlaceHolder || lblDescription.text == ""{
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please Write a problem.")
            //alertOk(title: "", message: "Please Write a problem.")
            return
        }else if lblLocation.text == ""{
            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"Please select a location.")
            //alertOk(title: "", message: "Please select a location.")
            return
        }
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "job_id":"","service_id":"\(categoryData["_id"] as? String ?? "")","address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","longitude":"\(APPDELEGATE?.SelectedLocationLong ?? 0.00)" ,"description":"\(self.lblDescription.text!)","is_emergency_job":"\(APPDELEGATE?.is_Emergency ?? "0")","city":"\(APPDELEGATE!.SelectedLocationCity)"]

        if APPDELEGATE?.uerdetail?.user_id == "" || APPDELEGATE?.uerdetail?.user_id == nil{
            APPDELEGATE?.addLoginSubview(viewcontroller:self, oprnfrom: "jobcreate", data: params, image: APPDELEGATE!.jobDetailImages)
            isJobCreated = false
            return
        }
        if (APPDELEGATE?.jobDetailImages.count)! > 0{
            isJobCreated = true
            CreateJOb()
        }else{
            isJobCreated = true
            CreateJObwithouImage()
        }
    }
    
    @IBAction func btnAddmore(_ sender: UIButton) {
        if (APPDELEGATE?.jobDetailImages.count)! > 0 {
            let objCustomiseProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "PreviewVC") as! PreviewVC
            objCustomiseProfileVC.arrImages = []
            objCustomiseProfileVC.arrPreview = APPDELEGATE!.jobDetailImages
            objCustomiseProfileVC.OpenFrom = "CreateJob"
            objCustomiseProfileVC.jobID = ""
            objCustomiseProfileVC.fromEdit = "yes"
            objCustomiseProfileVC.showPreviewAs = .fromOwnJOb
            objCustomiseProfileVC.blockCancel = {
            }
            objCustomiseProfileVC.modalPresentationStyle = .fullScreen
            self.present(objCustomiseProfileVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func btnAddJobImgAction(_ sender: UIButton){
        showCamera()
    }
    
    @IBAction func btntouchStarted(_ sender: UIButton) {
    }
    
    @IBAction func btnToiuchEnded(_ sender: UIButton) {
        if audioEngine.isRunning{
            pulsator.removeFromSuperlayer()
            audioEngine.stop()
            recognitionRequest?.endAudio()
        }
        else{
            if self.lblDescription.text == APPDELEGATE?.LetsGetWork_PlaceHolder
            {
                self.lblDescription.text = ""
            }
            else
            {
                self.strDescr = self.lblDescription.text
            }
            self.view.endEditing(true)
            startRecording()
            initPulse()
        }
    }
    
    @IBAction func btnBackAction(_ sender: UIButton) {
        var assetlist = [PHAsset]()
        for item in assets{
            if (item.creationDate?.minutes(from: Date()))! <= (APPDELEGATE?.deleteImageTimerCounter ?? 0/60) {
                assetlist.append(item)
            }
        }
        if assetlist.count > 0{
            APPDELEGATE?.deletePhoto(assets: assetlist)
        }
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMapAction(_ sender: UIButton) {
        let location = self.storyboard?.instantiateViewController(withIdentifier: "LocationSearchViewController") as? LocationSearchViewController
        location?.selectedLoc = lblLocation.text ?? ""
        self.navigationController?.pushViewController(location!, animated: false)
    }
    
    //Textview DElegate
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if lblDescription.text == APPDELEGATE?.LetsGetWork_PlaceHolder{
            lblDescription.text = ""
            self.lblDescription.autocorrectionType = .yes
            
            if UIDevice.current.screenType == .iPhones_5_5s_5c_SE || UIDevice.current.screenType == .iPhones_4_4S{
                IQKeyboardManager.shared.enable = true
            }else{
                IQKeyboardManager.shared.enable = false
            }
            
            if audioEngine.isRunning
            {
                pulsator.removeFromSuperlayer()
                audioEngine.stop()
                recognitionRequest?.endAudio()
            }
        }
        else
        {
            if audioEngine.isRunning
            {
                pulsator.removeFromSuperlayer()
                audioEngine.stop()
                recognitionRequest?.endAudio()
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if lblDescription.text == ""{
            lblDescription.text = APPDELEGATE?.LetsGetWork_PlaceHolder
        }
        else
        {
            self.strDescr = self.lblDescription.text
        }
        IQKeyboardManager.shared.enable = false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

//MARK:- APi call
extension LetsGetWorkVC{
    func CreateJOb()
    {
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        
        if APPDELEGATE!.SelectedLocationCity == "" || APPDELEGATE!.SelectedLocationCity.count == 0{
            APPDELEGATE!.SelectedLocationCity = APPDELEGATE?.city ?? ""
        }
        
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "job_id":"","service_id":"\(categoryData["_id"] as? String ?? "")","address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","longitude":"\(APPDELEGATE?.SelectedLocationLong ?? 0.00)" ,"description":"\(self.lblDescription.text!)","is_emergency_job":"\(APPDELEGATE?.is_Emergency ?? "0")","job_created_date":"\(job_created_date)","city":"\(APPDELEGATE!.SelectedLocationCity)"]
        
        var intCount = 0
        var isVideo = false
        appDelegate.addProgressView()
        for i in 0..<(APPDELEGATE?.jobDetailImages.count)!{
            if let strimage = APPDELEGATE?.jobDetailImages[i] as? URL{
                if (strimage.absoluteString.contains(".mp4")) || (strimage.absoluteString.contains(".mov")){
                    var movieData: Data?
                    intCount += 1
                    isVideo = true
                    do {
                        movieData = try Data(contentsOf: strimage, options: Data.ReadingOptions.alwaysMapped)
                        let compressedURL = NSURL.fileURL(withPath: NSTemporaryDirectory() + NSUUID().uuidString + ".mp4")
                        APPDELEGATE?.jobDetailImages[i] = compressedURL
                        compressVideo(inputURL: (strimage), outputURL: compressedURL) { (session) in
                            intCount -= 1
                            switch session!.status {
                            case .unknown:
                                break
                            case .waiting:
                                break
                            case .exporting:
                                break
                            case .completed:

                                let data = NSData(contentsOf: compressedURL)
                                print("File size after compression: \(Double(data!.length / 1048576)) mb")
                            case .failed:
                                break
                            case .cancelled:
                                break
                            }
                            if intCount == 0{
                                self.uploadData(params: params)
                            }
                        }
                    }catch{}
                }
            }
        }
        if !isVideo{
            self.uploadData(params: params)
        }
    }
    
    func uploadData(params: [String: String]) {
        WebService.Request.uploadMultipleFiles(url: createJob, images : APPDELEGATE!.jobDetailImages, parameters:params, isDefaultImage: true, isBackgroundPerform:false, headerForAPICall : ["Content-type": "multipart/form-data"]){ (response, error) in
            if error == nil {
                print(response!)
                if response!["status"] as? Bool == true {
                    var assetlist = [PHAsset]()
                    for item in self.assets{
                        if (item.creationDate?.minutes(from: Date()))! <= (APPDELEGATE?.deleteImageTimerCounter ?? 0/60) {
                            assetlist.append(item)
                        }
                    }
                    if assetlist.count > 0{
                        APPDELEGATE?.deletePhoto(assets: assetlist)
                    }
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "job", message:"\(response?["msg"] as? String ?? "")")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                }
                
            }
        }
    }
    
    func CreateJObwithouImage()
    {
        let Curr_date = Date()
        let job_created_date = DateTime.toString("yyyy-MM-dd HH:mm", date: Curr_date)
        
        let params = ["user_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")","loginuser_id":"\(APPDELEGATE?.uerdetail?.user_id ?? "")", "session_token": "\(APPDELEGATE?.uerdetail?.session_token ?? "")", "job_id":"","service_id":"\(categoryData["_id"] as? String ?? "")","address":"\(APPDELEGATE?.SelectedLocationAddress ?? "")","latitude":"\(APPDELEGATE?.SelectedLocationLat ?? 0.00)","longitude":"\(APPDELEGATE?.SelectedLocationLong ?? 0.00)" ,"description":"\(self.lblDescription.text!)","is_emergency_job":"\(APPDELEGATE?.is_Emergency ?? "0")","job_created_date":"\(job_created_date)","city":"\(APPDELEGATE!.SelectedLocationCity)"]
        
        WebService.Request.patch(url: createJob, type: .post, parameter: params, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                
                if response!["status"] as? Bool == true {
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "job", message:"\(response?["msg"] as? String ?? "")")
                }else{
                    APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "", message:"\(response?["msg"] as? String ?? "")")
                }
            }
        }
    }
}


//Speech to Text

extension LetsGetWorkVC:SFSpeechRecognizerDelegate{
    func initilizeSpeechtotext()
    {
        speechRecognizer!.delegate = self  //3

        var isButtonEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authStatus) in  //4
            
            switch authStatus {  //5
            case .authorized:
                isButtonEnabled = true
            case .denied:
                isButtonEnabled = false
                print("User denied access to speech recognition")
            case .restricted:
                isButtonEnabled = false
                print("Speech recognition restricted on this device")
            case .notDetermined:
                isButtonEnabled = false
                print("Speech recognition not yet authorized")
            }
        }
    }
    
    func startRecording()
    {
        if recognitionTask != nil
        {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()
        do
        {
            if #available(iOS 12.0, *) {
                try audioSession.setCategory(.record, mode: .voicePrompt)
            } else {
                // Fallback on earlier versions
            }
            try audioSession.setMode(.measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch
        {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
                
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else
        {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionTask = self.speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            
            var isFinal = false
            if result != nil
            {
                
                self.lblDescription.text = "\(self.strDescr) \(result?.bestTranscription.formattedString ?? "")"
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal
            {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        do
        {
            try audioEngine.start()
        }
        catch
        {
            print("audioEngine couldn't start because of an error.")
        }
        
    }

    func initPulse(){
        imgSpeech.layer.superlayer?.insertSublayer(pulsator, below: imgSpeech.layer)
        setupInitialValues()
        pulsator.start()
    }
    
    override func viewDidLayoutSubviews(){
        self.view.layer.layoutIfNeeded()
        pulsator.position = imgSpeech.layer.position
    }
    
    private func setupInitialValues() {
        pulsator.numPulse = Int(3)
        
        pulsator.radius = 0.7 * kMaxRadius
        
        pulsator.animationDuration = 0.5 * kMaxDuration
        
        pulsator.backgroundColor = UIColor (red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5).cgColor
    }

    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
    }
}

extension LetsGetWorkVC {
    func showCamera(){
        if APPDELEGATE?.jobDetailImages.count ?? 0 >= 20{
            alertOk(title: "", message: "Only 20 media allowed for a post.")
            return
        }
        let objCamera = self.storyboard?.instantiateViewController(withIdentifier: "CameraVC") as? CameraVC
        objCamera?.imageSelectionLimit = 20 - (APPDELEGATE?.jobDetailImages.count ?? 0)
        objCamera?.blockCancel = { status in
            if status{
            }
        }
        objCamera?.modalPresentationStyle = .fullScreen
        self.present(objCamera!, animated: true, completion: nil)
    }
}
