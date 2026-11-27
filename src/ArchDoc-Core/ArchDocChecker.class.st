"
I read one package's declarations and say what is wrong with them. I answer four collections of `ArchDocFinding`:

- `unresolvedRelations` — a declaration naming a class this image does not hold.
- `missingOpposites` — a declared opposite role the target does not declare back.
- `sampleInstanceViolations` — a class-side `<sampleInstance>` example whose object contradicts its class's declarations. I read its slots by reflection, never by sending accessors, so I read a class that hides what it holds and I build nothing by reading. A cache nobody has built reads as absent, which is no violation.
- `forbiddenDependencies` — an edge reaching a package the package's manifest forbids, read from `archDocForbiddenDependencies` on the manifest class.

`findings` answers all four. An architecture test is a test over those answers:

```
| checker |
checker := ArchDocChecker onPackageNamed: 'VectorGraphics-Canvas-Fonts'.
self assertEmpty: checker findings
```

I read the examples of the package named by `samplePackageName`, which is my model's package with `-Examples` appended, and the model's own package when there is none.

I judge, I never change: no declaration, no class and no live object is modified by any answer of mine.
"
Class {
	#name : 'ArchDocChecker',
	#superclass : 'Object',
	#instVars : [
		'model',
		'samplePackageName',
		'exampleRun'
	],
	#category : 'ArchDoc-Core-Checking',
	#package : 'ArchDoc-Core',
	#tag : 'Checking'
}

{ #category : 'instance creation' }
ArchDocChecker class >> onModel: anArchDocModel [
	^ self new setModel: anArchDocModel
]

{ #category : 'instance creation' }
ArchDocChecker class >> onPackageNamed: aString [
	^ self onModel: (ArchDocModel onPackageNamed: aString)
]

{ #category : 'testing' }
ArchDocChecker class >> opensAWindow: aSelector [
	"By convention an example that opens a window is named open… . Nothing that reads a package
	 in batch may run one: a suite that opens windows cannot be run unattended."

	^ aSelector beginsWith: 'open'
]

{ #category : 'checking' }
ArchDocChecker >> brokenExamples [
	"The examples of the samples package that raised when they were run. An example is the only
	 way this library reaches a live object, so one that cannot run is a hole in the reading, and
	 it is said out loud rather than swallowed."

	^ self exampleRun value asArray
]

{ #category : 'checking' }
ArchDocChecker >> classSideViolations [
	"What the classes of my package hold themselves, against what their archClassRelations
	 declare. No sample is needed: the class object is there to be read, and reading a slot
	 builds nothing, so an unbuilt session cache reads as absent and is no violation."

	| found |
	found := OrderedCollection new.
	model package definedClasses do: [ :each |
		(ArchDocRelation declaredBy: each class) do: [ :relation |
			(self violationOf: relation in: each)
				ifNotNil: [ :finding | found add: finding ] ] ].
	^ found asArray
]

{ #category : 'checking' }
ArchDocChecker >> componentFindings [
	"What every map claiming my package says against itself. A reader opening a package is told
	 its classes are unmapped without having to know which map claims it."

	^ self maps flatCollect: [ :each | each findings ]
]

{ #category : 'checking' }
ArchDocChecker >> countRows [
	"The package, what was read, the total, and one row per kind of finding, counted from the
	 findings themselves so that a kind written later appears here without being named."

	| found kinds |
	found := self findings.
	kinds := (found collect: [ :each | each kind ]) asSet asSortedCollection asArray.
	^ { { 'package'. model packageName asString } .
		{ 'declarations'. model relations size printString } .
		{ 'samples read'. self sampleInstances size printString } .
		{ 'findings'. found size printString } }
		, (kinds collect: [ :kind |
			{ kind asString.
			  (found count: [ :each | each kind = kind ]) printString } ])
]

{ #category : 'private' }
ArchDocChecker >> exampleRun [
	"The one run of the examples, kept, so that reading a package runs each example once."

	^ exampleRun ifNil: [ exampleRun := self runExamplesCollectingFailures ]
]

{ #category : 'private' }
ArchDocChecker >> finding: aRelation in: anObject saying: aString [
	^ ArchDocFinding
		kind: #sampleViolation
		subject: aRelation
		explanation: anObject class name , '>>' , aRelation role , ' declares '
			, aRelation multiplicityDescription , ' ' , aRelation targetName
			, ', the sample ' , aString
]

{ #category : 'checking' }
ArchDocChecker >> findings [
	"Everything I can say about the package, in one collection: declarations naming a class the
	 image does not answer, declarations with no reciprocal on the other side, live objects that
	 contradict their class's declarations, classes that contradict their own, edges reaching a
	 package the manifest forbids, examples that cannot run, and what a map claiming this package
	 says about its own coverage."

	^ self unresolvedRelations , self missingOpposites , self sampleInstanceViolations
		, self classSideViolations , self forbiddenDependencies , self brokenExamples
		, self componentFindings
]

{ #category : 'checking' }
ArchDocChecker >> forbiddenDependencies [
	"Every edge of my model that reaches a package the manifest forbids. This is the rule a
	 project states in one place and a test reads: a layering rule belongs beside the package,
	 not in a markdown file that drifts. It reads allEdges and not the graph: the graph draws
	 uses between its own nodes alone, and a forbidden reference points out of the diagram by
	 definition."

	self forbiddenPackageNames ifEmpty: [ ^ #() ].
	^ (model allEdges
		select: [ :each | self forbids: (self packageNameOf: each target) ])
		collect: [ :each |
			ArchDocFinding
				kind: #forbiddenDependency
				subject: each
				explanation: each source name , ' reaches ' , each target name , ' in '
					, (self packageNameOf: each target)
					, ', which this package may not depend on' ]
]

{ #category : 'private' }
ArchDocChecker >> forbiddenPackageNames [
	"Read from the manifest of the checked package, which is where Pharo already keeps what a
	 package says about itself. A package with no such declaration forbids nothing."

	| found |
	found := OrderedCollection new.
	model package definedClasses do: [ :each |
		(each class canUnderstand: #archDocForbiddenDependencies)
			ifTrue: [ found addAll: each archDocForbiddenDependencies ] ].
	^ found asArray
]

{ #category : 'private' }
ArchDocChecker >> forbids: aPackageName [
	"A declaration is a match pattern, not a name, so one line can forbid a whole project:
	 'Roassal*' answers true for every package of it."

	^ self forbiddenPackageNames anySatisfy: [ :each | each match: aPackageName ]
]

{ #category : 'inspector' }
ArchDocChecker >> inspectionCounts: aBuilder [
	"How many of each kind, counted from the answers themselves, so this tab cannot disagree
	 with the one beside it, and a kind written later needs no line here."

	<inspectorPresentationOrder: 2 title: 'Summary'>
	^ aBuilder newTable
		items: self countRows;
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each first ]) width: 200);
		addColumn: (SpStringTableColumn title: 'Count' evaluated: [ :each | each second ]);
		yourself
]

{ #category : 'inspector' }
ArchDocChecker >> inspectionFindings: aBuilder [
	"Everything wrong with the package I read, each row a sentence a reader can act on. An empty
	 table is the answer a project wants."

	<inspectorPresentationOrder: 1 title: 'Findings'>
	^ aBuilder newTable
		items: self findings;
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each kind asString ]) width: 170);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each explanation ]);
		yourself
]

{ #category : 'private' }
ArchDocChecker >> isBatchExample: aCompiledMethod [
	^ (aCompiledMethod pragmas anySatisfy: [ :each | each selector = #sampleInstance ])
		and: [ (self class opensAWindow: aCompiledMethod selector) not ]
]

{ #category : 'private' }
ArchDocChecker >> isReciprocal: aRelation [
	"True when the target of aRelation declares the named opposite role, pointing back at the
	 class that declared aRelation."

	| holderName |
	holderName := aRelation declaringClass instanceSide name asSymbol.
	^ (ArchDocRelation declaredBy: aRelation targetClass) anySatisfy: [ :each |
		each role = aRelation oppositeRole and: [ each targetName = holderName ] ]
]

{ #category : 'private' }
ArchDocChecker >> manyViolationOf: aRelation holding: aValue in: anObject [
	"An empty collection is no violation: a holding of many may legitimately hold none yet.
	 A nil among the elements is no violation in a cache either: a cache keyed by a question
	 remembers the answer nothing as well, which is how a glyph atlas keeps a space. In a
	 structural holding a nil is a fault, because nothing asked a question there."

	| elements |
	aValue isCollection ifFalse: [
		^ self
			finding: aRelation
			in: anObject
			saying: 'holds a ' , aValue class name , ', which is no collection' ].
	elements := aRelation isCache
		ifTrue: [ aValue reject: [ :each | each isNil ] ]
		ifFalse: [ aValue ].
	^ (elements allSatisfy: [ :each | each isKindOf: aRelation targetClass ])
		ifTrue: [ nil ]
		ifFalse: [
			self finding: aRelation in: anObject saying: 'holds objects of another kind' ]
]

{ #category : 'accessing' }
ArchDocChecker >> maps [
	"Every map of the image that claims my package, asked of the maps themselves."

	^ ArchDocComponentMap maps
		select: [ :each | each packageNames includes: model packageName ]
		thenCollect: [ :each | each new ]
]

{ #category : 'checking' }
ArchDocChecker >> missingOpposites [
	"A declaration that names an opposite role the target does not declare back. The graph then
	 says two different things depending on which end a reader starts from."

	^ ((model relations select: [ :each |
		each isTargetLoaded and: [ each hasOpposite and: [ (self isReciprocal: each) not ] ] ])
			collect: [ :each |
				ArchDocFinding
					kind: #missingOpposite
					subject: each
					explanation: each declaringClass name , '>>' , each role , ' names the opposite '
						, each oppositeRole , ', which ' , each targetName , ' does not declare' ])
]

{ #category : 'private' }
ArchDocChecker >> oneViolationOf: aRelation holding: anotherObject in: anObject [
	^ (anotherObject isKindOf: aRelation targetClass)
		ifTrue: [ nil ]
		ifFalse: [
			self
				finding: aRelation
				in: anObject
				saying: 'holds a ' , anotherObject class name ]
]

{ #category : 'private' }
ArchDocChecker >> packageNameOf: aClass [
	"A class the image holds but no package claims answers an empty name, which matches no rule."

	^ aClass package
		ifNil: [ '' ]
		ifNotNil: [ :each | each name asString ]
]

{ #category : 'private' }
ArchDocChecker >> runExamplesCollectingFailures [
	"Run every batch example of the samples package once, and answer the objects it answered
	 along with the failures it raised, as objects -> failures. One run serves both answers, so
	 an example is never run twice in a reading."

	| answered failures |
	answered := OrderedCollection new.
	failures := OrderedCollection new.
	self samplePackage definedClasses do: [ :each |
		each class methods do: [ :method |
			(self isBatchExample: method) ifTrue: [
				[ answered add: (each perform: method selector) ]
					on: Error
					do: [ :error |
						failures add: (ArchDocFinding
							kind: #brokenExample
							subject: method
							explanation: each name , '>>' , method selector
								, ' cannot run: ' , error class name , ', '
								, error messageText asString) ] ] ] ].
	^ answered -> failures
]

{ #category : 'checking' }
ArchDocChecker >> sampleInstanceViolations [
	"What the live objects say against what their classes declare. A cache nobody has built yet
	 reads as absent and is no violation; a structural holding that is empty or holds the wrong
	 kind of object is one."

	| found |
	found := OrderedCollection new.
	self sampleInstances do: [ :subject |
		(ArchDocRelation declaredBy: subject class) do: [ :relation |
			(self violationOf: relation in: subject)
				ifNotNil: [ :finding | found add: finding ] ] ].
	^ found asArray
]

{ #category : 'accessing' }
ArchDocChecker >> sampleInstances [
	"Every object the examples answered whose class my model's package defines. Running an
	 example is how this library reads a live object: there is no other registry of instances.
	 An example named open… is skipped, since it opens a window, and one that raises is a
	 finding of brokenExamples rather than an error here."

	| classes |
	classes := model package definedClasses.
	^ (self exampleRun key select: [ :each | classes includes: each class ]) asArray
]

{ #category : 'private' }
ArchDocChecker >> samplePackage [
	"The examples package, or the model's own package when there is none: a package of fixtures
	 keeps its examples beside them."

	^ Smalltalk packageOrganizer
		packageNamed: self samplePackageName
		ifAbsent: [ model package ]
]

{ #category : 'accessing' }
ArchDocChecker >> samplePackageName [
	"The package whose class-side <sampleInstance> examples I read. By convention it is the
	 model's package with -Examples appended, which is where this project keeps its examples."

	^ samplePackageName ifNil: [ samplePackageName := model packageName , '-Examples' ]
]

{ #category : 'accessing' }
ArchDocChecker >> samplePackageName: aString [
	samplePackageName := aString
]

{ #category : 'initialization' }
ArchDocChecker >> setModel: anArchDocModel [
	model := anArchDocModel
]

{ #category : 'checking' }
ArchDocChecker >> unresolvedRelations [
	"A declaration naming a class this image does not hold. Either the name is misspelt, or the
	 package that holds the target is not loaded and the declaration should say so."

	^ (model relations reject: [ :each | each isTargetLoaded ]) collect: [ :each |
		ArchDocFinding
			kind: #unresolved
			subject: each
			explanation: each declaringClass name , '>>' , each role , ' names '
				, each targetName , ', which nothing in this image answers' ]
]

{ #category : 'private' }
ArchDocChecker >> violationOf: aRelation in: anObject [
	"Read the slot the role names, by reflection rather than by sending the accessor, so a class
	 that hides what it holds is read too, and nothing is built by the reading."

	| slot value |
	aRelation isTargetLoaded ifFalse: [ ^ nil ].
	slot := anObject class allSlots
		detect: [ :each | each name = aRelation role asString ]
		ifNone: [ ^ nil ].
	value := slot read: anObject.
	value ifNil: [
		^ aRelation isCache
			ifTrue: [ nil ]
			ifFalse: [ self finding: aRelation in: anObject saying: 'holds nothing' ] ].
	^ aRelation isToMany
		ifTrue: [ self manyViolationOf: aRelation holding: value in: anObject ]
		ifFalse: [ self oneViolationOf: aRelation holding: value in: anObject ]
]
