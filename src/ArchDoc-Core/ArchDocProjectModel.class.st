"
I read a whole project rather than one package: my nodes are packages and my arrows are
the references between them, each carrying how many class references it stands for.

I invent no second scan. One ArchDocModel per package of the project answers every edge
its classes make, and I lift those edges onto the packages the two classes live in: an
edge inside one package disappears, an edge between two of them is one arrow, and the
strongest kind wins, holding over cache over use.

A package the project depends on from outside is a node of mine too, left as a visitor by
the drawing, because where a package sits is as much what it reaches as what it holds.

ArchDocProjectModel onPrefix: 'ArchDoc'
"
Class {
	#name : 'ArchDocProjectModel',
	#superclass : 'Object',
	#instVars : [
		'packages',
		'classEdges',
		'edges'
	],
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'instance creation' }
ArchDocProjectModel class >> onPackages: aCollection [
	^ self new setPackages: aCollection
]

{ #category : 'instance creation' }
ArchDocProjectModel class >> onPackagesNamed: aCollection [
	"The packages of the project named one by one, for a project whose packages share no prefix."

	^ self onPackages: (aCollection collect: [ :each |
		Smalltalk packageOrganizer packageNamed: each ])
]

{ #category : 'instance creation' }
ArchDocProjectModel class >> onPrefix: aString [
	"Every package whose name begins with the prefix, in alphabetical order, which is how a
	 project names its own packages: ArchDoc-Core, ArchDoc-Examples, and so on. The order is
	 fixed so that the same project draws the same picture twice."

	^ self onPackages: ((Smalltalk packageOrganizer packages
		select: [ :each | each name beginsWith: aString ])
		asSortedCollection: [ :a :b | a name <= b name ]) asArray
]

{ #category : 'private' }
ArchDocProjectModel >> beginningSharedBy: aString and: anotherString [
	| limit |
	limit := aString size min: anotherString size.
	1 to: limit do: [ :index |
		(aString at: index) = (anotherString at: index)
			ifFalse: [ ^ aString first: index - 1 ] ].
	^ aString first: limit
]

{ #category : 'accessing' }
ArchDocProjectModel >> classEdges [
	"Every edge the classes of my packages make, declared or inferred, computed once. One
	 ArchDocModel per package answers them: there is no second scan of the code here."

	^ classEdges ifNil: [
		classEdges := self packages flatCollect: [ :each |
			(ArchDocModel onPackage: each) allEdges ] ]
]

{ #category : 'accessing' }
ArchDocProjectModel >> drawnEdges [
	"The arrows the diagram shows: every one between two packages of the project, and the ones
	 pointing outside it that a declaration states. A use pointing outside is left to the
	 tables: every package reaches the kernel and the collections, and a picture holding all of
	 that answers no question about where the project sits."

	^ self edges select: [ :each |
		(packages includes: each target) or: [ each isUse not ] ]
]

{ #category : 'accessing' }
ArchDocProjectModel >> edges [
	"One arrow per ordered pair of packages, over every class edge between them, computed once.
	 An edge inside one package is no arrow here, and an edge pointing at a class no package
	 claims is dropped: there is nothing to draw it at."

	^ edges ifNil: [ edges := self liftClassEdges ]
]

{ #category : 'accessing' }
ArchDocProjectModel >> graph [
	"The package diagram of the project: one node per package of it, plus the packages it
	 declares a holding into, and one arrow per pair. The project's own packages are its home,
	 so the drawing tells a package of the project from one it depends on."

	^ ArchDocGraph
		title: self title
		nodes: self nodes
		edges: self drawnEdges
		home: packages
]

{ #category : 'inspector' }
ArchDocProjectModel >> inspectionPackages: aBuilder [
	"Each package of the project with its size and how far it reaches: what it declares into
	 another package, and what its code merely uses. A package that declares nothing and uses
	 much is wiring; a package nothing points at is a leaf."

	<inspectorPresentationOrder: 1 title: 'Packages'>
	^ aBuilder newTable
		items: self packages;
		addColumn: ((SpStringTableColumn title: 'Package' evaluated: [ :each | each name asString ]) width: 260);
		addColumn: ((SpStringTableColumn title: 'Classes' evaluated: [ :each | each definedClasses size printString ]) width: 80);
		addColumn: ((SpStringTableColumn title: 'Declares' evaluated: [ :each |
			(self edges count: [ :edge | edge source = each and: [ edge isUse not ] ]) printString ]) width: 90);
		addColumn: (SpStringTableColumn title: 'Uses' evaluated: [ :each |
			(self edges count: [ :edge | edge source = each and: [ edge isUse ] ]) printString ]);
		yourself
]

{ #category : 'private' }
ArchDocProjectModel >> liftClassEdges [
	"Group the class edges by the pair of packages their two ends live in, make one lifted edge
	 of each group, and mark the ones the source package's manifest forbids."

	| grouped |
	grouped := OrderedDictionary new.
	self classEdges do: [ :each |
		| source target |
		source := each source package.
		target := each target package.
		(source notNil and: [ target notNil and: [ source ~= target ] ]) ifTrue: [
			(grouped at: source -> target ifAbsentPut: [ OrderedCollection new ])
				add: each ] ].
	^ grouped associations collect: [ :each |
		| lifted |
		lifted := ArchDocLiftedEdge
			from: each key key
			to: each key value
			over: each value asArray.
		(ArchDocChecker package: each key key forbids: each key value name asString)
			ifTrue: [ lifted markForbidden ].
		lifted ]
]

{ #category : 'accessing' }
ArchDocProjectModel >> nodes [
	"The packages of the project and every package a drawn arrow points at."

	| found |
	found := OrderedCollection newFrom: packages.
	self drawnEdges do: [ :each |
		(found includes: each target) ifFalse: [ found add: each target ] ].
	^ found asArray
]

{ #category : 'accessing' }
ArchDocProjectModel >> packageNamed: aString [
	"The package of this project under that name, so a reader and a test name a node rather than
	 reach for the package organizer."

	^ packages detect: [ :each | each name = aString ]
]

{ #category : 'accessing' }
ArchDocProjectModel >> packages [
	"The packages of the project, in the order they will be drawn."

	^ packages
]

{ #category : 'private' }
ArchDocProjectModel >> setPackages: aCollection [
	packages := aCollection asArray
]

{ #category : 'accessing' }
ArchDocProjectModel >> title [
	"What the diagram is called: the beginning every package name shares, without the dash that
	 separates a project from its layers, which is the project's own name when the packages are
	 named after it."

	| shared |
	packages ifEmpty: [ ^ 'no package' ].
	shared := packages first name asString.
	packages do: [ :each |
		shared := self beginningSharedBy: shared and: each name asString ].
	^ (shared endsWith: '-')
		ifTrue: [ shared allButLast ]
		ifFalse: [ shared ]
]
