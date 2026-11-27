"
I am what a renderer draws: a title, a set of nodes and a set of `ArchDocEdge`.

My nodes are classes and my edges are facts about them. I hold no layout and no colour, and I know nothing of Roassal: `ArchDoc-Core` must load into an image with no graphics library at all, so that an architecture test can run where no window can open.

`ArchDocModel` builds me from one package. `ArchDocObjectGraph` builds a graph of live objects instead, which is the same shape with instances for nodes.

I know four things about a node: that it is one, that it is at home — a class the drawn package defines, rather than one a declaration reaches into another package for — that edges reach it, and that the author of the package declared it an entry point, which `entryNodes` answers in the order declared. The first three are read from the code; the fourth is the one thing no formula can work out, so the manifest states it and I carry it.

I answer `edgesOfKind:` so that a renderer can draw holdings, caches and inferred uses each in its own style, and `edgesFrom:` so that a view can list what one class holds.


"
Class {
	#name : 'ArchDocGraph',
	#superclass : 'Object',
	#instVars : [
		'title',
		'nodes',
		'edges',
		'homeNodes',
		'entryNodes'
	],
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'describing' }
ArchDocGraph class >> describe: anObject [
	"What a box and a table row call a node, in one place, because a graph of this library holds
	 classes at one altitude, packages at another, parts at a third, and live objects in an
	 object graph. Anything that has a name is called by it; a live object that has none prints
	 itself, which is what a reader of an object graph wants to read."

	^ (anObject respondsTo: #name)
		ifTrue: [ anObject name asString ]
		ifFalse: [ anObject printString ]
]

{ #category : 'instance creation' }
ArchDocGraph class >> title: aString nodes: aCollection edges: anotherCollection [
	^ self new setTitle: aString nodes: aCollection edges: anotherCollection
]

{ #category : 'instance creation' }
ArchDocGraph class >> title: aString nodes: aCollection edges: anotherCollection home: homeCollection [
	^ self new
		setTitle: aString
		nodes: aCollection
		edges: anotherCollection
		home: homeCollection
]

{ #category : 'initialization' }
ArchDocGraph >> beEnteredAt: aCollection [
	"The nodes the author of the package declared as entry points, in the order declared: that
	 order is the author's statement, so it is kept as given and not made a set. Said after I am
	 built, because a reader of my creation message should not have to count five arguments."

	entryNodes := aCollection asArray
]

{ #category : 'accessing' }
ArchDocGraph >> describe: aNode [
	"My nodes are classes in a package diagram, packages in a project diagram, parts in a
	 component diagram and objects in an object graph. My class says how each is named."

	^ self class describe: aNode
]

{ #category : 'accessing' }
ArchDocGraph >> edges [
	^ edges
]

{ #category : 'querying' }
ArchDocGraph >> edgesFrom: aNode [
	^ edges select: [ :each | each source = aNode ]
]

{ #category : 'querying' }
ArchDocGraph >> edgesOfKind: aSymbol [
	"So that a renderer draws each kind in its own style without restating what the kinds are."

	^ edges select: [ :each | each kind = aSymbol ]
]

{ #category : 'accessing' }
ArchDocGraph >> entryNodes [
	"The nodes the author of the package said to read first, in the order they were declared.
	 Empty is the honest answer of a graph nobody declared an entry point for."

	^ entryNodes
]

{ #category : 'testing' }
ArchDocGraph >> holdsAtHome: aNode [
	"Does this node belong to what the diagram is about — a class the drawn package defines,
	 rather than one a declaration reaches into another package for?"

	^ homeNodes includes: aNode
]

{ #category : 'inspector' }
ArchDocGraph >> inspectionEdges: aBuilder [
	"My arrows, each row saying which kind it is, so a reader can check the picture against the
	 facts it was drawn from."

	<inspectorPresentationOrder: 1 title: 'Edges'>
	^ aBuilder newTable
		items: (edges asSortedCollection: [ :a :b | a printString <= b printString ]) asArray;
		addColumn: ((SpStringTableColumn title: 'From' evaluated: [ :each | each sourceDescription ]) width: 240);
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each kind asString ]) width: 100);
		addColumn: ((SpStringTableColumn title: 'To' evaluated: [ :each | each targetDescription ]) width: 240);
		addColumn: (SpStringTableColumn title: 'Role' evaluated: [ :each | each label ]);
		yourself
]

{ #category : 'inspector' }
ArchDocGraph >> inspectionNodes: aBuilder [
	"My nodes with what each one holds, counted from my own edges rather than restated, so a
	 node that holds nothing reads as such."

	<inspectorPresentationOrder: 2 title: 'Nodes'>
	^ aBuilder newTable
		items: (nodes asSortedCollection: [ :a :b | (self describe: a) <= (self describe: b) ]) asArray;
		addColumn: ((SpStringTableColumn title: 'Node' evaluated: [ :each | self describe: each ]) width: 280);
		addColumn: ((SpStringTableColumn title: 'Holds' evaluated: [ :each |
			((self edgesFrom: each) count: [ :edge | edge isUse not ]) asString ]) width: 80);
		addColumn: (SpStringTableColumn title: 'Reaches' evaluated: [ :each |
			((self edgesFrom: each) count: [ :edge | edge isUse ]) asString ]);
		yourself
]

{ #category : 'inspector' }
ArchDocGraph >> inspectionWhereToStart: aBuilder [
	"Which of my nodes to read first. The order and the table are ArchDocReadingOrder's, built
	 through the same builder. It is offered here, on the graph, because a component, a map and a
	 package each hold one and each offered the tab by building an order of its own: the graph
	 answers it, and they delegate."

	<inspectorPresentationOrder: 3 title: 'Where to start'>
	^ (ArchDocReadingOrder on: self) inspectionWhereToStart: aBuilder
]

{ #category : 'testing' }
ArchDocGraph >> isEntryPoint: aNode [
	"Did the author of the package say to read this node first?"

	^ entryNodes includes: aNode
]

{ #category : 'accessing' }
ArchDocGraph >> nodes [
	^ nodes
]

{ #category : 'printing' }
ArchDocGraph >> printOn: aStream [
	aStream
		<< (title ifNil: [ 'graph' ])
		<< ' ('
		<< nodes size asString
		<< ' nodes, '
		<< edges size asString
		<< ' edges)'
]

{ #category : 'initialization' }
ArchDocGraph >> setTitle: aString nodes: aCollection edges: anotherCollection [
	"A graph that names no home is at home everywhere: a graph of live objects is about the
	 objects themselves, and no node of it is a visitor."

	self setTitle: aString nodes: aCollection edges: anotherCollection home: aCollection
]

{ #category : 'initialization' }
ArchDocGraph >> setTitle: aString nodes: aCollection edges: anotherCollection home: homeCollection [
	"A graph built from four facts about its nodes declares no entry point: the formula alone
	 then decides the reading order. A builder that knows where a reader starts says so with
	 beEnteredAt:, which is a message of its own rather than a fifth argument here."

	title := aString.
	nodes := aCollection asArray.
	edges := anotherCollection asArray.
	homeNodes := homeCollection asSet.
	entryNodes := #()
]

{ #category : 'accessing' }
ArchDocGraph >> title [
	^ title
]
