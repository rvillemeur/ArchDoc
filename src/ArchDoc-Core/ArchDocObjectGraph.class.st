"
I walk one live object through the relations its class declares, and answer an `ArchDocGraph` whose nodes are objects.

Three rules make me safe to open on anything:

- I read **slots**, never accessors. A class that exposes no accessor for what it holds — `VGFontFace`, for one — is still read, and a lazy accessor is never sent, so I build nothing. An unbuilt cache has nothing in its slot, so it is simply absent from the graph: that is the truth about the object as it stands, not an error.
- I am bounded: `maxDepth` (3) and `maxNodes` (50). A real scaled font reaches an atlas, its masks and their Cairo surfaces, and from there most of the image. A graph a reader cannot read is no better than none.
- The same object met twice is one node, by identity, so a cycle terminates. `ArchDocDeclaredSubject` holding its own child both ways answers two nodes and two edges.

```
(ArchDocObjectGraph of: VGScaledFontExamples defaultFontAtTwelvePoints) graph
```

What I answer is what the object actually holds. `ArchDocChecker` is what compares it against what the class declares.
"
Class {
	#name : 'ArchDocObjectGraph',
	#superclass : 'Object',
	#instVars : [
		'root',
		'maxDepth',
		'maxNodes',
		'nodes',
		'edges',
		'seen',
		'queue'
	],
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'instance creation' }
ArchDocObjectGraph class >> of: anObject [
	^ self new setRoot: anObject
]

{ #category : 'describing' }
ArchDocObjectGraph >> descriptionOf: aRelation [
	"What my root holds under aRelation, in words a reader can act on."

	| value |
	value := self valueOf: aRelation in: root.
	value ifNil: [
		^ aRelation isCache
			ifTrue: [ 'not built yet' ]
			ifFalse: [ 'nothing' ] ].
	^ (value isCollection and: [ value isString not ])
		ifTrue: [ value size printString , ' held' ]
		ifFalse: [ value printString ]
]

{ #category : 'private' }
ArchDocObjectGraph >> edgeFrom: anObject through: anAssociation [
	"anAssociation is a relation and the object held under it. The relation says which kind of
	 arrow it makes, the same answer the class-altitude model reads."

	| relation |
	relation := anAssociation key.
	^ ArchDocEdge
		from: anObject
		to: anAssociation value
		kind: relation edgeKind
		label: relation role asString
]

{ #category : 'walking' }
ArchDocObjectGraph >> graph [
	"Walk my root through the declarations of its class, breadth first, bounded in depth and in
	 node count. The same object met twice is one node, by identity, so a cycle terminates. The
	 walk starts afresh on every call, so an object that has changed answers a new graph."

	self startWalk.
	[ queue isEmpty ] whileFalse: [ self stepWalk ].
	^ ArchDocGraph title: root printString nodes: nodes edges: edges
]

{ #category : 'private' }
ArchDocObjectGraph >> holdingsOf: anObject [
	"Each declared relation of anObject's class and the object it actually holds, as relation ->
	 held. Read through the slot, never through the accessor: a lazy accessor would build what it
	 answers, and this walk must leave the object exactly as it found it. A slot holding nothing
	 yields nothing, so an unbuilt cache is simply absent."

	| found |
	found := OrderedCollection new.
	(ArchDocRelation declaredBy: anObject class) do: [ :relation |
		(self valueOf: relation in: anObject) ifNotNil: [ :value |
			relation isToMany
				ifTrue: [
					value isCollection ifTrue: [
						value do: [ :each | found add: relation -> each ] ] ]
				ifFalse: [ found add: relation -> value ] ] ].
	^ found
]

{ #category : 'initialization' }
ArchDocObjectGraph >> initialize [
	"Bounded by default, because a live graph of a real font reaches the whole image otherwise."

	super initialize.
	maxDepth := 3.
	maxNodes := 50
]

{ #category : 'inspector' }
ArchDocObjectGraph >> inspectionHoldings: aBuilder [
	"What my root holds right now, one row per declared relation, saying for each whether the
	 object answers it. A cache reads as not built yet, which is a fact about the object and not
	 a fault."

	<inspectorPresentationOrder: 1 title: 'Holdings'>
	^ aBuilder newTable
		items: (ArchDocRelation declaredBy: root class);
		addColumn: ((SpStringTableColumn title: 'Role' evaluated: [ :each | each role asString ]) width: 180);
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each kindDescription ]) width: 90);
		addColumn: ((SpStringTableColumn title: 'Declares' evaluated: [ :each | each targetName asString ]) width: 220);
		addColumn: (SpStringTableColumn title: 'Holds' evaluated: [ :each | self descriptionOf: each ]);
		yourself
]

{ #category : 'inspector' }
ArchDocObjectGraph >> inspectionWalk: aBuilder [
	"The bounds and what the walk reached under them, so a reader can tell a small graph from a
	 truncated one."

	<inspectorPresentationOrder: 2 title: 'Walk'>
	| walked |
	walked := self graph.
	^ aBuilder newTable
		items: {
				'root' -> root printString.
				'depth limit' -> maxDepth printString.
				'node budget' -> maxNodes printString.
				'nodes reached' -> walked nodes size printString.
				'edges drawn' -> walked edges size printString.
				'bounded out' -> (walked nodes size >= maxNodes
					ifTrue: [ 'yes: the budget is spent and the graph is cut short' ]
					ifFalse: [ 'no: this is the whole graph within the depth limit' ]) };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 160);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each value ]);
		yourself
]

{ #category : 'accessing' }
ArchDocObjectGraph >> maxDepth [
	^ maxDepth
]

{ #category : 'accessing' }
ArchDocObjectGraph >> maxDepth: anInteger [
	maxDepth := anInteger
]

{ #category : 'accessing' }
ArchDocObjectGraph >> maxNodes [
	^ maxNodes
]

{ #category : 'accessing' }
ArchDocObjectGraph >> maxNodes: anInteger [
	maxNodes := anInteger
]

{ #category : 'private' }
ArchDocObjectGraph >> reach: anObject atDepth: anInteger [
	"Add a newly met object, unless the node budget is spent: a graph a reader cannot read is no
	 better than none."

	(seen includes: anObject) ifTrue: [ ^ self ].
	nodes size >= maxNodes ifTrue: [ ^ self ].
	seen add: anObject.
	nodes add: anObject.
	queue addLast: anObject -> anInteger
]

{ #category : 'accessing' }
ArchDocObjectGraph >> root [
	^ root
]

{ #category : 'initialization' }
ArchDocObjectGraph >> setRoot: anObject [
	root := anObject
]

{ #category : 'private' }
ArchDocObjectGraph >> startWalk [
	nodes := OrderedCollection with: root.
	edges := OrderedCollection new.
	seen := IdentitySet with: root.
	queue := OrderedCollection with: root -> 0
]

{ #category : 'private' }
ArchDocObjectGraph >> stepWalk [
	"Take the next object off the queue and draw what it holds. Beyond the depth limit nothing
	 is read at all, so the limit bounds the reading and not only the drawing."

	| step |
	step := queue removeFirst.
	step value < maxDepth ifFalse: [ ^ self ].
	(self holdingsOf: step key) do: [ :holding |
		edges add: (self edgeFrom: step key through: holding).
		self reach: holding value atDepth: step value + 1 ]
]

{ #category : 'private' }
ArchDocObjectGraph >> valueOf: aRelation in: anObject [
	"Nil when the class has no slot of that name: a relation may be declared on a computed
	 accessor, and then there is nothing to read without running code."

	^ (anObject class allSlots
		detect: [ :each | each name = aRelation role asString ]
		ifNone: [ ^ nil ]) read: anObject
]
