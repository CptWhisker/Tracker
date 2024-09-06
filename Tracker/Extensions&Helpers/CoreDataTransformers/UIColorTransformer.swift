import UIKit

@objc(UIColorTransformer)
final class UIColorTransformer: ValueTransformer {
    struct ColorComponents: Codable {
        let red: CGFloat
        let green: CGFloat
        let blue: CGFloat
        let alpha: CGFloat
    }
    
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let color = value as? UIColor else { return nil }
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let components = ColorComponents(red: red, green: green, blue: blue, alpha: alpha)
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(components)
            return jsonData
        } catch {
            print("[UIColorTransformer transformedValue]: EncodingError - Failed to encode color to JSON")
            return nil
        }
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? Data else { return nil }
        
        let decoder = JSONDecoder()
        do {
            let components = try decoder.decode(ColorComponents.self, from: data)

            return UIColor(red: components.red, green: components.green, blue: components.blue, alpha: components.alpha)
        } catch {
            print("[UIColorTransformer reverseTransformedValue]: DecodingError - Failed to decode color from JSON")
            return nil
        }
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            UIColorTransformer(),
            forName: NSValueTransformerName(String(describing: UIColorTransformer.self))
        )
    }
}
