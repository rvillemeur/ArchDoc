Class {
	#name : 'ArchDocGraphRendererTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'running' }
ArchDocGraphRendererTest >> exampleGraph [
	^ ArchDocModelExamples graphOfTheExamplesPackage
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testACacheIsDashedAndAnInferredUseIsFainterThanAHolding [
	"The three kinds must be told apart at a glance, or the diagram says the wiring and the
	 design are the same thing."

	| canvas cacheLine holdingLine useLine |
	canvas := (ArchDocGraphRenderer on: self exampleGraph) canvas.
	cacheLine := canvas lines detect: [ :each | each model isCache ].
	holdingLine := canvas lines detect: [ :each |
		each model isCache not and: [ each model isUse not ] ].
	useLine := canvas lines detect: [ :each | each model isUse ].
	self assert: cacheLine border dashArray equals: #( 4 3 ).
	self assert: holdingLine border dashArray isEmptyOrNil.
	self assert: useLine color alpha < holdingLine color alpha
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testTheCanvasHoldsOneShapePerNodeAndOneLinePerEdge [
	| graph canvas |
	graph := self exampleGraph.
	canvas := (ArchDocGraphRenderer on: graph) canvas.
	self assert: canvas nodes size equals: graph nodes size.
	self assert: canvas lines size equals: graph edges size.
	self assert: (canvas nodes collect: [ :each | each model ]) asSet
		equals: graph nodes asSet
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testTheExampleRendererDrawsTheExamplePackage [
	"The renderer a reader clicks must draw something, and its legend must name the three kinds."

	| renderer canvas |
	renderer := ArchDocRendererExamples rendererOfTheExamplesPackage.
	canvas := renderer canvas.
	self deny: canvas nodes isEmpty.
	self assert: (canvas lines collect: [ :each | each model kind ]) asSet
		equals: #( #holding #cache #use ) asSet
]
