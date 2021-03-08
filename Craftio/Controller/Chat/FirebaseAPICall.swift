
import UIKit
import Firebase

class FirebaseAPICall {
    
    //Insert User detail
    class func SaveUserToFirebase(userId:String,userdetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if userId == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("User").child(userId).child("Credentials").updateChildValues(userdetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Add user to My ChatList
    class func firebaseAddUserToMyChatList(MyuserId:String,OponnentUserID:String,ChatuserDetail:[String:Any],completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if MyuserId == "" || OponnentUserID == ""{
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(OponnentUserID).setValue(ChatuserDetail)
        {(error, data) in
            if (error != nil)
            {
                print(error!)
                completion(false,"", nil)
            }
            else
            {
                completion(true,"", nil)
            }
        }
    }
    
    //Add Jobs
    class func firebaseAddJobs(jobConverionId:String,jobId:String,jobDetail:[String:Any],completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if jobConverionId == "" || jobId == ""{
            completion(false, "", nil)
            return
        }
         APPDELEGATE?.ref.child("Jobs").child(jobConverionId).child(jobId).setValue(jobDetail)
        {(error, data) in
            if (error != nil)
            {
                print(error!)
                completion(false,"", nil)
            }
            else
            {
                completion(true,"", nil)
            }
        }
    }
    
    //get Jobs
    class func firebaseGetJobs(jobConverionId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if jobConverionId == "" {
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(jobConverionId).observe(.value, with: { (snap) in
            if snap.exists() {
                
                if ((snap.value as? NSDictionary) != nil){
                    let user = snap.value as! NSDictionary
                    let arr = NSMutableArray()
                    arr.addObjects(from: user.allValues)
                    
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:arr)
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }else{
                    let user = snap.value as! NSArray
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:(user))
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }


    
    //Update last message
    class func FirebaseupdateLastMessage(MyuserId:String,OponnentUserID:String,ChatuserDetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if MyuserId == "" || OponnentUserID == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(OponnentUserID).updateChildValues(ChatuserDetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Update last message
    class func FirebaseupdateLastMessageJob(MyuserId:String,OponnentUserID:String,ChatuserDetail:[String:Any],jobconversationId:String,jobId:String,jobLastmesageDetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        
        if MyuserId == "" || OponnentUserID == "" || jobconversationId == "" || jobId == "" {
            completion(false)
            return
        }

        //Update to User
        APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(OponnentUserID).updateChildValues(ChatuserDetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
        
        //Update to Job
        APPDELEGATE?.ref.child("Jobs").child(jobconversationId).child(jobId).updateChildValues(jobLastmesageDetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
        
    }

    
    //Get selected USer from Firebase
    class func firebaseGetselectedUser(MyuserId:String,oponnentId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if MyuserId == "" || oponnentId == "" {
            completion(false, "", nil)
            return
        }
    APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(oponnentId).observe(.value, with: { (snap) in
            if snap.exists() {
                
                if ((snap.value as? NSDictionary) != nil){
                    let user = snap.value as! NSDictionary
                    let arr = NSMutableArray()
                    arr.add(user)
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:arr)
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }else{
                    let user = snap.value as! NSArray
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:(user))
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }
    
    
    //Get Users from my CHat List
    class func firebaseGetchatusers(MyuserId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if MyuserId == "" {
            completion(false, "", nil)
            return
        }

        APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").observe(.value, with: { (snap) in
            if snap.exists() {
                
                if ((snap.value as? NSDictionary) != nil){
                    let user = snap.value as! NSDictionary
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:(user.allValues as NSArray))
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }else{
                    let user = snap.value
                    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:(user as! NSArray))
                    let nonNilElements = arrdata.compactMap { $0 }
                    let muablearray = NSMutableArray()
                    muablearray.addObjects(from: arrdata as! [Any])
                    var removingArray = [Any]()
                    for item in muablearray
                    {
                        if ((item as? NSDictionary) != nil){
                            
                        }else{
                            removingArray.append(item)
                        }
                    }
                    muablearray.removeObjects(in: removingArray)

                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: muablearray, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }
    
    //Create Conversation
    class func createConversation(conversationId:String,messageId:String,messagedetail:[String:Any],completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())  {
        if conversationId == "" || messageId == "" {
            completion(false, "", nil)
            return
        }
     APPDELEGATE?.ref.child("Chat").child(conversationId).child(messageId).setValue(messagedetail)
            {(error, data) in
                if (error != nil)
                {
                    print(error!)
                    completion(false,"", nil)
                }
                else
                {
                    completion(true,"", nil)
                }
            }
    }
    
    //send Message
    class func firebaseSendMessage(conversationId:String,messageId:String,messsageDetail:[String:Any],completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if conversationId == "" || messageId == "" {
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("Chat").child(conversationId).child(messageId).setValue(messsageDetail)
        {(error, data) in
            if (error != nil)
            {
                print(error!)
                completion(false,"", nil)
            }
            else
            {
                completion(true,"", nil)
            }
        }
    }
    
    //Get Messages
    class func firebaseGetMessages(conversationId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if conversationId == ""{
            completion(false, "", nil)
            return
        }

        APPDELEGATE?.ref.child("Chat").child(conversationId).observe(.value, with: { (snap) in
            if snap.exists() {
                
                
                if ((snap.value as? NSDictionary) != nil){
                    let user = snap.value as! NSDictionary
                    let arrdata = sortArray(key:"timeinterval", ascending:true,arr:(user.allValues as NSArray))
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }else{
                    let user = snap.value as! NSArray
                    let arrdata = sortArray(key:"timeinterval", ascending:true,arr:(user))
                    
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
                        completion(true,"", jsonObject as AnyObject)
                    } catch let jsonerror {
                        print(jsonerror.localizedDescription)
                        completion(false,"", "" as AnyObject)
                    }
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }
    
    //Update Job CHat Status
    class func FirebaseupdatejobStatus(jobconversionId:String,jobId:String,jobdetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if jobconversionId == "" || jobId == ""{
            completion(false)
            return
        }
    APPDELEGATE?.ref.child("Jobs").child(jobconversionId).child(jobId).updateChildValues(jobdetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Update Quote Of selected Job from CHat
    class func FirebaseupdateQuote(MyuserId:String,OponnentUserID:String,Quote:String,completion: @escaping (Bool) -> Swift.Void) {
        var param = [String:Any]()
        if Quote == ""{
            param = ["jobprice":"\(0)"]
        }else{
            param = ["jobprice":"\(Quote)"]
        }
        if MyuserId == "" || OponnentUserID == ""{
            completion(false)
            return
        }
    APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(OponnentUserID).updateChildValues(param, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Update UnreadMessageCount
    class func FirebaseupdateMessageCount(MyuserId:String,OponnentUserID:String,count:Int,completion: @escaping (Bool) -> Swift.Void) {
        let param = ["unreadMessageCount":count]
        if MyuserId == "" || OponnentUserID == ""{
            completion(false)
            return
        }
    APPDELEGATE?.ref.child("User").child(MyuserId).child("chatusers").child(OponnentUserID).updateChildValues(param, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }

    //Update UnreadMessageCount toJob
    class func FirebaseupdateMessageCountTOJob(jobConversationId:String,JobId:String,detail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if jobConversationId == "" || JobId == ""{
            completion(false)
            return
        }
    APPDELEGATE?.ref.child("Jobs").child(jobConversationId).child(JobId).updateChildValues(detail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    class func sendNotificationusingfirebase(withDeviceToken strdeviceToken: String, body strbody: String, title strTitle: String, detail dictDetail: [AnyHashable: Any], badgeNumber: String)
    {
        var dictparam = [AnyHashable: Any]()
        dictparam["to"] = strdeviceToken
        dictparam["priority"] = "high"
        var dictdetaildata = [AnyHashable: Any]()
        dictdetaildata["body"] = strbody
        dictdetaildata["title"] = strTitle
        dictdetaildata["data"] = dictDetail
        dictdetaildata["sound"] = "default"
        dictdetaildata["badge"] = "\(badgeNumber)"
        dictparam["notification"] = dictdetaildata
        let defaultConfigObject = URLSessionConfiguration.default
        let defaultSession = URLSession(configuration: defaultConfigObject, delegate: nil, delegateQueue: OperationQueue.main)
        //Create an URLRequest
        let url = URL(string: "https://fcm.googleapis.com/fcm/send")
        var urlRequest = URLRequest(url: url!)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("key=AAAAx7K6wiI:APA91bEPURuJGad5KyA6uU4RavtNQpnTFZjg-xOLzckkt-TANHl2goG75Svkc0xRgLWsT2IvrD0MyFQCQEoOvlOK0ESBOIGJazn4IdaE7cFa0NbPBd8hdBe-mf8JhgmFpeu7sjDYnOqn", forHTTPHeaderField: "Authorization")
        //Create POST Params and add it to HTTPBody
        var error: Error?
        var jsondata: Data? = try? JSONSerialization.data(withJSONObject: dictparam, options: .prettyPrinted)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("\(UInt((jsondata?.count)!))", forHTTPHeaderField: "Content-Length")
        urlRequest.httpBody = jsondata
        //Create task
        let task = defaultSession.dataTask(with: urlRequest, completionHandler: {(data, response, error) -> Void in
            if let data = data {
                print("THIS ONE IS PRINTED, TOO")
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                if let response = response as? HTTPURLResponse , 200...299 ~= response.statusCode {
                } else {
                }
            }
        })
        task.resume()
        
    }


}
