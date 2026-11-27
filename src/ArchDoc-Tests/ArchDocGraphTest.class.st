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
