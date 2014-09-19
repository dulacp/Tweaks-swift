# Tweaks *Macros* for Swift

> Poetry cannot be translated; and, therefore, it is the poets that preserve the languages.
> 
> *Samuel Johnson*


### Why this extension ?

Because macros does not exists anymore in Swift, so we have to translate them into Swift functions `func`.

### Generics

Swift brings the power of generics, so this extension use it pretty intensively. The major benefit is that tweaks are now checked at compile time.

For instance, if you want to control the animation duration, you can do :

```swift
let duration: Double = tweak("Advanced", "Animation", "Duration", Double(1.0), Double(0.3), Double(8.0))
```

> NB: the `let duration: Double` is to prove to you that the `tweak(_:_:_:_:_:_:)` function is returining the right type, which is `Double` in this case.

## Installation

Three simple steps :

* of course, include the original `FBTweaks` project with one of the [two options](https://github.com/facebook/Tweaks#installation) they provide
* include the `FBTweaks+Macros.swift`
* add the content of the `ObjC-Briding-Header.h` file to your own Objective-C Briding Header file.

And you're good to go.

## Known issues

* tweaks are not statically stored during compile time in the `__FBTweak` section of the mach-o, as they are in the [objective-c macros implementation](https://github.com/facebook/Tweaks#how-it-works). If you figure out a way to do that with the Swift compiler, do not hesitate to make a PR.


## Contact

[Pierre Dulac](http://github.com/dulaccc)  
[@dulaccc](https://twitter.com/dulaccc)

## License
DPMeterView is available under the MIT license. See the LICENSE file for more info.