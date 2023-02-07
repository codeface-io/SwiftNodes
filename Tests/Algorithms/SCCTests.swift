@testable import SwiftNodes
import XCTest

class SCCTests: XCTestCase {
    
    func testEmptyGraph() {
        XCTAssertEqual(TestGraph().findStronglyConnectedComponents().count, 0)
    }
    
    func testGraphWithoutEdges() {
        let graph = TestGraph(values: [1, 2, 3])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2], [3]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
    
    func testGraphWithOneTrueComponent() {
        let graph = TestGraph(values: [1, 2, 3], edges: [(1, 2), (2, 3)])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2], [3]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
    
    func testGraphWithMultipleComponents() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(2, 3), (4, 5), (5, 6)])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2], [3], [4], [5], [6]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
    
    func testGraphWithMultipleComponentsAndCycles() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(2, 3), (3, 2), (4, 5), (5, 6), (6, 4)])
        
        let expectedComponents: Set<Set<Int>> = [[1], [2, 3], [4, 5, 6]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
    
    func testGraphWithOneBigCycle() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5],
                              edges: [(1, 2), (2, 3), (3, 4), (4, 5), (5, 1)])
        
        let expectedComponents: Set<Set<Int>> = [[1, 2, 3, 4, 5]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
    
    func testGraphWithTwoConnectedCycles() {
        let graph = TestGraph(values: [1, 2, 3, 4, 5, 6],
                              edges: [(1, 2), (2, 3), (3, 1), (4, 5), (5, 6), (6, 4)])
        
        let expectedComponents: Set<Set<Int>> = [[1, 2, 3], [4, 5, 6]]
        
        XCTAssertEqual(graph.findStronglyConnectedComponents(), expectedComponents)
    }
}
