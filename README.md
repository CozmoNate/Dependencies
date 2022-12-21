# Dependencies

[![License](https://img.shields.io/badge/license-MIT-ff69b4.svg)](https://github.com/kzlekk/Dependencies/raw/master/LICENSE)
![Language](https://img.shields.io/badge/swift-5.0-orange.svg)
![Coverage](https://img.shields.io/badge/coverage-93%25-yellowgreen)

A lightweight library implementing functionality similar to @Environment from SwiftUI but allowing to be used in any Swift class or struct.

## Installation

### Swift Package Manager

Add "Dependencies" dependency via integrated Swift Package Manager in XCode

## Usage

To register global dependency statically, you first need to create custom dependency value by extending the **DependencyValues** structure with new properties. Declare a new dependency key type and specify a value for the required **defaultValue** property:

```swift

    private struct MyDependencyKey: DependencyKey {
        static let defaultValue: String = "Default value"
    }
    
```

The Swift compiler automatically infers the associated **Value** type as the type you specify for the default value. 

Then use the key to define a new dependency property:

```swift

    extension Dependencies {
        var myCustomValue: String {
            get { self[MyDependencyKey.self] }
            set { self[MyDependencyKey.self] = newValue }
        }
    }

```

To access the dependency, declare a property using the **Dependency** property wrapper and specify the value's key path:

```swift

@Dependency(\.myCustomValue) 
var customValue: String

```

To register dependency dynamically without registering new **DependencyKey**, call **Dependencies** instance method *register* and pass the object:

```swift

Dependencies.default.register(instance: MyCustomObject())
    
```

To access dynamically registered dependency instance, use **Dependency** property wrapper passing the type of the object and optional container, or just omit any parameters:

```swift

@Dependency 
var customObject: MyCustomObject
    
```
