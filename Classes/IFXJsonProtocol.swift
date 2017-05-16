//
//  IFXJsonProtocol.swift
//  TTSwift
//
//  Created by 张大宗 on 2017/5/12.
//  Copyright © 2017年 张大宗. All rights reserved.
//

import Foundation

public protocol IFXJsonProtocol{
    
    /**
     *  属性到Json属性的映射
     */
    static func fxPropertyToJsonPropertyDictionary()->Dictionary<String,String>?;
    /**
     *  非Json属性列表
     */
    static func fxNonJsonPropertys()->Set<String>?;
    /**
     *  容器属性类型
     *  key：属性名称
     *  value：类型（Class）支持NSDictionary，NSSet，NSArray
     *  {
     *      @"users" : [UserDTO class],
     *      @"dict" : {
     *                   @"key1" : [DTOClass1 class],
     *                   @"key2" : [DTOClass2 class]
     *                }
     *  }
     */
    static func fxContainerPropertysGenericClass()->Dictionary<String,Any>?;
    /**
     *  日期属性Format字符串
     */
    static func fxPropertyDateFormatString(_ property:String)->String;
}
