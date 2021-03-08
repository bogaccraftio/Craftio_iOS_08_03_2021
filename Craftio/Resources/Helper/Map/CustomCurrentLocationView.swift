
import UIKit
let kMaxRadius: CGFloat = 150
let kMaxDuration: TimeInterval = 10

class CustomCurrentLocationView: UIView {

    @IBOutlet weak var sourceView: UIImageView!
    let pulsator = Pulsator()

    class func instanceFromNib() -> UIView {
        return UINib(nibName: "CustomCurrentLocationView", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    func initPulse(){
        sourceView.layer.superlayer?.insertSublayer(pulsator, below: sourceView.layer)
        setupInitialValues()
        pulsator.start()
    }
    
    override func layoutSubviews() {
        self.layer.layoutIfNeeded()
        pulsator.position = sourceView.layer.position
    }
    
    private func setupInitialValues() {
        pulsator.numPulse = Int(3)

        pulsator.radius = 0.7 * kMaxRadius

        pulsator.animationDuration = 0.5 * kMaxDuration

        pulsator.backgroundColor = UIColor (red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.5).cgColor
    }

}
