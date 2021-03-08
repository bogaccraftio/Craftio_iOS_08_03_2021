
import Foundation

class CountryList : NSObject
{
    static let CountryListSharedManager = CountryList()
    
    override init ()
    {
        super.init()
    }
    
    func GetCountryList() -> [String]
    {
        //MARK:- Country List
        var countries: [String] = []
        for code in NSLocale.isoCountryCodes as [String]
        {
            let id = NSLocale.localeIdentifier(fromComponents: [NSLocale.Key.countryCode.rawValue: code])
            let name = NSLocale(localeIdentifier: "en_UK").displayName(forKey: NSLocale.Key.identifier, value: id) ?? "Country not found for code: \(code)"
            countries.append(name)
         }        
        return countries
    }
}
