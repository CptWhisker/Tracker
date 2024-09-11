import Foundation

@objc(WeekDaysTransformer)
final class WeekDaysTransformer: ValueTransformer {
    override class func allowsReverseTransformation() -> Bool {
        return true
    }
    
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }
    
    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [WeekDays] else { return nil }
        return try? JSONEncoder().encode(days)
    }
    
    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([WeekDays].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            WeekDaysTransformer(),
            forName: NSValueTransformerName(String(describing: WeekDaysTransformer.self))
        )
    }
}
