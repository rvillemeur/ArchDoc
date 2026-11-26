Class {
	#name : 'ArchDocObjectGraphTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'running' }
ArchDocObjectGraphTest >> chainOfLength: anInteger [
	"A chain of subjects, each the child of the one before, and answer its head."

	| head |
	head := ArchDocDeclaredSubject new.
	(1 to: anInteger - 1) inject: head into: [ :last :ignored |
		| next |
		next := ArchDocDeclaredSubject new.
		last child: next.
		next ].
	^ head
]

{ #category : 'tests' }
ArchDocObjectGraphTest >> testACycleIsOneNodePerObjectAndTerminates [
	"Two subjects holding each other. The same object met twice is one node, by identity."

	| first second graph |
	first := ArchDocDeclaredSubject new.
	second := ArchDocDeclaredSubject new.
	first child: second.
	second child: first.
	graph := ((ArchDocObjectGraph of: first) maxDepth: 10) graph.
	self assert: graph nodes size equals: 2.
	self assert: graph edges size equals: 2
]

{ #category : 'tests' }
ArchDocObjectGraphTest >> testAnObjectThatHidesWhatItHoldsIsStillWalked [
	"ArchDocHiddenSubject exposes no accessor for the two subjects it holds, as VGFontFace does.
	 The walk reads its slots, so the graph shows them anyway, and its unbuilt cache does not
	 appear."

	| graph |
	graph := (ArchDocObjectGraph of: ArchDocHiddenSubject new) graph.
	self assert: graph nodes size equals: 3.
	self assert: ((graph edgesFrom: graph nodes first) collect: [ :each | each label ]) asSet
		equals: #( 'source' 'metadata' ) asSet
]

{ #category : 'tests' }
ArchDocObjectGraphTest >> testTheWalkFollowsDeclaredHoldingsAndBuildsNoCache [
	"The walk reads slots. It must reach what the declarations say is held, and the cache must
	 still be unbuilt afterwards: reading an object may not change it."

	| root graph |
	root := ArchDocDeclaredSubject new.
	root child: ArchDocDeclaredSubject new.
	root children add: ArchDocDeclaredSubject new.
	graph := (ArchDocObjectGraph of: root) graph.
	self assert: (graph nodes includes: root).
	self assert: graph nodes size equals: 3.
	self assert: (graph edgesFrom: root) size equals: 2.
	self deny: (graph edges anySatisfy: [ :each | each label = 'warmCache' ]).
	self assert: (root instVarNamed: 'warmCache') isNil
]

{ #category : 'tests' }
ArchDocObjectGraphTest >> testTheWalkStopsAtItsDepthLimit [
	"A live font reaches the whole image, so the walk is bounded and says nothing beyond its
	 limit rather than everything."

	| graph |
	graph := ((ArchDocObjectGraph of: (self chainOfLength: 6)) maxDepth: 2) graph.
	self assert: graph nodes size equals: 3
]

{ #category : 'tests' }
ArchDocObjectGraphTest >> testTheWalkStopsAtItsNodeBudget [
	| graph |
	graph := ((ArchDocObjectGraph of: (self chainOfLength: 20)) maxDepth: 20; maxNodes: 4; yourself) graph.
	self assert: graph nodes size equals: 4
]
