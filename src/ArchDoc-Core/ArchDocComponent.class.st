"
I am one named part of a design, read from a row of a component map.

A package diagram draws every class a package defines, which is the right altitude to check a declaration and the wrong altitude to read a design: seventeen boxes say what exists, not what the parts are. I stand one altitude above that. My name is the name a reader of the code would use for the part — 'Glyph cache', 'Font face' — my classes are the classes that part is made of, and my intention says in one line why the part exists.

My row states three things, and my map states the rest:

	#( 'Glyph cache'
	   #( VGGlyphAtlas VGGlyphMask )
	   'keeps a rasterised glyph so the same character is rasterised once' )

A class name this image does not hold is no class of mine: `classes` leaves it out and `unknownClassNames` reports it, so a renamed or unloaded class is a finding of the checker rather than a silent gap in the diagram.

I hold no edges. The edges between components are lifted from the class-level declarations by my map, because a component says which classes belong together and the classes themselves say what they hold.
"
Class {
	#name : 'ArchDocComponent',
	#superclass : 'Object',
	#instVars : [
		'name',
		'classNames',
		'intention',
		'declaringClass'
	],
	#category : 'ArchDoc-Core-Components',
	#package : 'ArchDoc-Core',
	#tag : 'Components'
}

{ #category : 'instance creation' }
ArchDocComponent class >> fromTableRow: anArray declaredIn: aClass [
	^ self new
		readFromTableRow: anArray declaredIn: aClass;
		yourself
]

{ #category : 'comparing' }
ArchDocComponent >> = anObject [
	"Compare by the part I name, not by the reading that built me, so a map read twice answers
	 components a set and an edge can match."

	^ self class = anObject class
		and: [ name = anObject name and: [ declaringClass = anObject declaringClass ] ]
]

{ #category : 'graphing' }
ArchDocComponent >> classEdges [
	"The class-level edges that run between my own classes: how I am built, which is what the map
	 drops when it lifts the edges."

	^ self map classEdges select: [ :each |
		(self includes: each source) and: [ self includes: each target ] ]
]

{ #category : 'accessing' }
ArchDocComponent >> classNames [
	^ classNames
]

{ #category : 'accessing' }
ArchDocComponent >> classes [
	"Only the names this image holds. A name it does not hold is a finding, not a class."

	^ classNames
		select: [ :each | Smalltalk includesKey: each ]
		thenCollect: [ :each | Smalltalk at: each ]
]

{ #category : 'accessing' }
ArchDocComponent >> declaringClass [
	^ declaringClass
]

{ #category : 'graphing' }
ArchDocComponent >> edges [
	"The lifted arrows of my map that touch me, in either direction."

	^ self map edges select: [ :each | each source = self or: [ each target = self ] ]
]

{ #category : 'graphing' }
ArchDocComponent >> graph [
	"My own classes and the edges between them: the altitude below the map, drawn the way a
	 package is drawn."

	| classes |
	classes := self classes.
	^ ArchDocGraph
		title: name
		nodes: classes
		edges: self classEdges
		home: classes
]

{ #category : 'comparing' }
ArchDocComponent >> hash [
	^ name hash bitXor: declaringClass hash
]

{ #category : 'testing' }
ArchDocComponent >> includes: aClass [
	^ classNames includes: aClass name asSymbol
]

{ #category : 'inspector' }
ArchDocComponent >> inspectionClasses: aBuilder [
	"Every name the row states, loaded or not, asked of the image rather than restated."

	<inspectorPresentationOrder: 1 title: 'Classes'>
	^ aBuilder newTable
		items: classNames;
		addColumn: ((SpStringTableColumn title: 'Class' evaluated: [ :each | each asString ]) width: 260);
		addColumn: (SpStringTableColumn title: 'In the image' evaluated: [ :each |
			(Smalltalk includesKey: each)
				ifTrue: [ 'loaded' ]
				ifFalse: [ 'not loaded' ] ]);
		yourself
]

{ #category : 'inspector' }
ArchDocComponent >> inspectionRelations: aBuilder [
	"The arrows that touch me, read from where I stand: which way each one runs, which other part
	 it joins, its kind, and how many class edges it stands for."

	<inspectorPresentationOrder: 2 title: 'Relations'>
	^ aBuilder newTable
		items: self edges;
		addColumn: ((SpStringTableColumn
			title: 'Way'
			evaluated: [ :each | each source = self ifTrue: [ 'to' ] ifFalse: [ 'from' ] ])
				width: 60);
		addColumn: ((SpStringTableColumn
			title: 'Part'
			evaluated: [ :each |
				(each source = self ifTrue: [ each target ] ifFalse: [ each source ]) name ])
					width: 180);
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each kind asString ])
			width: 90);
		addColumn: (SpStringTableColumn
			title: 'Class edges'
			evaluated: [ :each | each count printString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocComponent >> intention [
	^ intention
]

{ #category : 'accessing' }
ArchDocComponent >> map [
	"The map I was read from. A reader who opened me from a diagram holds me and not it, so I
	 answer the questions that need it myself."

	^ declaringClass new
]

{ #category : 'accessing' }
ArchDocComponent >> name [
	^ name
]

{ #category : 'printing' }
ArchDocComponent >> printOn: aStream [
	aStream
		nextPutAll: 'component ';
		nextPutAll: name;
		nextPutAll: ' of ';
		print: classNames size;
		nextPutAll: ' classes'
]

{ #category : 'initialization' }
ArchDocComponent >> readFromTableRow: anArray declaredIn: aClass [
	"A row states a name, the class names the component holds, and why it exists."

	name := anArray first.
	classNames := anArray second.
	intention := anArray third.
	declaringClass := aClass
]

{ #category : 'accessing' }
ArchDocComponent >> unknownClassNames [
	^ classNames reject: [ :each | Smalltalk includesKey: each ]
]
