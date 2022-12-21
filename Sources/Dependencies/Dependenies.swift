/*
 
Copyright (c) 2021 Natan Zalkin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 
 */

import ResolvingContainer

/// A key for accessing specific dependencies.
///
/// You can create custom dependency values by extending the
/// ``DependencyValues`` structure with new properties.
/// First declare a new dependency key type and specify a value for the
/// required ``defaultValue`` property:
///
///     private struct MyDependencyKey: DependencyKey {
///         static let defaultValue: String = "Default value"
///     }
///
/// The Swift compiler automatically infers the associated ``Value`` type as the
/// type you specify for the default value.
///
/// Then use the key to define a new dependency property:
///
///     extension DependencyContainer {
///         var myCustomValue: String {
///             get { self[MyDependencyKey.self] }
///             set { self[MyDependencyKey.self] = newValue }
///         }
///     }
///
public protocol DependencyKey {

    /// The associated type representing the type of the dependency key's value.
    /// The Swift compiler usually automatically infers this type from the ``defaultValue`` type.
    associatedtype Value

    /// The default value for this dependency key.
    static var defaultValue: Self.Value { get }
}

/// A dependency values container.
///
/// To access a dependency,
/// declare a property using the ``Dependency`` property wrapper and
/// specify the value's key path and optional container.
///
/// Create custom dependency by defining a type that
/// conforms to the ``DependencyKey`` protocol, and then extending the
/// dependencies class with a new property. Use your key to get and
/// set the value, and provide a dedicated modifier for clients to use when
/// setting the value:
///
///     private struct MyDependencyKey: DependencyKey {
///         static let defaultValue: String = "Default value"
///     }
///
///     extension DependencyContainer {
///         var myCustomValue: String {
///             get { self[MyDependencyKey.self] }
///             set { self[MyDependencyKey.self] = newValue }
///         }
///     }
///
/// To access the dependency, declare a property using the ``Dependency``
/// property wrapper and specify the value's key path. For example:
///
///     @Dependency(\.myCustomValue) var customValue: String
///
/// To register dependency dynamically without registering new ``DependencyKey``,
/// Call ``DependencyContainer`` instance method `register` and pass the object. For example:
///
///     DependencyContainer.default.register(instance: MyCustomObject())
///
/// To access dynamically registered dependency instance, use ``Dependency``
/// property wrapper passing the type of the object and optional container, or just omit parameters:
///
///     @Dependency var customObject: MyCustomObject
///
public class DependencyContainer: ResolvingContainer {
    
    public static let `default` = DependencyContainer()
    
    private var storage = [ObjectIdentifier: Any]()
    
    private init() {}
    
    public subscript<Key>(provider: Key.Type) -> Key.Value where Key: DependencyKey {
        get { storage[ObjectIdentifier(Key.self)] as? Key.Value ?? Key.defaultValue }
        set { storage[ObjectIdentifier(Key.self)] = newValue }
    }
}

/// A property wrapper that reads a value from a dependency container.
///
/// Use the ``Dependency`` property wrapper to read a value
/// stored in a dependency container. Indicate the value to read using a
/// ``DependencyContainer`` key path in the property declaration. For example:
///
///     @Dependency(\.customValue) var value: MyCustomValue
///
/// To read dynamically registered dependency instance, use ``Dependency``
/// property wrapper passing the type of the object and optional container, or just omit parameters:
///
///     @Dependency var customObject: MyCustomObject
///
@frozen @propertyWrapper public struct Dependency<Value> {
    
    private let getter: () -> Value
    
    public var wrappedValue: Value {
        getter()
    }
    
    public init(container: DependencyContainer = .default) {
        getter = {
            guard let value = container.resolve(Value.self) else {
                fatalError("Failed to resolve: \(String(describing: Value.self))")
            }
            return value
        }
    }
    
    public init(_ keyPath: KeyPath<DependencyContainer, Value>, container: DependencyContainer = .default) {
        getter = { container[keyPath: keyPath] }
    }
}

/// A property wrapper that reads and stores a value from a dependency container upon first access to the value.
///
/// Use the ``LazyDependency`` property wrapper to read a value
/// from a dependency container and store it internally. Indicate the value to store using a
/// ``DependencyContainer`` key path in the property declaration. For example:
///
///     @LazyDependency(\.customValue) var value: MyCustomValue
///
/// To read and store dynamically registered dependency instance, use ``LazyDependency``
/// property wrapper passing the type of the object and optional container, or just omit parameters:
///
///     @LazyDependency var customObject: MyCustomObject
///
@propertyWrapper public struct LazyDependency<Value> {
    
    private class Storage {

        lazy var value: Value = getter()

        private let getter: () -> Value
        
        init(_ keyPath: KeyPath<DependencyContainer, Value>?, _ container: DependencyContainer = .default) {
            if let keyPath {
                getter = { container[keyPath: keyPath] }
            } else {
                getter = {
                    guard let value = container.resolve(Value.self) else {
                        fatalError("Failed to resolve: \(String(describing: Value.self))")
                    }
                    return value
                }
            }
        }
    }
    
    private var storage: Storage
    
    public var wrappedValue: Value {
        storage.value
    }
    
    public init(container: DependencyContainer = .default) {
        storage = Storage(nil, container)
    }
    
    public init(_ keyPath: KeyPath<DependencyContainer, Value>, container: DependencyContainer = .default) {
        storage = Storage(keyPath, container)
    }
}
