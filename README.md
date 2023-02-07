# SwiftNodes

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcodeface-io%2FSwiftNodes%2Fbadge%3Ftype%3Dswift-versions&style=flat-square)](https://swiftpackageindex.com/codeface-io/SwiftNodes) &nbsp;[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fcodeface-io%2FSwiftNodes%2Fbadge%3Ftype%3Dplatforms&style=flat-square)](https://swiftpackageindex.com/codeface-io/SwiftNodes) &nbsp;[![](https://img.shields.io/badge/Documentation-DocC-blue.svg?style=flat-square)](https://swiftpackageindex.com/codeface-io/SwiftNodes/documentation) &nbsp;[![](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat-square)](LICENSE)

👩🏻‍🚀 *This project [is still a tad experimental](#development-status). Contributors and pioneers welcome!*

## What?

SwiftNodes offers a concurrency safe [graph data structure](https://en.wikipedia.org/wiki/Graph_(abstract_data_type)) together with graph algorithms. A graph stores values in identifiable nodes which can be connected via edges.

### Contents

* [Why?](#Why?)
* [How?](#How?)
* [Included Algorithms](#Included-Algorithms)
* [Architecture](#Architecture)
* [Development Status](#Development-Status)
* [Roadmap](#Roadmap)

## Why?

Graphs may be the most fundamental mathematical concept besides numbers. They have wide applications in problem solving, data analysis and visualization. And although such data structures fit well with the language, graph implementations in Swift are lacking – in particular, comprehensive graph algorithm libraries.

SwiftNodes and its included algorithms were extracted from [Codeface](https://codeface.io). But SwiftNodes is general enough to serve other applications as well – and extensible enough for more algorithms to be added.

### Design Goals

* Usability, safety, extensibility and maintainability – which also imply simplicity.
* In particular, the API is supposed to feel familiar and fit well with official Swift data structures. So one question that guides its design is: What would Apple do?

We put the above qualities over performance. But that doesn't mean we neccessarily end up with suboptimal performance. The main compromise SwiftNodes involves is that nodes are value types and can not be referenced, so they must be hashed. But that doesn't change the average case complexity and, in the future, we might even be able to avoid that hashing in essential use cases by exploiting array indices.

## How?

The following explanations touch only parts of the SwiftNodes API. We recommend exploring the [DocC reference](https://swiftpackageindex.com/codeface-io/SwiftNodes/documentation), [unit tests](https://github.com/codeface-io/SwiftNodes/tree/master/Tests) and [production code](https://github.com/codeface-io/SwiftNodes/tree/master/Code). The code in particular is actually small and easy to grasp.

### Insert Values

A `Graph<NodeID: Hashable, NodeValue>` holds values of type `NodeValue` in nodes of type `GraphNode<NodeID: Hashable, NodeValue>`. Nodes are unique and have IDs of type `NodeID`:

```swift
var graph = Graph<String, Int> { "id\($0)" }  // NodeID == String, NodeValue == Int
let node = graph.insert(1)                    // node.id == "id1", node.value == 1

let nodeForID1 = graph.node(for: "id1")       // nodeForID1.id == "id1"
let valueForID1 = graph.value(for: "id1")     // valueForID1 == 1
```

When inserting a value, a `Graph` must determine the ID of the node that would store the value. So the `Graph` initializer takes a closure returning a `NodeID` given a `NodeValue`.

> Side Note: The reason, there's an explicit node type at all is that a) values don't need to be unique, but nodes in a graph are, and b) a node holds caches for quick access to its neighbours. The reason there is an explicit edge type at all is that edges have a count (they are "weighted") and may hold their own values in the future.

### Generate Node IDs

You may generate `NodeID`s independent of `NodeValue`s:

```swift
var graph = Graph<UUID, Int> { _ in UUID() }  // NodeID == UUID, NodeValue == Int
let node1 = graph.insert(42)
let node2 = graph.insert(42)  // node1.id != node2.id, same value in different nodes
```

If `NodeID` and `NodeValue` are the same type, you can omit the closure and the `Graph` will assume the value is itself used as the node ID:

```swift
var graph = Graph<Int, Int>()  // NodeID == NodeValue == Int
let node1 = graph.insert(42)   // node1.value == node1.id == 42
let node2 = graph.insert(42)   // node1.id == node2.id because 42 implies the same ID
```

And if your `NodeValue` is itself `Identifiable` by IDs of type `NodeID`, then you can also omit the closure and `Graph` will use the `ID` of a `NodeValue` as the `NodeID` of the node holding that value:

```swift
struct IdentifiableValue: Identifiable { let id = UUID() }
var graph = Graph<UUID, IdentifiableValue>()  // NodeID == NodeValue.ID == UUID
let node = graph.insert(IdentifiableValue())  // node.id == node.value.id
```

### Connect Nodes via Edges

```swift
var graph = Graph<String, Int> { "id\($0)" }
let node1 = graph.insert(1)
let node2 = graph.insert(2)
let edge = graph.addEdge(from: node1.id,  to: node2.id)
```

An `edge` is directed and points from the node with ID `edge.originID` to the node with ID `edge.destinationID`.

### Specify Edge Counts

Every `edge` has an integer count accessible via `edge.count`. It is more specifically a "count" rather than a "weight", as it increases when the same edge is added again. By default, a new edge has `count` 1 and adding it again increases its `count` by 1. But you can specify a custom count when adding an edge:

```swift
graph.addEdge(from: node1.id, to: node2.id, count: 40)  // edge count is 40
graph.addEdge(from: node1.id, to: node2.id, count: 2)   // edge count is 42
```

### Initialize Graphs With Values And Edges 

To work with a `Graph` constant (for example as a property on a `Sendable` reference type), you need to initialize the whole graph, complete with its values and edges. There are more ways to do so than we can exemplify here, so have a look at the [graph initializers in code](Code/Graph/Graph.swift).

When you don't need to specify edge counts, the initializers allow to specify edges as tuples of node IDs. And when you're passing in values and edges anyway, you can omit the type parameters. Furthermore, you can often omit the closure that determines node IDs, as described earlier. All this together can make initialization as simple as it gets:

```swift
let graph = Graph(values: [-7, 0, 5, 42], 
                  edges: [(-7, 0), (0, 42)])
```

### Remove Edges

A `GraphEdge<NodeID: Hashable, NodeValue>` has its own `ID` type which combines the edge's `originID`- and `destinationID` node IDs. In the context of a `Graph` or `GraphEdge`, you can create edge IDs like so:

```swift
let edgeID = Edge.ID(node1.id, node2.id)
```

This leads to 3 ways of removing an edge:

```swift
let edge = graph.addEdge(from: node1.id, to: node2.id)

graph.removeEdge(with: edge.id)
graph.removeEdge(with: .init(node1.id, node2.id))
graph.removeEdge(from: node1.id, to: node2.id)
```

### Query and Traverse a Graph

`Graph` offers many ways to query its nodes, node IDs, values and edges. Have a look into [Graph.swift](https://github.com/codeface-io/SwiftNodes/blob/master/Code/Graph/Graph.swift) to see them all. In addition, a `GraphNode` has caches that enable quick access to its neighbours:

```swift
node.descendantIDs  // IDs of all nodes to which there is an edge from node
node.ancestorIDs    // IDs of all nodes from which there is an edge to node
node.neighbourIDs   // all descendant- and ancestor IDs
node.isSink         // whether node has no descendants
node.isSource       // whether node has no ancestors
```

### Copy and Share a Graph 

Like the official Swift data structures, `Graph` is a pure `struct` and inherits the benefits of value types:

* You decide on mutability by using `var` or `let`.
* You can use a `Graph` as a `@State` or `@Published` variable with SwiftUI.
* You can use property observers like `didSet` to observe changes in a `Graph`.
* You can easily copy a whole `Graph`.

Many algorithms produce a variant of a given graph. Rather than modifying the original graph, SwiftNodes suggests to copy it. You copy a `Graph` like any other value. But right now, SwiftNodes lets you add and remove only edges – not nodes. So, to create a subgraph with a **subset** of the nodes of a `graph`, you can use `graph.subGraph(nodeIDs:...)`:

```swift
var graph = Graph<Int, Int>()
	/* then add a bunch of nodes and edges ... */
let subsetOfNodeIDs: Set<Int> = [0, 3, 6, 9, 12]
let subGraph = graph.subGraph(nodeIDs: subsetOfNodeIDs)
```

A `Graph` is also `Sendable` **if** its value- and id type are. SwiftNodes is thereby ready for the strict concurrency safety of Swift 6. You can safely share `Sendable` `Graph` values between actors. Remember that, to declare a `Graph` property on a `Sendable` reference type, you need to make that property constant (use `let`).

### Mark Nodes in Algorithms

Many graph algorithms do associate little intermediate results with individual nodes. The literature often refers to this as "marking" a node. The most prominent example is marking a node as visited while traversing a potentially cyclic graph. Some algorithms write multiple different markings to nodes. 

When we made SwiftNodes concurrency safe (to play well with the new Swift concurrency features), we removed the possibility to mark nodes directly, as that had lost its potential for performance optimization. See how the [included algorithms](https://github.com/codeface-io/SwiftNodes/tree/master/Code/Graph%2BAlgorithms) now use hashing to associate markings with nodes.

## Included Algorithms

SwiftNodes has begun to accumulate [some graph algorithms](https://github.com/codeface-io/SwiftNodes/tree/master/Code/Graph%2BAlgorithms). The following overview also links to Wikipedia articles that explain what the algorithms do. We recommend also exploring them in code.

### Components

`graph.findComponents()`  returns multiple sets of node IDs which represent the [components](https://en.wikipedia.org/wiki/Component_(graph_theory)) of the `graph`.

### Strongly Connected Components

`graph.findStronglyConnectedComponents()`  returns multiple sets of node IDs which represent the [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `graph`.

### Condensation Graph

`graph.makeCondensationGraph()` creates the [condensation graph](https://en.wikipedia.org/wiki/Strongly_connected_component) of the `graph`, which is the graph in which all [strongly connected components](https://en.wikipedia.org/wiki/Strongly_connected_component) of the original `graph` have been collapsed into single nodes, so the resulting condensation graph is acyclic.

### Transitive Reduction

`graph.findTransitiveEdges()` finds all edges which are **not** in the [transitive reduction (the minimum equivalent graph)](https://en.wikipedia.org/wiki/Transitive_reduction) of the `graph`. **You** can also use `filterTransitiveReduction()` and `filteredTransitiveReduction()` to create a graph's [minimum equivalent graph](https://en.wikipedia.org/wiki/Transitive_reduction).

Right now, all this only works on acyclic graphs and might even hang or crash on cyclic ones.

### Essential Edges

`graph.findEssentialEdges()` returns the IDs of all "essential" edges. You can also use `graph.filterEssentialEdges()` and `graph.filteredEssentialEdges()` to remove all "non-essential" edges from a `graph`.

Edges are essential when they correspond to edges of the [MEG](https://en.wikipedia.org/wiki/Transitive_reduction) (the transitive reduction) of the [condensation graph](https://en.wikipedia.org/wiki/Strongly_connected_component). In simpler terms: Essential edges are either in cycles or they are essential to the reachability described by the graph – i.e. they cannot be removed without destroying the only path between some nodes.

Note that only edges of the condensation graph can be non-essential and so edges in cycles (i.e. in strongly connected components) are all considered essential. This is because it's [algorithmically](https://en.wikipedia.org/wiki/Feedback_arc_set#Hardness) as well as conceptually hard to decide which edges in cycles are "non-essential". We recommend dealing with cycles independently of using this function.

### Ancestor Counts

`graph.findNumberOfNodeAncestors()` returns a `[NodeID: Int]` containing the ancestor count for each node ID of the `graph`. The ancestor count is the number of all (recursive) ancestors of the node. Basically, it's the number of other nodes from which the node can be reached.

This only works on acyclic graphs right now and might return incorrect results for nodes in cycles.

Ancestor counts can serve as a proxy for [topological sorting](https://en.wikipedia.org/wiki/Topological_sorting).

## Architecture

Here is the architecture (composition and [essential](https://en.wikipedia.org/wiki/Transitive_reduction) dependencies) of the SwiftNodes code folder:

![](Documentation/architecture.png)

The above image was created with [Codeface](https://codeface.io).

## Development Status

From version/tag 0.1.0 on, SwiftNodes adheres to [semantic versioning](https://semver.org). So until it has reached 1.0.0, its API may still break frequently, and we express those breaks with minor version bumps.

SwiftNodes is already being used in production, but [Codeface](https://codeface.io) is still its primary client. SwiftNodes will move to version 1.0.0 as soon as **either one** of these conditions is met:

* Basic practicality and conceptual soundness have been validated by serving multiple real-world clients.
* We feel it's mature enough (well rounded and stable API, comprehensive tests, complete documentation and solid achievement of design goals).

## Roadmap

1. Round out and add algorithms (starting with the needs of Codeface):
   1. Make existing algorithms compatible with cycles (two algorithms are still not). meaning: don't hang or crash, maybe throw an error!
   2. Model edge weights so they *can* be considered in algorithms like Dijkstra. Do we really need a third type parameter for `Graph`? Or just use `Double` as universal weight type? Do we merge that with edge count or keep both distinct?
   3. Update and complete documentation
   4. Move to version 1.0.0 if possible
   5. Add general purpose graph traversal algorithms (BFT, DFT, compatible with potentially cyclic graphs)
   6. Add better ways of topological sorting
   7. Approximate the [minimum feedback arc set](https://en.wikipedia.org/wiki/Feedback_arc_set), so Codeface can guess "faulty" or unintended dependencies, i.e. the fewest dependencies that need to be cut in order to break all cycles.
2. Possibly optimize performance – but only based on measurements and only if measurements show that the optimization yields significant acceleration. Optimizing the algorithms might be more effective than optimizing the data structure itself.
    * What role does `@inlinable` play here?
    * What role does [`lazy`](https://developer.apple.com/documentation/swift/sequence/lazy) play here?
