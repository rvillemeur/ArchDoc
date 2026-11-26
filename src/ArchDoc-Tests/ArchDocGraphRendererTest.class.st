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
ArchDocGraphRendererTest >> testANodeIsABoxedLabelAndAVisitorIsNotFilledLikeAResident [
	"A bare label tells the layout nothing about its extent, so the labels pile on top of one
	 another. A box has a size. The fill says which classes belong to the package being drawn, so
	 the boundary of the package is read off the picture and not off a legend."

	| renderer boxOf |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	boxOf := [ :className |
		((renderer canvas nodes detect: [ :each | each model name = className ]) shapes
			detect: [ :each | each class = RSBox ]) ].
	self assert: (boxOf value: #ArchDocDeclaredSubject) color
		equals: renderer residentColor.
	self assert: (boxOf value: #Date) color equals: renderer visitorColor
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testARendererIsBuiltFromAPackageNameAlone [
	"A reader of a package has a name and nothing else, so the renderer takes one and reads the
	 model itself."

	| renderer |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	self assert: renderer graph title equals: 'ArchDoc-Examples'.
	self assert: renderer canvas nodes notEmpty
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testAnArrowHeadStopsAtTheEdgeOfTheBoxItPointsAt [
	"A line drawn between two centres puts its arrow head in the middle of the target's name,
	 where it is read as a stray mark over a word. It must stop at the border of the box: a point
	 on the border is right, a point inside it is not."

	| renderer line target |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	line := renderer canvas lines detect: [ :each | each model isUse not ].
	target := line to.
	self deny: ((target encompassingRectangle insetBy: 1) containsPoint: line endPoint)
]

{ #category : 'tests' }
ArchDocGraphRendererTest >> testNoTwoNodesOfADrawnPackageOverlap [
	"The complaint a reader makes about a diagram is that the names lie on top of one another.
	 The layout must keep the boxes apart, so the test states it of the real font package, the
	 one that failed: seventeen boxes, none covering another."

	| renderer boxes |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	boxes := renderer canvas nodes collect: [ :each | each encompassingRectangle ].
	boxes doWithIndex: [ :one :index |
		(boxes copyFrom: index + 1 to: boxes size) do: [ :other |
			self deny: (one intersects: other)
				description: 'two nodes of the diagram cover one another' ] ]
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
ArchDocGraphRendererTest >> testTheCanvasIsDrawnOnceAndKept [
	"The layout places the nodes at random and then pushes them apart, so a second drawing is a
	 different picture. A reader who scrolls a diagram and asks it a question twice must be
	 looking at one picture, so the canvas is built once and kept."

	| renderer |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	self assert: renderer canvas == renderer canvas
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

{ #category : 'tests' }
ArchDocGraphRendererTest >> testTheLegendStatesTheBoxFillsAsWellAsTheLineStyles [
	"The fill of a box now carries meaning — a class of the drawn package, or one a declaration
	 reaches into another package for. A legend that names the lines alone leaves the reader to
	 guess the boxes."

	| renderer rows |
	renderer := ArchDocGraphRenderer onPackageNamed: 'ArchDoc-Examples'.
	rows := renderer legendRows.
	self assert: (rows anySatisfy: [ :each |
		each first = 'resident' and: [ each third = renderer residentColor ] ]).
	self assert: (rows anySatisfy: [ :each |
		each first = 'visitor' and: [ each third = renderer visitorColor ] ]).
	self assert: (rows anySatisfy: [ :each | each first = 'holding' ])
]
