import UIKit

var greeting = "Hello, playground"

@resultBuilder
struct AttributedStringBuilder {
    
    static func buildBlock(_ components: NSAttributedString...) -> NSAttributedString {
        let result = NSMutableAttributedString()
        components.forEach { result.append($0) }
        return result
    }
    
    static func buildEither(first component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    static func buildEither(second component: NSAttributedString) -> NSAttributedString {
        component
    }
    
    static func buildOptional(_ component: NSAttributedString?) -> NSAttributedString {
        component ?? NSAttributedString()
    }
    
    static func buildArray(_ components: [NSAttributedString]) -> NSAttributedString {
        let attributedString = NSMutableAttributedString()
        for component in components {
            attributedString.append(component)
        }
        return components.reduce(into: NSMutableAttributedString()) { result, attributedString in
            result.append(attributedString)
        }
    }
    
    static func buildExpression(_ expression: NSAttributedString) -> NSAttributedString {
        expression
    }
}

@AttributedStringBuilder var attributedString: NSAttributedString {
    if Bool.random() {
        NSAttributedString(string: "Eldhose, ", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
    }
    for i in 1..<5 {
        NSAttributedString(string: "Lomy \(i)", attributes: [.font: UIFont.italicSystemFont(ofSize: 16)])
    }
    
    
}

//print(attributedString)


@resultBuilder
struct DictionaryBuilder<Key, Value> where Key: Hashable {
    
    static func buildBlock(_ components: [Key: Value]...) -> [Key: Value] {
        components.reduce(into: [:]) {
            $0.merge($1) { _, new in new }
        }
    }
    
    static func buildOptional(_ component: [Key : Value]?) -> [Key : Value] {
        component ?? [:]
    }
    
    static func buildEither(first component: [Key : Value]) -> [Key : Value] {
        component
    }
    
    static func buildEither(second component: [Key : Value]) -> [Key : Value] {
        component
    }
    
}

public extension Dictionary {
    init(@DictionaryBuilder<Key, Value> build: () -> Dictionary) {
        self = build()
    }
}


@DictionaryBuilder<String, Any>
var attributes: [String: Any] {
    ["name" : "Eldhose"]
    ["age" : 30]
    if Bool.random() {
        ["male": true]
    }
}

print(attributes)

var cars: [String: String]? = ["swift" : "alto"]

let attributes1: [String: Any] = Dictionary {
    ["name" : "Eldhose"]
    ["age" : 30]
    cars ?? [:]
}
print(attributes1)
