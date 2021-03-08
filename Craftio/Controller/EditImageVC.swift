
import UIKit
import AssetsLibrary
import Photos

class EditImageVC: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var tempImageView: UIImageView!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnEditText: UIButton!
    @IBOutlet weak var btnEditDraw: UIButton!
    @IBOutlet weak var btnUndo: UIButton!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnSelectedTypeDone: UIButton!
    @IBOutlet weak var viewButtons: UIView!
    @IBOutlet weak var collectionColorPicker: UICollectionView!
    @IBOutlet weak var topviewButtons: NSLayoutConstraint!
    @IBOutlet weak var topPencil: NSLayoutConstraint!
    @IBOutlet weak var topText: NSLayoutConstraint!
    @IBOutlet weak var heightButtons: NSLayoutConstraint!
    
    var txtViewEdit = UITextView()
    var lastPoint = CGPoint.zero
    var arrlayer = NSMutableArray()
    var arrtextlayer = NSMutableArray()
    var shapeLayer = CAShapeLayer()
    var bazierPath = UIBezierPath()
    var isText = false
    var isDraw = false
    var numberOfLabel = 0
    var selectedLabel = 0
    var selctedImage = UIImage()
    var arrColors = [UIColor]()
    var selectedColor: UIColor = .white
    var completionImageEdit : ((Bool?,URL?)->())?
    var selectionType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if UIApplication.shared.statusBarFrame.height > 40{
            topviewButtons.constant = 0
            heightButtons.constant = 62
            topPencil.constant = 13.5
            topText.constant = 13.5
        }else{
            topviewButtons.constant = 0
            topPencil.constant = 13.5
            topText.constant = 13.5
        }
        mainImageView.image = selctedImage
        mainImageView.backgroundColor = UIColor.black
        mainImageView.frame.size = mainImageView.intrinsicContentSize
        btnSelectedTypeDone.isHidden = true
        collectionColorPicker.isHidden = true
        for _ in 0...100{
            arrColors.append(UIColor .random())
        }
        collectionColorPicker.reloadData()
        if selectionType == 1{
            editWithPencil()
        }else if selectionType == 2{
            editWithText()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }
    
    //MARK:- Buttons Event
    @IBAction func btnCancel(sender: UIButton) {
        completionImageEdit?(false, URL(string: ""))
        presentedViewController?.dismiss(animated: false, completion: nil)
    }
    
    @IBAction func btnSelectedTypeDone(sender: UIButton) {
        btnUndo.isHidden = false
        btnEditDraw.isHidden = false
        btnEditText.isHidden = false
        btnSelectedTypeDone.isHidden = true
        btnDone.isHidden = false
        collectionColorPicker.isHidden = true
        if isText{
            createsLayers(storeImage: false)
        }
        isText = false
        isDraw = false
    }
    
    func makeDefaultImage()  {
        self.view.endEditing(true)
        if isText{
            createsLayers(storeImage: true)
        }else{
            storeImageToDocumentDirectory()
        }
    }
    
    @IBAction func btndone(sender: UIButton) {
        self.view.endEditing(true)
        if isText{
            createsLayers(storeImage: true)
        }else{
            storeImageToDocumentDirectory()
        }
    }
    
    @IBAction func btnPencil(sender: UIButton) {
        if isText{
            createsLayers(storeImage: false)
        }
        isText = false
        isDraw = false
        editWithPencil()
    }
    
    func editWithPencil(){
        collectionColorPicker.isHidden = false
        isText = false
        if isDraw{
            isDraw = false
            tempImageView.isHidden = true
        }else{
            isDraw = true
            tempImageView.isHidden = false
        }
    }
    
    @IBAction func btnRemove(sender: UIButton) {
        if let lastlayer = arrlayer.lastObject as? CAShapeLayer{
            arrlayer.removeLastObject()
            lastlayer.removeFromSuperlayer()
        }else if let lastlayer = arrlayer.lastObject as? CATextLayer{
            arrlayer.removeLastObject()
            lastlayer.removeFromSuperlayer()
        }
    }
    
    @IBAction func btnText(sender: UIButton) {
        editWithText()
    }
    
    func editWithText(){
        collectionColorPicker.isHidden = false
        btnSelectedTypeDone.isHidden = false
        btnDone.isHidden = false
        isDraw = false
        if isText{
            isText = false
        }else{
            isText = true
            addTextToView()
        }
    }
}

//MARK:- Methods for Creating Layers
extension EditImageVC{
    func createsLayers(storeImage: Bool) {
        for item in arrtextlayer{
            var lbltext = UITextView()
            lbltext = item as! UITextView
            
            let attributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: lbltext.font!.pointSize),
                NSAttributedString.Key.foregroundColor: lbltext.textColor!,
                NSAttributedString.Key.backgroundColor: UIColor.clear
            ]
            let layer = CALayer()
            let imageSize = lbltext.bounds.size
            let center = lbltext.center
            
            let textLayer = CATextLayer()
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            textLayer.fontSize = 20.0
            textLayer.font = UIFont(name: "Cabin-Regular", size: 20.0)
            textLayer.isWrapped = true
            textLayer.truncationMode = CATextLayerTruncationMode.end
            textLayer.foregroundColor = lbltext.textColor?.cgColor
            textLayer.string = lbltext.text
            
            
            var yOffset = (center.y + imageSize.height / 2) / mainImageView.frame.size.height
            yOffset = 1 - yOffset // invert screen proportion
            let scaledOriginX = (center.x - imageSize.width / 2)
            let scaledOriginY = (center.y - imageSize.height / 2)
            
            let frame = CGRect(x: scaledOriginX, y: scaledOriginY + 8, width: imageSize.width , height: imageSize.height)
            textLayer.frame = frame
            //Apply transforms but to original imageView
            var transform = lbltext.transform
            textLayer.transform =  CATransform3DMakeAffineTransform(transform)
            
            textLayer.masksToBounds = true
            mainImageView.layer.addSublayer(textLayer)
            arrlayer.add(textLayer)
            lbltext.text = ""
            lbltext.removeFromSuperview()
        }
        arrtextlayer = NSMutableArray()
        numberOfLabel = 0
        print("success")
        if storeImage{
            storeImageToDocumentDirectory()
        }
    }
    
    func image(from string: String?, attributes: [AnyHashable : Any]?, size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, _: false, _: 0)
        string?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height), withAttributes: attributes as? [NSAttributedString.Key : Any])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addTextToView()  {
        let lblframe = CGRect (x: 20, y: 200, width: UIScreen.main.bounds.size.width - 40, height: 100)
        let txtDescription = UITextView (frame: lblframe)

        txtDescription.delegate = self

        txtDescription.backgroundColor = .clear
        txtDescription.tag = numberOfLabel
        txtDescription.font = UIFont( name: "Cabin-Regular", size: 20)
        txtDescription.textAlignment = .center
        txtDescription.textColor = selectedColor
        txtViewEdit = txtDescription
        self.view .addSubview(txtDescription)
        self.view.bringSubviewToFront(txtDescription)
        self.view.bringSubviewToFront(collectionColorPicker)
        self.view.bringSubviewToFront(viewButtons)
        
        numberOfLabel = numberOfLabel + 1
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.addpangesture(panGesture:)))
        txtDescription.addGestureRecognizer(panGesture)
        
        let rotate = UIRotationGestureRecognizer(target: self, action:     #selector(rotatedView(_:)))
        txtDescription.addGestureRecognizer(rotate)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action:#selector(pinchRecognized(pinch:)))
        txtDescription.addGestureRecognizer(pinchGesture)
        
        arrtextlayer.add(txtDescription)
        txtDescription.becomeFirstResponder()
    }
    
    func drawLineFromPoint(start : CGPoint, toPoint end:CGPoint, ofColor lineColor: UIColor, inView view:UIView) {

        bazierPath.move(to: start)
        bazierPath.addLine(to: end)
        
        let path = UIBezierPath()
        path.move(to: start)
        path.addLine(to: end)
        
        let shapeLayer1 = CAShapeLayer()
        shapeLayer1.path = path.cgPath
        shapeLayer1.strokeColor = lineColor.cgColor
        shapeLayer1.lineWidth = 3.0
        tempImageView.layer.addSublayer(shapeLayer1)
    }
    
    func storeImageToDocumentDirectory(){
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(arc4random()).png"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        let imgSize = imageSizeAspectFit(imgview: mainImageView)
        let renderer = UIGraphicsImageRenderer(size: mainImageView.frame.size)
        let image = renderer.image { ctx in
            mainImageView.drawHierarchy(in: mainImageView.bounds, afterScreenUpdates: true)
        }

        let rect: CGRect = CGRect(x: (UIScreen.main.bounds.size.width/2 - imgSize.width/2), y: (UIScreen.main.bounds.size.height/2 - imgSize.height/2), width: imgSize.width, height: imgSize.height)

        let img1 = image//image.cropToRect(rect: rect)
        
        if let data = img1.jpegData(compressionQuality: 1.0),
            !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
                presentedViewController?.dismiss(animated: false, completion: nil)
                completionImageEdit!(true, fileURL)
            } catch {
                print("error saving file:", error)
                completionImageEdit!(false, fileURL)
            }
        }
    }
    
    func imageResize (setimage: UIImage, sizeChange:CGSize)-> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0 // Use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        let posX = CGFloat(((Double(UIScreen.main.bounds.size.width) - Double(sizeChange.width)) / 2))
        let posY = CGFloat(((Double(UIScreen.main.bounds.size.height) - Double(sizeChange.height)) / 2))
        
        let origin = CGPoint (x: posX, y: posY)

        setimage.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        return scaledImage
    }

    func cropToBounds(image: UIImage, width: Double, height: Double) -> UIImage {
        
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = CGFloat(width)
        var cgheight: CGFloat = CGFloat(height)
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.width
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.height
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)
        
        let imageRef: CGImage = cgimage.cropping(to: rect)!
        
        let image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return image
    }
}

//MARK:- Gesture REcognizer
extension EditImageVC{
    @objc func pinchRecognized(pinch: UIPinchGestureRecognizer) {
        selectedLabel = pinch.view!.tag
        var txt = UITextView()
        txt = arrtextlayer[selectedLabel] as! UITextView
        txt.clipsToBounds = true
        var pinchScale = pinch.scale
        
        pinchScale = round(pinchScale * 1000) / 1000.0
        let scale = pinch.scale
        txt.transform = txt.transform.scaledBy(x: scale, y: scale)
        pinch.scale = 1.0
        arrtextlayer.replaceObject(at: selectedLabel, with: txt)
    }
    
    @objc func rotatedView(_ sender: UIRotationGestureRecognizer) {
        print("rotation gesture is detected")
        selectedLabel = sender.view!.tag
        var txt = UITextView()
        txt = arrtextlayer[selectedLabel] as! UITextView
        txt.clipsToBounds = true
        // [_viewvideo bringSubviewToFront:txt];
        let angle = sender.rotation
        txt.transform = txt.transform.rotated(by: angle)
        sender.rotation = 0.0
        arrtextlayer.replaceObject(at: selectedLabel, with: txt)
    }
    
    @objc func addpangesture(panGesture: UIPanGestureRecognizer) {
        selectedLabel = panGesture.view!.tag
        
        var txt = UITextView()
        txt = arrtextlayer[selectedLabel] as! UITextView
        txt.clipsToBounds = true
        // [_viewvideo bringSubviewToFront:txt];
        let translation = panGesture.translation(in: view)
        var imageViewPosition = txt.center
        imageViewPosition.x += translation.x
        imageViewPosition.y += translation.y
        txt.center = imageViewPosition
        panGesture.setTranslation(CGPoint.zero, in: view)
        arrtextlayer.replaceObject(at: selectedLabel, with: txt)
        
        if panGesture.state == UIGestureRecognizer.State.began {
            // add something you want to happen when the Label Panning has started
        }
        
        if panGesture.state == UIGestureRecognizer.State.ended {
            // add something you want to happen when the Label Panning has ended
        }
        
        if panGesture.state == UIGestureRecognizer.State.changed {
            // add something you want to happen when the Label Panning has been change ( during the moving/panning )
        } else {
            // or something when its not moving
        }
    }
}

//MARK:- TextView Delegate Methods
extension EditImageVC{
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        let lbl = arrtextlayer[textView.tag] as? UITextView
        lbl?.contentSize = CGSize (width: (lbl?.frame.size.width)!, height: textView.contentSize.height)
        txtViewEdit = lbl!
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        txtViewEdit = textView
        arrtextlayer.replaceObject(at: textView.tag, with: textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
    }
}

//MARK:- UIView Touches methods
extension EditImageVC{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDraw{
            tempImageView.layer.sublayers = nil
            if let touch = touches.first {
                lastPoint = touch.location(in: self.view)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDraw{
            if let touch = touches.first {
                let currentPoint = touch.location(in: view)
                drawLineFromPoint(start: lastPoint, toPoint: currentPoint, ofColor: selectedColor, inView: tempImageView)
                
                lastPoint = currentPoint
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isDraw{
            drawLineFromPoint(start: lastPoint, toPoint: lastPoint, ofColor: selectedColor, inView: tempImageView)
            
            //design path in layer
            shapeLayer = CAShapeLayer()
            shapeLayer.path = bazierPath.cgPath
            shapeLayer.strokeColor = selectedColor.cgColor
            shapeLayer.lineWidth = 3.0
            mainImageView.layer.addSublayer(shapeLayer)
            tempImageView.layer.sublayers = nil
            bazierPath = UIBezierPath()
            arrlayer.add(shapeLayer)
        }
    }
}

//MARK:- CollectionView Delegate
extension EditImageVC: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let lblColor = cell.contentView.viewWithTag(1) as? UILabel
        lblColor?.backgroundColor = arrColors[indexPath.row]
        if arrColors[indexPath.row] == selectedColor{
            lblColor?.borderColor = UIColor.white
        }else{
            lblColor?.borderColor = UIColor.black
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = arrColors[indexPath.row]
        collectionColorPicker.reloadData()
        if isText{
            txtViewEdit.textColor = selectedColor
            txtViewEdit.text = txtViewEdit.text
            arrtextlayer.replaceObject(at: txtViewEdit.tag, with: txtViewEdit)
        }
    }
}

extension UIImageView
{
    override open var intrinsicContentSize: CGSize
    {
        let frameSizeWidth = self.frame.size.width
        
        guard let image = self.image else
        {
            return CGSize(width: frameSizeWidth, height: 1.0)
        }
        
        // MAIN
        let returnHeight = ceil(image.size.height * (frameSizeWidth / image.size.width))
        return CGSize(width: frameSizeWidth, height: returnHeight)
    }
    
}

func imageSizeAspectFit(imgview: UIImageView) -> CGSize {
    var newwidth: CGFloat
    var newheight: CGFloat
    let image: UIImage = imgview.image!

    if image.size.height >= image.size.width {
        newheight = imgview.frame.size.height;
        newwidth = (image.size.width / image.size.height) * newheight
        if newwidth > imgview.frame.size.width {
            let diff: CGFloat = imgview.frame.size.width - newwidth
            newheight = newheight + diff / newheight * newheight
            newwidth = imgview.frame.size.width
        }
    }else {
        newwidth = imgview.frame.size.width
        newheight = (image.size.height / image.size.width) * newwidth
        if newheight > imgview.frame.size.height {
            let diff: CGFloat = imgview.frame.size.height - newheight
            newwidth = newwidth + diff / newwidth * newwidth
            newheight = imgview.frame.size.height
        }
    }

    print(newwidth, newheight)
    return CGSize (width: newwidth, height: newheight)
}



extension UIImage {
    
    func resize(toTargetSize targetSize: CGSize) -> UIImage {
        
        let newScale = self.scale
        let originalSize = self.size
        
        let widthRatio = targetSize.width / originalSize.width
        let heightRatio = targetSize.height / originalSize.height
        
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: floor(originalSize.width * heightRatio), height: floor(originalSize.height * heightRatio))
        } else {
            newSize = CGSize(width: floor(originalSize.width * widthRatio), height: floor(originalSize.height * widthRatio))
        }
        
        let rect1 = CGPoint (x: (UIScreen.main.bounds.size.width - targetSize.width) / 2, y: (UIScreen.main.bounds.size.height - targetSize.height) / 2)

        let rect = CGRect(origin: rect1, size: newSize)
        
        let format = UIGraphicsImageRendererFormat()
        format.scale = newScale
        format.opaque = true
        let newImage = UIGraphicsImageRenderer(bounds: rect, format: format).image() { _ in
            self.draw(in: rect)
        }
        
        return newImage
    }
    
    func crop(to rect: CGRect) -> UIImage? {
        var rect = rect
        
        let cgimage = self.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size

        rect.size.width = rect.size.width * self.scale
        rect.size.height =  rect.size.height * self.scale
        
        // Crop the image
        guard let imageRef = self.cgImage?.cropping(to: rect) else {
            return nil
        }
        
        return UIImage(cgImage: imageRef)
    }

    func cropBottomImage(image: UIImage) -> UIImage {
        let height = image.size.height
        let rect = CGRect(x: 0, y: (UIScreen.main.bounds.height - height)/2, width: image.size.width, height: height)
        return cropImage(image: image, toRect: rect)
    }

    func cropImage(image:UIImage, toRect rect:CGRect) -> UIImage{
        let imageRef:CGImage = image.cgImage!.cropping(to: rect)!
        let croppedImage:UIImage = UIImage(cgImage:imageRef)
        return croppedImage
    }

    func squareImage(image: UIImage) -> UIImage {
        var originalWidth  = image.size.width
        var originalHeight = image.size.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var edge: CGFloat = 0.0
        
        if (originalWidth > originalHeight) {
            // landscape
            edge = originalHeight
            x = (originalWidth - edge) / 2.0
            y = 0.0
            
        } else if (originalHeight > originalWidth) {
            // portrait
            edge = originalWidth
            x = 0.0
            y = (originalHeight - originalWidth) / 2.0
        } else {
            // square
            edge = originalWidth
        }
        
        var cropSquare = CGRect (x: x, y: y, width: originalWidth, height: originalHeight)
        var imageRef = self.cgImage?.cropping(to: cropSquare)
        return UIImage(cgImage: imageRef!, scale: UIScreen.main.scale, orientation: image.imageOrientation)
    }
}


extension UIImage {
    
    func crop(to:CGSize) -> UIImage {
        
        guard let cgimage = self.cgImage else { return self }
        
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        
        guard let newCgImage = contextImage.cgImage else { return self }
        
        let contextSize: CGSize = contextImage.size
        
        //Set to square
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        let cropAspect: CGFloat = to.width / to.height
        
        var cropWidth: CGFloat = to.width
        var cropHeight: CGFloat = to.height
        
        if to.width > to.height { //Landscape
            cropWidth = contextSize.width
            cropHeight = contextSize.width / cropAspect
            posY = (contextSize.height - cropHeight) / 2
        } else if to.width < to.height { //Portrait
            cropWidth = contextSize.height
            cropHeight = contextSize.height / cropAspect
            posY = (contextSize.width - cropWidth) / 2
        } else { //Square
            if contextSize.width >= contextSize.height { //Square on landscape (or square)
                cropHeight = contextSize.height
                cropWidth = contextSize.height * cropAspect
                posX = (contextSize.width - cropWidth) / 2
            }else{ //Square on portrait
                cropWidth = contextSize.width
                cropHeight = contextSize.width / cropAspect
                posY = (contextSize.height - cropHeight) / 2
            }
        }
        
        let rect: CGRect = CGRect(x: posX, y: posY, width: cropWidth, height: cropHeight)
        
        guard let imageRef: CGImage = newCgImage.cropping(to: rect) else { return self}
        
        let cropped: UIImage = UIImage(cgImage: imageRef, scale: self.scale, orientation: self.imageOrientation)
        
        UIGraphicsBeginImageContextWithOptions(to, false, self.scale)
        cropped.draw(in: CGRect(x: 0, y: 0, width: to.width, height: to.height))
        let resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resized ?? self
    }
    
    func cropToRect(rect: CGRect!) -> UIImage? {
        let scaledRect = CGRect (x: rect.origin.x * self.scale, y: rect.origin.y * self.scale, width: rect.size.width * self.scale, height: rect.size.height * self.scale)
        let imageRef = self.cgImage?.cropping(to: scaledRect)
        let result = UIImage(cgImage: imageRef!, scale: self.scale, orientation: self.imageOrientation)
        
        return result;
    }

}
