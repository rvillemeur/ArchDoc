"
I am what a renderer draws: a title, a set of nodes and a set of `ArchDocEdge`.

My nodes are classes and my edges are facts about them. I hold no layout and no colour, and I know nothing of Roassal: `ArchDoc-Core` must load into an image with no graphics library at all, so that an architecture test can run where no window can open.

`ArchDocModel` builds me from one package. `ArchDocObjectGraph` builds a graph of live objects instead, which is the same shape with instances for nodes.

I answer `edgesOfKind:` so that a renderer can draw holdings, caches and inferred uses each in its own style, and `edgesFrom:` so that a view can list what one class holds.
"
Class {
	#name : 'ArchDocGraph',
	#superclass : 'Object',
	#instVars : [
		'title',
		'nodes',
		'edges',
		'homeNodes'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

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

{ #category : 'describing' }
ArchDocGraph >> describe: aNode [
	"My nodes are classes in a package diagram and objects in an object graph."

	^ aNode isClass
		ifTrue: [ aNode name ]
		ifFalse: [ aNode printString ]
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
	title := aString.
	nodes := aCollection asArray.
	edges := anotherCollection asArray.
	homeNodes := homeCollection asSet
]

{ #category : 'accessing' }
ArchDocGraph >> title [
	^ title
]
