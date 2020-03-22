//
//  RequestManager.swift
//  Reework
//
//  Created by Vivek Gajbe on 10/30/18.
//  Copyright © 2018 Intelegain. All rights reserved.
//

import UIKit

///description: api methods
enum apiMethod: String{
    case POST = "POST"
    case GET = "GET"
}

class RequestManager: NSObject
{
        /// common method is used for "POST", "GET", "DELETE", "PUT" type of request
        ///
        /// - Parameters:
        ///   - strAPIName: api name (procedure name)
        ///   - strParameterName: input param
        ///   - completion: return type
    func requestCommonMethod(strAPIName :String ,strParameterName : [String:Any] ,strMethod: apiMethod,completion:@escaping (_ response:Any?,_ completed:Bool,_ errorMessage : String)->Void)
        {
            let url : String = GAUrlConstants.BaseURl
            
            let headers = [ "content-type": "application/json",]
          
            
            do{
                let postData = try JSONSerialization.data(withJSONObject: strParameterName, options: [])
                
                let request = NSMutableURLRequest(url: NSURL(string: url)! as URL,
                                                  cachePolicy: .useProtocolCachePolicy,
                                                  timeoutInterval: 120.0)
                
                request.httpMethod = strMethod.rawValue
                request.allHTTPHeaderFields = headers
                //request.httpBody = postData as Data
                
                let session = URLSession.shared
                let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                    if (error != nil) {
                        completion(nil,false,error as? String ?? "WebServiceError" )
                    } else {
                        DispatchQueue.main.async {
                            let httpResponse = response as! HTTPURLResponse
                            let statusCode = httpResponse.statusCode
                            
                            do{
                                
                                if statusCode == 200 //Success
                                {
                                    completion(data,true,"")
                                }
                                else if statusCode == 401 //Unauthorized User 
                                {
                                    completion(data,false, "")
                                }else{
                                     completion(nil,false,"")
                                }
                            }catch
                            {
                                print("Error with Json: \(error)")
                                completion(nil,false,error as? String ?? "WebServiceError" )
                            }
                            
                        }
                    }
                })
                dataTask.resume()
            }catch {
                print("Error with Json: \(error)")
                completion(nil,false,error as? String ?? "WebServiceError")
            }
            
        }
}
