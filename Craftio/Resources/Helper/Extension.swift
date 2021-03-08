

import Foundation
import UIKit
import CoreLocation
import AVKit

extension Date {
    func timeAgoSince() -> String {
        
        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: self, to: now, options: [])
        
        if let day = components.day, day >= 2 {
            let df = DateFormatter()
            df.dateFormat = "d MMMM"
            return df.string(from: self)
            //        return "\(day) days ago"
        }
        
        if let day = components.day, day >= 1 {
            return "Yesterday"
        }
        
        if let hour = components.hour, hour >= 2 {
            return "\(hour) Hours ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return "An hour ago"
        }
        
        if let minute = components.minute, minute >= 2 {
            return "\(minute) Minutes ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return "A minute ago"
        }
        
        if let second = components.second, second >= 2 {
            return "\(second) Seconds ago"
        }
        
        return "Just Now"
        
    }
}

extension String {
    
    func htmlAttributed(family: String?, size: CGFloat) -> NSAttributedString?
    {
        do
        {
            let htmlCSSString = "<style>" +
                    "html *" +
                    "{" +
                
                    "font-family: \(family ?? "Helvetica"), Helvetica !important;" +
                "}</style> \(self)"
                
                guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                    return nil
                }
                
                return try NSAttributedString(data: data,
                                              options: [.documentType: NSAttributedString.DocumentType.html,
                                                        .characterEncoding: String.Encoding.utf8.rawValue],
                                              documentAttributes: nil)
            }
        catch
        {
            print("error: ", error)
            return nil
        }
    }
    
    var htmlToAttributedString: NSAttributedString?
    {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do
        {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        }
        catch
        {
            return NSAttributedString()
        }
    }
    
    var htmlToString: String
    {
        return htmlToAttributedString?.string ?? ""
    }
    
    // for attributed string
    func SetAttributed(location:Int,length:Int,font:String,size:Float) -> NSAttributedString?
    {
        var myMutableString = NSMutableAttributedString()
        
        myMutableString = NSMutableAttributedString(string: self, attributes: [NSAttributedString.Key.font:UIFont(name: font, size: CGFloat(size))!])
        //Cabin-Bold 18.0 "Cabin-Regular 15.0"
        myMutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: NSRange(location:location,length:length))
        
        return myMutableString
    }

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }
    
    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
    
    func getDate(dateFormat: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: self) // replace Date String
    }

    func convertEmailToId() -> String {
        let e = self.replacingOccurrences(of: "@", with: "\'")
        let toEmailId : String = e.replacingOccurrences(of: ".", with: ":")
        return toEmailId
    }
    
    func convertIdToEmail() -> String {
        let e = self.replacingOccurrences(of: "\'", with: "@")
        let toEmailId : String = e.replacingOccurrences(of: ":", with: ".")
        return toEmailId
    }
    
    var boolValue: Bool {
        return NSString(string: self).boolValue
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}


class RoundedImageView: UIImageView {
    
    var user : String?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let radius: CGFloat = self.bounds.size.width / 2.0
        self.layer.cornerRadius = radius
        self.clipsToBounds = true
    }
}


extension UITableView {
    func setup() {
        self.rowHeight = UITableView.automaticDimension
        self.estimatedRowHeight = 100
    }
}

extension UIViewController{
    func alertOk(title:String, message:String, completion: ((_ result:Bool) -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            completion?(true) } ))
    }
    
    func alertTwoButton(title:String, message:String, completion: ((_ result:Bool) -> Void)? = nil)
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            completion?(true) } ))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { action in
            completion?(false) } ))

    }
    func isModal() -> Bool {
        
        if let navigationController = self.navigationController{
            if navigationController.viewControllers.first != self{
                return false
            }
        }
        
        if self.presentingViewController != nil
        {
            return true
        }
        
        if self.navigationController?.presentingViewController?.presentedViewController == self.navigationController
        {
            return true
        }
        
        if self.tabBarController?.presentingViewController is UITabBarController
        {
            return true
        }
        return false
    }
}

extension UIView {
    
    func makeViewCircle() {
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
    }
    
    func makeViewCircle(withBorderColor color : String, width : CGFloat) {
        self.layer.cornerRadius = self.frame.width/2
        self.layer.masksToBounds = true
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = width
    }
    
    func setCorner(radius : CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    func setCorner(radius : CGFloat, withBorderColor color:String, width:CGFloat) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = width
    }
    
    func roundCorners(_ corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.bounds = self.frame
        mask.position = self.center
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
        //MARk:- Make Corner radius On Top
        func CorneronTop(cornerRadius: CGFloat, frame: CGRect)
        {
            let path = UIBezierPath(roundedRect:frame,
                                    byRoundingCorners:[.topRight, .topLeft],
                                    cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
        
        //MARk:- Make Corner radius On Top
        func CorneronBottom(cornerRadius: CGFloat, frame: CGRect)
        {
            let path = UIBezierPath(roundedRect:frame,
                                    byRoundingCorners:[.bottomRight, .bottomLeft],
                                    cornerRadii: CGSize(width: cornerRadius, height:  cornerRadius))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = path.cgPath
            self.layer.mask = maskLayer
        }
        
        func setShadow(cornerRadius: CGFloat){
                let shadowLayer = CAShapeLayer()
                shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
                shadowLayer.fillColor = UIColor.white.cgColor
                
                shadowLayer.shadowColor = UIColor.darkGray.cgColor
                shadowLayer.shadowPath = shadowLayer.path
                shadowLayer.shadowOffset = CGSize(width: 2.0, height: 2.0)
                shadowLayer.shadowOpacity = 5.0
                shadowLayer.shadowRadius = 2
                
                layer.insertSublayer(shadowLayer, at: 0)
                //layer.insertSublayer(shadowLayer, below: nil) // also works
            }

        
        func setUpSahadow()
        {
            self.layer.masksToBounds = false
            self.layer.shadowColor = UIColor.black.cgColor
            self.layer.shadowOpacity = 1
            self.layer.shadowOffset = CGSize(width: -1, height: 1)
            self.layer.shadowRadius = 3
            
            self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
            self.layer.shouldRasterize = true
            self.layer.rasterizationScale = true ? UIScreen.main.scale : 1
        }

    func zoomInWithEasing(duration: TimeInterval = 0.2, easingOffset: CGFloat = 0.2) {
        let easeScale = 1.0 + easingOffset
        let easingDuration = TimeInterval(easingOffset) * duration / TimeInterval(easeScale)
        let scalingDuration = duration - easingDuration
        UIView.animate(withDuration: scalingDuration, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: easeScale, y: easeScale)
        }, completion: { (completed: Bool) -> Void in
            UIView.animate(withDuration: easingDuration, delay: 0.0, options: .curveEaseOut, animations: { () -> Void in
                self.transform = CGAffineTransform.identity
            }, completion: { (completed: Bool) -> Void in
            })
        })
    }
}


extension Locale {
    static let currencies = Dictionary(uniqueKeysWithValues: Locale.isoRegionCodes.map {
        region -> (String, (code: String, symbol: String, locale: Locale)) in
        let locale = Locale(identifier: Locale.identifier(fromComponents: [NSLocale.Key.countryCode.rawValue: region]))
        return (region, (locale.currencyCode ?? "", locale.currencySymbol ?? "", locale))
    })
}



extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}


extension UIDevice {
    var iPhoneX: Bool {
        return UIScreen.main.nativeBounds.height == 2436
    }
    var iPhone: Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }
    enum ScreenType: String {
        case iPhones_4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhones_X_XS = "iPhone X or iPhone XS"
        case iPhone_XR = "iPhone XR"
        case iPhone_XSMax = "iPhone XS Max"
        case unknown
    }
    var screenType: ScreenType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhones_4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1792:
            return .iPhone_XR
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 2436:
            return .iPhones_X_XS
        case 2688:
            return .iPhone_XSMax
        default:
            return .unknown
        }
    }
}

extension UIImage{
    func saveImage(completionHandler: ((Bool,String) -> ())) {
        guard let data = self.jpegData(compressionQuality: 1) else {
            completionHandler(false,"")
            return
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            completionHandler(false,"")
            return
        }
        do {
            let pathURL = directory.appendingPathComponent("\(Date().timeIntervalSince1970).png")!
            try data.write(to: pathURL)
            completionHandler(true,pathURL.absoluteString)
        } catch {
            print(error.localizedDescription)
            completionHandler(false,"")
        }
    }
}

