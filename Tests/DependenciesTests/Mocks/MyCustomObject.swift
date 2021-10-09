import Foundation
import Dependencies

struct MyCustomKey: DependencyKey {
    
    static var defaultValue = MyCustomObject(name: "Default")
}

extension Dependencies {
    
    var customObject: MyCustomObject {
        get { return self[MyCustomKey.self] }
        set { self[MyCustomKey.self] = newValue }
    }
}

class MyCustomObject {
    let name: String
    
    init(name: String) {
        self.name = name
    }
}
