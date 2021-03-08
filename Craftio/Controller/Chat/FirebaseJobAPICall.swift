
import UIKit
import Firebase

class FirebaseJobAPICall {

    //get Jobs
    class func firebaseGetJob(myId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if myId == ""{
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(myId).observe(.value, with: { (snap) in
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
                    let data = NSMutableArray()
                    for detail in arrdata
                    {
                        if ((detail as? [String:Any]) != nil){
                            data.add(detail)
                        }
                    }
                    do {
                        let jsonObject = try JSONSerialization.data(withJSONObject: data, options: []) as AnyObject
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

    //Add Jobs
    class func firebaseAddJobs(myId:String,jobId:String,jobDetail:[String:Any],completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if myId == "" || jobId == ""{
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(myId).child(jobId).setValue(jobDetail)
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

    //Update UnreadMessageCount toJob
    class func FirebaseupdateMessageCountTOJob(UserID:String,JobId:String,detail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if UserID == "" || JobId == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(UserID).child(JobId).updateChildValues(detail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Update last message
    class func FirebaseupdateLastMessage(MyuserId:String,jobId:String,ChatuserDetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if MyuserId == "" || jobId == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(MyuserId).child(jobId).updateChildValues(ChatuserDetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
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

    //Update Job CHat Status
    class func FirebaseupdatejobStatus(userId:String,jobId:String,jobdetail:[String:Any],completion: @escaping (Bool) -> Swift.Void) {
        if userId == "" || jobId == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(userId).child(jobId).updateChildValues(jobdetail, withCompletionBlock: { (errr, _) in
            if errr == nil {
                completion(true)
            }
        })
    }
    
    //Add Jobs IDs to USer
    class func firebaseAddJobsToUser(userId:String,jobIds:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if userId == "" || jobIds == ""{
            completion(false, "", nil)
            return
        }
    APPDELEGATE?.ref.child("User").child(userId).child("jobs").child("jobIds").setValue(jobIds)
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

    class func firebaseGetJobToUser(myId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if myId == ""{
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("User").child(myId).child("jobs").observe(.value, with: { (snap) in
            if snap.exists() {
                
                if ((snap.value as? NSDictionary) != nil){
                    
                    let user = snap.value as! NSDictionary
                    completion(true,"", user as AnyObject)
                }else{
                    let user = snap.value as! NSArray
                    completion(true,"", user as AnyObject)
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }
    
    class func firebaseGetJobDEtail(myId:String,jobId:String,completion: @escaping (_ success: Bool, _ error : String, _ object: AnyObject?) -> ())
    {
        if myId == ""{
            completion(false, "", nil)
            return
        }
        APPDELEGATE?.ref.child("User").child(myId).child(jobId).observe(.value, with: { (snap) in
            if snap.exists() {
                
                if ((snap.value as? NSDictionary) != nil){
                    
                    let user = snap.value as! NSDictionary
                    completion(true,"", user as AnyObject)
                }else{
                    let user = snap.value as! NSArray
                    completion(true,"", user as AnyObject)
                }
                
                //print(user)
            }
            else{
                completion(false,"", "" as AnyObject)
            }
        })
    }


    
    //Send Notfication
    class func sendNotificationusingfirebase(withDeviceToken strdeviceToken: String, body strbody: String, title strTitle: String, detail dictDetail: [AnyHashable: Any])
    {
        var dictparam = [AnyHashable: Any]()
        dictparam["to"] = strdeviceToken
        dictparam["priority"] = "high"
        var dictdetaildata = [AnyHashable: Any]()
        dictdetaildata["body"] = strbody
        dictdetaildata["title"] = strTitle
        dictdetaildata["data"] = dictDetail
        dictdetaildata["sound"] = "default"
        dictdetaildata["badge"] = "1"
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
    
    class func firebasedelete(myId:String,jobId:String,completion: @escaping (_ success: Bool) -> ()){
        if myId == "" || jobId == ""{
            completion(false)
            return
        }
        APPDELEGATE?.ref.child("Jobs").child(myId).child(jobId).removeValue(completionBlock: { (error, SNAP) in
            if error == nil {
                completion(true)
            }
        })

    }

}




//Sort Array
func sortArray(key:String, ascending:Bool, arr:NSArray) -> NSArray{
    let ns = NSSortDescriptor.init(key: key, ascending: ascending)
    let aa = NSArray(object: ns)
    let arrResult = arr.sortedArray(using: aa as! [NSSortDescriptor])
    return arrResult as NSArray
}

func convertoJObsDetail(detail:Array<Any>) -> [jobsAdded]{
    let user = detail
    let arr = NSMutableArray()
    arr.addObjects(from: user)
    let arrdata = sortArray(key:"timeinterval", ascending:false,arr:arr)
    
    do {
        let jsonObject = try JSONSerialization.data(withJSONObject: arrdata, options: []) as AnyObject
        let conversion = try? JSONDecoder().decode([jobsAdded].self, from: jsonObject as! Data)
        return conversion ?? []
    } catch let jsonerror {
        print(jsonerror.localizedDescription)
        return []
    }
}


func getTimeInterval() -> String
{
    let timeinterval = Date().timeIntervalSince1970
    return "\(timeinterval)"
}

var fourDigitNumber: String {
    var result = ""
    repeat {
        // Create a string with a random number 0...9999
        result = String(format:"%04d", arc4random_uniform(10000000) )
    } while result.count < 4
    return result
}



class changeChatStatus{
    static let NotAny = "0"
    static let GiveAQuote = "1"
    static let YesIAccept = "2"
    static let Accept_Decline_Counter = "3"
    static let Counter = "4"
    static let Accept = "5"
    static let Decline = "6"
    static let Completed = "7"
    static let done = "8"
    static let report = "9"
}
