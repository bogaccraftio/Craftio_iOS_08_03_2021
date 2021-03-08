

import Foundation

struct firebaseChatUsers: Decodable {
    let user_id: String?
    let lastmessage: String?
    let conversationId: String?
    let lastmessagetime: String?
    let unreadMessageCount: Int?
    let timeinterval: String?
    let activeJobID: String?
    let chat_option_status: String?
    let jobprice: String?
    let jobconversionId: String?
    let jobCategory: String?
    let isRead: String?
    let senderId: String?
    let iscancellationType: String? // 1 = Cancel, 2 = request for cancel by client, 3 = decline by crafter, 4= accept by crafter
    let isCancelledUser: String?
    let senderUserType: String?
}

struct jobsAdded: Decodable{
    let job_id: String?
    let lastmessage: String?
    let conversationId: String?
    let lastmessagetime: String?
    let unreadMessageCount: Int?
    let timeinterval: String?
    let chat_option_status: String?
    let jobprice: String?
    let isRead: String?
    let senderId: String?
    let CrafterId: String?
    let ClientId: String?
    let service_image: String?
    let service_description: String?
    let jobdetailID: String?
    let payment_tag: String?
    let iscancellationType: String? // 1 = Cancel, 2 = request for cancel by client, 3 = decline by crafter, 4= accept by crafter
    let isCancelledUser: String?
    let senderUserType: String?
}

