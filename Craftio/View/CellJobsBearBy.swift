
import UIKit
import AVFoundation

class CellJobsBearBy: UITableViewCell, UIScrollViewDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewMain: UIView!
    
    @IBOutlet weak var lblInprogressDesc: UILabel!    
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgService: UIImageView!
    @IBOutlet weak var imgjob: UIImageView!
    
    @IBOutlet weak var imgVideoIcon: UIImageView!
    @IBOutlet weak var btnJobIcon: UIButton!
    
    @IBOutlet weak var scrlViewSlider: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var lblInactivated: UILabel!
    var Arrimg: [media] = [] {
        didSet {
            collectionPreview.reloadData()
        }
    }
    
    var previewImage = UIImageView()
    var blockZoomImage : ((Int)->())?
    var blockPreview : (()->())?
    @IBOutlet weak var collectionPreview: UICollectionView!
    
    //MARK:- Default Methods
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        viewMain.layer.masksToBounds = true
        viewMain.layer.cornerRadius = 15.0
        viewMain.clipsToBounds = false
        viewMain.layer.shadowColor = UIColor.gray.cgColor
        viewMain.layer.shadowOpacity = 0.5
        viewMain.layer.shadowOffset = CGSize.zero
        viewMain.layer.shadowRadius = 5
        
        let nib = UINib.init(nibName: "cellPreviewImage", bundle: nil)
        self.collectionPreview.register(nib, forCellWithReuseIdentifier: "cellPreviewImage")
    }

    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    func getThumbnailImage_2(forUrl url: URL) -> UIImage?
    {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }
        catch let error
        {
            print(error)
        }
        
        return nil
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in  collectionPreview.visibleCells{
            let indexPath = collectionPreview.indexPath(for: cell)
            print(indexPath!)
            
            self.pageController.currentPage = indexPath?.item ?? 0
        }
    }
}

extension CellJobsBearBy: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.Arrimg.count != 0 {
            return self.Arrimg.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellPreviewImage", for: indexPath) as! cellPreviewImage
        cell.imgjob.tag = indexPath.row
        cell.imgVideoIcon.isHidden = true
        cell.imgjob.isHidden = true

        if (self.Arrimg[indexPath.item].media_url?.contains(".mp4"))! || (self.Arrimg[indexPath.item].media_url?.contains(".mov"))!{
            let path = URL(string:self.Arrimg[indexPath.item].media_url ?? "")
            cell.imgVideoIcon.isHidden = false
            DispatchQueue.global(qos: .background).async
                {
                    if let thumbnailImage = self.getThumbnailImage_2(forUrl: path!)
                    {
                        DispatchQueue.main.async
                            {
                                if cell.imgjob.tag == indexPath.item{
                                    cell.imgjob.image = thumbnailImage
                                    cell.imgjob.isHidden = false
                                }
                        }
                    }
            }
        }else{
            cell.imgjob.isHidden = false
            let imgURL = URL(string:self.Arrimg[indexPath.item].media_url ?? "")
            cell.imgjob.kf.setImage(with: imgURL, placeholder: nil)
            cell.imgVideoIcon.isHidden = true
        }
        
        if Arrimg.count == 0{
            cell.imgjob.isHidden = false
            cell.imgjob.image = UIImage (named: "placeholder.jpg")
            cell.imgjob.backgroundColor = UIColor.lightGray
            cell.imgVideoIcon.isHidden = true
        }
        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.blockPreview!()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionPreview.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
