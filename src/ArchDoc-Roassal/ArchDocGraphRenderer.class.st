"
I draw an `ArchDocGraph` on a Roassal canvas.

One labelled shape per node and one line per edge. The style says which kind of arrow it is, and it is named in `colorFor:` and nowhere else, so the legend and the lines cannot disagree:

- a declared holding is solid and black,
- a cache is dashed and blue, because it may legitimately be absent from a live object,
- an inferred use is faint grey, because it is the wiring and not the design.

Each shape carries its node as its model and each line carries its `ArchDocEdge`, so a click in the diagram opens the thing itself.

The layout is force based. These graphs hold self holdings — a class whose children are of its own kind — and cycles, and `RSSugiyamaLayout` raises a `SubscriptOutOfBounds` on both.

I am the only class of this project that knows Roassal exists. `ArchDoc-Core` loads into an image with no graphics library, so an architecture test can run where no window can open.
"
Class {
	#name : 'ArchDocGraphRenderer',
	#superclass : 'Object',
	#instVars : [
		'graph',
		'canvas',
		'shapes'
	],
	#category : 'ArchDoc-Roassal',
	#package : 'ArchDoc-Roassal'
}

{ #category : 'instance creation' }
ArchDocGraphRenderer class >> on: anArchDocGraph [
	^ self new setGraph: anArchDocGraph
]

{ #category : 'private' }
ArchDocGraphRenderer >> addLineFor: anEdge [
	"A line whose style says which kind of arrow it is: a declared holding solid, a cache dashed
	 because it may legitimately be absent, an inferred use faint because it is the wiring and
	 not the design."

	| line |
	(shapes includesKey: anEdge source) ifFalse: [ ^ nil ].
	(shapes includesKey: anEdge target) ifFalse: [ ^ nil ].
	line := RSLine new
		model: anEdge;
		from: (shapes at: anEdge source);
		to: (shapes at: anEdge target);
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

{ #category : 'private' }
ArchDocGraphRenderer >> addShapeFor: aNode [
	"A box labelled as the graph describes the node, so the same renderer draws a diagram of
	 classes and a graph of live objects."

	| shape |
	shape := RSLabel new
		text: (graph describe: aNode);
		model: aNode;
		yourself.
	shapes at: aNode put: shape.
	canvas add: shape.
	shape @ RSPopup.
	^ shape
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> canvas [
	"One labelled shape per node and one line per edge, because the question a reader asks of a
	 diagram is what holds what. The layout is force based rather than layered: these graphs hold
	 self holdings and cycles, and a layered layout raises on both."

	canvas := RSCanvas new.
	shapes := Dictionary new.
	graph nodes do: [ :each | self addShapeFor: each ].
	graph edges do: [ :each | self addLineFor: each ].
	RSForceBasedLayout on: canvas nodes.
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : 'private' }
ArchDocGraphRenderer >> colorFor: anEdge [
	"Named here and nowhere else, so the legend and the lines cannot disagree."

	anEdge isUse ifTrue: [ ^ Color gray alpha: 0.3 ].
	anEdge isCache ifTrue: [ ^ Color blue alpha: 0.8 ].
	^ Color black
]

{ #category : 'inspector' }
ArchDocGraphRenderer >> inspectionDiagram: aBuilder [
	"What I draw, as I draw it."

	<inspectorPresentationOrder: 0 title: 'Diagram'>
	^ aBuilder newRoassal
		canvas: self canvas;
		yourself
]

{ #category : 'inspector' }
ArchDocGraphRenderer >> inspectionLegend: aBuilder [
	"What each style means, read from the renderer itself rather than restated, so this tab
	 cannot drift from what the lines are drawn with."

	<inspectorPresentationOrder: 1 title: 'Legend'>
	| rows |
	rows := { #holding. #cache. #use } collect: [ :kind |
		| sample |
		sample := ArchDocEdge from: Object to: Object kind: kind label: ''.
		kind -> sample ].
	^ aBuilder newTable
		items: rows;
		addColumn: ((SpStringTableColumn title: 'Kind' evaluated: [ :each | each key asString ]) width: 120);
		addColumn: ((SpStringTableColumn title: 'Line' evaluated: [ :each |
			each value isCache ifTrue: [ 'dashed' ] ifFalse: [ 'solid' ] ]) width: 100);
		addColumn: (SpStringTableColumn title: 'Colour' evaluated: [ :each |
			(self colorFor: each value) printString ]);
		yourself
]

{ #category : 'initialization' }
ArchDocGraphRenderer >> setGraph: anArchDocGraph [
	graph := anArchDocGraph
]
