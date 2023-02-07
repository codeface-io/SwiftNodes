@testable import SwiftNodes
import XCTest

class EdgeTests: XCTestCase {
    
    func testInitializeWithValuesAndEdges() throws {
        // with values as node IDs
        let graph = TestGraph(values: [-7, 0, 5, 42], edges: [(-7, 0)])
        
        XCTAssertNotNil(graph.edge(from: -7, to: 0))
        XCTAssertEqual(graph.node(with: -7)?.descendantIDs.contains(0), true)
        XCTAssertEqual(graph.node(with: 0)?.ancestorIDs.contains(-7), true)
        
        // with identifiable values
        struct IdentifiableValue: Identifiable { let id: Int }
        
        let values: [IdentifiableValue] = [.init(id: -7), .init(id: 0), .init(id: 5), .init(id: 42)]
        let graph2 = IdentifiableValuesGraph<IdentifiableValue, Int>(values: values, edges: [(-7, 0)])
        
        XCTAssertNotNil(graph2.edge(from: -7, to: 0))
        XCTAssertEqual(graph2.node(with: -7)?.descendantIDs.contains(0), true)
        XCTAssertEqual(graph2.node(with: 0)?.ancestorIDs.contains(-7), true)
    }
    
    func testAddingEdges() throws {
        var graph = TestGraph(values: [1, 2])
        graph.insertEdge(from: 1, to: 2)
        
        XCTAssertNil(graph.edge(from: 1, to: 3))
        XCTAssertNil(graph.edge(from: 0, to: 2))
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.weight, 1)
    }
    
    func testAddingEdgeWithBigCount() throws {
        var graph = TestGraph(values: [1, 2])
        
        graph.insertEdge(from: 1, to: 2, weight: 42)
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.weight, 42)
        
        graph.add(weight: 58, toEdgeWith: .init(1, 2))
        XCTAssertEqual(graph.edge(from: 1, to: 2)?.weight, 100)
    }
    
    func testEdgesAreDirected() throws {
        var graph = TestGraph(values: [1, 2])
        graph.insertEdge(from: 1, to: 2)
        
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: 2, to: 1))
    }
    
    func testThreeWaysToRemoveAnEdge() {
        var graph = TestGraph(values: [5, 3])
        
        let edge = graph.insertEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(with: edge.id)
        XCTAssertNil(graph.edge(from: 5, to: 3))
        
        graph.insertEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(with: .init(5, 3))
        XCTAssertNil(graph.edge(from: 5, to: 3))
        
        graph.insertEdge(from: 5, to: 3)
        XCTAssertNotNil(graph.edge(from: 5, to: 3))
        graph.removeEdge(from: 5, to: 3)
        XCTAssertNil(graph.edge(from: 5, to: 3))
    }
    
    func testInsertingConnectingAndDisconnectingValues() throws {
        var graph = TestGraph()
        XCTAssertNil(graph.node(with: 1))
        XCTAssertNil(graph.value(for: 1))
        
        let node1 = graph.insert(1)
        XCTAssertEqual(graph.value(for: 1), 1)
        XCTAssertEqual(graph.node(with: 1)?.id, node1.id)
        XCTAssertEqual(graph.insert(1).id, node1.id)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        
        XCTAssertEqual(node1.id, 1)
        XCTAssertEqual(node1.value, 1)

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        let edge12 = graph.insertEdge(from: node1.id, to: node2.id)
        XCTAssertNotNil(graph.edge(from: 1, to: 2))
        XCTAssertNotNil(graph.edge(from: node1.id, to: node2.id))
        
        XCTAssertEqual(edge12.weight, 1)
        XCTAssertEqual(2, graph.add(weight: 1, toEdgeWith: .init(1, 2)))
        XCTAssertEqual(graph.edge(from: node1.id, to: node2.id)?.weight, 2)
        XCTAssertEqual(edge12.originID, node1.id)
        XCTAssertEqual(edge12.destinationID, node2.id)
        
        guard let updatedNode1 = graph.node(with: node1.id) else
        {
            throw "There should still exist a node for the id of node 1"
        }
        
        XCTAssertFalse(updatedNode1.isSink)
        XCTAssert(updatedNode1.descendantIDs.contains(node2.id))
        XCTAssert(updatedNode1.isSource)
        
        guard let updatedNode2 = graph.node(with: node2.id) else
        {
            throw "There should still exist a node for the id of node 2"
        }
        
        XCTAssertFalse(updatedNode2.isSource)
        XCTAssert(updatedNode2.ancestorIDs.contains(node1.id))
        XCTAssert(updatedNode2.isSink)
        
        graph.removeEdge(with: edge12.id)
        XCTAssertNil(graph.edge(from: 1, to: 2))
        XCTAssertNil(graph.edge(from: node1.id, to: node2.id))
        
        guard let finalNode1 = graph.node(with: node1.id),
              let finalNode2 = graph.node(with: node2.id) else
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
