
import UIKit

struct JobHistoryData: Decodable
{
    let _id:String?
    let client_id: String?
    let service_id: String?
    let device_token: String?
    let full_name: String?
    let description: String?
    let booking_amount: String?
    let accept_time: String?
    let complete_time: String?
    let booking_date: String?
    let handyman_id: String?
    let booking_status: String?
    let created_date: String?
    let client_latitude: String?
    let client_longitude: String?
    let address: String?
    let user_name: String?
    let user_id: String?
    let total_rating: String?
    let service_name: String?
    let service_image: String?
    let ser_description: String?
    let job_id: String?
    let profile_image:String?
    var first_name:String?
    var last_name:String?
    var media: [media]
    var chat_option_status: String?
    let reported_handyman: NSInteger?
    let reported_client: NSInteger?
    let is_block: String?
    let message_status:String?
    let email_status:String?
    let notification_status : String?
    let is_review : String?
    let job_review: String?
    let is_acceptable: String?
    let is_emergency_job : Int?
    let client_name: String?
    let client_profile_image: String?
    let total_jobs: String?
    let is_payment_done: String?
    let payment_tag: String?
    let remaining_amount: String?
    let payment_array: [payment_array]
    let payment_date: String?
    let is_archive: String?
    let is_delete: String?
    let cancellation_status: String?
    let cancelled_by: String?
    let cancelled_user_type: String?
    let review_tag: String?
    let review_id: String?
    let cancellation_time: String?
    var city: String?
    let cancellation_reason: String? //(1 : Wrong quote, 2 : Accepted by mistake, 3 : Other)
    var isFreeQuote: String? //1: Free, 0: paid
    var is_resolved:String?
}

struct media: Decodable
{
    let _id: String?
    let jobdetail_id:String?
    let media_url: String?
    let created_date:String?
    let is_default:String?
}

struct payment_array: Decodable{
    let message:String?
}
