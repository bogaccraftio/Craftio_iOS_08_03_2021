
import Foundation
import UIKit
import AVKit
import CoreLocation

let kPresignupVC = "PreSignupVC"
let screen_width = UIScreen.main.bounds.width
let screen_height = UIScreen.main.bounds.height

class Util {
    
    class func getViewController(for storyboardId: String) -> UIViewController {
        let st = UIStoryboard(name: "Main", bundle: nil)
        let vc = st.instantiateViewController(withIdentifier: storyboardId)
        return vc
    }
    
}

func setUserName(name:String) -> String{
    let tempName = name.split(separator: " ")
    var finalName = ""
    if tempName.count >= 2{
        let temp = tempName[1]
        finalName = "\(tempName.first ?? "") \(temp.first ?? " ")"
    }else{
        finalName = name
    }
    return finalName
}

func IS_INTERNET_AVAILABLE()->Bool{
    var Status:Bool = false
    let url = URL(string: "http://google.com/")
    let request = NSMutableURLRequest(url: url!)
    request.httpMethod = "HEAD"
    request.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringLocalAndRemoteCacheData
    request.timeoutInterval = 10.0
    
    var response: URLResponse?
    _ = try? NSURLConnection.sendSynchronousRequest(request as URLRequest, returning: &response) as Data?
    
    if let httpResponse = response as? HTTPURLResponse {
        if httpResponse.statusCode == 200 {
            Status = true
        }
    }
    return Status
}

func findtopViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
        return findtopViewController(controller: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
        if let selected = tabController.selectedViewController {
            return findtopViewController(controller: selected)
        }
    }
    if let presented = controller?.presentedViewController {
        return findtopViewController(controller: presented)
    }
    return controller
}

func alertController(message: String , controller: UIViewController)
{
    let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
    
    let action1 = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
        controller.dismiss(animated: true, completion: nil)
    }
    
    alertController.addAction(action1)
    controller.present(alertController, animated: true, completion: nil)
}



func setContiner(VC aVC: String, parent : UIViewController, container : UIView, newController : ((UIViewController)->())? = nil){
    guard let aVC = parent.storyboard?.instantiateViewController(withIdentifier: aVC) else { return }
    newController?(aVC)
    for aView in container.subviews{
        aView.removeFromSuperview()
    }
    for aChildVC in parent.children{
        aChildVC.removeFromParent()
    }
    aVC.view.frame = container.bounds
    container.addSubview(aVC.view)
    parent.addChild(aVC)
}
func setContinerOther(VC aVC: String, storyboardName:String, parent : UIViewController, container : UIView, newController : ((UIViewController)->())? = nil){
    let st = UIStoryboard.init(name: storyboardName, bundle: nil)
    let aVC = st.instantiateViewController(withIdentifier: aVC)
    newController?(aVC)
    for aView in container.subviews{
        aView.removeFromSuperview()
    }
    for aChildVC in parent.children{
        aChildVC.removeFromParent()
    }
    aVC.view.frame = container.bounds
    container.addSubview(aVC.view)
    parent.addChild(aVC)
}

func localegetCountryCOde(forfullCountryName : String) -> String {
    let locales : String = ""
    for localeCode in NSLocale.isoCountryCodes {
        let identifier = NSLocale(localeIdentifier: localeCode)
        let countryName = identifier.displayName(forKey: NSLocale.Key.countryCode, value: localeCode)
        if forfullCountryName.lowercased() == countryName?.lowercased() {
            return localeCode
        }
    }
    return locales
}

func checkNetworkConnectivity(isSilent : Bool = false) -> Bool{
    guard ConnectivityNew.isConnectedToInternet() else {
        
        guard !isSilent else { return false }
        
        let aController : UIViewController? = appDelegate.window?.rootViewController as? UINavigationController ?? appDelegate.window?.rootViewController
        
        APPDELEGATE?.addAlertPopupview(viewcontroller: (APPDELEGATE?.window!.rootViewController)!, oprnfrom: "", message:"No Internet Connection!")
        
        return false
    }
    
    return true
}

func timeAgoSinceDate(_ date:Date) -> String {
    let calendar = NSCalendar.current
    let unitFlags: Set<Calendar.Component> = [.minute, .hour, .day, .weekOfYear, .month, .year, .second]
    let now = Date()
    let earliest = now < date ? now : date
    let latest = (earliest == now) ? date : now
    let components = calendar.dateComponents(unitFlags, from: earliest,  to: latest)
    if (components.year! >= 1) || (components.month! >= 1) || (components.weekOfYear! >= 1) || (components.day! >= 2){
        return "\(DateTime.toString(DateTimeFormats.dd_mm_yyyy, date: date)) at \(DateTime.toString(DateTimeFormats.hh_mm_a, date: date))"
    }else{
        if (components.day! == 1) || !Calendar.current.isDateInToday(date){
            return "Yesterday at \(DateTime.toString(DateTimeFormats.hh_mm_a, date: date))"
        }else{
            return "\(DateTime.toString(DateTimeFormats.hh_mm_a, date: date))"
        }
    }
}

func convertToDictionary(text: String) -> [String: Any]? {
    if let data = text.data(using: .utf8) {
        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print(error.localizedDescription)
        }
    }
    return nil
}

func convertJsonString(from object:[String:Any]) -> String {
    guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
        return ""
    }
    return String(data: data, encoding: String.Encoding.utf8)!
}


func previewImageForLocalVideo(url:URL) -> UIImage?
{
    let asset = AVAsset(url: url)
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    var time = asset.duration
    //If possible - take not the first frame (it could be completely black or white on camara's videos)
    time.value = min(time.value, 2)
    
    do {
        let imageRef = try imageGenerator.copyCGImage(at: time, actualTime: nil)
        return UIImage(cgImage: imageRef)
    }
    catch let error as NSError
    {
        print("Image generation failed with error \(error)")
        return nil
    }
}

func generateThumbnailcomp(path: URL,completion: @escaping (UIImage) -> Swift.Void) {
    DispatchQueue.global(qos: .background).async {
        DispatchQueue.main.async {
            do {
                let asset = AVURLAsset(url: path, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                completion(thumbnail)
            } catch let error {
                completion(UIImage (named: "")!)
            }
        }
    }
}

func generateThumbnail(path: URL) -> UIImage? {
    do {
        let asset = AVURLAsset(url: path, options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
        let thumbnail = UIImage(cgImage: cgImage)
        return thumbnail
    } catch let error {
        print("*** Error generating thumbnail: \(error.localizedDescription)")
        return nil
    }
}


func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
    let urlAsset = AVURLAsset(url: inputURL, options: nil)
    guard let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) else {
        handler(nil)
        
        return
    }
    
    exportSession.outputURL = outputURL
    exportSession.outputFileType = AVFileType.mov
    exportSession.shouldOptimizeForNetworkUse = true
    exportSession.exportAsynchronously { () -> Void in
        handler(exportSession)
    }
}

func dropShadow(view: UIView,color: UIColor, opacity: Float = 0.2, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
    view.layer.masksToBounds = false
    view.layer.shadowColor = color.cgColor
    view.layer.shadowOpacity = opacity
    view.layer.shadowOffset = offSet
    view.layer.shadowRadius = radius
}

func loadImagesFromAlbum(folderName:String) -> [String]{
    
    let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
    let nsUserDomainMask    = FileManager.SearchPathDomainMask.userDomainMask
    let paths               = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
    var theItems = [String]()
    if let dirPath          = paths.first
    {
        let imageURL = URL(fileURLWithPath: dirPath)
        
        do {
            theItems = try FileManager.default.contentsOfDirectory(atPath: imageURL.path)
            return theItems
        } catch let error as NSError {
            print(error.localizedDescription)
            return theItems
        }
    }
    return theItems
}


func getMockLocationsFor(location: CLLocation, itemCount: Int) -> [CLLocation] {
    
    func getBase(number: Double) -> Double {
        return round(number * 1000)/1000
    }
    func randomCoordinate() -> Double {
        return Double(arc4random_uniform(140)) * 0.0001
    }
    
    let baseLatitude = getBase(number: location.coordinate.latitude - 0.010)
    // longitude is a little higher since I am not on equator, you can adjust or make dynamic
    let baseLongitude = getBase(number: location.coordinate.longitude - 0.010)
    
    var items = [CLLocation]()
    for i in 0..<itemCount {
        
        let randomLat = baseLatitude + randomCoordinate()
        let randomLong = baseLongitude + randomCoordinate()
        let location = CLLocation(latitude: randomLat, longitude: randomLong)
        
        items.append(location)
        
    }
    
    return items
}

func imageWithImage(image:UIImage ,scaledToSize newSize:CGSize)-> UIImage
{
    UIGraphicsBeginImageContext( newSize )
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
    UIGraphicsEndImageContext();
    return newImage
}

func decimal(with string: String) -> NSDecimalNumber {
    let formatter = NumberFormatter()
    formatter.generatesDecimalNumbers = true
    return formatter.number(from: string) as? NSDecimalNumber ?? 0
}

func setDifferentColor(string: String, location: Int, length: Int) -> NSAttributedString{

    let attText = NSMutableAttributedString(string: string)
    attText.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor (red: 0.0/255.0, green: 245.0/255.0, blue: 145.0/255.0, alpha: 1.0), range: NSRange(location:location,length:length))
    return attText

}


enum MessageType {
    case text
}

enum MessageOwner {
    case sender
    case receiver
}

