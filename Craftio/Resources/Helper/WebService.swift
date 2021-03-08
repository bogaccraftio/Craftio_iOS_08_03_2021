
import Foundation
import UIKit
import CoreLocation
import Alamofire
import MBProgressHUD
import SVProgressHUD
import Photos

class WebService: NSObject {
    
    static var shared = WebService()
    
    struct UDefault {
        static func save(key : String, value : Any){
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
        static func get(key : String, value : Any){
            UserDefaults.value(forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    struct Alert {
        
        typealias alertCompletion = ((UIAlertAction)->())
        
        static func showAlert(title: String = "Alert", message: String, viewController : UIViewController, okAction : @escaping alertCompletion){
            let aAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            let aAlertOK = UIAlertAction(title: "Ok", style: .default, handler: okAction)
            
            aAlertController.addAction(aAlertOK)
            
            viewController.present(aAlertController, animated: true, completion: nil)
            
        }
        
        static func showAlert(title: String = "Alert", message: String, button : [String], viewController : UIViewController, completionHandler : ((Int)->())? = nil) -> UIAlertController{
            let aAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            
            for (aIndex,aTitle) in button.enumerated(){
                
                let aAlert = UIAlertAction(title: aTitle, style: .default, handler: { (aAction) in
                    completionHandler?(aIndex)
                })
                
                aAlertController.addAction(aAlert)
            }
            
            viewController.present(aAlertController, animated: true, completion: nil)
            return aAlertController
        }
    }
    
    struct Loader {
        static func show() {
            appDelegate.addProgressView()
        }
        
        static func hide() {
            appDelegate.hideProgrssVoew()
        }
    }
    
    struct Request {
        
        static func patch(url: String, type: HTTPMethod ,parameter : [String:Any]?, callSilently : Bool = false , header : HTTPHeaders? = nil, completionBlock : (([String:Any]?,Error?)->())?){
            
            request(url: url, type: type, parameter: parameter, callSilently :callSilently, header: header, completionBlock: completionBlock)
        }
        
        static func get(url: String, parameter : [String:Any]?, header : HTTPHeaders? = nil, callSilently : Bool = false, encoding:ParameterEncoding = URLEncoding.httpBody, completionBlock : (([String:Any]?,Error?)->())?){
            
            request(url: url, type: .get, parameter: parameter, callSilently :callSilently, header: header, encoding: encoding, completionBlock: completionBlock)
        }
        
        private static func request(url: String, type : HTTPMethod, parameter : [String:Any]?, callSilently : Bool = false, header : HTTPHeaders? = nil,encoding:ParameterEncoding = URLEncoding.httpBody, completionBlock : (([String:Any]?,Error?)->())?){
            
            
            guard let aUrl = URL(string: url) else { return }
            guard checkNetworkConnectivity() else { return }
            
            print("========================================")
            print("API -> \(url)")
            print("Param -> \(parameter ?? [:])")
            print("========================================")
            
            let aController : UIViewController? = appDelegate.window?.rootViewController as? UINavigationController ?? appDelegate.window?.rootViewController
            
            if !callSilently {
                Loader.show()
                aController?.view.isUserInteractionEnabled = false
            }
            
            var urlencoding: ParameterEncoding!
            if url.contains("forgotPassword"){
                urlencoding = URLEncoding.httpBody
            }else{
                urlencoding = URLEncoding.httpBody
            }
            
            Alamofire.request(aUrl, method: type, parameters: parameter, encoding: urlencoding, headers: header).responseJSON { (aResponse) in
                
                if !callSilently {
                    Loader.hide()
                    aController?.view.isUserInteractionEnabled = true
                }
                
                guard aResponse.error == nil else {
                    completionBlock?(nil,aResponse.error)
                    return
                }
                
                guard let aDicResponse = aResponse.result.value as? [String:Any] else {
                    completionBlock?(nil,aResponse.error)
                    return
                }
                if let TempresponseDict:NSDictionary = aResponse.result.value as? NSDictionary
                {
                    if TempresponseDict.object(forKey: "status") != nil {
                        
                        if TempresponseDict.object(forKey: "login_screen") as? String == "1"{
                            let domain = Bundle.main.bundleIdentifier!
                            UserDefaults.standard.removePersistentDomain(forName: domain)
                            UserDefaults.standard.synchronize()
                            print(Array(UserDefaults.standard.dictionaryRepresentation().keys).count)
                            APPDELEGATE?.notificationCount = 0
                            APPDELEGATE?.chatCount = 0
                            APPDELEGATE?.totalConut = 0
                            UIApplication.shared.applicationIconBadgeNumber = 0
                            APPDELEGATE?.uerdetail = nil
                            APPDELEGATE?.selectedUserType = .none
                            APPDELEGATE!.isAddressEdited = false
                            APPDELEGATE?.addAlertPopupview(viewcontroller: findtopViewController()!, oprnfrom: "webservice", message:TempresponseDict.object(forKey: "msg") as? String ?? "Your session has been expired.")
                        }
                    }
                }
                completionBlock?(aDicResponse,aResponse.error)
            }
        }
        
        static func uploadFiles(url: String, fileUrls : [URL], parameters:[String:String], isBackgroundPerform:Bool = false, headerForAPICall : [String:String] = ["Content-type": "multipart/form-data"] ,completion : ((DataResponse<Any>?,Error?)->())?) {
            
            guard let aUrl = URL(string: url) else { return }
            guard checkNetworkConnectivity(isSilent: true) else { return }
            
            let aController : UIViewController? = appDelegate.window?.rootViewController as? UINavigationController ?? appDelegate.window?.rootViewController
            
            if !isBackgroundPerform {
                aController?.view.isUserInteractionEnabled = false
                appDelegate.addProgressView()
            }
            
            let aFiles = fileUrls.map { (aUrl) -> Data in
                var aData = Data()
                
                do{
                    aData = try Data(contentsOf: aUrl)
                }catch{
                    
                }
                
                return aData
            }
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                for (aIndex,aFileData) in aFiles.enumerated() {
                    let aExtension = fileUrls[aIndex].lastPathComponent.components(separatedBy: ".").last!.lowercased()
                    let aFileName = fileUrls[aIndex].lastPathComponent.components(separatedBy: ".").first!
                    
                    if aExtension == "db" {
                        
                        if fileUrls.count > 0 {
                            
                            if FileManager.default.fileExists(atPath: fileUrls[aIndex].path){
                                if let cert = NSData(contentsOfFile: fileUrls[aIndex].path) {
                                    let aData = cert as Data
                                    print("aFileData: \(aData.count)")
                                    
                                    multipartFormData.append(aData, withName: "file[]", fileName: "\(aFileName + "." + aExtension)", mimeType: "application/octet-stream")
                                }
                            }
                        }
                        
                        
                    } else {
                        let aType = aExtension == "pdf" ? "application/pdf" : "image/\(aExtension)"
                        multipartFormData.append(aFileData, withName: "file[]", fileName: "\(aFileName + "." + aExtension)", mimeType: aType)
                    }
                    
                }
                
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, usingThreshold: UInt64.init(), to: aUrl, method: .post, headers: headerForAPICall) { (aResult) in
                
                func enableInteraction(){
                    DispatchQueue.main.async {
                        aController?.view.isUserInteractionEnabled = true
                        appDelegate.hideProgrssVoew()
                    }
                }
                
                switch aResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (aProgress) in
                        
                        if !isBackgroundPerform {
                            
                        }
                    })
                    
                    upload.responseJSON { response in
                        
                        if !isBackgroundPerform {
                            enableInteraction()
                        }
                        
                        completion?(response,nil)
                    }
                case .failure(let error):
                    print(error)
                    if !isBackgroundPerform {
                        enableInteraction()
                    }
                    
                    completion?(nil,error)
                }
            }
        }

        //MARK Upload Multiple Image
        static func uploadMultipleFiles(url: String, images : [Any], parameters:[String:String],isDefaultImage: Bool = false, isBackgroundPerform:Bool = false, headerForAPICall : [String:String] = ["Content-type": "multipart/form-data"] ,completion : (([String:Any]?,Error?)->())?) {
            
            guard let aUrl = URL(string: url) else { return }
            guard checkNetworkConnectivity(isSilent: true) else { return }
            
            if !isBackgroundPerform {
                appDelegate.addProgressView()
            }
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
                for i in 0..<images.count{
                    if isDefaultImage && i == 0 && ((images[i] as? UIImage) != nil){
                        
                        var defaultImage = UIImage()
                        if ((images[0] as? UIImage) != nil){
                            defaultImage = (images[0] as? UIImage)!
                            if defaultImage.size.height > defaultImage.size.width{
                                defaultImage = imageWithImage(image: defaultImage, scaledToSize: CGSize(width: defaultImage.size.width, height: defaultImage.size.height))
                            }
                            multipartFormData.append(defaultImage.jpegData(compressionQuality: 0.75)!, withName: "default_image", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")

                        }else if ((images[0] as? URL) != nil){
                            let mediaURL = images[0] as? URL
                            if ((mediaURL?.absoluteString.contains(".mp4"))!) || ((mediaURL?.absoluteString.contains(".mov"))!){
                                var movieData: Data?
                                do {
                                    movieData = try Data(contentsOf: (images[0] as? URL)!, options: Data.ReadingOptions.alwaysMapped)
                                    multipartFormData.append(movieData!, withName: "default_image", fileName: "\(Date())file.mp4", mimeType: "video/mp4")
                                    
                                } catch _ {
                                    movieData = nil
                                    return
                                }
                            }
                        }
                    }else if isDefaultImage && i == 0 && ((images[0] as? URL) != nil){
                        var defaultImage = UIImage()
                        if ((images[0] as? URL) != nil){
                            let mediaURL = images[0] as? URL
                            if ((mediaURL?.absoluteString.contains(".mp4"))!) || ((mediaURL?.absoluteString.contains(".mov"))!){
                                var movieData: Data?
                                do {
                                    movieData = try Data(contentsOf: (images[0] as? URL)!, options: Data.ReadingOptions.alwaysMapped)
                                    multipartFormData.append(movieData!, withName: "default_image", fileName: "\(Date())file.mp4", mimeType: "video/mp4")
                                    
                                } catch _ {
                                    movieData = nil
                                    return
                                }
                            }else if isDefaultImage && i == 0 &&  (UIImage(contentsOfFile: mediaURL!.path ) != nil){
                                guard let imagefromURL = UIImage(contentsOfFile: mediaURL!.path )else { return }
                            if imagefromURL.size.height > imagefromURL.size.width{
                                defaultImage = imageWithImage(image: imagefromURL, scaledToSize: CGSize(width: imagefromURL.size.width, height: imagefromURL.size.height))
                            }else{
                                defaultImage = imagefromURL
                            }
                        multipartFormData.append(defaultImage.jpegData(compressionQuality: 0.75)!, withName: "default_image", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")
                            }else if let imagefromURL = UIImage(contentsOfFile: mediaURL!.path ){
                                if imagefromURL.size.height > imagefromURL.size.width{
                                    defaultImage = imageWithImage(image: imagefromURL, scaledToSize: CGSize(width: imagefromURL.size.width, height: imagefromURL.size.height))
                                }else{
                                    defaultImage = imagefromURL
                                }
                                multipartFormData.append(defaultImage.jpegData(compressionQuality: 0.75)!, withName: "media[\(i)]", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")
                            }
                        }
                    }else{
                        if ((images[i] as? media) != nil){
                        }
                        else if ((images[i] as? UIImage) != nil){
                            var image = images[i] as? UIImage
                            if image!.size.height > image!.size.width{
                                image = imageWithImage(image: image!, scaledToSize: CGSize(width: (image?.size.width)!, height: (image?.size.height)!))
                            }
                            multipartFormData.append(image!.jpegData(compressionQuality: 0.75)!, withName: "media[\(i)]", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")
                        }else if let strimage = images[i] as? URL{
                            if (strimage.absoluteString.contains(".mp4")) || (strimage.absoluteString.contains(".mov")){
                                var movieData: Data?
                                do {
                                    movieData = try Data(contentsOf: (images[i] as? URL)!, options: Data.ReadingOptions.alwaysMapped)
                                    multipartFormData.append(movieData!, withName: "media[\(i)]", fileName: "\(Date())file.mp4", mimeType: "video/mp4")
                                    
                                } catch _ {
                                    movieData = nil
                                    return
                                }
                            }else if isDefaultImage && i == 0 &&  (UIImage(contentsOfFile: strimage.path ) != nil){
                                guard let imagefromURL = UIImage(contentsOfFile: strimage.path )else { return }
                                var image = UIImage()

                                if imagefromURL.size.height > imagefromURL.size.width{
                                    image = imageWithImage(image: imagefromURL, scaledToSize: CGSize(width: imagefromURL.size.width, height: imagefromURL.size.height))
                                }else{
                                    image = imagefromURL
                                }

                                multipartFormData.append(image.jpegData(compressionQuality: 0.75)!, withName: "default_image", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")
                            }else if let imagefromURL = UIImage(contentsOfFile: strimage.path ){                                             var image = UIImage()

                                if imagefromURL.size.height > imagefromURL.size.width{
                                    image = imageWithImage(image: imagefromURL, scaledToSize: CGSize(width: imagefromURL.size.width, height: imagefromURL.size.height))
                                }else{
                                    image = imagefromURL
                                }
                                multipartFormData.append(image.jpegData(compressionQuality: 0.75)!, withName: "media[\(i)]", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")
                            }
                        }
                    }
                }
                
            }, usingThreshold: UInt64.init(), to: aUrl, method: .post, headers: headerForAPICall) { (aResult) in
                
                func enableInteraction(){
                    DispatchQueue.main.async {
                        appDelegate.hideProgrssVoew()
                    }
                }
                
                switch aResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (aProgress) in
                        
                        if !isBackgroundPerform {
                            
                        }
                    })
                    
                    upload.responseJSON { response in
                        
                        if !isBackgroundPerform {
                            enableInteraction()
                        }
                        
                        guard let aDicResponse = response.result.value as? [String:Any] else {
                            completion?(nil,response.error)
                            return
                        }
                        FileManager.default.clearDocumentsDirectory()
                        completion?(aDicResponse,response.error)

                    }
                case .failure(let error):
                    print(error)
                    if !isBackgroundPerform {
                        enableInteraction()
                    }
                    
                    completion?(nil,error)
                }
            }
        }
        
        static func compressVideo(inputURL: URL, outputURL: URL, handler:@escaping (_ session: AVAssetExportSession)-> Void) {
            let urlAsset = AVURLAsset(url: inputURL, options: nil)
            if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mov
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.exportAsynchronously { () -> Void in
                    handler(exportSession)
                }
            }
        }
        
        //MARK:- Single Image Upload
        //MARK Upload Multiple Image
        static func uploadSingleFiles(url: String, images : UIImage, parameters:[String:String], isBackgroundPerform:Bool = false, headerForAPICall : [String:String] = ["Content-type": "multipart/form-data"] ,completion : (([String:Any]?,Error?)->())?){
            
            guard let aUrl = URL(string: url) else { return }
            guard checkNetworkConnectivity(isSilent: true) else { return }
            
            if !isBackgroundPerform {
                appDelegate.addProgressView()
            }
            
            Alamofire.upload(multipartFormData: { (multipartFormData) in
                
                multipartFormData.append(images.jpegData(compressionQuality: 0.75)!, withName: "image", fileName: "\(Date())file.jpeg", mimeType: "image/jpeg")                
               
                for (key, value) in parameters {
                    multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
                }
            }, usingThreshold: UInt64.init(), to: aUrl, method: .post, headers: headerForAPICall) { (aResult) in
                
                func enableInteraction(){
                    DispatchQueue.main.async {
                        appDelegate.hideProgrssVoew()
                    }
                }
                
                switch aResult {
                case .success(let upload, _, _):
                    upload.uploadProgress(closure: { (aProgress) in
                        
                        if !isBackgroundPerform {
                            
                        }
                    })
                    
                    upload.responseJSON { response in
                        
                        if !isBackgroundPerform {
                            enableInteraction()
                        }
                        guard let aDicResponse = response.result.value as? [String:Any] else {
                            completion?(nil,response.error)
                            return
                        }
                        completion?(aDicResponse,response.error)
                        //completion?(response,nil)
                    }
                case .failure(let error):
                    print(error)
                    if !isBackgroundPerform {
                        enableInteraction()
                    }
                    completion?(nil,error)
                }
            }
        }
    }
}



class ConnectivityNew
{
    class func isConnectedToInternet() ->Bool
    {
        return NetworkReachabilityManager()!.isReachable
    }
}
