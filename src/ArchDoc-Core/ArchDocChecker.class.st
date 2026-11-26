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
		'samplePackageName'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

{ #category : 'instance creation' }
ArchDocChecker class >> onModel: anArchDocModel [
	^ self new setModel: anArchDocModel
]

{ #category : 'instance creation' }
ArchDocChecker class >> onPackageNamed: aString [
	^ self onModel: (ArchDocModel onPackageNamed: aString)
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
	"The four answers together, which is what an architecture test asserts is empty and what the
	 inspector shows."

	^ self unresolvedRelations , self missingOpposites , self sampleInstanceViolations
		, self forbiddenDependencies
]

{ #category : 'checking' }
ArchDocChecker >> forbiddenDependencies [
	"Every edge of my model that reaches a package the manifest forbids. This is the rule a
	 project states in one place and a test reads: a layering rule belongs beside the package,
	 not in a markdown file that drifts."

	| forbidden |
	forbidden := self forbiddenPackageNames.
	forbidden ifEmpty: [ ^ #() ].
	^ (model graph edges
		select: [ :each | forbidden includes: (self packageNameOf: each target) ])
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

{ #category : 'inspector' }
ArchDocChecker >> inspectionCounts: aBuilder [
	"How many of each kind, counted from the answers themselves, so this tab cannot disagree
	 with the one beside it."

	<inspectorPresentationOrder: 2 title: 'Summary'>
	^ aBuilder newTable
		items: {
				'package' -> model packageName.
				'declarations' -> model relations size printString.
				'unresolved' -> self unresolvedRelations size printString.
				'missing opposites' -> self missingOpposites size printString.
				'sample violations' -> self sampleInstanceViolations size printString.
				'forbidden dependencies' -> self forbiddenDependencies size printString.
				'samples read' -> self sampleInstances size printString };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 200);
		addColumn: (SpStringTableColumn title: 'Count' evaluated: [ :each | each value ]);
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
	"An empty collection is no violation: a holding of many may legitimately hold none yet."

	aValue isCollection ifFalse: [
		^ self
			finding: aRelation
			in: anObject
			saying: 'holds a ' , aValue class name , ', which is no collection' ].
	^ (aValue allSatisfy: [ :each | each isKindOf: aRelation targetClass ])
		ifTrue: [ nil ]
		ifFalse: [
			self finding: aRelation in: anObject saying: 'holds objects of another kind' ]
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
	"Every object the examples answer whose class my model's package defines. Running an example
	 is how this library reads a live object: there is no other registry of instances."

	| classes found |
	classes := model package definedClasses.
	found := OrderedCollection new.
	self samplePackage definedClasses do: [ :each |
		each class methods do: [ :method |
			(method pragmas anySatisfy: [ :pragma | pragma selector = #sampleInstance ])
				ifTrue: [
					| answered |
					answered := each perform: method selector.
					(classes includes: answered class) ifTrue: [ found add: answered ] ] ] ].
	^ found asArray
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
