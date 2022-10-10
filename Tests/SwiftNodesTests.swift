@testable import SwiftNodes
import XCTest

class SwiftNodesTests: XCTestCase {
    
    func testCodeExamplesFromREADME() throws {
        let graph = Graph<String, Int> { "id\($0)" }  // NodeID == String, NodeValue == Int
        let node1 = graph.insert(1)                   // node1.id == "id1"
        
        let valueForID1 = graph.value(for: "id1")     // valueForID1 == 1
        let nodeForID1 = graph.node(for: "id1")       // nodeForID1 === node1
        
        XCTAssertEqual(valueForID1, node1.value)
        XCTAssertIdentical(nodeForID1, node1)
    }
    
    func testAddingEdges() throws {
        let graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        graph.addEdge(from: node1, to: node2)
        
        XCTAssertNotNil(graph.edge(from: node1, to: node2))
        XCTAssertNil(graph.edge(from: node2, to: node1))
        XCTAssertEqual(graph.edge(from: node1, to: node2)?.count, 1)
    }
    
    func testAddingEdgeWithBigCount() throws {
        let graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        
        graph.addEdge(from: node1, to: node2, count: 42)
        XCTAssertEqual(graph.edge(from: node1, to: node2)?.count, 42)
        
        graph.addEdge(from: node1, to: node2, count: 58)
        XCTAssertEqual(graph.edge(from: node1, to: node2)?.count, 100)
    }
    
    func testEdgesAreDirected() throws {
        let graph = Graph<String, Int> { "id\($0)" }
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        XCTAssertNotNil(graph.addEdge(from: node1, to: node2))
        XCTAssertNil(graph.edge(from: node2, to: node1))
    }
    
    func testUUIDAsID() throws {
        let graph = Graph<UUID, Int> { _ in UUID() }  // NodeID == UUID, NodeValue == Int
        let node1 = graph.insert(1)
        let node2 = graph.insert(1)
        XCTAssertNotIdentical(node1, node2)
        XCTAssertEqual(node1.value, node2.value)
        XCTAssertNotEqual(node1.id, node2.id)
    }
    
    func testOmittingClosureForIdentifiableValues() throws {
        struct IdentifiableValue: Identifiable { let id = UUID() }
        let graph = Graph<UUID, IdentifiableValue>()  // NodeID == NodeValue.ID == UUID
        let node = graph.insert(IdentifiableValue())  // node.id == node.value.id
        XCTAssertEqual(node.id, node.value.id)
    }
    
    func testSorting() throws {
        let graph = Graph<Int, Int>()
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let edge = graph.addEdge(from: node1, to: node2)
        
        graph.remove(edge)
        graph.removeEdge(with: edge.id)
        graph.removeEdge(with: .init(node1, node2))
        graph.removeEdge(with: .init(node1.id, node2.id))
        graph.removeEdge(from: node1, to: node2)
        graph.removeEdge(from: node1.id, to: node2.id)
    }
    
    func testSixWaysToRemoveAnEdgeDoCompile() {
        let graph = Graph<Int, Int>()
        let node1 = graph.insert(5)
        let node2 = graph.insert(3)
        let edge = graph.addEdge(from: node1, to: node2)
        
        XCTAssertNotNil(edge)
        XCTAssertIdentical(edge, graph.edge(from: node1, to: node2))
        
        graph.remove(edge)
        
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        graph.removeEdge(with: edge.id)
        graph.removeEdge(with: .init(node1, node2))
        graph.removeEdge(with: .init(node1.id, node2.id))
        graph.removeEdge(from: node1, to: node2)
        graph.removeEdge(from: node1.id, to: node2.id)
    }
    
    func testInsertingConnectingAndDisconnectingValues() throws {
        let graph = Graph<String, Int> { "id\($0)" }
        XCTAssertNil(graph.node(for: "id1"))
        XCTAssertNil(graph.value(for: "id1"))
        
        let node1 = graph.insert(1)
        XCTAssertEqual(graph.value(for: "id1"), 1)
        XCTAssertIdentical(graph.node(for: "id1"), node1)
        XCTAssertIdentical(graph.insert(1), node1)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        
        XCTAssertEqual(node1.id, "id1")
        XCTAssertEqual(node1.value, 1)
        
        XCTAssert(node1.ancestors.isEmpty)
        XCTAssert(node1.descendants.isEmpty)
        XCTAssert(node1.isSource)
        XCTAssert(node1.isSink)

        let node2 = graph.insert(2)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        let edge12 = try graph.addEdge(from: node1.id, to: node2.id).unwrap()
        XCTAssertNotNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(graph.edge(from: node1, to: node2))
        
        XCTAssertEqual(edge12.count, 1)
        XCTAssertIdentical(edge12, graph.addEdge(from: "id1", to: "id2"))
        XCTAssertEqual(edge12.count, 2)
        XCTAssertIdentical(edge12.origin, node1)
        XCTAssertIdentical(edge12.destination, node2)
        
        XCTAssertFalse(node1.isSink)
        XCTAssert(node1.descendants.contains(node2))
        XCTAssert(node1.isSource)
        
        XCTAssertFalse(node2.isSource)
        XCTAssert(node2.ancestors.contains(node1))
        XCTAssert(node2.isSink)
        
        graph.removeEdge(with: edge12.id)
        XCTAssertNil(graph.edge(from: "id1", to: "id2"))
        XCTAssertNil(graph.edge(from: node1, to: node2))
        
        XCTAssertEqual(edge12.count, 0)
        
        XCTAssert(node1.ancestors.isEmpty)
        XCTAssert(node1.descendants.isEmpty)
        XCTAssert(node1.isSource)
        XCTAssert(node1.isSink)
        XCTAssert(node2.ancestors.isEmpty)
        XCTAssert(node2.descendants.isEmpty)
        XCTAssert(node2.isSource)
        XCTAssert(node2.isSink)
    }
    
    func testGraphCopying() {
        let graph = Graph<String, Int> { "id\($0)" }
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let node3 = graph.insert(3)
        
        let edge1 = graph.addEdge(from: node1, to: node2)
        _ = graph.addEdge(from: node2, to: node3, count: 2)
        
        let graphCopy = graph.copy()
        XCTAssertEqual(graph.values, graphCopy.values)
        XCTAssertEqual(graph.nodesIDs, graphCopy.nodesIDs)
        XCTAssert(Set(graph.nodes).intersection(Set(graphCopy.nodes)).isEmpty)
        XCTAssertEqual(graph.value(for: "id3"), graphCopy.value(for: "id3"))
        
        XCTAssertNil(graphCopy.edge(from: node1, to: node2))
        XCTAssertNotNil(graphCopy.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(graphCopy.edge(from: "id2", to: "id3"))
        XCTAssertNil(graphCopy.edge(from: "id1", to: "id3"))
        XCTAssertNotIdentical(graphCopy.edge(from: "id1", to: "id2"), edge1)
        XCTAssertEqual(graphCopy.edge(from: "id2", to: "id3")?.count, 2)
    }
    
    func testMinimumEquivalentGraph() {
        // make original graph
        let graph = Graph<String, Int> { "id\($0)" }
        
        let node1 = graph.insert(1)
        let node2 = graph.insert(2)
        let node3 = graph.insert(3)
        
        graph.addEdge(from: node1, to: node2)
        graph.addEdge(from: node2, to: node3)
        graph.addEdge(from: node1, to: node3)
        
        XCTAssertEqual(graph.edges.count, 3)
        
        // make MEG
        let meg = graph.makeMinimumEquivalentGraph()
        
        XCTAssertEqual(meg.edges.count, 2)
        XCTAssertNotNil(meg.edge(from: "id1", to: "id2"))
        XCTAssertNotNil(meg.edge(from: "id2", to: "id3"))
        XCTAssertNil(meg.edge(from: "id1", to: "id3"))
    }
    
    // TODO: Test more algorithms
}
