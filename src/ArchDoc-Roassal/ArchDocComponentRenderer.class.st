"
I draw a component map: one box per part, laid out left to right in the order the map declares its
parts, and one arrow per lifted edge.

I am the altitude above `ArchDocGraphRenderer`, which draws classes. Two things differ. The layout is
the declared order rather than a force layout, because a map holds a handful of parts in an order its
author chose, and because a diagram a reader returns to must be the same picture every time. An edge
pointing at a part declared earlier is routed under the row instead of through the boxes between, so
that the one fact a reader must notice — the design reads against its own order here — is the one
thing drawn out of line.

Every arrow carries the number of class-level edges it stands for, and clicking it opens the lifted
edge, which names the roles.

```
ArchDocComponentRenderer onMap: ArchDocExampleMap new
```
"
Class {
	#name : 'ArchDocComponentRenderer',
	#superclass : 'ArchDocGraphRenderer',
	#category : 'ArchDoc-Roassal',
	#package : 'ArchDoc-Roassal'
}

{ #category : 'instance creation' }
ArchDocComponentRenderer class >> onMap: anArchDocComponentMap [
	"A map answers its own graph, so a reader names the map and not the graph."

	^ self on: anArchDocComponentMap graph
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> addBackwardLineFor: anEdge [
	"Down from the source box, under the row, and up into the target box. Each backward edge gets
	 its own depth, so two of them are read apart."

	| from to depth line |
	from := self shapeFor: anEdge source.
	to := self shapeFor: anEdge target.
	depth := self rowBottom + (self rowDrop * (self backwardLineCount + 1)).
	line := RSPolyline new
		model: anEdge;
		controlPoints: {
				from position x @ from encompassingRectangle bottom.
				from position x @ depth.
				to position x @ depth.
				to position x @ to encompassingRectangle bottom };
		color: (self colorFor: anEdge);
		markerEnd: (RSShapeFactory arrow
			size: 8;
			color: (self colorFor: anEdge);
			yourself);
		yourself.
	anEdge isCache ifTrue: [ line dashArray: #( 4 3 ) ].
	canvas add: line.
	^ line
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> addCountLabelFor: anEdge on: aLine [
	"The number of class edges the arrow stands for, written beside it: one arrow carrying twelve
	 edges and one carrying a single reference are not the same fact. The line's own colour at
	 full opacity, since a faint grey line still needs a readable number."

	| label |
	label := RSLabel new
		model: anEdge;
		text: anEdge count printString;
		fontSize: 8;
		color: ((self colorFor: anEdge) alpha: 1);
		yourself.
	canvas add: label.
	label translateTo: (self labelPointFor: anEdge on: aLine).
	^ label
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> addLineFor: anEdge [
	"A forward edge is a straight arrow between two boxes of the row; a backward one goes under
	 the row, so it crosses no box standing between its two ends. Either way the count of class
	 edges it stands for is written beside it."

	| line |
	line := (self isBackward: anEdge)
		ifTrue: [ self addBackwardLineFor: anEdge ]
		ifFalse: [ super addLineFor: anEdge ].
	line ifNotNil: [ self addCountLabelFor: anEdge on: line ].
	^ line
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> backwardLineCount [
	"How many backward lines the canvas already holds, which is how deep the next one goes."

	^ canvas lines count: [ :each | each class = RSPolyline ]
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> columnGap [
	"The clear space between two boxes of the row, in pixels: enough for an arrow head and the
	 count beside it."

	^ 90
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> drawCanvas [
	"One box per component, laid out left to right in the order the map declares them, because
	 that order is the reading order the map's author chose. No force layout here: a handful of
	 parts in a settled order must answer the same picture every time it is drawn."

	canvas := RSCanvas new.
	shapes := Dictionary new.
	graph nodes do: [ :each | self addShapeFor: each ].
	self placeNodesInDeclarationOrder.
	graph edges do: [ :each | self addLineFor: each ].
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : 'accessing' }
ArchDocComponentRenderer >> indexOf: aComponent [
	"Where the part stands in the declared order, which is where it stands in the row."

	^ graph nodes indexOf: aComponent
]

{ #category : 'inspector' }
ArchDocComponentRenderer >> inspectionReadingOrder: aBuilder [
	"The row in words: each part in the order it is drawn, and how many of its arrows read
	 against that order. A part whose arrows all point forward is one a reader meets after
	 everything it needs; a part with backward arrows is where the order breaks."

	<inspectorPresentationOrder: 2 title: 'Reading order'>
	^ aBuilder newTable
		items: graph nodes;
		addColumn: ((SpStringTableColumn
			title: 'No'
			evaluated: [ :each | (self indexOf: each) printString ]) width: 40);
		addColumn: ((SpStringTableColumn title: 'Part' evaluated: [ :each | each name ])
			width: 180);
		addColumn: (SpStringTableColumn
			title: 'Arrows against the order'
			evaluated: [ :each |
				(graph edges count: [ :edge |
					edge source = each and: [ self isBackward: edge ] ]) printString ]);
		yourself
]

{ #category : 'testing' }
ArchDocComponentRenderer >> isBackward: anEdge [
	"An edge pointing at a part declared before its own source. It is what a reader must notice:
	 the row reads left to right, and this one reads against it."

	^ (self indexOf: anEdge target) < (self indexOf: anEdge source)
]

{ #category : 'accessing' }
ArchDocComponentRenderer >> labelFor: aNode [
	"The part's name and how many classes it names, so the picture says the size of each part
	 without a reader opening it."

	^ aNode name , ' (' , aNode classNames size printString , ')'
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> labelPointFor: anEdge on: aLine [
	"Where the count is written: over the middle of a straight arrow, and on the deep part of a
	 backward one, which is the stretch of it with nothing else drawn there."

	(self isBackward: anEdge) ifTrue: [
		| deep |
		deep := aLine controlPoints second y.
		^ ((self shapeFor: anEdge source) position x
			+ (self shapeFor: anEdge target) position x) / 2 @ (deep - 8) ].
	^ ((self shapeFor: anEdge source) position
		+ (self shapeFor: anEdge target) position) / 2 - (0 @ 9)
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> placeNodesInDeclarationOrder [
	"Every box on one row, in declaration order, with a gap wide enough for an arrow head and a
	 count to be read between two of them."

	| left |
	left := 0.
	graph nodes do: [ :each |
		| shape |
		shape := self shapeFor: each.
		shape translateTo: left + (shape encompassingRectangle width / 2) @ 0.
		left := left + shape encompassingRectangle width + self columnGap ]
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> rowBottom [
	"The lowest edge of the row of boxes: where the space kept for backward lines begins."

	^ (graph nodes collect: [ :each |
		(self shapeFor: each) encompassingRectangle bottom ]) max
]

{ #category : 'rendering' }
ArchDocComponentRenderer >> rowDrop [
	"How far below the row one backward line runs, in pixels."

	^ 34
]
