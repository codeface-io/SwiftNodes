@testable import SwiftNodes
import XCTest

class CondensationGraphTests: XCTestCase {
    
    func testGraphWithoutEdges() {
        let graph = Graph(values: [1, 2, 3])
        let condensationGraph = graph.makeCondensationGraph()
        XCTAssertEqual(condensationGraph.nodes.count, 3)
    }
    
    func testGraphWithoutCycles() {
        let graph = Graph(values: [1, 2, 3, 4],
        edges: [(1, 2), (2, 3), (3, 4), (1, 3), (2, 4)])
        let condensationGraph = graph.makeCondensationGraph()
        XCTAssertEqual(condensationGraph.nodes.count, 4)
    }
    
    func testGraphMadeOfOneCycle() {
        let graph = Graph(values: [1, 2, 3, 4],
                          edges: [(1, 2), (2, 3), (3, 4), (4, 1)])
        
        let condensationGraph = graph.makeCondensationGraph()
        XCTAssertEqual(condensationGraph.nodes.count, 1)
        XCTAssertEqual(condensationGraph.edges.count, 0)
        
        let condensationNodeSizes = condensationGraph.values.map { $0.nodes.count }.sorted()
        XCTAssertEqual(condensationNodeSizes, [4])
    }
    
    func testGraphContainingOneCycle() {
        let graph = Graph(values: [1, 2, 3, 4],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        XCTAssertEqual(condensationGraph.nodes.count, 2)
        XCTAssertEqual(condensationGraph.edges.count, 1)
        
        let condensationNodeSizes = condensationGraph.values.map { $0.nodes.count }.sorted()
        XCTAssertEqual(condensationNodeSizes, [1, 3])
    }
    
    func testGraphContainingTwoCycles() {
        let graph = Graph(values: [1, 2, 3, 4, 5, 6],
                          edges: [(1, 2), (2, 3), (3, 1), (3, 4), (4, 5), (5, 6), (6, 4)])
        
        let condensationGraph = graph.makeCondensationGraph()
        XCTAssertEqual(condensationGraph.nodes.count, 2)
        XCTAssertEqual(condensationGraph.edges.count, 1)
        
        let condensationNodeSizes = condensationGraph.values.map { $0.nodes.count }.sorted()
        XCTAssertEqual(condensationNodeSizes, [3, 3])
    }
}
