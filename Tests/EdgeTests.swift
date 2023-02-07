@testable import SwiftNodes
import XCTest

class EdgeTests: XCTestCase {
    
    func testInitializeWithValuesAndEdges() throws {
        // with values as node IDs
        let graph = Graph(values: [-7, 0, 5, 42], edges: [(-7, 0)])
        
        XCTAssertNotNil(graph.edge(from: -7, to: 0))
        XCTAssertEqual(graph.node(for: -7)?.descendantIDs.contains(0), true)
        XCTAssertEqual(graph.node(for: 0)?.ancestorIDs.contains(-7), true)
        
        // with identifiable values
        struct IdentifiableValue: Identifiable { let id: Int }
        
        let values: [IdentifiableValue] = [.init(id: -7), .init(id: 0), .init(id: 5), .init(id: 42)]
        let graph2 = Graph(values: values, edges: [(-7, 0)])
        
        XCTAssertNotNil(graph2.edge(from: -7, to: 0))
        XCTAssertEqual(graph2.node(for: -7)?.descendantIDs.contains(0), true)
        XCTAssertEqual(graph2.node(for: 0)?.ancestorIDs.contains(-7), true)
    }
    
    func testAddingEdges() throws {
        var graph = Graph(values: [1, 2])
        graph.addEdge(from: 1, to: 2)
        
        XCTAssertNil(graph.edge(from: 1, to: 3))
        XCTAssertNil(graph.edge(from: 0, to: 2))
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.count, 1)
    }
    
    func testAddingEdgeWithBigCount() throws {
        var graph = Graph(values: [1, 2])
        
        graph.addEdge(from: 1, to: 2, count: 42)
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.count, 42)
        
        graph.addEdge(from: 1, to: 2, count: 58)
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.count, 100)
    }
    
    func testEdgesAreDirected() throws {
        var graph = Graph(values: [1, 2])
        graph.addEdge(from: 1, to: 2)
        
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: 2, to: 1))
    }
    
    func testThreeWaysToRemoveAnEdge() {
        var graph = Graph(values: [5, 3])
        
        let edge = graph.addEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(with: edge.id)
        XCTAssertNil(graph.edge(from: 5, to: 3))
        
        graph.addEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(with: .init(5, 3))
        XCTAssertNil(graph.edge(from: 5, to: 3))
        
        graph.addEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(from: 5, to: 3)
        XCTAssertNil(graph.edge(from: 5, to: 3))
    }
    
    func testInsertingConnectingAndDisconnectingValues() throws {
        var graph = Graph<Int, Int>()
        XCTAssertNil(graph.node(for: 1))
        XCTAssertNil(graph.value(for: 1))
        
        let node1 = graph.insert(1)
        XCTAssertEqual(graph.value(for: 1), 1)
        XCTAssertEqual(graph.node(for: 1)?.id, node1.id)
        XCTAssertEqual(graph.insert(1).id, node1.id)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        
        XCTAssertEqual(node1.id, 1)
        XCTAssertEqual(node1.value, 1)

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        let edge12 = graph.addEdge(from: node1.id, to: node2.id)
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertNotNil(graph.edge(from: node1.id, to: node2.id))
        
        XCTAssertEqual(edge12.count, 1)
        XCTAssertEqual(edge12.id, graph.addEdge(from: 1, to: 2).id)
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.count, 2)
        XCTAssertEqual(edge12.originID, node1.id)
        XCTAssertEqual(edge12.destinationID, node2.id)
        
        guard let updatedNode1 = graph.node(for: node1.id) else
        {
            throw "There should still exist a node for the id of node 1"
        }
        
        XCTAssertFalse(updatedNode1.isSink)
        XCTAssert(updatedNode1.descendantIDs.contains(node2.id))
        XCTAssert(updatedNode1.isSource)
        
        guard let updatedNode2 = graph.node(for: node2.id) else
        {
            throw "There should still exist a node for the id of node 2"
        }
        
        XCTAssertFalse(updatedNode2.isSource)
        XCTAssert(updatedNode2.ancestorIDs.contains(node1.id))
        XCTAssert(updatedNode2.isSink)
        
        graph.removeEdge(with: edge12.id)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        guard let finalNode1 = graph.node(for: node1.id),
              let finalNode2 = graph.node(for: node2.id) else
        {
            throw "There should still exist node for the ids of nodes 1 and 2"
        }
        
        XCTAssert(finalNode1.ancestorIDs.isEmpty)
        XCTAssert(finalNode1.descendantIDs.isEmpty)
        XCTAssert(finalNode1.isSource)
        XCTAssert(finalNode1.isSink)
        XCTAssert(finalNode2.ancestorIDs.isEmpty)
        XCTAssert(finalNode2.descendantIDs.isEmpty)
        XCTAssert(finalNode2.isSource)
        XCTAssert(finalNode2.isSink)
    }
}
