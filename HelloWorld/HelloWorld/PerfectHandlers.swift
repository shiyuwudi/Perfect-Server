//
//  PerfectHandlers.swift
//  HelloWorld
//
//  Created by apple2 on 16/2/28.
//  Copyright shiyuwudi 2016年. All rights reserved.
//

import PerfectLib
import MySQL

let HOST = "127.0.0.1"
let USER = "root"
let PASSWORD = "123456"
let SCHEME = "clouddiaryDB"

// This is the function which all Perfect Server modules must expose.
// The system will load the module and call this function.
// In here, register any handlers or perform any one-time tasks.
public func PerfectServerModuleInit() {
    Routing.Handler.registerGlobally()
    Routing.Routes["GET", ["/"]] = { (_:WebResponse) in return PerfectHandler() }
    
    Routing.Routes["GET", ["/test.htm"]] = { (_:WebResponse) in
        let handler = PerfectHandler()
        handler.type = "test"
        return handler
    }
    
    print("\(Routing.Routes.description)")
}

//Create a handler for index Route
class PerfectHandler: RequestHandler {
    
    var type : String?
    
    func handleRequest(request: WebRequest, response: WebResponse) {
        
        response.addHeader("Content-Type", value: "application/json")
        response.addHeader("Content-Type", value: "text/html; charset=utf-8")
        
        let mysql = MySQL()
        let connect = mysql.connect(HOST, user: USER, password: PASSWORD)
        if(connect)
        {
            let sres = mysql.selectDatabase(SCHEME)
            if(sres)
            {
                
                let sres2 = mysql.query("SELECT * FROM account_table")
                
                if(sres2)
                {
                    let results = mysql.storeResults()!
                    
                    
                    
                    if(results.numRows()==0)
                    {
                        do{
                            
                            
                            let encoder = JSONEncoder()
                            let data = try encoder.encode(["result": ""])
                            response.appendBodyString(data)
                        }
                        catch{
                            response.setStatus(500, message: "Could not create data")
                        }
                    }
                    else
                    {
                        
                        var dataArray:Array<AnyObject> = []
                        var dict = Dictionary<String,String>()
                        
                        if type != nil && type == "test" {
                            while let row = results.next() {
                                
                                dict["username"] = row[0];
                                dict["password"] = row[1];
                                dataArray.append(dict)
                                
                            }
                        } else {
                            while let row = results.next() {
                                
                                dict["username"] = row[0];
                                dataArray.append(dict)
                                
                            }
                        }
                        
                        print(NSJSONSerialization.isValidJSONObject(dataArray))
                        
                        
                        do {
                            
                            
                            let dataFinal = try NSJSONSerialization.dataWithJSONObject(dataArray, options:NSJSONWritingOptions(rawValue:0))
                            
                            let string = NSString(data: dataFinal, encoding: NSUTF8StringEncoding)
                            
                            let tee : String = string as! String
                            response.appendBodyString(tee)
                        }
                        catch{
                            response.setStatus(500, message: "Could not create data")
                        }
                        
                        
                        
                    }
                    
                    
                    
                    
                    results.close()
                }
            }
            mysql.close()
        }
        response.requestCompletedCallback()
    }
}


