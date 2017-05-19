//
//  FXJsonUtiles.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/12.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

extension NSObject:IFXJsonProtocol{
    
    static public func initFXJsonDictionary(dictionary:Dictionary<String,Any>)->NSObject{
        let selfObject = self.init()
        let allPropertys = FXJsonUtiles.getPropertys(type(of: selfObject))
        for object in allPropertys! {
            if object.nonJson {
                continue;
            }
            let value = dictionary[object.jsonName]
            if value != nil{//NSNull
                let returnValue = FXJsonUtiles.fromObject(value! as AnyObject, propertyDesc: object)
                if returnValue != nil  {//NSNull
                    selfObject.setValue(returnValue!, forKey: object.name)
                }
            }
        }
        return selfObject
    }
    
    public func fxDictionary()->Dictionary<String,Any>{
        var dict = Dictionary<String,Any>.init()
        let allPropertys = FXJsonUtiles.getPropertys(type(of: self))
        for object in allPropertys! {
            if object.nonJson {
                continue
            }
            let value = self.value(forKey: object.name)
            if value != nil {//NSNull
                let o = FXJsonUtiles.toObjectValue(value as AnyObject, propertyDesc: object)
                if o != nil {
                    dict[object.jsonName] = o
                }
            }
        }
        return dict
    }
    
    open class func fxPropertyToJsonPropertyDictionary() -> Dictionary<String, String>? {
        return nil
    }
    
    open class func fxNonJsonPropertys() -> Set<String>? {
        return nil;
    }
    
    open class func fxContainerPropertysGenericClass() -> Dictionary<String, Any
        >? {
        return nil;
    }
    
    open class func fxPropertyDateFormatString(_ property: String) -> String {
        return "YYYY-MM-dd'T'HH:mm:ssZ";//Default ISO8601
    }
}

//忽略属性名称列表
let ignorePropertyNames:Set = Set.init(arrayLiteral: "superclass","hash","debugDescription","description");
//数字类型名称列表
let numberTypeNames:Set = Set.init(arrayLiteral: "B","i","I","d","D","c","C","f","l","L","s","S","q","Q");

public class FXJsonUtiles{
    
    public static func getType(_ value:AnyObject)->FXObjectType {
        if value is NSString {
            return FXObjectType.String;
        }else if value is NSNumber {
            return FXObjectType.Number;
        }else if value is NSSet {
            return FXObjectType.Set;
        }else if value is NSArray {
            return FXObjectType.Array;
        }else if value is NSDictionary{
            return FXObjectType.Dictionary;
        }else if value is NSDate{
            return FXObjectType.Date
        }else if value is IFXJsonProtocol {
            return FXObjectType.Custom
        }
        return FXObjectType.Object
    }
    
    public static func toJson(_ object:AnyObject)throws-> Data?{
        var o:AnyObject? = object
        if !JSONSerialization.isValidJSONObject(object) {
            o = self.toObjectValue(object, propertyDesc: nil)
        }
        if o != nil {
            print(o!)
            do{
                let jsonData = try JSONSerialization.data(withJSONObject: o!, options: JSONSerialization.WritingOptions.prettyPrinted)
                return jsonData
            }catch{
                throw NSError.init(domain: "FXJsonException", code: 500, userInfo: [NSLocalizedDescriptionKey:"转换Json数据失败"])
            }
        }
        return nil
    }
    
    public static func toObjectValue(_ value:AnyObject,propertyDesc desc:FXJsonObject?)->AnyObject?{
        var t:FXObjectType?
        if desc != nil {
            t = desc!.type
        }else{
            t = self.getType(value)
        }
        var returnValue:AnyObject?
        switch t! {
        case .Array:
            let clz = desc?.genericClass
            var array = Array<AnyObject>.init()
            let cv = value as! Array<AnyObject>
            for o in cv {
                if o is String || o is NSNumber {
                    array.append(o)
                }else{
                    if clz != nil {
                        array.append((o as! NSObject).fxDictionary() as AnyObject)
                    }else{
                        array.append(self.toObjectValue(o, propertyDesc: nil)!)
                    }
                }
            }
            returnValue = array as AnyObject
        case .Set:
            let clz = desc?.genericClass
            var array = Array<AnyObject>.init()
            let cv = value as! Set<NSObject>
            for o in cv {
                if o is String || o is NSNumber {
                    array.append(o)
                }else{
                    if clz != nil {
                        array.append(o.fxDictionary() as AnyObject)
                    }else{
                        array.append(self.toObjectValue(o, propertyDesc: nil)!)
                    }
                }
            }
            returnValue = array as AnyObject
        case .Dictionary:
            let clzDict = desc?.genericClassDict
            var dict = Dictionary<String,AnyObject>.init()
            let cv = value as! Dictionary<String,Any>
            for key in cv.keys {
                let v = cv[key]
                if v is String || v is NSNumber {
                    dict[key] = v as AnyObject
                }else{
                    let clz = clzDict?[key]
                    if clz != nil {
                        dict[key] = (v as! NSObject).fxDictionary() as AnyObject
                    }else{
                        dict[key] = self.toObjectValue(v as AnyObject, propertyDesc: nil)
                    }
                }
            }
            returnValue = dict as AnyObject;
        case .Date:
            let dfs = desc?.dateFormat
            if dfs != nil {
                let fxDateFormat = DateFormatter.init()
                fxDateFormat.dateFormat = dfs
                returnValue = fxDateFormat.string(from: value as! Date) as AnyObject
            }else{
                returnValue = value
            }
        case .Number:
            returnValue = value
        case .String:
            returnValue = value
        case .Custom:
            returnValue = (value as! NSObject).fxDictionary() as AnyObject
        default:
            returnValue = value
            break
        }
        return returnValue
    }
    
    
    
    public static func fromObject(_ value:AnyObject,propertyDesc desc:FXJsonObject?)->AnyObject?{
        var t:FXObjectType = FXObjectType.Object
        if desc != nil {
            t = desc!.type
        }
        var returnValue:AnyObject?
        switch t {
        case .Array:
            let clz = desc?.genericClass
            var array = Array<NSObject>.init()
            let cv =  value as? Array<Dictionary<String, Any>>
            for o in cv! {
                if clz != nil {
                    let v = clz?.initFXJsonDictionary(dictionary: o)
                    if v != nil {
                        array.append(v!)
                    }
                }else{
                    let v = self.fromObject(o as AnyObject, propertyDesc: nil)
                    if v != nil {
                        array.append(v as! NSObject)
                    }
                }
            }
            returnValue = array as AnyObject
        case .Set:
            let clz = desc?.genericClass
            var set = Set<NSObject>.init()
            let cv =  value as? Set<NSObject>
            for o in cv! {
                if clz != nil {
                    let v = clz?.initFXJsonDictionary(dictionary: o as! Dictionary<String, Any>)
                    if v != nil {
                        set.insert(v!)
                    }
                }else{
                    let v = self.fromObject(o as AnyObject, propertyDesc: nil)
                    if v != nil {
                        set.insert(v! as! NSObject)
                    }
                }
            }
            returnValue = set as AnyObject
        case .Date:
            let dfs = desc?.dateFormat
            if dfs != nil {
                let fxDateFormat = DateFormatter.init()
                fxDateFormat.dateFormat = dfs
                returnValue = fxDateFormat.string(from: value as! Date) as AnyObject
            }
        case .Number:
            returnValue = value
        case .String:
            returnValue = value
        case .Dictionary:
            let clzDic = desc?.genericClassDict
            var dic = Dictionary<String,Any>.init()
            let cv = value as! Dictionary<String,Any>
            for key in cv.keys {
                let o = cv[key]
                let clz = clzDic?[key]
                var v:AnyObject?
                if clz != nil && o is Dictionary<String,Any> {
                    v = clz?.initFXJsonDictionary(dictionary: o  as! Dictionary<String, Any>)
                }else{
                    v = self.fromObject(o as AnyObject, propertyDesc: nil)
                }
                if v != nil {
                    dic[key] = v!
                }
            }
            returnValue = dic as AnyObject
        case .Custom:
            let clz = NSClassFromString((desc?.typeName)!) as? NSObject.Type
            returnValue = clz?.initFXJsonDictionary(dictionary: value as! Dictionary<String, Any>)
        default:
            returnValue = value
            break;
        }
        return returnValue
    }
    
    public static func fromJsonData(json:Data,Class clazz:NSObject.Type)throws ->AnyObject?{
        var o:Any?
        do{
            o = try JSONSerialization.jsonObject(with: json, options: JSONSerialization.ReadingOptions.allowFragments)
            if !(o is NSDictionary) {
                let reason = String.init(format: "%@ 类型无法解析此json", clazz as! CVarArg)
                throw NSError(domain: "FXJSONException", code: 500, userInfo: [NSLocalizedDescriptionKey:reason])
            }else{
                return clazz.initFXJsonDictionary(dictionary: o as! Dictionary<String, Any>)
            }
        }catch{
            return nil;
        }
    }
    
    public static func fromJsonString(json:NSString)->AnyObject?{
        do{
            let o = try self.fromJsonData(jsonData: json.data(using: String.Encoding.utf8.rawValue)! as NSData)!
            return o
        }catch{
            return nil
        }
    }
    
    public static func fromJsonData(jsonData:NSData)throws ->AnyObject?{
        do{
            let o = try JSONSerialization.jsonObject(with: jsonData as Data, options: JSONSerialization.ReadingOptions.allowFragments)
            return o as AnyObject
        }catch{
            throw NSError(domain: "FXJSONException", code: 500, userInfo: [NSLocalizedDescriptionKey:"json二进制解析失败"])
        }
    }
    
    //获取属性名称
    public static func getPropertyTypeNameByPropertyName(_ proName:String,_ clazz:AnyClass)->String?{
        let property:objc_property_t = class_getProperty(clazz, proName.cString(using: String.Encoding.utf8));
        return self.getPropertyTypeName(property: property);
    }
    
    //获取工程的名字
    public static func getBundleName() -> String{
        var bundlePath = Bundle.main.bundlePath
        bundlePath = bundlePath.components(separatedBy: "/").last!
        bundlePath = bundlePath.components(separatedBy: ".").first!
        return bundlePath
    }
    
    //通过类名返回一个AnyClass
    public static func getClassWithClassName(_ name:String) ->AnyClass?{
        let type = self.getBundleName() + "." + name
        return NSClassFromString(type)
    }

    //获取所有属性
    public static func getPropertys(_ clazz: NSObject.Type)->Array<FXJsonObject>?{
        if clazz == NSObject.classForCoder() {
            return nil
        }
        
        var count:UInt32 = 0
        //获取属性的列表
        let propertyList = class_copyPropertyList(clazz, &count)
        let jsonMap = clazz.fxPropertyToJsonPropertyDictionary()
        let nonJsonSet = clazz.fxNonJsonPropertys()
        let genericClassNameDict = clazz.fxContainerPropertysGenericClass()
        var propertyArray = self.getPropertys(clazz.superclass() as! NSObject.Type)
        if propertyArray == nil {
            propertyArray = Array<FXJsonObject>.init()
        }
        for i in 0..<Int(count){
            //取出每一个属性
            let property:objc_property_t = propertyList![i]!
            //获取每一个属性的变量名
            let propertyName = property_getName(property)
            let proName = String.init(cString: propertyName!)
            if ignorePropertyNames.contains(proName) {
                continue
            }
            let typeName = self.getPropertyTypeName(property: property);
            var jsonName = jsonMap?[proName];
            if jsonName == nil {
                jsonName = proName;
            }
            var isNonJson = false;
            if  nonJsonSet != nil && (nonJsonSet?.contains(proName))! {
                isNonJson = true;
            }
            let object = FXJsonObject.init(TypeName: typeName, Name: proName, JsonName: jsonName!, NonJson: isNonJson)
            switch object.type {
            case .Date:
                let df = clazz.fxPropertyDateFormatString(proName);
                object.dateFormat = df;
            default:
                break;
            }
            
            switch object.type {
            case .Array:
                let clazz = genericClassNameDict?[proName];
                if clazz != nil {
                    object.genericClass = clazz as? NSObject.Type;
                }
            case .Set:
                let clazz = genericClassNameDict?[proName];
                if clazz != nil {
                    object.genericClass = clazz as? NSObject.Type;
                }
            case .Dictionary:
                let value = genericClassNameDict?[proName] as? Dictionary<String,NSObject.Type>;
                if value != nil {
                    var dict = Dictionary<String, NSObject.Type>.init();
                    let allkeys = value?.keys
                    for key in allkeys!{
                        let clz = value?[key]
                        if clz != nil {
                            dict[key] = clz
                        }
                    }
                    if dict.count > 0{
                        object.genericClassDict = dict
                    }
                }
            default:
                break;
            }
            propertyArray?.append(object)
        }
        free(propertyList)
        return propertyArray;
    }
    
    //获取属性名称
    public static func getPropertyTypeName(property:objc_property_t)->String?{
        let attributes = property_getAttributes(property);
        let attributeStr = NSString.init(bytes: attributes!, length: Int(strlen(attributes)), encoding: String.Encoding.utf8.rawValue);
        let a1 = attributeStr?.components(separatedBy: ",")[0].replacingOccurrences(of: "\"", with: "");
        var typeName:String?;
        if (a1?.hasPrefix("T@"))! {
            let start = a1?.index((a1?.startIndex)!, offsetBy: 2);
            let end = a1?.endIndex;
            typeName = a1?.substring(with: Range.init(uncheckedBounds: (lower:start!,upper:end!)));
        }else{
            if a1 != nil && (a1?.characters.count)! >= 2 {
                typeName = a1?.substring(from: (a1?.index((a1?.startIndex)!, offsetBy: 1))!);
                if numberTypeNames.contains(typeName!) {
                    typeName = "NSNumber";
                }
            }
        }
        return typeName;
    }
    
}

