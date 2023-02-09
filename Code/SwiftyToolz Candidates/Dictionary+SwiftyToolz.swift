public extension Dictionary
{
    init(values: some Sequence<Value>) where Value: Identifiable, Value.ID == Key
    {
        self.init(uniqueKeysWithValues: values.map({ ($0.id, $0) }))
    }
    
    init(values: some Sequence<Value>) where Value: Hashable, Value == Key
    {
        self.init(uniqueKeysWithValues: values.map({ ($0, $0) }))
    }
    
    mutating func insert(_ value: Value) where Value: Identifiable, Value.ID == Key
    {
        self[value.id] = value
    }
}
