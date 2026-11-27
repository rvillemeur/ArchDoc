Class {
	#name : 'ArchDocComponentRendererTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocComponentRendererTest >> testABackwardEdgeIsRoutedBelowTheRow [
	"An edge pointing at a part declared earlier is the one a reader must notice, so it is not
	 drawn through the boxes between: it goes under the row and comes back up."

	| renderer backward line row |
	renderer := ArchDocComponentRenderer onMap: ArchDocExampleMap new.
	backward := renderer graph edges
		detect: [ :each | (renderer indexOf: each target) < (renderer indexOf: each source) ].
	line := renderer canvas lines detect: [ :each | each model = backward ].
	row := (renderer graph nodes
		collect: [ :each | (renderer shapeFor: each) encompassingRectangle bottom ]) max.
	self
		assert: (line controlPoints anySatisfy: [ :each | each y > row ])
		description: 'the backward line passes below every box of the row'
]

{ #category : 'tests' }
ArchDocComponentRendererTest >> testEachBoxNamesThePartAndHowManyClassesItHolds [
	| renderer map labels |
	map := ArchDocExampleMap new.
	renderer := ArchDocComponentRenderer onMap: map.
	labels := map components collect: [ :each | renderer labelFor: each ].
	self assert: (labels first includesSubstring: 'Subjects').
	self
		assert: (labels second includesSubstring: '2')
		description: 'the box says how many classes the part holds'
]

{ #category : 'tests' }
ArchDocComponentRendererTest >> testEveryLineCarriesTheNumberOfClassEdgesItStandsFor [
	"One arrow stands for several class edges, so the count is written beside it: an arrow
	 carrying twelve edges and one carrying one are not the same fact."

	| renderer counts |
	renderer := ArchDocComponentRenderer onMap: ArchDocExampleMap new.
	counts := (renderer canvas shapes select: [ :each | each class = RSLabel ])
		collect: [ :each | each text ].
	renderer graph edges do: [ :each |
		self
			assert: (counts includes: each count printString)
			description: 'the count of ' , each printString , ' is drawn' ]
]

{ #category : 'tests' }
ArchDocComponentRendererTest >> testTheBoxesLieLeftToRightInDeclarationOrder [
	"The order the map declares its parts in is the order a reader is meant to read them, so it
	 is the order they are drawn in. No force layout: a map read twice answers the same picture."

	| renderer boxes |
	renderer := ArchDocComponentRenderer onMap: ArchDocExampleMap new.
	boxes := renderer graph nodes collect: [ :each |
		(renderer shapeFor: each) encompassingRectangle ].
	boxes allButFirst doWithIndex: [ :each :index |
		self
			assert: each left > (boxes at: index) right
			description: 'a part is drawn to the right of the one declared before it' ]
]

{ #category : 'tests - views' }
ArchDocComponentRendererTest >> testTheReadingOrderViewNumbersThePartsAndSaysWhichEdgesReadBackwards [
	| renderer presenter rows |
	renderer := ArchDocComponentRenderer onMap: ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionReadingOrder: on: renderer.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self assert: (rows includes: '1' -> 'Subjects').
	self assert: rows size equals: renderer graph nodes size.
	self
		assert: ((rows collect: [ :each | each key ]) asArray = #( '1' '2' '3' ))
		description: 'the parts are numbered in the order they are drawn in'
]
