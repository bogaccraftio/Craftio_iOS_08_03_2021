
import Foundation
import UIKit

//MARK:- Appdelegate Object
var appDelegate = UIApplication.shared.delegate as! AppDelegate


//MARK:- Google Map API Key
let Google_Map_API_Key = "AIzaSyC_YWfdWGvvKJJVqnTEudk2en4K-Czv0W4"
//"AIzaSyA_q7ntm2kM1imt2bFruFCq_gaW8K4IjBQ"//

//MARK:- API Related Object
let CONNECTION_TITLE = "Connection Error!"
let CONNECTION_MSG = "The Internet connection appears to be offline."

//MARK:- Email Validation String
let Email_RegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

//MARK:- Mobile 123-123-1234 Format String
let Phone_RegEx_Format = "^\\d{3}-\\d{3}-\\d{4}$"

//MARK:- Mobile with Plus(+) Sign String 
let Phone_RegEx_PlusSign = "^((\\+)|(00))[0-9]{6,10}$"

//MARK:- Mobile 10 Digit String
let Phone_RegEx_10Digit = "[0-9]{10}"

//MARK:- Zip/Pin Code 6 Digit String
let Zip_RegEx = "[0-9]{6}"

//MARK:- Password Validation String
let Password_RegEx = "(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{6,}"

//MARK:- USER TYPE
let Client = "1"
let Crafter = "2"

//MARK:- DEVCIE TYPE
let deviceType = "1"

//MARK:- BASE URL
let baseURL = "http://craftio.craftio.net/API/"//"http://ybtestserver.in/Craftios/API/"


//MARK:- API URL
let loginAPI = baseURL + "logIn"
let logoutAPI = baseURL + "logOut"
let registerationAPI = baseURL + "registration"
let forgotPasswordAPI = baseURL + "forgotPassword"
let getServiceList = baseURL + "getAllServices"
let getJobListing = baseURL + "getJobListing"
let getNearbyMeCrafter = baseURL + "getNearbyMeHandyman"
let getNearByMeJob = baseURL + "getNearByMeJobHandyman"
let getSettingData = baseURL + "getSettingData"
let updateCrafter = baseURL + "updateHandyman"

let AddServices = baseURL + "AddServices"
let blockUnblockUser = baseURL + "blockUnblockUser"
let createJob = baseURL + "createJob"
let deleteJob = baseURL + "deleteJob"
let getBlockUserList = baseURL + "getBlockUserList"
let getHireCrafterList = baseURL + "getHireHandymanList"
let getNotificationList = baseURL + "getNotificationList"
let getStaticPage = baseURL + "getStaticPage"
let updateUserLocation = baseURL + "updateUserLocation"
let updateUserProfile = baseURL + "updateUserProfile"
let AddReview = baseURL + "AddReview"
let changeNotificationStatus = baseURL + "changeNotificationStatus"
let getUserProfile = baseURL + "getUserProfile"
let giveReviewLike = baseURL + "giveReviewLike"
let deleteJobImages = baseURL + "deleteJobImages"
let getUserInfo = baseURL + "getUserInfo"
let getAllServicesNew = baseURL + "getAllServicesNew"
let changeUserStatus = baseURL + "changeUserStatus"
let getNotificationCount = baseURL + "getNotificationCount"
let emailCheck = baseURL + "emailCheck"
let changeJobStatus = baseURL + "changeJobStatus"
let makeOffer = baseURL + "makeOffer"
let getJobDetail = baseURL + "getJobDetail"
let getAllServicesData = baseURL + "getAllServicesData"
let reportUser = baseURL + "reportUser"
let getNeedHelp = baseURL + "getNeedHelp"
let changeStatus = baseURL + "changeStatus"
let sendNotificationForQuote = baseURL + "sendNotification"
let changeNotificationCount = baseURL + "changeNotificationCount"
let updateDefaultImage = baseURL + "updateDefaultImage"
let getReviewList = baseURL + "getReviewList"
let getCommissionData = baseURL + "getCommissionData"

let getPlaceholders = baseURL + "getPlaceholders"
let getAllCountry = baseURL + "getAllCountry"
let savePersonalInformation = baseURL + "savePersonalInformation"
let getPersonalInformation = baseURL + "getPersonalInformation"
let setPaymentTags = baseURL + "setPaymentTags"
let saveUserChatData = baseURL + "saveUserChatData"
let generateClientSecret = baseURL + "generateClientSecret"
let changeJobCancellationStatus = baseURL + "changeJobCancellationStatus"
let saveChatData = baseURL + "saveChatData"
let sendPaymentRequest = baseURL + "sendPaymentRequest"
let getPaymentCredential = baseURL + "getPaymentCredential"
let addPaymentForCrafter = baseURL + "addPaymentForHandyman"
let sendChatNotification = baseURL + "sendChatNotification"
let deleteChatNotification = baseURL + "deleteChatNotification"



struct PaymentType {
    static let none = "0"
    static let depositNow = "1"
    static let depositLater = "2"
    static let releaseSomeFund = "3"
    static let releaseAll = "4"
}

struct PaymentTag {
    static let stripe = "1"
    static let ApplePay = "4"
}



let crafterCancelJobOwnMessage = "cancelled the job."
let crafterCancelJobClientMessage = "cancelled the job."
let crafterCancelJobClientMessageAfterPayment = "cancelled the job. We will refund your deposit in 3 working days."
let clientCancelJobOwnMessage = "cancelled the job."
let clientCancelJobCrafterMessage = "cancelled the job."
let clientCancelJobAfterPaymentOwnMessage = "job cancellation request has been sent to crafter. Please wait for your crafters response. Thank you."
let clientCancelJobAfterPaymentCrafterMessage = "sent a job cancellation request. Please accept or decline the cancellation request."
let crafterAcceptJobCancellationOwnMessage = "accepted client's request to cancel the job."
let crafterAcceptJobCancellationClientMessage = "accepted your job cancellation request. We will refund your deposit in 3 working days."
let crafterCancelJobCancellationOwnMessage = "declined client's job cancellation request. Now job is under dispute. We sent a message to client including your contact details. Please kindly wait for client to contact you. Thank you."
let crafterCancelJobCancellationClientMessage = "does not accept job cancellation and its under dispute now. Please download the file to see how to proceed."

let crafterCancelJobCancellationForPDF = "Crafter declined cancellation request. Now job is under dispute."
let crafterAcceptJobCancellationForPDF = "Crafter accepted client's request to cancel the job."
