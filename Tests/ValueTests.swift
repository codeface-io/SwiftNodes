@testable import SwiftNodes
import XCTest

class ValueTests: XCTestCase {
    
    func testThatCodeFromREADMECompiles()
    {
        let graph = Graph<Int, Int, Double>(values: [1, 2, 3],
                                            edges: [(1, 2), (2, 3), (1, 3)])
        
        let graph2: Graph<Int, Int, Double> = [1, 2, 3]
        
        typealias MyGraph = Graph<String, Int, Double>
        
        let graph3 = MyGraph(valuesByID: ["a": 1, "b": 2, "c": 3],
                             edges: [("a", "b"), ("b", "c"), ("a", "c")])
        
        let graph4: MyGraph = ["a": 1, "b": 2, "c": 3]
        
        struct IdentifiableValue: Identifiable { let id = UUID() }
        typealias IVGraph = Graph<UUID, IdentifiableValue, Double>
        
        let values = [IdentifiableValue(), IdentifiableValue(), IdentifiableValue()]
        let ids = values.map { $0.id }
        let graph5 = IVGraph(values: values,
                             edges: [(ids[0], ids[1]), (ids[1], ids[2]), (ids[0], ids[2])])
        
        var graph6 = Graph<String, Int, Double>()
        
        graph6["a"] = 1
        let valueA = graph6["a"]
        graph6["a"] = nil
        
        graph6.update(2, for: "b")  // returns the updated/created `Node` but is `@discardable`
        let valueB = graph6.value(for: "b")
        graph6.removeValue(for: "b")  // returns the removed `NodeValue?` but is `@discardable`
        
        let allValues = graph6.values  // returns `some Collection`
        
        var graph7 = Graph<Int, Int, Double>()
        
        graph7.insert(1)  // returns the updated/created `Node` but is `@discardable`
        graph7.remove(1)  // returns the removed `Node?` but is `@discardable`
    }
    
    func testInitializingWithIDValuePairs() {
        
    }
    
    func testAccessingMutatingAndDeletingValuesViaSubscript()
    {
        
    }
    
    func testThatProvidingMultipleEdgesWithTheSameIDAddsTheirWeights()
    {
        
    }
    
    func testThatProvidingOrInferingDuplicateNodeIDsWorks()
    {
        
    }
    
    func testInitializingWithValuesWhereValuesAreNodeIDs() {
        
    }
    
    func testInitializingWithValuesWhereValuesAreIdentifiable() {
        
    }
    
    func testGettingAllValues() {
        
    }
    
    func testGettingValues() {
        
        
        
    }
    
    func testUpdatingValues() {
        
        
        
    }
    
    func testSubscript() {
        
        
        
    }
    
    func testInsertingValuesWhereValuesAreNodeIDs() {
        
        
        
    }
    
    func testInsertingValuesWhereValuesAreIdentifiable() {
        
    }
}
