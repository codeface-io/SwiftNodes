@testable import SwiftNodes
import XCTest

class NodeFilterTests: XCTestCase {
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        
        XCTAssertEqual(graph.filteredNodes([]),
                       Graph(values: []))
        
        XCTAssertEqual(graph.filteredNodes([1, 2]),
                       Graph(values: [1, 2]))
        
        XCTAssertEqual(graph.filteredNodes([1, 2, 4]),
                       Graph(values: [1, 2]))
        
        XCTAssertEqual(graph.filteredNodes([1, 2, 3]),
                       Graph(values: [1, 2, 3]))
    }
    
    func testSimpleGraph() {
        let graph = Graph(values: [1, 2, 3, 4],
                          edges: [(1, 2), (2, 3), (3, 4)])
        
        XCTAssertEqual(graph.filteredNodes([]),
                       Graph(values: []))
        
        XCTAssertEqual(graph.filteredNodes([1, 3]),
                       Graph(values: [1, 3]))
        
        XCTAssertEqual(graph.filteredNodes([2, 4]),
                       Graph(values: [2, 4]))
        
        XCTAssertEqual(graph.filteredNodes([2, 3]),
                       Graph(values: [2, 3], edges: [(2, 3)]))
        
        XCTAssertEqual(graph.filteredNodes([2, 3, 4]),
                       Graph(values: [2, 3, 4], edges: [(2, 3), (3, 4)]))
    }
    
    func testGraphWithTransitiveEdges() {
        let graph = Graph(values: [1, 2, 3, 4, 5],
                          edges: [(1, 2), (2, 3), (3, 4), (4, 5), (1, 3), (2, 4), (3, 5)])
        
        XCTAssertEqual(graph.filteredNodes([]),
                       Graph(values: []))
        
        XCTAssertEqual(graph.filteredNodes([2, 3]),
                       Graph(values: [2, 3], edges: [(2, 3)]))
        
        XCTAssertEqual(graph.filteredNodes([2, 3, 4]),
                       Graph(values: [2, 3, 4], edges: [(2, 3), (3, 4), (2, 4)]))
        
        XCTAssertEqual(graph.filteredNodes([1, 3, 5]),
                       Graph(values: [1, 3, 5], edges: [(1, 3), (3, 5)]))
    }
    
    func testGraphWithCycles() {
        let graph = Graph(values: [1, 2, 3, 4, 5],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 3)])
        
        XCTAssertEqual(graph.filteredNodes([]),
                       Graph(values: []))
        
        XCTAssertEqual(graph.filteredNodes([1, 4]),
                       Graph(values: [1, 4]))
        
        XCTAssertEqual(graph.filteredNodes([2, 3, 4]),
                       Graph(values: [2, 3, 4], edges: [(2, 3), (3, 4)]))
        
        XCTAssertEqual(graph.filteredNodes([3, 4, 5]),
                       Graph(values: [3, 4, 5], edges: [(3, 4), (4, 5), (5, 3)]))
    }
}
