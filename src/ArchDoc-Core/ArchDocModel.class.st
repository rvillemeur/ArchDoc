"
I am what one package says about its own structure.

I read the declarations of its classes — an `<archRelation:to:>` or `<archCache:to:>` pragma on an accessor, or a class-side `archRelations` table for a class that exposes no accessor — and answer them as `ArchDocRelation`. I also answer the references the package's code makes that no declaration states, as `ArchDocEdge` of kind `#use`, so that a reader sees the architecture and the wiring side by side and can tell which is which.

`graph` answers an `ArchDocGraph` a renderer can draw: one node per class of mine plus every class an edge reaches, and one edge per fact.

I compute each answer once and keep it. A package whose code changes needs a new model; this costs nothing, since reading a package is reading its pragmas.

```
ArchDocModel onPackageNamed: 'VectorGraphics-Canvas-Fonts'
```

I never load a class to resolve a declaration. A declaration naming a class this image does not hold answers no edge, and `ArchDocChecker` is what reports it.
"
Class {
	#name : 'ArchDocModel',
	#superclass : 'Object',
	#instVars : [
		'package',
		'relations',
		'inferredUses',
		'declaredEdges'
	],
	#category : 'ArchDoc-Core',
	#package : 'ArchDoc-Core'
}

{ #category : 'instance creation' }
ArchDocModel class >> onPackage: aPackage [
	^ self new setPackage: aPackage
]

{ #category : 'instance creation' }
ArchDocModel class >> onPackageNamed: aString [
	^ self onPackage: (Smalltalk packageOrganizer packageNamed: aString)
]

{ #category : 'private' }
ArchDocModel >> classesReferencedBy: aClass [
	"Every class the code of aClass names, on both sides, answered by its instance side, since a
	 reference to a metaclass and one to its class are the same fact for a diagram."

	| reached |
	reached := Set new.
	(aClass methods , aClass class methods) do: [ :method |
		method referencedClasses do: [ :each | reached add: each instanceSide ] ].
	^ reached
]

{ #category : 'private' }
ArchDocModel >> collectInferredUses [
	"A class reached by the code of one of mine, that no declaration of mine mentions, and that
	 is not the reaching class itself. A set, so that many methods stating the same reference
	 yield one arrow."

	| declared found |
	declared := self declaredPairs.
	found := Set new.
	package definedClasses do: [ :holder |
		(self classesReferencedBy: holder) do: [ :reached |
			(reached = holder or: [ declared includes: holder -> reached ])
				ifFalse: [ found add: (ArchDocEdge useFrom: holder to: reached) ] ] ].
	^ found
]

{ #category : 'private' }
ArchDocModel >> collectRelations [
	"Asked of each class of mine, since a relation is declared by a class and not by a package."

	| found |
	found := OrderedCollection new.
	package definedClasses do: [ :each |
		found addAll: (ArchDocRelation declaredBy: each) ].
	^ found asArray
]

{ #category : 'private' }
ArchDocModel >> declaredEdges [
	"One edge per declaration whose target this image holds, computed once because the graph and
	 its node set both ask. A declaration pointing at an unloaded class draws nothing; the
	 checker is what reports it."

	^ declaredEdges ifNil: [
		declaredEdges := (self relations select: [ :each | each isTargetLoaded ]) collect: [ :each |
			ArchDocEdge
				from: each declaringClass instanceSide
				to: each targetClass instanceSide
				kind: (each isCache ifTrue: [ #cache ] ifFalse: [ #holding ])
				label: each role asString ] ]
]

{ #category : 'private' }
ArchDocModel >> declaredPairs [
	"The holder and target of every declaration of mine, as a set of associations of classes.
	 A declaration whose target no image holds names no pair, and the checker reports it."

	^ (self relations
		select: [ :each | each isTargetLoaded ]
		thenCollect: [ :each | each declaringClass instanceSide -> each targetClass instanceSide ])
		asSet
]

{ #category : 'accessing' }
ArchDocModel >> graph [
	"The class diagram of my package: one node per class of mine, plus every class my
	 declarations point at, and one edge per fact — a holding, a cache or an inferred use."

	^ ArchDocGraph
		title: package name
		nodes: self nodes
		edges: self declaredEdges , self inferredUses asArray
]

{ #category : 'accessing' }
ArchDocModel >> inferredUses [
	"The references of my package's code that no declaration states, computed once."

	^ inferredUses ifNil: [ inferredUses := self collectInferredUses ]
]

{ #category : 'inspector' }
ArchDocModel >> inspectionRelations: aBuilder [
	"Every declaration of my package, asked of the relations themselves, with the one column
	 that can be false — whether the named target is loaded — last."

	<inspectorPresentationOrder: 1 title: 'Relations'>
	^ aBuilder newTable
		items: self relations;
		addColumn: ((SpStringTableColumn title: 'Holder' evaluated: [ :each | each declaringClass name ]) width: 220);
		addColumn: ((SpStringTableColumn title: 'Role' evaluated: [ :each | each role asString ]) width: 160);
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each kindDescription ]) width: 90);
		addColumn: ((SpStringTableColumn title: 'Many' evaluated: [ :each | each multiplicityDescription ]) width: 70);
		addColumn: ((SpStringTableColumn title: 'Target' evaluated: [ :each | each targetName asString ]) width: 220);
		addColumn: (SpStringTableColumn title: 'Loaded' evaluated: [ :each | each targetDescription ]);
		yourself
]

{ #category : 'inspector' }
ArchDocModel >> inspectionUses: aBuilder [
	"The references my package's code makes that no declaration states. A long list here is not
	 a fault: it is the wiring, and the reader decides which lines belong in the architecture."

	<inspectorPresentationOrder: 2 title: 'Inferred uses'>
	^ aBuilder newTable
		items: (self inferredUses asSortedCollection: [ :a :b |
			a source name , a target name <= (b source name , b target name) ]) asArray;
		addColumn: ((SpStringTableColumn title: 'Reaches from' evaluated: [ :each | each source name ]) width: 260);
		addColumn: (SpStringTableColumn title: 'To' evaluated: [ :each | each target name ]);
		yourself
]

{ #category : 'accessing' }
ArchDocModel >> nodes [
	"The classes of my package, and every further class an edge of mine reaches, so that no edge
	 points at a node the graph does not hold."

	| found |
	found := Set newFrom: package definedClasses.
	self declaredEdges do: [ :each | found add: each target ].
	self inferredUses do: [ :each | found add: each target ].
	^ found asArray
]

{ #category : 'accessing' }
ArchDocModel >> package [
	^ package
]

{ #category : 'accessing' }
ArchDocModel >> packageName [
	^ package name
]

{ #category : 'accessing' }
ArchDocModel >> relations [
	"Every relation the classes of my package declare, computed once."

	^ relations ifNil: [ relations := self collectRelations ]
]

{ #category : 'initialization' }
ArchDocModel >> setPackage: aPackage [
	package := aPackage
]
