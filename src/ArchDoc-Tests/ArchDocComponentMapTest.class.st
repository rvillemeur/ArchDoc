Class {
	#name : 'ArchDocComponentMapTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocComponentMapTest >> testAClassTwoComponentsNameIsAmbiguousAndAClassNoImageHoldsIsUnknown [
	| map |
	map := ArchDocExampleMap new.
	self assert: map ambiguousClasses asArray equals: { ArchDocBrokenSubject }.
	self assert: map unknownClassNames asArray equals: #( #ArchDocNoSuchClass )
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testAMapAnswersOneComponentPerRowInDeclarationOrder [
	| map |
	map := ArchDocExampleMap new.
	self
		assert: (map components collect: [ :each | each name ]) asArray
		equals: #( 'Subjects' 'Holders' 'Examples' ).
	self assert: map components first declaringClass equals: ArchDocExampleMap
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testAMapAnswersWhichComponentHoldsAClass [
	| map |
	map := ArchDocExampleMap new.
	self
		assert: (map componentOf: ArchDocDeclaredSubject) name
		equals: 'Subjects'.
	self assert: (map componentOf: ArchDocCheckerExamples) isNil.
	self assert: (map componentNamed: 'Examples') name equals: 'Examples'
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testAMapClaimsEveryClassOfItsPackagesAndSaysWhichItMissed [
	| map |
	map := ArchDocExampleMap new.
	self
		assert: (map claimedClasses includes: ArchDocCheckerExamples)
		description: 'a class of a claimed package is claimed whether it is mapped or not'.
	self
		deny: (map claimedClasses anySatisfy: [ :each | each inheritsFrom: PackageManifest ])
		description: 'a package manifest is no part of a design'.
	self assert: map unmappedClasses asArray equals: { ArchDocCheckerExamples }
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testAnEdgeInsideOneComponentIsNotLifted [
	"Two classes of one part holding each other is how the part is built, not an edge of the
	 design, so it is drawn at class altitude and nowhere else."

	| map |
	map := ArchDocExampleMap new.
	self
		deny: (map edges anySatisfy: [ :each | each source = each target ])
		description: 'a lifted edge never points at its own component'
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testAnInferredUseBetweenTwoComponentsStaysVisible [
	"A use between two parts that no declaration explains is what says a declaration is missing,
	 so it is lifted like the rest and drawn faintly."

	| map lifted |
	map := ArchDocExampleMap new.
	lifted := map edges detect: [ :each |
		each source name = 'Examples' and: [ each target name = 'Subjects' ] ].
	self assert: lifted kind equals: #use.
	self assert: lifted count >= 1
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testEveryClassEdgeBetweenTwoComponentsLiftsIntoOneEdgeOfTheStrongestKind [
	| map lifted |
	map := ArchDocExampleMap new.
	lifted := map edges
		detect: [ :each |
			each source name = 'Holders' and: [ each target name = 'Subjects' ] ].
	self
		assert: (map edges count: [ :each |
			each source name = 'Holders' and: [ each target name = 'Subjects' ] ])
		equals: 1.
	self
		assert: lifted kind equals: #holding.
	self
		assert: lifted count
		equals: (map classEdges count: [ :each |
			((map componentOf: each source) ifNotNil: [ :one | one name ]) = 'Holders'
				and: [ ((map componentOf: each target) ifNotNil: [ :one | one name ]) = 'Subjects' ] ]).
	self
		assert: (lifted roles includesAll: #( 'source' 'metadata' 'outlines' ))
		description: 'the roles that made the edge are kept for the popup'
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testEveryDeclaredMapOfTheImageIsFoundByItsClass [
	self
		assert: (ArchDocComponentMap maps includes: ArchDocExampleMap)
		description: 'a map is found by subclassing, so a project declares one without being registered'.
	self deny: (ArchDocComponentMap maps includes: ArchDocComponentMap)
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testTheBrokenExampleMapReportsOneFindingOfEachKind [
	| map kinds |
	map := ArchDocExampleMap new.
	kinds := map findings collect: [ :each | each kind ].
	self
		assert: kinds asBag
		equals: #( #unmappedClass #ambiguousClass #unknownComponentClass ) asBag.
	self
		assert: ((map findings detect: [ :each | each kind = #unmappedClass ]) explanation
			includesSubstring: 'ArchDocCheckerExamples')
		description: 'a finding says which class it is about'
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheComponentsViewStatesEachPartItsSizeAndItsIntention [
	| map presenter component |
	map := ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionComponents: on: map.
	component := presenter items second.
	self assert: (presenter columns first evaluation value: component) equals: 'Holders'.
	self assert: (presenter columns second evaluation value: component) equals: '2'.
	self
		assert: (presenter columns third evaluation value: component)
		equals: component intention
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheCoverageViewAsksTheMapRatherThanRestatingIt [
	| map presenter rows |
	map := ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionCoverage: on: map.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self
		assert: rows asArray
		equals: {
			'claimed' -> map claimedClasses size printString.
			'mapped' -> (map claimedClasses size - map unmappedClasses size) printString.
			'unmapped' -> map unmappedClasses size printString.
			'ambiguous' -> map ambiguousClasses size printString.
			'not loaded' -> map unknownClassNames size printString }
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheFindingsViewSaysOneSentencePerFault [
	| map presenter rows |
	map := ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionFindings: on: map.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self
		assert: (rows collect: [ :each | each key ]) asArray
		equals: (map findings collect: [ :each | each kind asString ]) asArray.
	self
		assert: rows first value
		equals: map findings first explanation
]

{ #category : 'tests' }
ArchDocComponentMapTest >> testTheGraphOfAMapHoldsTheComponentsAndTheLiftedEdges [
	| map graph |
	map := ArchDocExampleMap new.
	graph := map graph.
	self
		assert: (graph nodes collect: [ :each | each name ]) asArray
		equals: #( 'Subjects' 'Holders' 'Examples' ).
	self assert: graph edges asArray equals: map edges asArray.
	self
		assert: (graph nodes allSatisfy: [ :each | graph holdsAtHome: each ])
		description: 'every component of a map is a resident of that map'
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheLiftedArrowViewSaysTheKindTheCountAndTheRoles [
	| edge presenter rows |
	edge := ArchDocComponentExamples liftedEdge.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionLiftedArrow: on: edge.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self assert: (rows includes: 'kind' -> 'holding').
	self assert: (rows includes: 'class edges' -> edge count printString).
	self
		assert: ((rows detect: [ :each | each key = 'roles' ]) value includesSubstring: 'source')
		description: 'the roles that made the arrow are named'
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheMapDrawsItsPartsAsADiagram [
	| map presenter boxes |
	map := ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionDiagram: on: map.
	boxes := presenter canvas nodes select: [ :each | each class = RSComposite ].
	self
		assert: (boxes collect: [ :each | each model ]) asArray
		equals: map components asArray
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testThePackagesViewNamesEachClaimedPackageAndHowManyClassesItHolds [
	| map presenter rows |
	map := ArchDocExampleMap new.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionPackages: on: map.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self assert: rows size equals: map packages size.
	self
		assert: rows first
		equals: 'ArchDoc-Examples' -> map claimedClasses size printString
]

{ #category : 'tests - views' }
ArchDocComponentMapTest >> testTheWhereToStartViewOrdersTheComponentsOfTheLiftedGraph [
	"One altitude up, the same question: which part of the map to read first. The order is over
	 the lifted graph, so a part the rest of the map reaches is at the head and a part weighs
	 what the classes it names weigh."

	| map presenter context order |
	map := ArchDocExampleMap new.
	context := StInspectionContext new
		inspectedObject: map;
		methodSelector: #inspectionWhereToStart:;
		yourself.
	presenter := context newInspectionPresenterOnApplication: SpApplication new.
	order := ArchDocReadingOrder on: map graph.
	self assert: presenter items asArray equals: order nodesInOrder.
	self assert: (presenter items allSatisfy: [ :each | each isKindOf: ArchDocComponent ]).
	self
		assert: (order sizeOf: map components first)
		equals: (map components first classes
			inject: 0 into: [ :sum :each | sum + (order sizeOf: each) ])
]
