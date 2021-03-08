
import UIKit

struct JobNearByData: Decodable
{
    let _id:String?
    let first_name: String?
    let last_name: String?
    let image: String?
    let email_id: String?
    let device_type: String?
    let device_token: String?
    let session_token: String?
    let user_name: String?
    let password: String?
    let gender: String?
    let age: String?
    let mobile_no: String?
    let user_type: String?
    let created_date: String?
    let modified_date: String?
    let available_status: String?
    let profile_image: String?
    let total_rating: String?
    let notification_status: String?
    let user_latitude: String?
    let user_longitude:  String?
    let user_address:  String?
    let distance:  String?
    let is_emergency_job : Int?
    let total_jobs: String?
}
