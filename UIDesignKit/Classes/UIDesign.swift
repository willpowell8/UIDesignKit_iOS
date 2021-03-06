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

public enum UIDesignAligment:String {
    case ltr = "ltr"
    case rtl = "rtl"
    case unknown = "unknown"
}

public enum UIDesignStatus {
    case connected
    case notConnected
    case disconnected
    case connecting
    case starting
    case unknown
}



public class UIDesign {
    
    static let textAlignmentOptions:[(label:String, value:Int)] = [
        (label:"Left", value: NSTextAlignment.left.rawValue),
        (label:"Right", value: NSTextAlignment.right.rawValue),
        (label:"Natural", value: NSTextAlignment.natural.rawValue),
        (label:"Center", value: NSTextAlignment.center.rawValue),
        (label:"Justified", value: NSTextAlignment.justified.rawValue)
    ]
    
    static let imageContentModeOptions:[(label:String, value:Int)] = [
        (label:"Aspect Fit", value: UIView.ContentMode.scaleAspectFit.rawValue),
        (label:"Aspect Fill", value: UIView.ContentMode.scaleAspectFill.rawValue),
        (label:"Scale Fill", value: UIView.ContentMode.scaleToFill.rawValue),
        (label:"Bottom", value: UIView.ContentMode.bottom.rawValue),
        (label:"Bottom Left", value: UIView.ContentMode.bottomLeft.rawValue),
        (label:"Bottom Right", value: UIView.ContentMode.bottomRight.rawValue),
        (label:"Center", value: UIView.ContentMode.center.rawValue),
        (label:"Left", value: UIView.ContentMode.left.rawValue),
        (label:"Right", value: UIView.ContentMode.right.rawValue),
        (label:"Top", value: UIView.ContentMode.top.rawValue),
        (label:"Top Left", value: UIView.ContentMode.topLeft.rawValue),
        (label:"Top Right", value: UIView.ContentMode.topRight.rawValue)
    ]
    
    public static var debug:Bool = false
    public static var server:String = "http://www.uidesignkit.com"
    
    public static var socket:SocketIOClient?
    public static var manager:SocketManager?
    
    internal static var appKey:String?
    public static var deviceType:String = ""
    
    private static var _appName:String?
    
    public static var appName:String?{
        get{
            return _appName
        }
    }
    
    public static var status:UIDesignStatus {
        get{
            guard let s = socket else {
                return UIDesignStatus.unknown
            }
            switch(s.status){
            case .connected:
                return UIDesignStatus.connected
            case .connecting:
                return UIDesignStatus.connecting
            case .disconnected:
                return UIDesignStatus.disconnected
            case .notConnected:
                return UIDesignStatus.notConnected
            }
        }
    }
    
    public static var layoutAlignment:UIDesignAligment = UIDesignAligment.ltr
    
    public static func updateLayoutAlignment(layout:UIDesignAligment){
        layoutAlignment = layout
        NotificationCenter.default.post(name: UIDesign.LOADED, object: self)
    }
    
    
    public static var ignoreRemote:Bool = false
    internal static var loadedDesign = [AnyHashable:Any]()
    private static var loadedTheme = [AnyHashable:Any]()
    
    public static var LOADED = Notification.Name(rawValue: "LOADED_DESIGN")
    public static var INLINE_EDIT_CHANGED = Notification.Name(rawValue: "UIDESIGN_INLINE_EDIT")
    public static var hasLoaded = false
    
    public static var allowInlineEdit = false {
        didSet{
            if oldValue != allowInlineEdit {
                NotificationCenter.default.post(name: UIDesign.INLINE_EDIT_CHANGED, object: nil)
            }
        }
    }
    
    
    private static var _liveEnabled:Bool = false;
    private static var eventHandler:((_ error:String?,_ result:String?) -> Void)?
    
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
    
    public static func stop(){
        _liveEnabled = false
        if let socket = self.socket {
            socket.disconnect()
        }
        self.loadedTheme = [AnyHashable:Any]()
        self.hasLoaded = false
        self.loadedDesign = [AnyHashable:Any]()
        self.socket = nil
        self.allowInlineEdit = false
        _appName = nil
        NotificationCenter.default.removeObserver(self, name:UserDefaults.didChangeNotification, object: nil)
    }
    
    
    public static func start(appKey:String, live:Bool, event:((_ error:String?,_ result:String?) -> Void)? = nil){
        guard self.appKey != appKey else {
            print("App Key Already Set")
            return
        }
        stop()
        eventHandler = event
        self.appKey = appKey
        loadDesign()
        self.liveEnabled = live
        
    }
    
    public static func start(appKey:String, useSettings:Bool, event:((_ error:String?,_ result:String?) -> Void)? = nil){
        guard self.appKey != appKey else {
            print("App Key Already Set")
            return
        }
        stop()
        eventHandler = event
        self.appKey = appKey
        var hasTriggeredLoad = false
        if useSettings == true {
            NotificationCenter.default.addObserver(self, selector: #selector(UIDesign.defaultsChanged),
                                               name: UserDefaults.didChangeNotification, object: nil)
            hasTriggeredLoad = UIDesign.defaultsChanged()
        }
        if hasTriggeredLoad == false {
            loadDesign()
        }
    }
    
    @objc public static func defaultsChanged()->Bool{
        var hasTriggeredLoad = false
        let userDefaults = UserDefaults.standard
        let val = userDefaults.bool(forKey: "live_design");
        if(val == true && self.liveEnabled == false){
            loadDesign()
            hasTriggeredLoad = true
        }
        self.liveEnabled = val;
        
        let inlineEdit = userDefaults.bool(forKey: "live_design_edit");
        self.allowInlineEdit = inlineEdit
        return hasTriggeredLoad
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
        guard self.hasLoaded == true else {
            return
        }
        let data = NSKeyedArchiver.archivedData(withRootObject: design)
        let standard = UserDefaults.standard;
        standard.set(data, forKey: "UIDesign");
        standard.synchronize()
    }
    
    public static func loadDesignFromDisk(){
        let standard = UserDefaults.standard
        var diskData:[AnyHashable:Any]?
        if let data = standard.object(forKey: "UIDesign") as? Data, let dataFromData = NSKeyedUnarchiver.unarchiveObject(with: data) as? [AnyHashable:Any] {
            diskData = dataFromData
        }else if let data = standard.object(forKey: "UIDesign") as? [AnyHashable:Any] {
            diskData = data
        }
        if let loaded = diskData, loaded.keys.count > 0 {
            self.loadedDesign = loaded
            self.hasLoaded = true
            NotificationCenter.default.post(name: UIDesign.LOADED, object: self)
        }
    }
    
    public static func showAllDesignKeysView(){
        let podBundle = Bundle(for: DesignInlineEditorHandler.self)
        let bundleURL = podBundle.url(forResource: "UIDesignKit", withExtension: "bundle")
        let bundle = Bundle(url: bundleURL!)!
        let v = UIStoryboard(name: "Storyboard", bundle: bundle).instantiateViewController(withIdentifier: "AllDesignKeysTableViewController")
        if let vc = UIApplication.shared.keyWindow?.rootViewController {
            let popController = UINavigationController(rootViewController: v)
            popController.navigationBar.barStyle = .default
            popController.modalPresentationStyle = .formSheet
            vc.present(popController, animated: false, completion: nil)
        }
    }
    
    private static func loadDesign(){
        self.loadDesignFromDisk();
        guard let appKey = self.appKey else{
            self.eventHandler?("No App Key", nil)
            return
        }
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        let urlString = UIDesign.server+"/api/app/\(appKey)/data"
        guard let url = URL(string: urlString as String) else{
            self.eventHandler?("Invalid URL", nil)
            return
        }
        session.dataTask(with: url) { (data, response, error) in
            if (response as? HTTPURLResponse) != nil, let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [AnyHashable:Any] {
                        if let appData = json["app"] as? [AnyHashable:Any]{
                            if let appName = appData["name"] as? String {
                                self._appName = appName
                            }
                        }
                        if let loaded = json["data"] as? [AnyHashable:Any] {
                            self.hasLoaded = true
                            self.loadedDesign = loaded
                            saveDesignToDisk(design: self.loadedDesign)
                            NotificationCenter.default.post(name: UIDesign.LOADED, object: self)
                            self.eventHandler?(nil, "Loaded")
                        }else{
                            // designs failed to load
                            self.eventHandler?("Failed to load design", nil)
                        }
                    }
                } catch {
                    print("error serializing JSON: \(error)")
                     self.eventHandler?("error serializing JSON", nil)
                }
                
            }else{
                self.eventHandler?("No response from url", nil)
            }
            }.resume()
    }
    
    
    private static func startSocket(){
        guard let url = URL(string: server) else{
            print("Socket URL error")
            return
        }
        let manager = SocketManager(socketURL: url, config: [.log(false), .compress])//, .path("/v2/socket.io")])
        self.manager = manager
        let socket = manager.defaultSocket
        socket.on("connect", callback: {(data,ack) in
            guard let appKey = self.appKey else{
                print("Socket Connected but no app key")
                return
            }
            let appRoom = "\(appKey)"
            sendMessage(type: "join", data: ["room":appRoom])
            NotificationCenter.default.post(name: LOADED, object: self)
        })
        socket.on("highlight", callback: {(data,ack) in
            guard let dictionary = data[0] as? [AnyHashable : Any], let meta = dictionary["meta"] as? String else{
                return
            }
            let event = "DESIGN_HIGHLIGHT_\(meta)"
            NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
        })
        socket.on("design", callback: {(data,ack) in
            guard let dictionary = data[0] as? [AnyHashable : Any] else{
                return
            }
            guard let key = dictionary["key"] as? String else{
                return
            }
            guard let property = dictionary["property"] as? String else{
                return
            }
            guard let form = dictionary["form"] as? String else{
                return
            }
            if let value = dictionary["value"] {
                self.updateLocalKeyProperty(key: key, property: property, form: form, value: value)
            }
        })
        socket.connect()
        self.socket = socket
    }
    
    
    private static func joinRoom(name:String){
        self.sendMessage(type: "join", data: ["room":name])
    }
    
    private static func leaveRoom(name:String){
        self.sendMessage(type: "leave", data: ["room":name])
    }
    
    private static func sendMessage(type:String, data:SocketData...){
        if socket?.status == .connected {
            socket?.emit(type, with: data)
        }
    }
    
    public static func get(_ key:String) -> [AnyHashable:Any]?{
        guard let design =  self.loadedDesign[key] as? [AnyHashable:Any] else {
            return nil;
        }
        return design
    }
    
    public static func createKey(_ key:String,type:String,  properties:[String:Any]){
        if socket?.status == .connected, loadedDesign[key] == nil, hasLoaded == true, let appKey = self.appKey, self.loadedDesign[key] == nil {
            self.sendMessage(type: "key:add", data: ["appuuid":appKey, "type":type, "key":key, "properties":properties])
            self.loadedDesign[key] = ["type": type, "data":properties]
            saveDesignToDisk(design: self.loadedDesign)
        }
    }
    
    public static func updateKeyProperty(_ key:String, property:String, value:Any ){
        if socket?.status == .connected, self.loadedDesign[key] != nil, self.hasLoaded == true, let appKey = self.appKey {
            self.sendMessage(type: "design:save", data: ["appuuid":appKey,"key":key, "property":property, "value":value])
            self.updateLocalKeyProperty(key: key, property: property, form: "universal", value: value)
        }
    }
    
    static func updateLocalKeyProperty(key:String, property:String, form:String, value:Any){
        guard var keyElement = self.loadedDesign[key] as? [AnyHashable:Any], let keyData = keyElement["data"] as? [AnyHashable:Any] else {
            return
        }
        var outputProperties = [AnyHashable:Any]()
        var shouldUpdate = false
        for (vKey, vValue) in keyData {
            if let vKeyStr = vKey as? String, vKeyStr == property{
                if var vValueMod = vValue as? [AnyHashable:Any] {
                    if let currentValue = vValueMod[form] as? AnyHashable, let val = value as? AnyHashable {
                        if currentValue != val {
                            vValueMod[form] = value
                            shouldUpdate = true
                        }
                    }else{
                        vValueMod[form] = value
                        shouldUpdate = true
                    }
                    outputProperties[vKey] = vValueMod
                }
            }else{
                outputProperties[vKey] = vValue
            }
        }
        guard shouldUpdate == true else {
            return
        }
        keyElement["data"] = outputProperties
        self.loadedDesign[key] = keyElement
        saveDesignToDisk(design: self.loadedDesign)
        let event = "DESIGN_UPDATE_\(key)"
        NotificationCenter.default.post(name: Notification.Name(rawValue: event), object: self)
    }
    
    public static func addPropertyToKey(_ key:String, property:String, attribute:Any){
        if socket?.status == .connected, self.hasLoaded == true, let appKey = self.appKey {
            self.sendMessage(type: "key:add_property", data: ["appuuid":appKey, "key":key, "name":property, "attribute":attribute])
            if let attr = attribute  as? [AnyHashable:Any],var keyElement = self.loadedDesign[key] as? [AnyHashable:Any],  var keyData = keyElement["data"] as? [AnyHashable:Any]{
                keyData[property] = ["universal":attr["value"]]
                keyElement["data"] = keyData
                self.loadedDesign[key] = keyElement
                saveDesignToDisk(design: self.loadedDesign)
            }
        }
    }
    
    public static func getThemeValue(_ name:String, type:String, value:String) -> [AnyHashable:Any]?{
        guard let theme =  self.loadedTheme[name] as? [AnyHashable:Any] else {
            addThemeToKey(name, type: type, value: value)
            return ["value":value];
        }
        return theme
    }
    
    public static func addThemeToKey(_ name:String, type:String, value:String){
        if socket?.status == .connected, self.hasLoaded == true , let appKey = self.appKey {
            self.sendMessage(type: "theme:save", data: ["appuuid":appKey, "name":name, "type":type, "value":value])
            /*if var keyElement = self.loadedTheme[name] as? [AnyHashable:Any],  var keyData = keyElement["data"] as? [AnyHashable:Any]{
                keyData[property] = ["universal":attr["value"]]
                keyElement["data"] = keyData
                self.loadedDesign[key] = keyElement
            }*/
        }
    }
    
    static var _colours = [String]()
    static var _loadedColours = false
    public static var colours:[String] {
        get{
            if !_loadedColours {
                loadColours()
            }
            return _colours
        }
        set{
            var coloursTemp = [String]()
            for i in 0..<newValue.count {
                if i<8{
                    coloursTemp.append(newValue[i])
                }
            }
            _colours = coloursTemp
            saveColors()
        }
    }
    
    public static func saveColors(){
        UserDefaults.standard.set(_colours, forKey: "UIDESIGN_ref_colours")
        UserDefaults.standard.synchronize()
    }
    
    public static func loadColours(){
        _loadedColours = true
        if let ref_colours = UserDefaults.standard.array(forKey: "UIDESIGN_ref_colours") as? [String] {
            _colours = ref_colours
        }
    }
}
