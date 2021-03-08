struct NotificationListData: Decodable
{
    let _id : String?
    let jobdetail_id : String?
    let from_id : String?
    let to_id : String?
    let message : String?
    let type : String?
    let is_read : String?
    let created_date : String?
    let send_user_type : String?
    let to_user_type : String?
    let send_user_name : String?
    let send_user_profile : String?
    let to_user_name : String?
    let notification_time : String?
    let Time : String?
    let jobs: JobHistoryData?
    let is_open: String?
}
