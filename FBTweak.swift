//
//  FBTweak.swift
//  HonghaoZ
//
//  Created by Honghao Zhang on 2014-11-13.
//  Copyright (c) 2014 HonghaoZ. All rights reserved.
//

// Note:
// Import following headers into your project *-Bridging-Header.h

//// FBTweaks
//#ifndef Tweak_Swift_ObjC_Bridging_Header_h
//#define Tweak_Swift_ObjC_Bridging_Header_h
//
//#import "FBTweakEnabled.h"
//#import "FBTweak.h"
//#import "FBTweakStore.h"
//#import "FBTweakCategory.h"
//#import "FBTweakCollection.h"
//#import "_FBTweakBindObserver.h"
//#import "FBTweakShakeWindow.h"
//
//#endif

import Foundation

private let _tweakIdentifier = "com.pierredulac.tweaks"

func getTweakIdentifier(categoryName: String!, collectionName: String!, tweakName: String!) -> String {
    return "FBTweak:\(categoryName)-\(collectionName)-\(tweakName)"
}

func tweakBind<T>(object: NSObject!, property: String!, categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T) {
    tweakBind(object, property, categoryName, collectionName, tweakName, defaultValue, nil, nil)
}

func tweakBind<T>(object: NSObject!, property: String!, categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) {
    #if NDEBUG
        let tweak = _tweakInternal(categoryName, collectionName, tweakName, defaultValue, nil, nil)
        object.setValue(_tweakValueInternal(tweak, defaultValue),
        forKey: property)
        #else
        let tweak = _tweakInternal(categoryName, collectionName, tweakName, defaultValue, minValue, maxValue)
        _tweakBindInternal(object, property, defaultValue, tweak)
    #endif
}

func tweak<T>(categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) -> T {
    #if NDEBUG
        return defaultValue
        #else
        let tweak = _tweakInternal(categoryName, collectionName, tweakName, defaultValue, minValue, maxValue)
        return _tweakValueUnpackedInternal(tweak!, defaultValue)
    #endif
}

// MARK: Internals

func _tweakInternal<T>(categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) -> FBTweak! {
    let store = FBTweakStore.sharedInstance()
    var category: FBTweakCategory? = store.tweakCategoryWithName(categoryName)
    if category == nil {
        category = FBTweakCategory(name: categoryName)
        store.addTweakCategory(category)
    }
    var collection: FBTweakCollection? = category!.tweakCollectionWithName(collectionName)
    if collection == nil {
        collection = FBTweakCollection(name: collectionName)
        category!.addTweakCollection(collection)
    }
    let identifier = getTweakIdentifier(categoryName, collectionName, tweakName)
    var tweak: FBTweak? = collection?.tweakWithIdentifier(identifier)
    if tweak == nil {
        tweak = FBTweak(identifier: identifier)
        tweak!.name = tweakName
        collection!.addTweak(tweak!)
    }
    
    tweak!.defaultValue = _tweakPackValue(defaultValue)
    if minValue != nil {
        tweak!.minimumValue = _tweakPackValue(minValue!)
    }
    if maxValue != nil {
        tweak!.maximumValue = _tweakPackValue(maxValue!)
    }
    
    return tweak!
}

func _tweakBindInternal<T>(object: NSObject!, property: String!, defaultValue: T, tweak: FBTweak!) {
    object.setValue(_tweakValueInternal(tweak, defaultValue),
        forKey: property)
    
    let observer: _FBTweakBindObserver = _FBTweakBindObserver(tweak: tweak, {
        (obj: AnyObject!) in
        
        let _object = obj as? NSObject
        _object?.setValue(_tweakValueInternal(tweak, defaultValue),
            forKey: property)
    })
    
    observer.attachToObject(object)
}

func _tweakValueInternal<T>(tweak: FBTweak!, defaultValue: T) -> FBTweakValue? {
    let currentValue: FBTweakValue? = tweak.currentValue ?? tweak.defaultValue
    return currentValue
}

func _tweakValueUnpackedInternal<T>(tweak: FBTweak!, defaultValue: T) -> T {
    return _tweakUnpackValue(_tweakValueInternal(tweak, defaultValue), defaultValue)
}

func _tweakPackValue<T>(value: T) -> AnyObject? {
    
    // if the value is already an object we return it
    if let v = value as? NSNumber {
        return v
    }
    if let v = value as? NSValue {
        return v
    }
    
    // pack Int
    if let v = value as? Int {
        return NSNumber(long: v)
    }
    if let v = value as? Int8 {
        return NSNumber(char: v)
    }
    if let v = value as? Int16 {
        return NSNumber(short: v)
    }
    if let v = value as? Int32 {
        return NSNumber(int: v)
    }
    if let v = value as? Int64 {
        return NSNumber(longLong: v)
    }
    if let v = value as? UInt {
        return NSNumber(unsignedLong: v)
    }
    if let v = value as? UInt8 {
        return NSNumber(unsignedChar: v)
    }
    if let v = value as? UInt16 {
        return NSNumber(unsignedShort: v)
    }
    if let v = value as? UInt32 {
        return NSNumber(unsignedInt: v)
    }
    if let v = value as? UInt64 {
        return NSNumber(unsignedLongLong: v)
    }
    
    // pack Decimal
    if let v = value as? Float {
        return NSNumber(float: v)
    }
    if let v = value as? CGFloat {
        return NSNumber(double: Double(v))
    }
    if let v = value as? Double {
        return NSNumber(double: v)
    }
    
    // pack Boolean
    if let v = value as? Bool {
        return NSNumber(bool: v)
    }
    
    println("Warning: Unknown value type \(value.dynamicType) for value \(value), can't be packed")
    return nil
}

func _tweakUnpackValue<T>(value: AnyObject?, defaultValue: T) -> T {
    
    // unpack Int
    if defaultValue is Int {
        return value?.integerValue as T
    }
    if defaultValue is Int8 {
        return value?.charValue as T
    }
    if defaultValue is Int16 {
        return value?.shortValue as T
    }
    if defaultValue is Int32 {
        return value?.intValue as T
    }
    if defaultValue is Int64 {
        return value?.longLongValue as T
    }
    if defaultValue is UInt {
        return value?.unsignedIntegerValue as T
    }
    if defaultValue is UInt8 {
        return value?.unsignedCharValue as T
    }
    if defaultValue is UInt16 {
        return value?.unsignedShortValue as T
    }
    if defaultValue is UInt32 {
        return value?.unsignedIntValue as T
    }
    if defaultValue is UInt64 {
        return value?.unsignedLongLongValue as T
    }
    
    // unpack Decimal
    if defaultValue is Float {
        return value?.floatValue as T
    }
    if defaultValue is Double {
        return value?.doubleValue as T
    }
    
    // unpack Boolean
    if defaultValue is Bool {
        return value?.boolValue as T
    }
    
    return defaultValue as T
}