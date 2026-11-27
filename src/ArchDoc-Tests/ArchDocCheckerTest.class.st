Class {
	#name : 'ArchDocCheckerTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'running' }
ArchDocCheckerTest >> checkerOnTheExamples [
	^ ArchDocChecker onPackageNamed: 'ArchDoc-Examples'
]

{ #category : 'tests' }
ArchDocCheckerTest >> testACacheOfManyMayRememberThatThereIsNothingToHold [
	"A cache keyed by a question remembers the answer nothing as well: the glyph atlas keeps nil
	 for a space, so it is looked at once and never again. So a nil inside a cache of many is no
	 violation, while a nil inside a structural holding of many is."

	| explanations |
	explanations := (ArchDocChecker onPackageNamed: 'ArchDoc-Examples')
		sampleInstanceViolations collect: [ :each | each explanation ].
	self deny: (explanations anySatisfy: [ :each | each includesSubstring: 'answers' ]).
	self assert: (explanations anySatisfy: [ :each | each includesSubstring: 'neighbours' ])
]

{ #category : 'tests' }
ArchDocCheckerTest >> testAClassSideCacheHoldingTheWrongKindIsReported [
	"What a class keeps for the session is read from the class object itself. An unbuilt cache is
	 absent and no violation; a built one holding the wrong kind of object is one."

	| explanations |
	ArchDocBrokenSubject buildWrongKeptSubject.
	explanations := [
		(ArchDocChecker onPackageNamed: 'ArchDoc-Examples') classSideViolations
			collect: [ :each | each explanation ] ]
		ensure: [ ArchDocBrokenSubject resetKeptSubject ].
	self assert: explanations size equals: 1.
	self assert: (explanations first includesSubstring: 'keptSubject')
]

{ #category : 'tests' }
ArchDocCheckerTest >> testADeclarationNamingAnUnloadedClassIsReported [
	"ArchDocDeclaredSubject declares a ghost on purpose: nothing of that name is loaded, and a
	 declaration pointing at nothing is the first thing a reader must be told."

	| findings |
	findings := self checkerOnTheExamples unresolvedRelations.
	self assert: (findings anySatisfy: [ :each |
		each subject role = #ghost ]).
	self assert: (findings allSatisfy: [ :each | each kind = #unresolved ]).
	self deny: (findings anySatisfy: [ :each | each subject role = #child ])
]

{ #category : 'tests' }
ArchDocCheckerTest >> testAReferenceTheManifestForbidsIsReported [
	"ManifestArchDocExamples forbids reaching ArchDoc-Core, and the examples reach it everywhere."

	| findings |
	findings := self checkerOnTheExamples forbiddenDependencies.
	self assert: (findings anySatisfy: [ :each | each subject target = ArchDocRelation ]).
	self assert: (findings allSatisfy: [ :each | each kind = #forbiddenDependency ]).
	self deny: (findings anySatisfy: [ :each |
		each subject target = ArchDocDeclaredSubject ])
]

{ #category : 'tests' }
ArchDocCheckerTest >> testASampleInstanceContradictingItsDeclarationIsReported [
	"ArchDocBrokenSubject declares one ArchDocDeclaredSubject as its neighbour and holds a String
	 there. A cache no one has built yet is not a violation: it reads as absent."

	| findings |
	findings := self checkerOnTheExamples sampleInstanceViolations.
	self assert: (findings anySatisfy: [ :each | each subject role = #neighbour ]).
	self assert: (findings allSatisfy: [ :each | each kind = #sampleViolation ]).
	self deny: (findings anySatisfy: [ :each | each subject role = #warmCache ]).
	self deny: (findings anySatisfy: [ :each | each subject role = #child ])
]

{ #category : 'tests' }
ArchDocCheckerTest >> testAnEntryPointNamingNoClassOfThePackageIsReported [
	"ManifestArchDocExamples names ArchDocNoSuchSubject on purpose. An entry point is a promise
	 to a reader — start here — so one pointing at nothing is as much a fault as a declaration
	 naming an unloaded class, and the two classes it names rightly are not findings."

	| findings |
	findings := self checkerOnTheExamples unknownEntryPoints.
	self assert: findings size equals: 1.
	self assert: findings first subject equals: #ArchDocNoSuchSubject.
	self assert: findings first kind equals: #unknownEntryPoint.
	self
		assert: (findings first explanation includesSubstring: 'ArchDocNoSuchSubject').
	self assert: ((self checkerOnTheExamples findings collect: [ :each | each kind ]) asSet
		includes: #unknownEntryPoint)
]

{ #category : 'tests' }
ArchDocCheckerTest >> testAnExampleThatRaisesIsReportedAndStopsNothing [
	"Reading a package must not depend on every example of it running. An example that raises is
	 a finding of its own, with the error in it, and the other examples are still read."

	| checker kinds |
	checker := ArchDocChecker onPackageNamed: 'ArchDoc-Examples'.
	kinds := (checker findings collect: [ :each | each kind ]) asSet.
	self assert: (kinds includes: #brokenExample).
	self assert: ((checker brokenExamples collect: [ :each | each explanation ])
		anySatisfy: [ :each | each includesSubstring: 'raisesOnPurpose' ]).
	self assert: (kinds includes: #sampleViolation)
]

{ #category : 'tests' }
ArchDocCheckerTest >> testAnOppositeTheTargetDoesNotDeclareIsReported [
	"ArchDocBrokenSubject>>partner names the opposite #nobody, and nothing declares it."

	| findings |
	findings := self checkerOnTheExamples missingOpposites.
	self assert: (findings anySatisfy: [ :each | each subject role = #partner ]).
	self assert: (findings allSatisfy: [ :each | each kind = #missingOpposite ]).
	self deny: (findings anySatisfy: [ :each | each subject role = #child ])
]

{ #category : 'tests' }
ArchDocCheckerTest >> testTheCheckerOfAClaimedPackageRepeatsWhatItsMapSays [
	"A reader opening a package should not have to know a map exists to be told its classes are
	 unmapped, so the checker folds in what every map claiming that package says."

	| checker kinds |
	checker := ArchDocChecker onPackageNamed: 'ArchDoc-Examples'.
	kinds := (checker findings collect: [ :each | each kind ]) asSet.
	self assert: (kinds includes: #unmappedClass).
	self assert: (kinds includes: #ambiguousClass).
	self assert: (kinds includes: #unknownComponentClass).
	self
		assert: (checker componentFindings collect: [ :each | each explanation ]) asArray
		equals: (ArchDocExampleMap new findings collect: [ :each | each explanation ]) asArray
]

{ #category : 'tests' }
ArchDocCheckerTest >> testTheExampleCheckerReportsAllFourKinds [
	"The checker a reader clicks from the browser must show every kind at once, or the table
	 teaches nothing about what the four answers mean."

	| kinds |
	kinds := (ArchDocCheckerExamples checkerOfTheExamplesPackage findings
		collect: [ :each | each kind ]) asSet.
	self assert: (kinds includesAll:
		#( #unresolved #missingOpposite #sampleViolation #forbiddenDependency )).
	self assert: ArchDocCheckerExamples findingAboutADeclarationThatPointsAtNothing kind
		equals: #unresolved
]

{ #category : 'tests - views' }
ArchDocCheckerTest >> testTheSummaryViewCountsEveryKindItFindsWithoutBeingToldTheKinds [
	"A kind added to the findings must appear in the summary on its own, or the two tabs disagree
	 the first time a new finding is written."

	| checker presenter rows |
	checker := ArchDocChecker onPackageNamed: 'ArchDoc-Examples'.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionCounts: on: checker.
	rows := presenter items collect: [ :each |
		(presenter columns first evaluation value: each)
			-> (presenter columns second evaluation value: each) ].
	self assert: (rows includes: 'unmappedClass' -> '1').
	self assert: (rows includes: 'ambiguousClass' -> '1').
	self assert: (rows includes: 'unknownComponentClass' -> '1').
	self
		assert: (rows includes: 'findings' -> checker findings size printString)
		description: 'the total is counted from the findings themselves'
]
