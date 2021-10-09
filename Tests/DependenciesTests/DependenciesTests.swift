import Quick
import Nimble
import ResolvingContainer

@testable import Dependencies

final class DependencyTests: QuickSpec {
    override func spec() {
        describe("Dependencies") {
            
            context("@Dependency by passing keyPath") {
                
                @Dependency(\.customObject) var customObject: MyCustomObject
                
                it("Should be able to inject dependencies") {
                    expect(customObject.name).to(equal("Default"))
                }
            }
            
            context("@Dependency by inferring from property type") {
                
                @Dependency var customObject: MyCustomObject
                
                beforeEach {
                    Dependencies.default.register(instance: MyCustomObject(name: "Test"))
                }
                
                it("Should be able to inject dependencies") {
                    expect(customObject.name).to(equal("Test"))
                }
            }
            
            context("Rewrite dependency value under specific key") {
                
                @Dependency(\.customObject) var customObject: MyCustomObject
                
                beforeEach {
                    Dependencies.default[MyCustomKey.self] = MyCustomObject(name: "Rewritten")
                }
                
                it("Should read rewritten object") {
                    expect(customObject.name).to(equal("Rewritten"))
                }
            }
        }
    }
}
