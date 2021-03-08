
import UIKit

struct UserData: Decodable
{
    let _id : String?
    let first_name : String?
    let last_name : String?
    let email_id : String?
    let device_type : String?
    let device_token : String?
    let session_token : String?
    let user_name : String?
    let password : String?
    let gender : String?
    let age : String?
    let mobile_no : String?
    let user_type : String?
    let created_date : String?
    let modified_date : String?
    var available_status : String?
    let profile_image : String?
    let total_rating : String?
    var notification_status : String?
    let user_latitude : String?
    let user_longitude : String?
    let user_address : String?
    var reviews: [reviews]?
    let work_details: NSInteger?
    let user_id : String?
    let user_services:String?
    let user_status:String?
    var message_status:String?
    var email_status:String?
    let job_ratio: String?
    var quoteExpireDate: String?
    var quoteQty: String?
    var remainingQuote: String?
}

struct reviews: Decodable{
    let _id : String?
    let from_user_id : String?
    let to_user_id : String?
    let job_id : String?
    let rating : String?
    let review_message : String?
    let review_by : String?
    let review_like : String?
    let like_by : String?
    let created_date : String?
    var total_like : String?
    var is_like : String?
    var from_user_name : String?
}
