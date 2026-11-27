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
		equals: #( 'Subjects' 'Examples' ).
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
	component := presenter items first.
	self assert: (presenter columns first evaluation value: component) equals: 'Subjects'.
	self assert: (presenter columns second evaluation value: component) equals: '3'.
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
