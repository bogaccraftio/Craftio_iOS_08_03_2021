
import Foundation

struct firebaseMessage: Decodable {
    let message: String?
    let messageTime: String?
    let senderId: String?
    let isRead: String?
    let conversationId: String?
    let messageid: String?
    let timeinterval: String?
    let isOnlyDisplayOnClientSide: String?
    let iscancellationType: String? // 1 = Cancel, 2 = request for cancel by client, 3 = decline by crafter, 4= accept by crafter
    let isCancelledUser: String?
    let senderUserType: String?
    let isSystemMessage: String?
}

