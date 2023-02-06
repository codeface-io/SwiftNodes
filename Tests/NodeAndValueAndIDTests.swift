@testable import SwiftNodes
import XCTest

class NodeAndValueAndIDTests: XCTestCase {
    
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
    
    func testInsertingNodes() throws {
        var graph = Graph<Int, Int>()
        let node1 = graph.insert(1)
        
        let valueForID1 = graph.value(for: 1)
        let nodeForID1 = graph.node(for: 1)
        
        XCTAssertEqual(valueForID1, node1.value)
        XCTAssertEqual(nodeForID1?.id, node1.id)
    }
    
    func testUUIDAsID() throws {
        var graph = Graph<UUID, Int>()
        let node1 = graph.update(1, for: UUID())
        let node2 = graph.update(1, for: UUID())
        XCTAssertNotEqual(node1.id, node2.id)
        XCTAssertEqual(node1.value, node2.value)
        XCTAssertNotEqual(node1.id, node2.id)
    }
    
    func testOmittingClosureForIdentifiableValues() throws {
        struct IdentifiableValue: Identifiable { let id = UUID() }
        var graph = Graph<UUID, IdentifiableValue>()  // NodeID == NodeValue.ID == UUID
        let node = graph.insert(IdentifiableValue())  // node.id == node.value.id
        XCTAssertEqual(node.id, node.value.id)
    }
}
