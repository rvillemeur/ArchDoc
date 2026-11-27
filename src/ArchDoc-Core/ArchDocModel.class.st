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
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'instance creation' }
ArchDocModel class >> onPackage: aPackage [
	^ self new setPackage: aPackage
]

{ #category : 'instance creation' }
ArchDocModel class >> onPackageNamed: aString [
	^ self onPackage: (Smalltalk packageOrganizer packageNamed: aString)
]

{ #category : 'accessing' }
ArchDocModel >> allEdges [
	"Every fact I hold, drawn or not: the declarations and every inferred use, including the ones
	 whose target is no node of the diagram. The checker reads this rather than the graph, because
	 a reference to a package the manifest forbids is exactly a reference out of the diagram."

	^ self declaredEdges , self inferredUses asArray
]

{ #category : 'accessing' }
ArchDocModel >> classesReferencedBy: aClass [
	"The classes the methods of this package install on aClass name. A method another package
	 installs on aClass is that package's reference, not this one's: the Diagram tab of
	 ArchDoc-Roassal names a renderer, and ArchDocGraph does not thereby depend on it."

	| reached |
	reached := Set new.
	((aClass methods , aClass class methods) select: [ :each | self owns: each ]) do: [ :method |
		method referencedClasses do: [ :each | reached add: each instanceSide ] ].
	^ reached
]

{ #category : 'private' }
ArchDocModel >> collectInferredUses [
	"A class reached by the code of one of mine, that no declaration of mine mentions, and that
	 is not the reaching class itself. Every one of them, including the classes of other projects:
	 this is what the checker reads to report a forbidden dependency, so filtering here would
	 blind it. The diagram draws a part of this set; see drawnUses. A set, so that many methods
	 stating the same reference yield one arrow."

	| declared found |
	declared := self declaredPairs.
	found := Set new.
	(package definedClasses reject: [ :each | self isManifest: each ]) do: [ :holder |
		(self classesReferencedBy: holder) do: [ :reached |
			(reached = holder or: [ declared includes: holder -> reached ])
				ifFalse: [ found add: (ArchDocEdge useFrom: holder to: reached) ] ] ].
	^ found
]

{ #category : 'private' }
ArchDocModel >> collectRelations [
	"Both sides of every class of my package: what its instances hold, and what the class object
	 itself holds for the session."

	| found |
	found := OrderedCollection new.
	package definedClasses do: [ :each |
		found addAll: (ArchDocRelation declaredBy: each).
		found addAll: (ArchDocRelation declaredBy: each class) ].
	^ found asArray
]

{ #category : 'accessing' }
ArchDocModel >> declaredEdges [
	"One edge per declaration whose target this image holds, computed once because the graph and
	 its node set both ask. A declaration pointing at an unloaded class draws nothing; the
	 checker is what reports it. The declaration says which kind of arrow it makes."

	^ declaredEdges ifNil: [
		declaredEdges := (self relations select: [ :each | each isTargetLoaded ]) collect: [ :each |
			ArchDocEdge
				from: each declaringClass instanceSide
				to: each targetClass instanceSide
				kind: each edgeKind
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

{ #category : 'private' }
ArchDocModel >> drawnUses [
	"The inferred uses the diagram shows: those between two nodes of it. A use of a class the
	 diagram does not hold would drag that class in, and a package reaches dozens — kernel
	 classes, collections, widgets — so the picture would stop answering what holds what. The
	 checker reads inferredUses, which holds them all."

	| drawn |
	drawn := self nodes asSet.
	^ (self inferredUses select: [ :each |
		   (drawn includes: each source) and: [ drawn includes: each target ] ]) asArray
]

{ #category : 'accessing' }
ArchDocModel >> graph [
	"The class diagram of my package: one node per class of mine, plus every class my
	 declarations point at, and one edge per fact — a holding, a cache, or a use between two
	 classes the diagram already holds. The classes of my package are its home, so the drawing
	 can tell a resident from a visitor."

	^ ArchDocGraph
		title: package name
		nodes: self nodes
		edges: self declaredEdges , self drawnUses
		home: (package definedClasses reject: [ :each | self isManifest: each ])
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

{ #category : 'private' }
ArchDocModel >> isManifest: aClass [
	^ aClass inheritsFrom: PackageManifest
]

{ #category : 'accessing' }
ArchDocModel >> nodes [
	"The classes of my package and every class a declaration of mine points at. Nothing else: a
	 class merely reached by my code is a node nobody asked for, and a diagram carrying thirty of
	 them answers no question. A manifest states the rules the package is held to rather than a
	 part of its design, so it is no node either."

	| found |
	found := Set newFrom:
		(package definedClasses reject: [ :each | self isManifest: each ]).
	self declaredEdges do: [ :each | found add: each target ].
	^ found asArray
]

{ #category : 'private' }
ArchDocModel >> owns: aCompiledMethod [
	^ aCompiledMethod package = package
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
