//
//  FXJsonObject.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/12.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

/**
 *  对象类型
 */
public enum FXObjectType:Int{
    case Object//任意类型自定义
    case Dictionary//词典类型
    case Array//数组类型
    case Set//集合类型
    case Number//数字类型
    case String//字符串类型
    case Date//日期类型
    case Custom//自定义类型
}

public class FXJsonObject:AnyObject{
    
    public var type:FXObjectType = FXObjectType.Object;
    public var name:String;//属性名称
    public var jsonName:String;//属性对应的json名称
    public var typeName:String?;//类型名
    public var nonJson:Bool=false;//是否为非序列化属性（Default NO）
    public var dateFormat:String?;//日期格式化字符串
    public var genericClass:NSObject.Type?;//泛型（NSArray，NSSet）
    public var genericClassDict:Dictionary<String,NSObject.Type>?;//词典泛型（NSDictionary）
    
    public init(TypeName typeName:String?,Name name:String,JsonName jsonName:String,NonJson nonJson:Bool){
        self.name=name;
        self.jsonName=jsonName;
        self.nonJson=nonJson;
        self.setTypeName(typeName: typeName)
    }
    
    public func setTypeName(typeName:String?){
        self.typeName = typeName;
        if typeName == "NSDate" {
            self.type = FXObjectType.Date;
        }else if typeName == "NSString" || typeName == "NSMutableString" {
            self.type = FXObjectType.String;
        }else if typeName == "NSNumber" {
            self.type = FXObjectType.Number;
        }else if typeName == "NSSet" || typeName == "NSMutableSet"{
            self.type = FXObjectType.Set;
        }else if typeName == "NSArray" || typeName == "NSMutableArray" {
            self.type = FXObjectType.Array;
        }else if typeName == "NSDictionary" || typeName == "NSMutableDictionary"{
            self.type = FXObjectType.Dictionary;
        }else{
            if NSClassFromString(typeName!) is IFXJsonProtocol.Type {
                self.type = FXObjectType.Custom;
            }else{
                self.type = FXObjectType.Object;
            }
        }
    }
}
