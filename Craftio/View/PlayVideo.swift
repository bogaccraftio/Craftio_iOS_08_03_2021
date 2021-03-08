
import UIKit

class PlayVideo: UIView {

    public var player = Player()
    @IBOutlet weak var btnCancel: UIButton!
    
    class func instanceFromNib() -> UIView {
        return UINib(nibName: "PlayVideo", bundle: nil).instantiate(withOwner: self, options: nil).first as! UIView
    }
    
    @IBAction func dismissView(_ sender: UIButton) {
        player.stop()
        self.removeFromSuperview()
    }
    
    func playVideo(strVideoURL: String)  {
        let imgURL = URL(string: strVideoURL)
        player.url = imgURL
        player.playerDelegate = self
        player.playbackDelegate = self
        self.addSubview(player.view)
        self.bringSubviewToFront(btnCancel)
        player.playFromBeginning()
    }
}

extension PlayVideo: PlayerDelegate
{
    func playerReady(_ player: Player) {
        print("\(#function) ready")
    }
    
    func playerPlaybackStateDidChange(_ player: Player) {
        print("\(#function) \(player.playbackState.description)")
    }
    
    func playerBufferingStateDidChange(_ player: Player) { }
    
    func playerBufferTimeDidChange(_ bufferTime: Double) { }
    
    func player(_ player: Player, didFailWithError error: Error?) {
        print("\(#function)" + error!.localizedDescription)
    }
}

extension PlayVideo: PlayerPlaybackDelegate
{
    func playerCurrentTimeDidChange(_ player: Player) { }
    
    func playerPlaybackWillStartFromBeginning(_ player: Player) { }
    
    func playerPlaybackDidEnd(_ player: Player) {
        print("Finish")
    }
    
    func playerPlaybackWillLoop(_ player: Player) { }
}
