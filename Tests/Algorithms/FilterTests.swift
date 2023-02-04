@testable import SwiftNodes
import XCTest

class FilterTests: XCTestCase {
    
    func testEdgeFilterCopyingGraph() {
        let graph = Graph(values: [1, 2, 3, 4],
                          edges: [(1, 2), (2, 3), (3, 4)])
        
        let filteredGraph = graph.filteredEdges {
            $0.originID != 3 && $0.destinationID != 3
        }
        
        let expectedGraph = Graph(values: [1, 2, 3, 4],
                                  edges: [(1, 2)])
        
        // this also compares node neighbour caches, so we also test that the filter correctly updates those...
        XCTAssertEqual(filteredGraph, expectedGraph)
    }
    
    func testEdgeFilterMutatingGraph() {
        var graph = Graph(values: [1, 2, 3, 4],
                          edges: [(1, 2), (2, 3), (3, 4)])
        
        graph.filterEdges {
            $0.originID != 3 && $0.destinationID != 3
        }
        
        let expectedGraph = Graph(values: [1, 2, 3, 4],
                                  edges: [(1, 2)])
        
        // this also compares node neighbour caches, so we also test that the filter correctly updates those...
        XCTAssertEqual(graph, expectedGraph)
    }
}
