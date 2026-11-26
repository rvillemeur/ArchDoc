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
ArchDocCheckerTest >> testAnOppositeTheTargetDoesNotDeclareIsReported [
	"ArchDocBrokenSubject>>partner names the opposite #nobody, and nothing declares it."

	| findings |
	findings := self checkerOnTheExamples missingOpposites.
	self assert: (findings anySatisfy: [ :each | each subject role = #partner ]).
	self assert: (findings allSatisfy: [ :each | each kind = #missingOpposite ]).
	self deny: (findings anySatisfy: [ :each | each subject role = #child ])
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
