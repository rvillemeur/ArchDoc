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

{ #category : 'instance creation' }
ArchDocGraphRenderer class >> onPackageNamed: aString [
	"The reader of a package holds its name and nothing else, so read the model from here."

	^ self on: (ArchDocModel onPackageNamed: aString) graph
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> addLineFor: anEdge [
	"A line whose style says which kind of arrow it is: a declared holding solid, a cache dashed
	 because it may legitimately be absent, an inferred use faint because it is the wiring and
	 not the design. It is attached to the borders of the two boxes and not to their centres, so
	 the arrow head is read beside the name it points at rather than across it."

	| line |
	(shapes includesKey: anEdge source) ifFalse: [ ^ nil ].
	(shapes includesKey: anEdge target) ifFalse: [ ^ nil ].
	line := RSLine new
		model: anEdge;
		from: (shapes at: anEdge source);
		to: (shapes at: anEdge target);
		attachPoint: RSBorderAttachPoint new;
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

{ #category : 'drawing' }
ArchDocGraphRenderer >> addShapeFor: aNode [
	"A label inside a box. The box is what gives the layout an extent to keep clear: a bare label
	 states no size, so a force layout packs the nodes until the words lie on top of one another
	 and the diagram reads as a heap of text. The fill says whether the class belongs to the
	 package being drawn, so the boundary of the package is read off the picture."

	| label box shape |
	label := RSLabel new
		text: (self labelFor: aNode);
		fontSize: 10;
		color: Color black;
		yourself.
	box := RSBox new
		extent: label extent + (14 @ 10);
		color: (self fillFor: aNode);
		border: (RSBorder new color: Color gray; width: 1; yourself);
		cornerRadius: 3;
		yourself.
	shape := RSComposite new
		shapes: { box. label };
		model: aNode;
		yourself.
	shapes at: aNode put: shape.
	canvas add: shape.
	shape @ RSPopup.
	^ shape
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> canvas [
	"The drawn diagram, built once and kept: the layout places the nodes at random before they
	 are pushed apart, so drawing twice would answer two different pictures."

	^ canvas ifNil: [ canvas := self drawCanvas ]
]

{ #category : 'private' }
ArchDocGraphRenderer >> colorFor: anEdge [
	"Named here and nowhere else, so the legend and the lines cannot disagree."

	anEdge isUse ifTrue: [ ^ Color gray alpha: 0.3 ].
	anEdge isCache ifTrue: [ ^ Color blue alpha: 0.8 ].
	^ Color black
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> does: aShape overlap: anotherShape [
	"Two nodes overlap when their boxes come within the gap of one another. The gap is what keeps
	 a line's arrow head visible between two boxes."

	^ (aShape encompassingRectangle expandBy: self nodeGap)
		intersects: anotherShape encompassingRectangle
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> drawCanvas [
	"One labelled box per node and one line per edge, because the question a reader asks of a
	 diagram is what holds what. The layout is force based rather than layered: these graphs hold
	 self holdings and cycles, and a layered layout raises on both. The force layout reads the
	 edges alone and knows nothing of how wide a box is, so the boxes are pushed apart afterwards."

	canvas := RSCanvas new.
	shapes := Dictionary new.
	graph nodes do: [ :each | self addShapeFor: each ].
	graph edges do: [ :each | self addLineFor: each ].
	RSForceBasedLayout new
		charge: -600;
		length: 160;
		on: canvas nodes.
	self spreadNodes.
	canvas @ RSCanvasController.
	^ canvas
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> fillFor: aNode [
	"A class of the package being drawn is filled; a class the diagram shows because a
	 declaration points at it, and that lives elsewhere, is left white."

	^ (graph holdsAtHome: aNode)
		ifTrue: [ self residentColor ]
		ifFalse: [ self visitorColor ]
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> graph [
	"The graph I draw. A reader who built me from a package name asks me for it rather than
	 reading the model a second time."

	<archRelation: #one to: #ArchDocGraph>
	^ graph
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
	 cannot drift from what the diagram is drawn with."

	<inspectorPresentationOrder: 1 title: 'Legend'>
	^ aBuilder newTable
		items: self legendRows;
		addColumn: ((SpStringTableColumn title: 'Means' evaluated: [ :each | each first ])
			width: 120);
		addColumn: ((SpStringTableColumn title: 'Drawn as' evaluated: [ :each | each second ])
			width: 120);
		addColumn: (SpStringTableColumn title: 'Colour' evaluated: [ :each | each third printString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> labelFor: aNode [
	"The words inside a node's box. A class diagram writes the class name; a component diagram
	 writes the name of the part and its size, so the hook is here."

	^ graph describe: aNode
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> legendRows [
	"What each style of the drawing means: name, what carries it, and the colour. The colours are
	 asked of the renderer rather than restated, so the legend cannot drift from the picture."

	| lineRows |
	lineRows := #( #holding #cache #use ) collect: [ :kind |
		| sample |
		sample := ArchDocEdge from: Object to: Object kind: kind label: ''.
		{ kind asString.
		  sample isCache ifTrue: [ 'dashed line' ] ifFalse: [ 'solid line' ].
		  self colorFor: sample } ].
	^ lineRows , {
		{ 'resident'. 'filled box'. self residentColor }.
		{ 'visitor'. 'white box'. self visitorColor } }
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> nodeGap [
	"The clear space kept between two boxes, in pixels: enough for an arrow head to be seen."

	^ 16
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> push: aShape awayFrom: anotherShape [
	"Half a step each, along the line between the two centres. Two nodes the layout left at the
	 very same point have no such line, so they are parted along the diagonal."

	| delta step |
	delta := aShape position - anotherShape position.
	delta isZero ifTrue: [ delta := 1 @ 1 ].
	step := delta / delta r * (self nodeGap / 2).
	aShape translateBy: step.
	anotherShape translateBy: step negated
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> pushOverlappingPairApartIn: aCollection [
	"One pass: each pair whose boxes come closer than the gap is pushed apart along the line
	 between the two, each node taking half the step. Answers whether anything moved."

	| moved |
	moved := false.
	aCollection doWithIndex: [ :one :index |
		(aCollection copyFrom: index + 1 to: aCollection size) do: [ :other |
			(self does: one overlap: other) ifTrue: [
				self push: one awayFrom: other.
				moved := true ] ] ].
	^ moved
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> residentColor [
	"The fill of a class the drawn package defines. Named here and nowhere else, so the legend
	 and the boxes cannot disagree."

	^ Color r: 0.87 g: 0.91 b: 0.98
]

{ #category : 'initialization' }
ArchDocGraphRenderer >> setGraph: anArchDocGraph [
	graph := anArchDocGraph
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> shapeFor: aNode [
	"The box drawn for a node, so a reader and a test ask the renderer rather than reach into it.
	 Asking for a shape draws the diagram if it is not drawn yet, since there is no shape before
	 then; during the drawing the canvas is already in place, so this does not recur."

	self canvas.
	^ shapes at: aNode
]

{ #category : 'rendering' }
ArchDocGraphRenderer >> spreadNodes [
	"The force layout places a node by its edges and knows nothing of how wide its box is, so
	 boxes still land on one another. Push every overlapping pair apart, a step at a time, until
	 a pass moves nothing — a diagram whose names cover one another answers no question. The pass
	 count is a bound and not a target: the loop leaves as soon as the picture is clear."

	| nodes |
	nodes := canvas nodes.
	self spreadingPasses timesRepeat: [
		(self pushOverlappingPairApartIn: nodes) ifFalse: [ ^ self ] ]
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> spreadingPasses [
	"How many separation passes are allowed before the drawing is handed over regardless. A
	 bound, not a target: a package of a few dozen classes is clear in far fewer."

	^ 400
]

{ #category : 'accessing' }
ArchDocGraphRenderer >> visitorColor [
	"The fill of a class the diagram shows although it lives in another package."

	^ Color white
]
