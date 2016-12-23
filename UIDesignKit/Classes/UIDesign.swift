//
//  UIDesign.swift
//  Pods
//
//  Created by Will Powell on 22/11/2016.
//
//

import Foundation
import SocketIO

public enum UIDesignError: Error {
    case invalidDesignKey(key:String)
}


public enum UIDesignType: String
{
    case color = "COLOR"
    case font = "FONT"
    case url = "URL"
    case int = "INT"
    case float = "FLOAT"
    case string = "STRING"
    case bool = "BOOL"
}

public enum UIUserInterfaceIdiom : Int {
    case Unspecified
    
    case Phone // iPhone and iPod touch style UI
    case Pad // iPad style UI
}

public class UIDesign {
    
    public static var server:String = "http://www.uidesignkit.com:3000";
    
    public static var socket:SocketIOClient?
    
    private static var appKey:String?
    public static var deviceType:String = ""
    
    
    private static var loadedDesign:[AnyHashable:Any]?
    
    public static var LOADED = Notification.Name(rawValue: "LOADED_DESIGN")
    
    
    private static var _liveEnabled:Bool = false;
    
    public static var liveEnabled:Bool {
        get {
            return _liveEnabled;
        }
        set (newValue){
            if(_liveEnabled != newValue){
                _liveEnabled = newValue
                if(newValue){
                    startSocket();
                }else{
                    // end socket
                    if((self.socket) != nil){
                        self.socket?.disconnect()
                    }
                }
            }
            
        }
    }
    
    
    public static func start(appKey:String, live:Bool){
        self.appKey = appKey
        loadDesign();
        self.liveEnabled = live;
        
    }
    
    public static func start(appKey:String, useSettings:Bool){
        self.appKey = appKey
        NotificationCenter.default.addObserver(self, selector: #selector(UIDesign.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
        loadDesign();
    }
    
    @objc public static func defaultsChanged(){
        let userDefaults = UserDefaults.standard
        let val = userDefaults.bool(forKey: "live_design");
        if(val == true && self.liveEnabled == false){
            loadDesign();
        }
        self.liveEnabled = val;
    }

    
    
    public static func start(appKey:String){
        self.appKey = appKey
        self.deviceType = "iPhone"
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.deviceType = "iPhone"
        case .pad:
            self.deviceType = "iPad"
        case .unspecified:
            self.deviceType = "universal"
        default:
            self.deviceType = "universal"
            break
        }
        loadDesign();
        
        startSocket();
        
    }
    
    public static func saveDesignToDisk(design:[AnyHashable:Any]){
        let standard = UserDefaults.standard;
        standard.set(design, forKey: "UIDesign");
        standard.synchronize()
    }
    
    public static func loadDesignFromDisk(){
        let standard = UserDefaults.standard
        guard let data = standard.object(forKey: "UIDesign") else {
            return
        }
        self.loadedDesign = data as! [AnyHashable:Any];
        NotificationCenter.default.post(name: UIDesign.LOADED, object: self)
    }
    
    private static func loadDesign(){
        self.loadDesignFromDisk();
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = UIDesign.server+"/api/app/\((self.appKey)!)/data"
        let url = URL(string: urlString as String)
        session.dataTask(with: url!) {
            (data, response, error) in
            if (response as? HTTPURLResponse) != nil {
                do {
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [AnyHashable:Any]
                    loadedDesign = json?["data"] as! [AnyHashable:Any];
                    saveDesignToDisk(design: self.loadedDesign!);
                    NotificationCenter.default.post(name: UIDesign.LOADED, object: self)
                } catch {
                    print("error serializing JSON: \(error)")
                }
                
            }
            }.resume()
    }
    
    
    private static func startSocket(){
        let url = URL(string: server)
        socket = SocketIOClient(socketURL: url!)
        socket?.on("connect", callback: {(data,ack) in
            let appRoom = "\((self.appKey)!)"
            sendMessage(type: "join", data: ["room":appRoom])
            NotificationCenter.default.post(name: LOADED, object: self)
        })
        socket?.on("highlight", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
            let meta = dictionary["meta"] as! String
            let event = "DESIGN_HIGHLIGHT_\(meta)"
            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
        })
        socket?.on("design", callback: {(data,ack) in
            let dictionary = data[0] as! [AnyHashable : Any]
            let key = dictionary["key"] as! String
            let property = dictionary["property"] as! String
            let form = dictionary["form"] as! String
            let value = dictionary["value"] as! String
            let elementData = self.loadedDesign?[key];
            
            var keyElement = self.loadedDesign?[key] as! [AnyHashable:Any]
            var keyData = keyElement["data"] as! [AnyHashable:Any]
            var outputProperties = [AnyHashable:Any]()
            for (vKey, vValue) in keyData {
                if(vKey as! String == property){
                    var vValueMod = vValue as! [AnyHashable:Any];
                    vValueMod[form] = value
                    outputProperties[vKey] = vValueMod
                }else{
                    outputProperties[vKey] = vValue
                }
            }
            keyElement["data"] = outputProperties
            self.loadedDesign?[key] = keyElement
            let event = "DESIGN_UPDATE_\(key)"
            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
        })
        socket?.connect()
    }
    
    
    private static func joinRoom(name:String){
        self.sendMessage(type: "join", data: ["room":name])
    }
    
    private static func leaveRoom(name:String){
        self.sendMessage(type: "leave", data: ["room":name])
    }
    
    private static func sendMessage(type:String, data:SocketData...){
        if socket?.status == SocketIOClientStatus.connected {
            socket?.emit(type, with: data)
        }
    }
    
    public static func get(_ key:String) -> [AnyHashable:Any]?{
        let m = self.loadedDesign
        if m == nil {
            return nil
        }
        
        guard let design =  self.loadedDesign?[key] as? [AnyHashable:Any] else {
            return nil;
        }
       
        return design
    }
    
    public static func createKey(_ key:String,type:String,  properties:[String:Any]){
        if socket?.status == SocketIOClientStatus.connected && self.loadedDesign?[key] == nil {
            //self.loadedDesign?[key] = key
            self.sendMessage(type: "key:add", data: ["appuuid":self.appKey!, "type":type, "key":key, "properties":properties])
            self.loadedDesign?[key] = ["type": type, "data":properties];
        }
    }
    
    public static func addPropertyToKey(_ key:String, property:String, attribute:Any){
        if socket?.status == SocketIOClientStatus.connected {
            
            self.sendMessage(type: "key:add_property", data: ["appuuid":self.appKey!, "key":key, "name":property, "attribute":attribute])
            let attr = attribute  as! [AnyHashable:Any]
            var keyElement = self.loadedDesign?[key] as! [AnyHashable:Any]
            var keyData = keyElement["data"] as! [AnyHashable:Any]
            keyData[property] = ["universal":attr["value"]]
            keyElement["data"] = keyData
            self.loadedDesign?[key] = keyElement
        }
    }
}
