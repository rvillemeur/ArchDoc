"
I am one thing `ArchDocChecker` has to report: a kind, the subject it is about, and a sentence a reader can act on.

My kind is one of `#unresolved`, `#missingOpposite`, `#sampleViolation` and `#forbiddenDependency`. My subject is whatever the finding is about — a relation, a class, an edge — and my explanation says what is wrong in words, because the kind alone tells a reader nothing they can fix.

An architecture test asserts that the collections of me are empty, and prints my explanation when they are not.
"
Class {
	#name : 'ArchDocFinding',
	#superclass : 'Object',
	#instVars : [
		'kind',
		'subject',
		'explanation'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

{ #category : 'instance creation' }
ArchDocFinding class >> kind: aSymbol subject: anObject explanation: aString [
	^ self new setKind: aSymbol subject: anObject explanation: aString
]

{ #category : 'accessing' }
ArchDocFinding >> explanation [
	^ explanation
]

{ #category : 'inspector' }
ArchDocFinding >> inspectionFinding: aBuilder [
	"One finding in words, with its subject's own printString, so a reader can go from the
	 sentence to the declaration it is about."

	<inspectorPresentationOrder: 1 title: 'Finding'>
	^ aBuilder newTable
		items: {
				'kind' -> kind.
				'says' -> explanation.
				'subject' -> subject printString };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 100);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each value asString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocFinding >> kind [
	"One of #unresolved, #missingOpposite, #sampleViolation and #forbiddenDependency."

	^ kind
]

{ #category : 'printing' }
ArchDocFinding >> printOn: aStream [
	aStream << kind << ': ' << explanation
]

{ #category : 'initialization' }
ArchDocFinding >> setKind: aSymbol subject: anObject explanation: aString [
	kind := aSymbol.
	subject := anObject.
	explanation := aString
]

{ #category : 'accessing' }
ArchDocFinding >> subject [
	"Whatever the finding is about: a relation, a class or an edge."

	^ subject
]
