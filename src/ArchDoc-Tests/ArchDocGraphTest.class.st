"
I test `ArchDocGraph`: the shape every renderer and every view of this library is given.

The facts I state are the ones a holder of a graph relies on without reading it — that a graph names its own nodes, and that it answers the reading order of them itself, so that a component, a map and a package each delegate one line instead of building an order of their own.
"
Class {
	#name : 'ArchDocGraphTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocGraphTest >> testAGraphAnswersTheReadingOrderOfItsOwnNodes [
	"Three holders of a graph offered this tab, each building an order of its own from the graph
	 it holds. The graph answers it, so every holder delegates and one place knows that an order
	 is read from a graph. Built the way the inspector builds it, since a column block runs only
	 when a row is drawn: the presenter is asked for by the real selector, so a graph that does
	 not answer it fails here."

	| graph context presenter |
	graph := (ArchDocModel onPackageNamed: 'ArchDoc-Examples') graph.
	context := StInspectionContext new
		inspectedObject: graph;
		methodSelector: #inspectionWhereToStart:;
		yourself.
	presenter := context basicNewInspectionPresenter:
		(SpPresenterBuilder newApplication: SpApplication new).
	self
		assert: presenter items asArray
		equals: (ArchDocReadingOrder on: graph) nodesInOrder.
	presenter items do: [ :item |
		presenter columns do: [ :column |
			self deny: (column evaluation value: item) isNil ] ]
]

{ #category : 'tests' }
ArchDocGraphTest >> testAGraphKeepsTheEntryPointsItWasBuiltWithInTheOrderTheyWereDeclared [
	"A declared entry point is a fourth fact about a node, beside being a node, being at home and
	 being reached: the author of the package said to read this class first. The order they were
	 declared in is kept, because that order is itself the author's statement, and a graph nobody
	 told where to start — an object graph, a component — declares none.
	 The nodes are classes of this project. A test naming a class of another package makes this
	 package reach it, which is a use the project diagram drops and its omissions view then
	 reports as a package the picture leaves out."

	| nodes graph |
	nodes := { ArchDocHiddenSubject. ArchDocBrokenSubject }.
	graph := (ArchDocGraph title: 'two' nodes: nodes edges: #() home: nodes)
		beEnteredAt: { ArchDocBrokenSubject. ArchDocHiddenSubject };
		yourself.
	self
		assert: graph entryNodes
		equals: { ArchDocBrokenSubject. ArchDocHiddenSubject }.
	self assert: (graph isEntryPoint: ArchDocBrokenSubject).
	self assert: (graph isEntryPoint: ArchDocHiddenSubject).
	graph := ArchDocGraph title: 'none' nodes: nodes edges: #().
	self assert: graph entryNodes equals: #().
	self deny: (graph isEntryPoint: ArchDocHiddenSubject)
]
