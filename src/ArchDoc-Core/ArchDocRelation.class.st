"
I am one declared relation between two classes of a documented project: a holder, a role, a target and a multiplicity.

I am read from a pragma on the accessor that reads the instance variable, which is where a reader of the code already looks:

```
child
	<archRelation: #one to: #ArchDocDeclaredSubject opposite: #children>
	^ child
```

Three pragmas declare a relation. `archRelation:to:` states a holding, `archRelation:to:opposite:` adds the role by which the target holds the holder back, and `archCache:to:` states a holding that is built on first use rather than given at creation — a cache, which a diagram draws apart from a structural holding, because its absence in a live object means nothing.

A pragma is a literal, so declaring a relation costs the declaring package no dependency on ArchDoc.

I name my target by symbol and not by class, so that a declaration survives a target that is not loaded. `ArchDocChecker` is what reports a target symbol that resolves to nothing.

`ArchDocDeclaredSubject`, in the examples package, declares one relation of each kind, and `ArchDocRelationExamples` opens one.
"
Class {
	#name : 'ArchDocRelation',
	#superclass : 'Object',
	#instVars : [
		'role',
		'targetName',
		'multiplicity',
		'oppositeRole',
		'isCache',
		'declaringClass'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

{ #category : 'declarations' }
ArchDocRelation class >> declarationSelectors [
	"The pragmas that declare a relation. A method carrying none of them declares nothing."

	^ #( #archRelation:to: #archRelation:to:opposite: #archCache:to: )
]

{ #category : 'instance creation' }
ArchDocRelation class >> fromMethod: aCompiledMethod [
	"Answer the relation the method declares, or nil when it declares none."

	| pragma |
	pragma := aCompiledMethod pragmas
		detect: [ :each | self declarationSelectors includes: each selector ]
		ifNone: [ ^ nil ].
	^ self new readFromPragma: pragma
]

{ #category : 'instance creation' }
ArchDocRelation class >> fromTableRow: anArray declaredIn: aClass [
	"Answer the relation one row of a class-side archRelations table states. The row is the
	 role, the multiplicity, the target and the opposite; nil names no opposite."

	^ self new readFromTableRow: anArray declaredIn: aClass
]

{ #category : 'accessing' }
ArchDocRelation >> declaringClass [
	"The class that declares me. For a declaration on the class side, this is the metaclass, and
	 that is the truth: the holding is the class's own, not its instances'."

	^ declaringClass
]

{ #category : 'testing' }
ArchDocRelation >> hasOpposite [
	"Does my declaration name the role by which my target holds my holder back? The checker
	 reports a named opposite that the target does not declare in return."

	^ oppositeRole notNil
]

{ #category : 'inspector' }
ArchDocRelation >> inspectionDeclaration: aBuilder [
	"What I declare, in words, one row per thing I state."

	<inspectorPresentationOrder: 1 title: 'Declaration'>
	^ aBuilder newTable
		items: {
				'holder' -> declaringClass name.
				'role' -> role.
				'multiplicity' -> self multiplicityDescription.
				'kind' -> (self isCache
					ifTrue: [ 'cache, built on first use' ]
					ifFalse: [ 'structural' ]).
				'opposite' -> self oppositeDescription.
				'target' -> targetName.
				'target resolves' -> self targetDescription };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 140);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each value asString ]);
		yourself
]

{ #category : 'testing' }
ArchDocRelation >> isCache [
	"Am I built on first use? An unbuilt cache is absent from a live object, and that absence
	 contradicts no declaration."

	^ isCache
]

{ #category : 'testing' }
ArchDocRelation >> isStructural [
	"Am I given at creation rather than built on first use? A structural holding absent from a
	 live object contradicts the declaration; an unbuilt cache does not."

	^ self isCache not
]

{ #category : 'testing' }
ArchDocRelation >> isTargetLoaded [
	^ self targetClass notNil
]

{ #category : 'testing' }
ArchDocRelation >> isToMany [
	^ multiplicity = #many
]

{ #category : 'testing' }
ArchDocRelation >> isToOne [
	^ multiplicity = #one
]

{ #category : 'describing' }
ArchDocRelation >> kindDescription [
	^ self isCache
		ifTrue: [ 'cache' ]
		ifFalse: [ 'holding' ]
]

{ #category : 'describing' }
ArchDocRelation >> multiplicityDescription [
	^ self isToMany
		ifTrue: [ 'many' ]
		ifFalse: [ 'one' ]
]

{ #category : 'describing' }
ArchDocRelation >> oppositeDescription [
	^ self hasOpposite
		ifTrue: [ oppositeRole asString ]
		ifFalse: [ 'none declared' ]
]

{ #category : 'accessing' }
ArchDocRelation >> oppositeRole [
	"The role by which my target holds my holder back, or nil when my declaration names none."

	^ oppositeRole
]

{ #category : 'printing' }
ArchDocRelation >> printOn: aStream [
	"Say the whole declaration, because a reader meets me in a list of several and the holder is
	 what tells them apart."

	aStream
		<< declaringClass name
		<< '>>'
		<< role.
	self isCache ifTrue: [ aStream << ' cache' ].
	aStream
		<< ' '
		<< multiplicity
		<< ' '
		<< targetName
]

{ #category : 'initialization' }
ArchDocRelation >> readFromPragma: aPragma [
	"Read my whole state from one declaration. The role is the selector of the accessor the
	 pragma sits on, so a declaration never repeats the name of the instance variable."

	role := aPragma methodSelector.
	declaringClass := aPragma methodClass.
	isCache := aPragma selector = #archCache:to:.
	multiplicity := aPragma argumentAt: 1.
	targetName := aPragma argumentAt: 2.
	oppositeRole := aPragma numArgs >= 3
		ifTrue: [ aPragma argumentAt: 3 ]
		ifFalse: [ nil ]
]

{ #category : 'initialization' }
ArchDocRelation >> readFromTableRow: anArray declaredIn: aClass [
	"One shape of row states a structural holding and a cache alike: the multiplicity carries
	 both facts, as #one, #many, #cacheOne or #cacheMany."

	| stated |
	role := anArray first.
	declaringClass := aClass.
	stated := anArray second.
	isCache := #( #cacheOne #cacheMany ) includes: stated.
	multiplicity := (#( #many #cacheMany ) includes: stated)
		ifTrue: [ #many ]
		ifFalse: [ #one ].
	targetName := anArray third.
	oppositeRole := anArray fourth
]

{ #category : 'accessing' }
ArchDocRelation >> role [
	"The selector of the accessor I was declared on, which is also the name of the instance
	 variable it reads."

	^ role
]

{ #category : 'accessing' }
ArchDocRelation >> targetClass [
	"The class I name, or nil when this image holds none of that name. I answer nil rather than
	 raise, because a declaration pointing at an unloaded package is a finding and not an error."

	^ Smalltalk globals at: targetName ifAbsent: [ nil ]
]

{ #category : 'describing' }
ArchDocRelation >> targetDescription [
	"Says whether the named target resolves, because a declaration pointing at nothing is the
	 one row of a table that a reader must act on."

	^ self isTargetLoaded
		ifTrue: [ 'yes' ]
		ifFalse: [ 'NO: nothing of that name is loaded' ]
]

{ #category : 'accessing' }
ArchDocRelation >> targetName [
	"The symbol naming the class I point at. A symbol and not a class, so that I survive a
	 target that is not loaded."

	^ targetName
]
