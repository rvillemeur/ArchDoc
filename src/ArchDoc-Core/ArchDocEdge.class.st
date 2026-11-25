"
I am one arrow of a diagram: a source class, a target class, a kind and a label.

Three kinds, because a reader needs to tell them apart:

- `#holding` — a declared structural relation. The source holds the target, and that is the architecture.
- `#cache` — a declared relation built on first use. Drawn dashed: a live object that has not built it yet contradicts nothing.
- `#use` — no declaration at all, inferred from a static reference in the source's code. Drawn faintly: it is the wiring, not the design.

I compare and hash by my source, my target and my kind, so a set of me holds one arrow per fact however many methods state it.

`ArchDocModel` builds me from the declarations of a package and from the references of its methods; `ArchDocGraph` collects me with the nodes.
"
Class {
	#name : 'ArchDocEdge',
	#superclass : 'Object',
	#instVars : [
		'source',
		'target',
		'kind',
		'label'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

{ #category : 'instance creation' }
ArchDocEdge class >> from: aClass to: anotherClass kind: aSymbol label: aString [
	^ self new setSource: aClass target: anotherClass kind: aSymbol label: aString
]

{ #category : 'instance creation' }
ArchDocEdge class >> useFrom: aClass to: anotherClass [
	"A reference no declaration states. It carries no label: there is no role to name."

	^ self from: aClass to: anotherClass kind: #use label: ''
]

{ #category : 'comparing' }
ArchDocEdge >> = anObject [
	"Compare by the fact I state, not by the method that stated it, so a set of me holds one
	 arrow however many methods say the same thing."

	^ self class = anObject class
		and: [ source = anObject source
		and: [ target = anObject target and: [ kind = anObject kind ] ] ]
]

{ #category : 'comparing' }
ArchDocEdge >> hash [
	^ (source hash bitXor: target hash) bitXor: kind hash
]

{ #category : 'inspector' }
ArchDocEdge >> inspectionArrow: aBuilder [
	"The one fact I state, in words, because a reader meets me from a diagram and needs to know
	 which kind of arrow they clicked."

	<inspectorPresentationOrder: 1 title: 'Arrow'>
	^ aBuilder newTable
		items: {
				'from' -> source name.
				'to' -> target name.
				'kind' -> kind.
				'role' -> (label isEmptyOrNil ifTrue: [ 'none: inferred from a reference' ] ifFalse: [ label ]) };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 100);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each value asString ]);
		yourself
]

{ #category : 'testing' }
ArchDocEdge >> isCache [
	^ kind = #cache
]

{ #category : 'testing' }
ArchDocEdge >> isUse [
	^ kind = #use
]

{ #category : 'accessing' }
ArchDocEdge >> kind [
	"One of #holding, #cache and #use."

	^ kind
]

{ #category : 'accessing' }
ArchDocEdge >> label [
	"The role the declaration gives, or an empty string for an inferred use."

	^ label
]

{ #category : 'printing' }
ArchDocEdge >> printOn: aStream [
	aStream
		<< source name
		<< ' -'
		<< kind
		<< '-> '
		<< target name.
	label isEmptyOrNil ifFalse: [ aStream << ' (' << label << ')' ]
]

{ #category : 'initialization' }
ArchDocEdge >> setSource: aClass target: anotherClass kind: aSymbol label: aString [
	source := aClass.
	target := anotherClass.
	kind := aSymbol.
	label := aString
]

{ #category : 'accessing' }
ArchDocEdge >> source [
	^ source
]

{ #category : 'accessing' }
ArchDocEdge >> target [
	^ target
]
