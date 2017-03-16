//
//  FBTweaks+Macros.swift
//
//  Created by Pierre Dulac on 16/09/2014.
//  Copyright (c) 2014 Pierre Dulac. All rights reserved.
//

import Foundation
import UIKit

private let _tweakIdentifier = "com.pierredulac.tweaks"


func getTweakIdentifier(_ categoryName: String!, collectionName: String!, tweakName: String!) -> String {
    return "FBTweak:\(categoryName)-\(collectionName)-\(tweakName)"
}

func tweakBind<T>(_ object: NSObject!, property: String!, categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T) {
    tweakBind(object, property: property, categoryName: categoryName, collectionName: collectionName, tweakName: tweakName, defaultValue: defaultValue, minValue: nil, maxValue: nil)
}

func tweakBind<T>(_ object: NSObject!, property: String!, categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) {
    #if NDEBUG
        let tweak = _tweakInternal(categoryName, collectionName, tweakName, defaultValue, nil, nil)
        object.setValue(_tweakValueInternal(tweak, defaultValue),
            forKey: property)
    #else
        let tweak = _tweakInternal(categoryName, collectionName: collectionName, tweakName: tweakName, defaultValue: defaultValue, minValue: minValue, maxValue: maxValue)
        _tweakBindInternal(object, property: property, defaultValue: defaultValue, tweak: tweak)
    #endif
}

func tweak<T>(_ categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) -> T {
    #if NDEBUG
        return defaultValue
    #else
        let tweak = _tweakInternal(categoryName, collectionName: collectionName, tweakName: tweakName, defaultValue: defaultValue, minValue: minValue, maxValue: maxValue)
        return _tweakValueUnpackedInternal(tweak!, defaultValue: defaultValue)
    #endif
}

// MARK: Internals

func _tweakInternal<T>(_ categoryName: String!, collectionName: String!, tweakName: String!, defaultValue: T, minValue: T?, maxValue: T?) -> FBTweak! {
    let store = FBTweakStore.sharedInstance()
    var category: FBTweakCategory? = store?.tweakCategory(withName: categoryName)
    if category == nil {
        category = FBTweakCategory(name: categoryName)
        store?.addTweakCategory(category)
    }
    var collection: FBTweakCollection? = category!.tweakCollection(withName: collectionName)
    if collection == nil {
        collection = FBTweakCollection(name: collectionName)
        category!.addTweakCollection(collection)
    }
    let identifier = getTweakIdentifier(categoryName, collectionName: collectionName, tweakName: tweakName)
    var tweak: FBTweak? = collection?.tweak(withIdentifier: identifier)
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

func _tweakBindInternal<T>(_ object: NSObject!, property: String!, defaultValue: T, tweak: FBTweak!) {
    object.setValue(_tweakValueInternal(tweak, defaultValue: defaultValue),
        forKey: property)
    
    let observer: _FBTweakBindObserver = _FBTweakBindObserver(tweak: tweak, block: {
        (obj: AnyObject!) in
        
        let _object = obj as? NSObject
        _object?.setValue(_tweakValueInternal(tweak, defaultValue: defaultValue),
            forKey: property)
    } as! _FBTweakBindObserverBlock)
    
    observer.attach(to: object)
}

func _tweakValueInternal<T>(_ tweak: FBTweak!, defaultValue: T) -> FBTweakValue? {
    let currentValue: FBTweakValue? = tweak.currentValue as FBTweakValue? ?? tweak.defaultValue as FBTweakValue?
    return currentValue
}

func _tweakValueUnpackedInternal<T>(_ tweak: FBTweak!, defaultValue: T) -> T {
    return _tweakUnpackValue(_tweakValueInternal(tweak, defaultValue: defaultValue), defaultValue: defaultValue)
}

func _tweakPackValue<T>(_ value: T) -> AnyObject? {
    
    // if the value is already an object we return it
    if let v = value as? NSNumber {
        return v
    }
    if let v = value as? NSValue {
        return v
    }
    
    // pack Int
    if let v = value as? Int {
        return NSNumber(value: v as Int)
    }
    if let v = value as? Int8 {
        return NSNumber(value: v as Int8)
    }
    if let v = value as? Int16 {
        return NSNumber(value: v as Int16)
    }
    if let v = value as? Int32 {
        return NSNumber(value: v as Int32)
    }
    if let v = value as? Int64 {
        return NSNumber(value: v as Int64)
    }
    if let v = value as? UInt {
        return NSNumber(value: v as UInt)
    }
    if let v = value as? UInt8 {
        return NSNumber(value: v as UInt8)
    }
    if let v = value as? UInt16 {
        return NSNumber(value: v as UInt16)
    }
    if let v = value as? UInt32 {
        return NSNumber(value: v as UInt32)
    }
    if let v = value as? UInt64 {
        return NSNumber(value: v as UInt64)
    }
    
    // pack Decimal
    if let v = value as? Float {
        return NSNumber(value: v as Float)
    }
    if let v = value as? CGFloat {
        return NSNumber(value: Double(v) as Double)
    }
    if let v = value as? Double {
        return NSNumber(value: v as Double)
    }
    
    // pack Boolean
    if let v = value as? Bool {
        return NSNumber(value: v as Bool)
    }
    
    print("Warning: Unknown value type \(type(of: value)) for value \(value), can't be packed")
    return nil
}

func _tweakUnpackValue<T>(_ value: AnyObject?, defaultValue: T) -> T {

    // unpack Int
    if defaultValue is Int {
        return value?.integerValue as! T
    }
    if defaultValue is Int8 {
        return value?.int8Value as! T
    }
    if defaultValue is Int16 {
        return value?.int16Value as! T
    }
    if defaultValue is Int32 {
        return value?.int32Value as! T
    }
    if defaultValue is Int64 {
        return value?.int64Value as! T
    }
    if defaultValue is UInt {
        return value?.uintValue as! T
    }
    if defaultValue is UInt8 {
        return value?.uint8Value as! T
    }
    if defaultValue is UInt16 {
        return value?.uint16Value as! T
    }
    if defaultValue is UInt32 {
        return value?.uint32Value as! T
    }
    if defaultValue is UInt64 {
        return value?.uint64Value as! T
    }
    
    // unpack Decimal
    if defaultValue is Float {
        return value?.floatValue as! T
    }
    if defaultValue is Double {
        return value?.doubleValue as! T
    }
    
    // unpack Boolean
    if defaultValue is Bool {
        return value?.boolValue as! T
    }
    
    return defaultValue as T
}
