Class {
	#name : 'ArchDocModelTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocModelTest >> testGraphHoldsOneNodePerClassAndOneEdgePerFact [
	| model graph edgeOf |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	graph := model graph.
	self assert: (graph nodes includesAll: {
		ArchDocDeclaredSubject.
		ArchDocHiddenSubject.
		ArchDocRelationExamples }).
	edgeOf := [ :role |
		graph edges detect: [ :edge | edge label = role asString ] ifNone: [ nil ] ].
	self assert: (edgeOf value: #child) kind equals: #holding.
	self assert: (edgeOf value: #warmCache) kind equals: #cache.
	self assert: (edgeOf value: #outlines) kind equals: #cache.
	self assert: (edgeOf value: #ghost) isNil
]

{ #category : 'tests' }
ArchDocModelTest >> testInferredUsesHoldTheReferencesNoDeclarationStates [
	"A class the code reaches but no declaration mentions is a use, drawn faintly, so that the
	 diagram distinguishes the architecture from the wiring."

	| model uses |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	uses := model inferredUses.
	self assert: (uses anySatisfy: [ :edge |
		edge source = ArchDocRelationExamples and: [ edge target = ArchDocRelation ] ]).
	self assert: (uses allSatisfy: [ :edge | edge isUse ]).
	self deny: (uses anySatisfy: [ :edge |
		edge source = ArchDocDeclaredSubject and: [ edge target = ArchDocDeclaredSubject ] ])
]

{ #category : 'tests' }
ArchDocModelTest >> testModelOfAPackageCollectsEveryDeclaredRelationAndNothingElse [
	| model roles |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	roles := ((model relations select: [ :each | each declaringClass = ArchDocDeclaredSubject ])
		collect: [ :each | each role ]) asSortedCollection asArray.
	self assert: roles equals: #( #child #children #ghost #warmCache ).
	self deny: (roles includes: #scratch)
]

{ #category : 'tests' }
ArchDocModelTest >> testModelReadsAClassSideTableAsItReadsAPragma [
	| model declarations hidden |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	declarations := model relations select: [ :each | each declaringClass = ArchDocHiddenSubject ].
	self assert: declarations size equals: 3.
	hidden := declarations detect: [ :each | each role = #outlines ].
	self assert: hidden isCache.
	self assert: hidden isToMany.
	self assert: hidden targetName equals: #ArchDocDeclaredSubject.
	self deny: hidden hasOpposite
]

{ #category : 'tests' }
ArchDocModelTest >> testTheExampleGraphCarriesTheThreeKindsOfArrow [
	"The examples are what a reader clicks first, so the graph one of them answers must show a
	 holding, a cache and an inferred use at once."

	| graph |
	graph := ArchDocModelExamples graphOfTheExamplesPackage.
	self deny: (graph edgesOfKind: #holding) isEmpty.
	self deny: (graph edgesOfKind: #cache) isEmpty.
	self deny: (graph edgesOfKind: #use) isEmpty.
	self assert: ArchDocModelExamples cacheEdge isCache
]
