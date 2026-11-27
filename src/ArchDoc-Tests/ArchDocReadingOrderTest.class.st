"
I test `ArchDocReadingOrder`, the order in which a newcomer should read the nodes of a graph.

I build small graphs by hand, so that a score is tested against a fan-in I can count on one hand, and I state the order over a real package as well, since a formula that behaves on two nodes may still answer nonsense on twenty.
"
Class {
	#name : 'ArchDocReadingOrderTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'running' }
ArchDocReadingOrderTest >> graphOfTwoClassesOneReferencedTenTimes [
	"Two nodes, and ten others pointing at one of them alone, so that fan-in is the only
	 difference between the pair that the order can read. The nodes are real classes, because a
	 node must answer its own size; which classes they are does not matter to the fan-in."

	| referenced ignored others edges |
	referenced := ArchDocEdge.
	ignored := ArchDocLiftedEdge.
	others := { ArchDocGraph. ArchDocModel. ArchDocComponent. ArchDocComponentMap.
		ArchDocProjectModel. ArchDocChecker. ArchDocRelation. ArchDocObjectGraph.
		ArchDocFinding. ArchDocGraphRenderer }.
	edges := others collect: [ :each |
		ArchDocEdge from: each to: referenced kind: #use label: '' ].
	^ ArchDocGraph
		title: 'two classes'
		nodes: { referenced. ignored } , others
		edges: edges
]

{ #category : 'tests' }
ArchDocReadingOrderTest >> testAClassNothingReferencesScoresBelowAnIdenticalClassManyReference [
	"Fan-in is the whole point of the formula: of two nodes of the same size, the one the rest of
	 the package reaches is the one to read first. Size is divided out of the comparison by
	 scoring each node against its own size, so the test states the fan-in term alone."

	| order weighted ignored |
	order := ArchDocReadingOrder on: self graphOfTwoClassesOneReferencedTenTimes.
	weighted := (order scoreOf: ArchDocEdge) / (order sizeOf: ArchDocEdge).
	ignored := (order scoreOf: ArchDocLiftedEdge) / (order sizeOf: ArchDocLiftedEdge).
	self assert: (order fanInOf: ArchDocEdge) equals: 10.
	self assert: (order fanInOf: ArchDocLiftedEdge) equals: 0.
	self assert: weighted > ignored
]

{ #category : 'tests' }
ArchDocReadingOrderTest >> testEveryKindOfNodeAnswersASizeAndAContainerIsTheSumOfWhatItHolds [
	"A graph of this library holds classes, packages, components and live objects, and the order
	 must weigh all four. A package weighs what its classes weigh and a component what the
	 classes it names weigh, so both rules are asked of real objects rather than restated here.
	 An object with no source of its own weighs one, not nothing: a node of weight nothing would
	 score nothing whatever reaches it."

	| order package component |
	order := ArchDocReadingOrderExamples readingOrderOfTheCorePackage.
	package := Smalltalk packageOrganizer packageNamed: 'ArchDoc-Core'.
	component := ArchDocExampleMap new components first.
	self assert: (order sizeOf: ArchDocEdge) > 0.
	self assert: (order sizeOf: 3) equals: 1.
	self
		assert: (order sizeOf: package)
		equals: (package definedClasses
			inject: 0 into: [ :sum :each | sum + (order sizeOf: each) ]).
	self
		assert: (order sizeOf: component)
		equals: (component classes
			inject: 0 into: [ :sum :each | sum + (order sizeOf: each) ])
]

{ #category : 'tests' }
ArchDocReadingOrderTest >> testTheMostReachedClassIsFirstAndTheOrderIsTheSameTwice [
	"A reader asks for the order, scrolls, and asks again; two different answers would mean the
	 ties were broken by whatever the hash of a set happened to be. The node ten others reach is
	 read first, and the one nothing reaches is read after it — not last, since the ten others
	 carry sizes of their own and size is half the formula."

	| order first second |
	order := ArchDocReadingOrder on: self graphOfTwoClassesOneReferencedTenTimes.
	first := order nodesInOrder.
	second := order nodesInOrder.
	self assert: first first equals: ArchDocEdge.
	self assert: (first indexOf: ArchDocLiftedEdge) > (first indexOf: ArchDocEdge).
	self assert: first asArray equals: second asArray.
	self assert: first size equals: order graph nodes size
]

{ #category : 'tests' }
ArchDocReadingOrderTest >> testTheWeightOfANodeIsReadOnceHoweverManyComparisonsTheSortMakes [
	"A sort of n nodes makes far more than n comparisons, and every comparison asks for a score,
	 which reads the source of a node's methods. Read per comparison, a graph of forty-five
	 packages took 1744 milliseconds to order; read once per node, the reading is bounded by the
	 graph. Two sorts are asked for, because a reader opens the tab and asks again."

	| spy |
	spy := ArchDocReadingOrderSpy on: (ArchDocModel onPackageNamed: 'ArchDoc-Core') graph.
	spy nodesInOrder.
	spy nodesInOrder.
	self assert: spy graph nodes size > 10.
	self
		assert: spy reads <= (spy graph nodes size * 2)
		description: 'the source of a class was read ' , spy reads printString
			, ' times for ' , spy graph nodes size printString , ' nodes'
]

{ #category : 'tests' }
ArchDocReadingOrderTest >> testTheWhereToStartViewListsTheNodesInOrderAndEveryColumnReads [
	"The tab is the whole point of the score, so it must hold one row per node, in the order,
	 and every column must answer for every row: a column block runs only when a row is drawn,
	 so the test sends it by hand. The order read is the one a reader clicks in the browser."

	| order presenter context |
	order := ArchDocReadingOrderExamples readingOrderOfTheCorePackage.
	context := StInspectionContext new
		inspectedObject: order;
		methodSelector: #inspectionWhereToStart:;
		yourself.
	presenter := context newInspectionPresenterOnApplication: SpApplication new.
	self assert: presenter items asArray equals: order nodesInOrder.
	presenter items do: [ :item |
		presenter columns do: [ :column |
			self deny: (column evaluation value: item) isNil ] ]
]
