Class {
	#name : 'ArchDocComponentTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocComponentTest >> testAClassNameTheImageDoesNotHoldIsReportedAndNotDrawn [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject #ArchDocNoSuchClass )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: component classes asArray equals: { ArchDocDeclaredSubject }.
	self assert: component unknownClassNames asArray equals: #( #ArchDocNoSuchClass )
]

{ #category : 'tests' }
ArchDocComponentTest >> testAComponentReadsItsNameClassesAndIntentionFromItsRow [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject #ArchDocHiddenSubject )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: component name equals: 'Glyph cache'.
	self
		assert: component classes asArray
		equals: { ArchDocDeclaredSubject. ArchDocHiddenSubject }.
	self
		assert: component intention
		equals: 'keeps the answer so the question is asked once'.
	self assert: component declaringClass equals: ArchDocComponentExamples.
	self assert: component unknownClassNames isEmpty
]

{ #category : 'tests' }
ArchDocComponentTest >> testAComponentSaysWhichClassesItHolds [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: (component includes: ArchDocDeclaredSubject).
	self deny: (component includes: ArchDocHiddenSubject)
]

{ #category : 'tests' }
ArchDocComponentTest >> testAPartKnowsTheArrowsThatTouchItAndTheClassEdgesInsideIt [
	"A part is opened from a diagram, so it must answer the same facts the diagram drew without
	 the reader holding the map."

	| map part |
	map := ArchDocExampleMap new.
	part := map componentNamed: 'Subjects'.
	self assert: part map class equals: ArchDocExampleMap.
	self
		assert: (part edges allSatisfy: [ :each |
			each source = part or: [ each target = part ] ])
		description: 'every arrow a part answers touches it'.
	self
		assert: (part edges size)
		equals: (map edges count: [ :each | each source = part or: [ each target = part ] ]).
	self
		assert: (part classEdges allSatisfy: [ :each |
			(part includes: each source) and: [ part includes: each target ] ])
		description: 'the class edges of a part run between its own classes'
]

{ #category : 'tests - views' }
ArchDocComponentTest >> testTheClassesViewListsEveryClassNameOfTheRowLoadedOrNot [
	| component presenter rows |
	component := ArchDocComponentExamples glyphCache.
	presenter := ArchDocArtefactTest new
		presenterOf: #inspectionClasses:
		on: component.
	rows := presenter items collect: [ :each |
		presenter columns first evaluation value: each ].
	self
		assert: rows asArray
		equals: #( 'ArchDocDeclaredSubject' 'ArchDocHiddenSubject' 'ArchDocNoSuchClass' ).
	self
		assert: (presenter columns second evaluation value: #ArchDocDeclaredSubject)
		equals: 'loaded'.
	self
		assert: (presenter columns second evaluation value: #ArchDocNoSuchClass)
		equals: 'not loaded'
]

{ #category : 'tests' }
ArchDocComponentTest >> testTheGraphOfAPartHoldsItsOwnClassesAtHome [
	| part graph |
	part := ArchDocExampleMap new componentNamed: 'Subjects'.
	graph := part graph.
	self assert: graph nodes asArray equals: part classes asArray.
	self
		assert: (graph nodes allSatisfy: [ :each | graph holdsAtHome: each ])
		description: 'the classes of the part are its residents'
]

{ #category : 'tests - views' }
ArchDocComponentTest >> testThePartDrawsItsOwnClassesAsADiagram [
	| part presenter |
	part := ArchDocExampleMap new componentNamed: 'Examples'.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionDiagram: on: part.
	self assert: presenter canvas nodes size equals: part classes size
]

{ #category : 'tests - views' }
ArchDocComponentTest >> testTheRelationsViewSaysWhichPartEachArrowRunsToAndItsKind [
	| part presenter rows |
	part := ArchDocExampleMap new componentNamed: 'Subjects'.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionRelations: on: part.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self assert: rows size equals: part edges size.
	self
		assert: (rows includes: 'from' -> 'Holders')
		description: 'an arrow pointing at the part is read as coming from the other part'
]
