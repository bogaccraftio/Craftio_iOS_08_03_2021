import AVFoundation
import UIKit

@objc public class Configuration: NSObject {
    
    public enum AssetType {
        case photo
        case video
        case all
    }
    
    // MARK: Colors
    
    @objc public var backgroundColor = UIColor(red: 0.15, green: 0.19, blue: 0.24, alpha: 1)
    @objc public var gallerySeparatorColor = UIColor.black.withAlphaComponent(0.6)
    @objc public var mainColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
    @objc public var noImagesColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    @objc public var noCameraColor = UIColor(red: 0.86, green: 0.86, blue: 0.86, alpha: 1)
    @objc public var settingsColor = UIColor.white
    @objc public var bottomContainerColor = UIColor(red: 0.09, green: 0.11, blue: 0.13, alpha: 1)
    
    // MARK: Fonts
    
    @objc public var numberLabelFont = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.bold)
    @objc public var doneButton = UIFont.systemFont(ofSize: 19, weight: UIFont.Weight.medium)
    @objc public var flashButton = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.medium)
    @objc public var noImagesFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
    @objc public var noCameraFont = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
    @objc public var settingsFont = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.medium)
    
    // MARK: Titles
    
    @objc public var OKButtonTitle = "OK"
    @objc public var cancelButtonTitle = "DONE"
    @objc public var doneButtonTitle = "Done"
    @objc public var noImagesTitle = "No images available"
    @objc public var noCameraTitle = "Camera is not available"
    @objc public var settingsTitle = "Settings"
    @objc public var requestPermissionTitle = "Permission denied"
    @objc public var requestPermissionMessage = "Please, allow the application to access to your photo library."
    
    // MARK: Dimensions
    
    @objc public var cellSpacing: CGFloat = 2
    @objc public var indicatorWidth: CGFloat = 35
    @objc public var indicatorHeight: CGFloat = 6
    @objc public var stackImageDistance: NSInteger = 5
    @objc public var stackWidthHeight: NSInteger = 25
    // MARK: Custom behaviour
    
    public var fetchType = AssetType.all
    public var maxVideoInterval: TimeInterval?
    
    // MARK: Images
    @objc public var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.6)
        view.layer.cornerRadius = 4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override public init() {}
}

