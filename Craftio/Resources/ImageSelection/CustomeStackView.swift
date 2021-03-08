
import UIKit
import Photos

class CustomeStackView: UIView {
    
    var top = 30
    var bottom = 50
    var leading = 30
    var tailing = 50
    var configuration = Configuration()
    var isFirst = true
    var selectedAssetsView = [Any]()
    var intImageCount = 0
    var maxStackViewCount = 4
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func setupViews(images: [PHAsset]) {
        let view = UIView (frame: CGRect (x: NSInteger( (self.frame.width/2) - 25), y: NSInteger((self.frame.height/2) - 25), width: bottom, height: tailing))
        
        view.layer.cornerRadius = 5.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        self.addSubview(view)
    }
    
    func addNew(image: UIImage) {
        if isFirst{
            isFirst = false
        }else{
            configuration.stackWidthHeight += 3
        }
        top -= configuration.stackImageDistance
        leading -= configuration.stackImageDistance
        let view = UIView (frame: CGRect (x: NSInteger( (self.frame.width/2) - CGFloat(configuration.stackWidthHeight)), y: NSInteger((self.frame.height/2) - CGFloat(configuration.stackWidthHeight)), width: bottom, height: tailing))
        let img = UIImageView (frame: CGRect (x: 0, y: 0, width: bottom, height: tailing))
        img.image = image
        img.contentMode = .scaleAspectFill
        view.addSubview(img)
        view.layer.cornerRadius = 5.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        self.addSubview(view)
    }
    
    func reloadViews(images: [Any]) {
        for item in self.subviews{
            item.removeFromSuperview()
        }
        top = 30
        bottom = 50
        leading = 30
        tailing = 50
        isFirst = true
        self.configuration.stackWidthHeight = 25
        self.configuration.stackImageDistance = 5
        var stackCount = 0
        for item in images{
            if ((item as? PHAsset) != nil){
                AssetManager.resolveAsset(item as! PHAsset, size: CGSize(width: 100, height: 100)) { image in
                    guard image != nil else { return }
                    self.setupStack(image: image!, stackCount: stackCount, images: images)
                    stackCount += 1
                }
            }else if ((item as? UIImage) != nil){
                setupStack(image: item as! UIImage, stackCount: stackCount, images: images)
                stackCount += 1
            }else if let avAsset = item as? URL{
                setupStack(image: AssetManager.generateThumbnail(path: avAsset)!, stackCount: stackCount, images: images)
                stackCount += 1
            }
        }
        if images.count == 0{
            let view = UIView (frame: CGRect (x: NSInteger( (self.frame.width/2) - CGFloat(self.configuration.stackWidthHeight)), y: NSInteger((self.frame.height/2) - CGFloat(self.configuration.stackWidthHeight)), width: self.bottom, height: self.tailing))
            let img = UIImageView (frame: CGRect (x: 0, y: 0, width: self.bottom, height: self.tailing))
            img.contentMode = .scaleAspectFill
            view.addSubview(img)
            view.layer.cornerRadius = 10.0
            view.layer.borderColor = UIColor.white.cgColor
            view.layer.borderWidth = 1.0
            view.layer.masksToBounds = true
            self.addSubview(view)
        }
    }
    
    func setupStack(image: UIImage,stackCount: NSInteger, images: [Any])  {
        if (stackCount == images.count - 4) || (stackCount == images.count - 3) || (stackCount == images.count - 2) || (stackCount == images.count - 1){
            if self.isFirst{
                self.isFirst = false
            }else{
                self.configuration.stackWidthHeight += 3
            }
            self.top -= self.configuration.stackImageDistance
            self.leading -= self.configuration.stackImageDistance
        }
        
        let view = UIView (frame: CGRect (x: NSInteger( (self.frame.width/2) - CGFloat(self.configuration.stackWidthHeight)), y: NSInteger((self.frame.height/2) - CGFloat(self.configuration.stackWidthHeight)), width: self.bottom, height: self.tailing))
        let img = UIImageView (frame: CGRect (x: 0, y: 0, width: self.bottom, height: self.tailing))
        img.image = image
        img.contentMode = .scaleAspectFill
        view.addSubview(img)
        view.layer.cornerRadius = 10.0
        view.layer.borderColor = UIColor.white.cgColor
        view.layer.borderWidth = 1.0
        view.layer.masksToBounds = true
        if (stackCount == images.count - 4) || (stackCount == images.count - 3) || (stackCount == images.count - 2) || (stackCount == images.count - 1){
        }else{
            self.subviews.last?.removeFromSuperview()
        }
        self.addSubview(view)
    }
}
