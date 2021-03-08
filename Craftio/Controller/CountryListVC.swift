
import UIKit
import IQKeyboardManagerSwift

class CountryListVC: UIViewController
{
    //MARK:- Variables & Outlets
    @IBOutlet weak var tblCountryList: UITableView!
    @IBOutlet weak var CountrysearchBar: UISearchBar!
    @IBOutlet weak var searchBarHeight: NSLayoutConstraint!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    var ConutrinData = NSMutableArray()
    var TempConutrinData = NSMutableArray()
    
    //MARK:- Default Methods
    override func viewDidLoad()
    {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = false
        self.getCountryListAPICall()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillAppear(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillDisappear(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @objc
    func keyboardWillAppear(notification: NSNotification?) {
        
        guard let keyboardFrame = notification?.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        
        let keyboardHeight: CGFloat
        if #available(iOS 11.0, *) {
            keyboardHeight = keyboardFrame.cgRectValue.height - self.view.safeAreaInsets.bottom
        } else {
            keyboardHeight = keyboardFrame.cgRectValue.height
        }
        
        tableViewBottomLayoutConstraint.constant = keyboardHeight
    }
    
    @objc
    func keyboardWillDisappear(notification: NSNotification?) {
        tableViewBottomLayoutConstraint.constant = 0.0
    }
    //MARK:- Button Tapped Events
    @IBAction func btnBackAction(_ sender: UIButton)
    {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
}
extension CountryListVC : UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.ConutrinData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryListCell") as! CountryListCell
        let data = ConutrinData[indexPath.row] as? [String:Any]
        cell.lblCountryName.text = data?["country_name"] as? String ?? ""
        cell.lblCountryCode.text = data?["country_code"] as? String ?? ""
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        self.view.endEditing(true)
        let data = ConutrinData[indexPath.row] as? [String:Any]
        appDelegate.countryName = data?["country_name"] as? String ?? ""
        appDelegate.countryNameCode = data?["id"] as? String ?? ""
        self.dismiss(animated: true, completion: nil)        
    }
}

extension CountryListVC: UISearchBarDelegate, UIGestureRecognizerDelegate
{
    //MARK:- Search Bar Delegate Method
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if (searchBar.text?.isEmpty)!
        {
            self.ConutrinData = self.TempConutrinData
            self.tblCountryList.reloadData()
        }
        self.view.endEditing(true)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)
    {
        searchBar.returnKeyType = .done
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        if (searchText.isEmpty)
        {
            self.ConutrinData = self.TempConutrinData
            self.tblCountryList.reloadData()
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool
    {
        print("Hellooo")
        let str = self.CountrysearchBar.text! + text
        print(str)
        
        if(text.isEmpty)
        {
            if (searchBar.text?.count == 1) && (str.count == 1)
            {
                self.ConutrinData = self.TempConutrinData
                self.tblCountryList.reloadData()
                return true
            }
            
            let tempStr = String(str.dropLast())
            self.filterArray(tempStr)
            return true
        }
        self.filterArray(str)
        return true
    }
    
    //MARK:- User Define Method
    func filterArray(_ str: String)
    {
        let strFinal = String(str.filter { !" \n\t\r".contains($0) })
        
        print("final",strFinal)
        
        let predicate = NSPredicate(format: "country_name CONTAINS[c] %@", strFinal)
        let arrTemp = self.TempConutrinData.filtered(using: predicate)
        self.ConutrinData = NSMutableArray()
        self.ConutrinData.addObjects(from: arrTemp)
        self.tblCountryList.reloadData()
    }
}

extension CountryListVC
{
    //Get Service List API Call
    func getCountryListAPICall() {
        WebService.Request.patch(url: getAllCountry, type: .get, parameter: nil, callSilently: false, header: nil) { (response, error) in
            if error == nil {
                print(response!)
                if let data = response!["data"] as? [[String: Any]] {
                    
                    self.TempConutrinData = NSMutableArray()
                    self.TempConutrinData.addObjects(from: data)
                    self.ConutrinData = NSMutableArray()
                    self.ConutrinData = self.TempConutrinData
                    self.tblCountryList.reloadData()
                }
            }
        }
    }
}
