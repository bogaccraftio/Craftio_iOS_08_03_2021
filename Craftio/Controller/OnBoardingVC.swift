
import UIKit

class OnBoardingVC: UIViewController {
    
    @IBOutlet weak var collectionScroll: UICollectionView!
    @IBOutlet weak var pageCOntroller: UIPageControl!
    var arrtext = ["Welcome to Craftio!","Client can select the service and a location to create a job and get it done.","Crafter can select the nearby jobs, make an offer and can offer his service."]
    var arrImages = ["app on boarding page 1.png","app on boarding page 2.png","app on boarding page 3.png"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        APPDELEGATE?.isfromChat()
        pageCOntroller.numberOfPages = arrtext.count
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageCOntroller?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageCOntroller?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    
    @IBAction func btnIMClient(_ sender: Any) {
        APPDELEGATE!.selectedUserType = .Client
        UserDefaults.standard.set("1", forKey: "usertype")
        UserDefaults.standard.synchronize()
        let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
    }
    
    @IBAction func btnIMCrafter(_ sender: Any) {
        APPDELEGATE!.selectedUserType = .Crafter
        UserDefaults.standard.set("2", forKey: "usertype")
        UserDefaults.standard.synchronize()
        let objJobHistoryVC = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        self.navigationController?.pushViewController(objJobHistoryVC, animated: true)
    }
}


extension OnBoardingVC: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout
{
    // tell the collection view how many cells to make
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrImages.count
    }
    
    // make a cell for each cell index path
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // get a reference to our storyboard cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        let imgBack = cell.contentView.viewWithTag(2) as? UIImageView
        imgBack?.image = UIImage (named: arrImages[indexPath.row])

        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // handle tap events
        print("You selected cell #\(indexPath.item)!")
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width, height: self.view.frame.size.height)
    }
    
    //Use for interspacing
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}
