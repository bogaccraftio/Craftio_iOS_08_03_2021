
import UIKit
import AVFoundation

class CellWorkHistory: UITableViewCell, UIScrollViewDelegate
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var viewMain: UIView!
    @IBOutlet weak var imgBackg: UIImageView!
    @IBOutlet weak var viewProfile: UIView!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnEditChat: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    @IBOutlet weak var viewInprogress: UIView!
    @IBOutlet weak var viewreview: UIView!
    @IBOutlet weak var lblInprogressDesc: UILabel!
    @IBOutlet weak var btnJobIcon: UIButton!
    @IBOutlet weak var btnProfile: UIButton!
    @IBOutlet weak var heightReview: NSLayoutConstraint!
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    
    @IBOutlet weak var imgRate1: UIImageView!
    @IBOutlet weak var imgRate2: UIImageView!
    @IBOutlet weak var imgRate3: UIImageView!
    @IBOutlet weak var imgRate4: UIImageView!
    @IBOutlet weak var imgRate5: UIImageView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var lblDescInProgress: UILabel!
    @IBOutlet weak var imgService: UIImageView!
    
    @IBOutlet weak var imgVideoIcon: UIImageView!
    
    @IBOutlet weak var scrlViewSlider: UIScrollView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var lblInactivated: UILabel!
    var Arrimg: [media] = [] {
        didSet {
            collectionPreview.reloadData()
        }
    }
    
    @IBOutlet weak var lblunreadCount: UILabel!
    
    var previewImage = UIImageView()
    @IBOutlet weak var collectionPreview: UICollectionView!
    var blockPreview : (()->())?
    
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
        
        let scrollViewTap = UITapGestureRecognizer(target: self, action: #selector(scrollViewTapped))
        scrollViewTap.numberOfTapsRequired = 1
        self.scrlViewSlider.addGestureRecognizer(scrollViewTap)
        
        let nib = UINib.init(nibName: "cellPreviewImage", bundle: nil)
        self.collectionPreview.register(nib, forCellWithReuseIdentifier: "cellPreviewImage")
    }
    
    
    @objc func scrollViewTapped() {
        print("scrollViewTapped")
        let configuration = ImageViewerConfiguration { config in
            config.imageView = self.previewImage
        }
        let imageViewerController = ImageViewerController(configuration: configuration)
        findtopViewController()!.present(imageViewerController, animated: true)
    }
    
    func getThumbnailImage_2(forUrl url: URL) -> UIImage?
    {
        let asset: AVAsset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 2) , actualTime: nil)
            return UIImage(cgImage: thumbnailImage)
        }
        catch let error
        {
            print(error)
        }
        
        return nil
    }
    
    //MARK:- ScrollView Delegate
//    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView)
//    {
//        self.changePageWhileScroll()
//    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        for cell in  collectionPreview.visibleCells{
            let indexPath = collectionPreview.indexPath(for: cell)
            print(indexPath!)
            
            self.pageController.currentPage = indexPath?.item ?? 0
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool)
    {
        super.setSelected(selected, animated: animated)
    }
    
    //Cell Button Click
    @IBAction func btnDeleteAction(_ sender: UIButton)
    {
        
    }
    
    @IBAction func btnEditChatAction(_ sender: UIButton)
    {
    
    }
    
    @IBAction func btnJobIconAction(_ sender: UIButton)
    {
    
    }
}

extension CellWorkHistory: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.Arrimg != nil {
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

        if (self.Arrimg[indexPath.row].media_url?.contains(".mp4"))! || (self.Arrimg[indexPath.row].media_url?.contains(".mov"))!{
            let path = URL(string:self.Arrimg[indexPath.row].media_url ?? "")
            cell.imgVideoIcon.isHidden = false
            
            DispatchQueue.global(qos: .background).async
                {
                    if let thumbnailImage = self.getThumbnailImage_2(forUrl: path!)
                    {
                        DispatchQueue.main.async
                            {
                                if cell.imgjob.tag == indexPath.row{
                                    cell.imgjob.image = thumbnailImage
                                    cell.imgjob.isHidden = false
                                }
                            }
                    }
            }
        }else{
            cell.imgjob.isHidden = false
            let imgURL = URL(string:self.Arrimg[indexPath.row].media_url ?? "")
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
    
    //    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    //        self.pageController.currentPage = indexPath.item
    //    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if (self.Arrimg[indexPath.row].media_url?.contains(".mp4"))! || (self.Arrimg[indexPath.row].media_url?.contains(".mov"))!{
//            APPDELEGATE?.addViewForPopUpPlayVideo(viewcontroller: findtopViewController()!, strVideoUrl: self.Arrimg[indexPath.row].media_url ?? "")
//        }else{
////            let cell = collectionPreview.cellForItem(at: indexPath) as! cellPreviewImage
////            DispatchQueue.main.async {
////                let configuration = ImageViewerConfiguration { config in
////                    config.imageView = cell.imgjob
////                }
////                let imageViewerController = ImageViewerController(configuration: configuration)
////                findtopViewController()?.present(imageViewerController, animated: true)
////            }
//            //
//            
//            let cell = collectionPreview.cellForItem(at: indexPath) as! cellPreviewImage
//            let configuration = ImageViewerConfiguration { config in
//                config.imageView = cell.imgjob
//            }
//            let imageViewerController = ImageViewerController(configuration: configuration)
//            let transition = CATransition()
//            transition.duration = 0.5
//            transition.timingFunction = CAMediaTimingFunction(name:CAMediaTimingFunctionName.easeIn)
//            window?.layer.add(transition, forKey: kCATransition)
//            findtopViewController()?.present(imageViewerController, animated: false)
//        }
        //
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
