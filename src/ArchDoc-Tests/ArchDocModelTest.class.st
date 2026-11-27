Class {
	#name : 'ArchDocModelTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocModelTest >> testAGraphOfAPackageKnowsWhichOfItsNodesLiveThere [
	"A diagram of a package shows classes from elsewhere when a declaration points at them. The
	 graph is what says which is which, because it is the graph that knows what it is a diagram of."

	| graph |
	graph := (ArchDocModel onPackageNamed: 'ArchDoc-Examples') graph.
	self assert: (graph holdsAtHome: ArchDocDeclaredSubject).
	self deny: (graph holdsAtHome: ArchDocRelation)
]

{ #category : 'tests' }
ArchDocModelTest >> testAPackageManifestIsNoNodeOfItsOwnDiagram [
	"A manifest states the rules the package is held to. It is not a part of the design the
	 diagram draws, so it is no node of it."

	| model |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	self deny: ((model graph nodes collect: [ :each | each name ]) includes: #ManifestArchDocExamples)
]

{ #category : 'tests' }
ArchDocModelTest >> testAnExtensionMethodFromAnotherPackageIsNotAUseOfThisOne [
	"ArchDocGraph carries a Diagram tab that ArchDoc-Roassal installs on it. That method names
	 ArchDocGraphRenderer, but the reference belongs to the package that owns the method, not to
	 the package that defines the class, or every extended class would read as depending on
	 whatever extends it."

	| model reached |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Core'.
	reached := model classesReferencedBy: ArchDocGraph.
	self deny: (reached includes: ArchDocGraphRenderer)
]

{ #category : 'tests' }
ArchDocModelTest >> testAnInferredUseOfAClassNoDeclarationReachesIsLeftOutOfTheGraph [
	"A diagram of a package is about that package. A class reached from it that no declaration
	 points at — a kernel class, a collection, a widget — is a node nobody asked for, and thirty
	 of them is how a diagram stops being readable. Such a use is left out, node and edge alike."

	| model targets |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	targets := (model graph edges collect: [ :each | each target ]) asSet.
	self deny: (targets includes: Dictionary).
	self deny: ((model graph nodes collect: [ :each | each name ]) includes: #Dictionary)
]

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
	self assert: roles
		equals: #( #answers #child #children #ghost #stamp #warmCache #warmCacheWithOpposite ).
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

{ #category : 'tests' }
ArchDocModelTest >> testTheGraphCarriesTheEntryPointsTheManifestDeclares [
	"Where to start reading a package is the one thing its author knows and no formula does, so
	 the manifest states it and the graph carries it. A name the package does not define is no
	 node of the graph — ManifestArchDocExamples names one on purpose — and the checker is what
	 reports it."

	| model |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	self
		assert: model entryPointNames asArray
		equals: #( #ArchDocHiddenSubject #ArchDocDeclaredSubject #ArchDocNoSuchSubject ).
	self
		assert: model graph entryNodes
		equals: { ArchDocHiddenSubject. ArchDocDeclaredSubject }.
	self
		assert: (ArchDocModel onPackageNamed: 'ArchDoc-Tests') graph entryNodes
		equals: #()
]

{ #category : 'tests' }
ArchDocModelTest >> testThePackageReadsWhatItsClassesThemselvesHold [
	"A cache a class keeps for the whole session is part of the architecture, so the model must
	 read archClassRelations as well as the instance-side declarations."

	| model relation |
	model := ArchDocModel onPackageNamed: 'ArchDoc-Examples'.
	relation := model relations detect: [ :each | each role = #defaultSubject ].
	self assert: relation declaringClass equals: ArchDocDeclaredSubject class.
	self assert: relation isCache
]
