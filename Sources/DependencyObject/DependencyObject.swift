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

import SwiftUI
import Dependencies

/// A property wrapper type for an observable object supplied by a ``DependencyContainer`` specified.
/// NOTE: Object value will be read from a ``DependencyContainer`` and stored internally when the property wrapper is initialized.
///
/// Use the ``DependencyObject`` property wrapper to read and store a value
/// from a dependency container. Indicate the value to store using a
/// ``DependencyContainer`` key path in the property declaration. For example:
///
///     @DependencyObject(\.model) var model: Model
///
/// To read and store dynamically registered dependency instance, use ``LazyDependency``
/// property wrapper passing the type of the object and optional container, or just omit parameters:
///
///     @DependencyObject var model: Model
///
@frozen @propertyWrapper public struct DependencyObject<Value: ObservableObject>: DynamicProperty {
    
    @dynamicMemberLookup @frozen public struct Wrapper {

        var object: Value

        /// Returns a binding to the resulting value of a given key path.
        ///
        /// - Parameter keyPath: A key path to a specific resulting value.
        ///
        /// - Returns: A new binding.
        @MainActor public subscript<Subject>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, Subject>) -> Binding<Subject> {
            Binding {
                object[keyPath: keyPath]
            } set: { newValue in
                object[keyPath: keyPath] = newValue
            }
        }
    }
    
    @ObservedObject @MainActor public var wrappedValue: Value
    
    public private(set) var projectedValue: Wrapper
    
    public init(container: DependencyContainer = .default) {
        guard let resolved = container.resolve(Value.self) else {
            fatalError("Failed to resolve: \(String(describing: Value.self))")
        }
        wrappedValue = resolved
        projectedValue = Wrapper(object: resolved)
    }
    
    public init(_ keyPath: KeyPath<DependencyContainer, Value>, container: DependencyContainer = .default) {
        let resolved = container[keyPath: keyPath]
        wrappedValue = resolved
        projectedValue = Wrapper(object: resolved)
    }
}
