@testable import SwiftNodes
import XCTest

class ComponentTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssertEqual(TestGraph().findComponents().count, 0)
    }
    
    func testGraphWithoutEdges() {
        let graph = TestGraph(values: [1, 2, 3])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2], [3]]
        
        XCTAssertEqual(graph.findComponents(), expectedComponents)
    }
    
    func testGraphWithOneTrueComponent() {
        let graph = TestGraph(values: [1, 2, 3], edges: [(1, 2), (2, 3)])
        
        let expectedComponents: Set<Set<Int>> = [[1, 2, 3]]
        
        XCTAssertEqual(graph.findComponents(), expectedComponents)
    }
    
    func testGraphWithMultipleComponents() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(2, 3), (4, 5), (5, 6)])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2, 3], [4, 5, 6]]
        
        XCTAssertEqual(graph.findComponents(), expectedComponents)
    }
    
    func testGraphWithMultipleComponentsAndCycles() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(2, 3), (3, 2), (4, 5), (5, 6), (6, 4)])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2, 3], [4, 5, 6]]
        
        XCTAssertEqual(graph.findComponents(), expectedComponents)
    }
}
