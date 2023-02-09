@testable import SwiftNodes
import XCTest

class ValueTests: XCTestCase {
    
    func testInitializingWithIDValuePairs() {
        let graph = Graph<Int, Int, Double>(values: [1, 2, 3],
                                            edges: [(1, 2), (2, 3), (1, 3)])
        
        let graph2 = Graph<String, Int, Double>(valuesByID: ["a": 1, "b": 2, "c": 3],
                                                edges: [("a", "b"), ("b", "c"), ("a", "c")])
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
