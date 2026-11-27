"
I am the map of one route through a project: which parts it is made of, in which order, and which packages they are drawn from.

A project declares a map by subclassing me and writing two class-side methods. `packageNames` states the packages the map claims; `components` states the parts, one row each, in the order the route runs, from its input to its output:

	VGFontRouteMap class >> packageNames
		^ #( 'VectorGraphics-Canvas-Fonts' 'VectorGraphics-Bloc-Text' )

	VGFontRouteMap class >> components
		^ { #( 'Font face' #( VGFontFace VGFontOptions ) 'the parsed font and its options' ) . … }

Nothing registers a map: `ArchDocComponentMap maps` answers every subclass, so a map exists as soon as its package is loaded and disappears with it.

Coverage over the claimed packages is total and the components are disjoint, which is what makes me a map rather than a drawing. Three questions say whether that still holds, and the checker turns each into a finding: `unmappedClasses`, a claimed class no component names; `ambiguousClasses`, a class two components name; `unknownClassNames`, a name this image does not hold. A class added to a claimed package is unmapped until somebody says which part it belongs to, so the suite asks the question rather than letting the diagram go quietly out of date.

Two kinds of class are left out of the count, because they describe a package rather than belong to its design: a `PackageManifest`, and a map — including me.

I hold no edges. The classes themselves say what they hold, through their declarations, and the edges between components are lifted from those.
"
Class {
	#name : 'ArchDocComponentMap',
	#superclass : 'Object',
	#category : 'ArchDoc-Core-Components',
	#package : 'ArchDoc-Core',
	#tag : 'Components'
}

{ #category : 'declaring' }
ArchDocComponentMap class >> components [
	"Each row states a component: its name, the class names it holds, and why it exists. The order
	 of the rows is the order of the route, from its input to its output, and the diagram is laid
	 out in that order."

	^ self subclassResponsibility
]

{ #category : 'testing' }
ArchDocComponentMap class >> isAbstract [
	^ self = ArchDocComponentMap
]

{ #category : 'accessing' }
ArchDocComponentMap class >> maps [
	"Every map this image holds. A project declares one by subclassing, so nothing has to register
	 it and nothing has to be loaded for ArchDoc to find it."

	^ self allSubclasses asArray
]

{ #category : 'declaring' }
ArchDocComponentMap class >> packageNames [
	"The packages this map claims. Every class those packages define must belong to one component,
	 which is what makes a missing one a finding rather than an omission nobody sees."

	^ self subclassResponsibility
]

{ #category : 'checking' }
ArchDocComponentMap >> ambiguousClasses [
	"A class two components name. Components are disjoint, so this says the map stopped being a
	 map: there is no one answer to which part the class belongs to."

	| counted |
	counted := Bag new.
	self components do: [ :each | counted addAll: each classes ].
	^ (counted asSet
		select: [ :each | (counted occurrencesOf: each) > 1 ]) asArray
]

{ #category : 'accessing' }
ArchDocComponentMap >> claimedClasses [
	"Every class the claimed packages define, bar the ones that describe the package rather than
	 belong to it: a manifest is Pharo's own declaration object, and a map is this documentation
	 of the route, not a part of it."

	^ (self packages flatCollect: [ :each | each definedClasses ])
		reject: [ :each | self describesRatherThanBelongs: each ]
]

{ #category : 'accessing' }
ArchDocComponentMap >> componentNamed: aString [
	^ self components
		detect: [ :each | each name = aString ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
ArchDocComponentMap >> componentOf: aClass [
	"The one component holding this class, or nil. Components are disjoint, so the first answer is
	 the only answer; a class two components name is reported by ambiguousClasses."

	^ self components
		detect: [ :each | each includes: aClass ]
		ifNone: [ nil ]
]

{ #category : 'accessing' }
ArchDocComponentMap >> components [
	^ self class components collect: [ :each |
		ArchDocComponent fromTableRow: each declaredIn: self class ]
]

{ #category : 'checking' }
ArchDocComponentMap >> coverageRows [
	| claimed unmapped |
	claimed := self claimedClasses size.
	unmapped := self unmappedClasses size.
	^ {
		{ 'claimed'. claimed } .
		{ 'mapped'. claimed - unmapped } .
		{ 'unmapped'. unmapped } .
		{ 'ambiguous'. self ambiguousClasses size } .
		{ 'not loaded'. self unknownClassNames size } }
]

{ #category : 'testing' }
ArchDocComponentMap >> describesRatherThanBelongs: aClass [
	"Two kinds of class describe a package rather than belong to its design: a manifest, which is
	 Pharo's own declaration object, and a map, which is this documentation of the route. A map is
	 recognised by what it declares rather than by its name, so a map of another project is left
	 out of the count too."

	^ (aClass inheritsFrom: PackageManifest)
		or: [ aClass class canUnderstand: #components ]
]

{ #category : 'inspector' }
ArchDocComponentMap >> inspectionComponents: aBuilder [
	"The parts of the route, in the order they are declared, which is the order the diagram is
	 laid out in."

	<inspectorPresentationOrder: 1 title: 'Components'>
	^ aBuilder newTable
		items: self components;
		addColumn: ((SpStringTableColumn title: 'Component' evaluated: [ :each | each name ]) width: 200);
		addColumn: ((SpStringTableColumn title: 'Classes' evaluated: [ :each | each classes size printString ]) width: 80);
		addColumn: (SpStringTableColumn title: 'Why it exists' evaluated: [ :each | each intention ]);
		yourself
]

{ #category : 'inspector' }
ArchDocComponentMap >> inspectionCoverage: aBuilder [
	"What the map covers, counted by asking the map, so that no number here can drift from the
	 answers the checker reads."

	<inspectorPresentationOrder: 2 title: 'Coverage'>
	^ aBuilder newTable
		items: self coverageRows;
		addColumn: ((SpStringTableColumn title: 'Classes' evaluated: [ :each | each first ]) width: 140);
		addColumn: (SpStringTableColumn title: 'How many' evaluated: [ :each | each second printString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocComponentMap >> packages [
	^ self class packageNames collect: [ :each |
		Smalltalk packageOrganizer packageNamed: each ]
]

{ #category : 'printing' }
ArchDocComponentMap >> printOn: aStream [
	aStream
		nextPutAll: 'map of ';
		print: self components size;
		nextPutAll: ' components over ';
		nextPutAll: (', ' join: self class packageNames)
]

{ #category : 'checking' }
ArchDocComponentMap >> unknownClassNames [
	^ self components flatCollect: [ :each | each unknownClassNames ]
]

{ #category : 'checking' }
ArchDocComponentMap >> unmappedClasses [
	"A claimed class no component names. Coverage is total, so this is a finding: a class added to
	 the route stays unmapped until someone says which part it belongs to."

	^ self claimedClasses reject: [ :each | (self componentOf: each) notNil ]
]
