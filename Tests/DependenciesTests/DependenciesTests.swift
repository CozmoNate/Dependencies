import Quick
import Nimble
import ResolvingContainer
import Combine
import Foundation

@testable import Dependencies
@testable import DependencyObject

typealias TestValue = String

struct TestValueKey: DependencyKey {
    
    static var defaultValue = TestValue("Default")
}

class TestObject: ObservableObject {
    
    var value: String
    
    init(value: String) {
        self.value = value
    }
}

struct TestWrapper {
    
    @DependencyObject(\.testObject)
    var testObject
    
}

struct TestObjectKey: DependencyKey {
    
    static var defaultValue = TestObject(value: "Default")
}

extension DependencyContainer {
    
    var testValue: TestValue {
        get { return self[TestValueKey.self] }
        set { self[TestValueKey.self] = newValue }
    }
    
    var testObject: TestObject {
        get { return self[TestObjectKey.self] }
        set { self[TestObjectKey.self] = newValue }
    }
}

final class DependenciesTests: QuickSpec {
    override func spec() {
        
        // ObservableObject should be registered prior to initialization of any class/struct using @DependencyObject
        DependencyContainer.default.register(instance: TestObject(value: "Test"))
        
        describe("LazyDependency") {
            
            context("@LazyDependency by passing keyPath") {
                
                @LazyDependency(\.testValue)
                var testValue: TestValue
                
                it("Should be able to inject dependencies") {
                    expect(testValue).to(equal("Default"))
                }
            }
            
            context("@LazyDependency by inferring from property type") {
                
                @LazyDependency
                var testValue: TestValue
                
                beforeEach {
                    DependencyContainer.default.register(instance: TestValue("Test"))
                }
                
                it("Should be able to inject dependencies") {
                    expect(testValue).to(equal("Test"))
                }
            }
        }
        
        describe("DependencyObject") {
            
            context("@DependencyObject by passing keyPath") {
                
                @DependencyObject(\.testObject)
                var testObject: TestObject
                
                it("Should be able to inject dependencies") {
                    expect(testObject.value).to(equal("Default"))
                }
            }
            
            context("@DependencyObject by inferring from property type") {
                
                @DependencyObject
                var testObject: TestObject
                
                it("Should be able to inject dependencies") {
                    expect(testObject.value).to(equal("Test"))
                }
            }
            
            context("Access projectedValue if @DependencyObject") {

                it("Should be able to read & change projectedValue") {
                    waitUntil { done in
                        Task { @MainActor in
                            let testWrapper = TestWrapper()
                            expect(testWrapper.$testObject.value.wrappedValue).to(equal("Default"))
                            testWrapper.$testObject.value.wrappedValue = "Test"
                            expect(testWrapper.$testObject.value.wrappedValue).to(equal("Test"))
                            done()
                        }
                    }
                }
            }
        }
        
        describe("Dependency") {
            
            context("@Dependency by passing keyPath") {
                
                @Dependency(\.testValue)
                var testValue: TestValue
                
                it("Should be able to inject dependencies") {
                    expect(testValue).to(equal("Default"))
                }
            }
            
            context("@Dependency by inferring from property type") {
                
                @Dependency
                var testValue: TestValue
                
                beforeEach {
                    DependencyContainer.default.register(instance: TestValue("Test"))
                }
                
                it("Should be able to inject dependencies") {
                    expect(testValue).to(equal("Test"))
                }
            }
            
            context("Rewrite dependency value under specific key") {
                
                @Dependency(\.testValue)
                var testValue: TestValue
                
                beforeEach {
                    DependencyContainer.default[TestValueKey.self] = TestValue("Rewritten")
                }
                
                it("Should read rewritten object") {
                    expect(testValue).to(equal("Rewritten"))
                }
            }
        }
    }
}
