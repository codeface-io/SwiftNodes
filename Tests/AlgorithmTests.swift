@testable import SwiftNodes
import XCTest

class AlgorithmTests: XCTestCase {
    
    func testMinimumEquivalentGraph() {
        // make original graph
        var graph = Graph<String, Int> { "id\($0)" }
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let node3 = graph.insert(3)
        
        graph.addEdge(from: node1.id, to: node2.id)
        graph.addEdge(from: node2.id, to: node3.id)
        graph.addEdge(from: node1.id, to: node3.id)
        
        XCTAssertEqual(graph.edges.count, 3)
        
        // make MEG
        let meg = graph.makeMinimumEquivalentGraph()
        
        XCTAssertEqual(meg.edges.count, 2)
        XCTAssertNotNil(meg.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(meg.edge(from: "id2", to: "id3"))
        XCTAssertNil(meg.edge(from: "id1", to: "id3"))
    }
    
    func testSubGraph() {
        var graph = Graph<Int, Int>()
        
        for value in 0 ... 20
        {
            graph.insert(value)
        }
        
        for value in 0 ... 19
        {
            graph.addEdge(from: value, to: value + 1)
        }
        
        XCTAssertEqual(graph.edges.count, 20)
        XCTAssertNotNil(graph.edge(from: 12, to: 13))
        
        let subsetOfNodeIDs: Set<Int> = [0, 3, 6, 9, 12, 13, 14, 15]
        let subGraph = graph.subGraph(nodeIDs: subsetOfNodeIDs)
        
        XCTAssertEqual(graph.edges.count, 20)
        XCTAssertNotNil(graph.edge(from: 9, to: 10))
        
        XCTAssertEqual(subGraph.edges.count, 3)
        XCTAssertNil(subGraph.edge(from: 9, to: 10))
    }
}
