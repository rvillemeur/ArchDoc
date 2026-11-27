"
I answer the order in which a newcomer should read the nodes of an `ArchDocGraph`, and the score that puts them in it.

The formula is archify's, with the one substitution the image forces:

```
score := size * (1 + (1 + fanIn) log: 2)
```

`size` is the characters of source of a node's methods — Pharo has no file to count the lines of — and `fanIn` is how many other nodes of the same graph point at it. Both are read inside the graph alone: the question I answer is where to start reading *this* package, so a reference from outside it belongs to somebody else's reading order.

I weigh any node a graph of this library holds: a class by its methods on both sides, a package by its classes, a component by the classes it names, and anything else — a live object in an object graph — by one. The rule is in `sizeOf:`, in one place, as `ArchDocGraph class >> describe:` names a node in one place.

```
(ArchDocReadingOrder on: (ArchDocModel onPackageNamed: 'ArchDoc-Core') graph) nodesInOrder
```

**A reading order, not importance.** A big class the whole package reaches is where a newcomer learns most per page read. It is not thereby the best class, the most stable one, or the one to change first.
"
Class {
	#name : 'ArchDocReadingOrder',
	#superclass : 'Object',
	#instVars : [
		'graph'
	],
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'instance creation' }
ArchDocReadingOrder class >> on: aGraph [
	^ self new setGraph: aGraph
]

{ #category : 'accessing' }
ArchDocReadingOrder >> fanInOf: aNode [
	"How many nodes of my graph point at aNode. Counted inside the graph alone: the question the
	 order answers is where to start reading this package, so a reference from outside it is
	 somebody else's reading order. A node counts once however many arrows it sends."

	^ (graph edges
		select: [ :each | each target = aNode and: [ each source ~= aNode ] ]
		thenCollect: [ :each | each source ]) asSet size
]

{ #category : 'accessing' }
ArchDocReadingOrder >> fanOutOf: aNode [
	"How many nodes of my graph aNode points at, counted the way fan-in is: inside the graph,
	 each other node once however many arrows reach it."

	^ (graph edges
		select: [ :each | each source = aNode and: [ each target ~= aNode ] ]
		thenCollect: [ :each | each target ]) asSet size
]

{ #category : 'accessing' }
ArchDocReadingOrder >> graph [
	^ graph
]

{ #category : 'inspector' }
ArchDocReadingOrder >> inspectionWhereToStart: aBuilder [
	"Where a newcomer starts, one row per node, the first row first. The score is shown rounded,
	 since a reader compares rows and does not read a logarithm, and the two terms it is made of
	 are shown beside it so that a surprising order can be understood rather than believed. The
	 order is read once into a local: a column block runs per drawn row, and the sort costs
	 twenty-six milliseconds on a package of twelve classes."

	<inspectorPresentationOrder: 1 title: 'Where to start'>
	| ordered |
	ordered := self nodesInOrder.
	^ aBuilder newTable
		items: ordered;
		addColumn: ((SpStringTableColumn title: 'Read'
			evaluated: [ :each | (ordered indexOf: each) printString ]) width: 60);
		addColumn: (SpStringTableColumn title: 'Node'
			evaluated: [ :each | graph describe: each ]);
		addColumn: ((SpStringTableColumn title: 'Score'
			evaluated: [ :each | (self scoreOf: each) rounded printString ]) width: 90);
		addColumn: ((SpStringTableColumn title: 'Reached by'
			evaluated: [ :each | (self fanInOf: each) printString ]) width: 100);
		addColumn: ((SpStringTableColumn title: 'Source'
			evaluated: [ :each | (self sizeOf: each) printString , ' chars' ]) width: 110);
		yourself
]

{ #category : 'private' }
ArchDocReadingOrder >> isRead: aNode before: anotherNode [
	"Score descending, and on a tie fan-in, then fan-out, then name, which archify breaks its
	 ties by too. The name decides in the end, so two nodes are never in a different order on a
	 second asking."

	| mine theirs |
	mine := self scoreOf: aNode.
	theirs := self scoreOf: anotherNode.
	mine = theirs ifFalse: [ ^ mine > theirs ].
	mine := self fanInOf: aNode.
	theirs := self fanInOf: anotherNode.
	mine = theirs ifFalse: [ ^ mine > theirs ].
	mine := self fanOutOf: aNode.
	theirs := self fanOutOf: anotherNode.
	mine = theirs ifFalse: [ ^ mine > theirs ].
	^ (graph describe: aNode) < (graph describe: anotherNode)
]

{ #category : 'accessing' }
ArchDocReadingOrder >> nodesInOrder [
	"The nodes of my graph, the one to read first at the head. A total order, so that a reader
	 who asks twice reads the same list."

	^ graph nodes asArray
		sorted: [ :a :b | self isRead: a before: b ]
]

{ #category : 'accessing' }
ArchDocReadingOrder >> scoreOf: aNode [
	"Archify's weight, with the one substitution the image forces: characters of source where
	 archify counts lines.

	 	score := size * (1 + (1 + fanIn) log: 2)

	 A reading order, not importance. A big class the whole package reaches is where a newcomer
	 learns most per page read; it is not thereby the best class, the most stable one, or the one
	 to change first."

	^ (self sizeOf: aNode) * (1 + ((1 + (self fanInOf: aNode)) log: 2))
]

{ #category : 'initialization' }
ArchDocReadingOrder >> setGraph: aGraph [
	graph := aGraph
]

{ #category : 'accessing' }
ArchDocReadingOrder >> sizeOf: aNode [
	"The weight of a node, in characters of source. Pharo has no file to count the lines of, so
	 the source of the methods is counted instead: both sides of a class, every class of a
	 package or a component, and one for anything else, a live object among them, which has no
	 source of its own. Asked here in one place, as ArchDocGraph class >> describe: names a node
	 in one place, because a graph of this library holds four kinds of node and none of them may
	 carry a method of ours."

	(aNode isBehavior and: [ aNode isMeta not ])
		ifTrue: [ ^ (self sourceSizeOfMethodsOf: aNode)
			+ (self sourceSizeOfMethodsOf: aNode class) ].
	(aNode respondsTo: #definedClasses)
		ifTrue: [ ^ self sizeOfAll: aNode definedClasses ].
	(aNode respondsTo: #classes)
		ifTrue: [ ^ self sizeOfAll: aNode classes ].
	^ 1
]

{ #category : 'private' }
ArchDocReadingOrder >> sizeOfAll: aCollection [
	^ aCollection inject: 0 into: [ :sum :each | sum + (self sizeOf: each) ]
]

{ #category : 'private' }
ArchDocReadingOrder >> sourceSizeOfMethodsOf: aBehavior [
	^ aBehavior methods
		inject: 0
		into: [ :sum :each | sum + each sourceCode size ]
]
