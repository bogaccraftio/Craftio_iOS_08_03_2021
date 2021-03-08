
import Foundation
import UIKit

public class DateTime:NSObject
{
    class func toDate(_ format: String,StrDate:String) -> Date
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let date = dateFormatter.date(from: StrDate)
        return date!
    }
    
    class func toString(_ format: String, date:Date) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let strDate = dateFormatter.string(from: date)        
        return strDate
    }
}


func stringToDate(strDate: String) -> Date {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss z"
    let date = dateFormatter.date(from: strDate)
    return date ?? Date()
}

class DateTimeFormats
{
    static let EEEE_MMM_d_yyyy = "EEEE, MMM d, yyyy"                                    //Wednesday, Sep 12, 2018
    static let MM_dd_yyyy = "MM/dd/yyyy"                                                // 09/12/2018
    static let MM_dd_yyyy_HH_mm = "MM-dd-yyyy HH:mm"                                    // 09-12-2018 14:11
    static let MMM_d_h_mm_a = "MMM d, h:mm a"                                           // Sep 12, 2:11 PM
    static let MMMM_yyyy = "MMMM yyyy"                                                  // September 2018
    static let MMM_d_yyyy = "MMM d, yyyy"                                               // Sep 12, 2018
    static let E_d_MMM_yyyy_HH_mm_ss_Z = "E, d MMM yyyy HH:mm:ss Z"                     //Wed, 12 Sep 2018 14:11:54 +0000
    static let yyyy_MM_dd_T_HH_mm_ssZ = "yyyy-MM-dd'T'HH:mm:ssZ"                        // 2018-09-12T14:11:54+0000
    static let dd_MM_yy = "dd.MM.yy"                                                    // 12.09.18
    static let HH_mm_ss_SSS = "HH:mm:ss.SSS"                                            // 10:41:02.112
    static let DD_mm_yyyy = "DD/MM/YYYY"
    static let hh_mm_a = "hh:mm a"
    static let dd_mm_yyyy = "dd-MM-yyyy"                                                // 28-2-2000
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date))y"   }
        if months(from: date)  > 0 { return "\(months(from: date))M"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date))w"   }
        if days(from: date)    > 0 { return "\(days(from: date))d"    }
        if hours(from: date)   > 0 { return "\(hours(from: date))h"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date))m" }
        if seconds(from: date) > 0 { return "\(seconds(from: date))s" }
        return ""
    }
}
