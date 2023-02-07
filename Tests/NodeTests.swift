@testable import SwiftNodes
import XCTest

class NodeTests: XCTestCase {
    
    func testInsertingNodes() throws {
        var graph = TestGraph()
        let node1 = graph.insert(1)
        
        let valueForID1 = graph.value(for: 1)
        let nodeForID1 = graph.node(with: 1)
        
        XCTAssertEqual(valueForID1, node1.value)
        XCTAssertEqual(nodeForID1?.id, node1.id)
    }
    
    func testUUIDAsID() throws {
        var graph = Graph<UUID, Int, Double>()
        let node1 = graph.update(1, for: UUID())
        let node2 = graph.update(1, for: UUID())
        XCTAssertNotEqual(node1.id, node2.id)
        XCTAssertEqual(node1.value, node2.value)
        XCTAssertNotEqual(node1.id, node2.id)
    }
    
    func testOmittingClosureForIdentifiableValues() throws {
        struct IdentifiableValue: Identifiable { let id = UUID() }
        var graph = Graph<UUID, IdentifiableValue, Double>()
        let node = graph.insert(IdentifiableValue())  // node.id == node.value.id
        XCTAssertEqual(node.id, node.value.id)
    }
}
