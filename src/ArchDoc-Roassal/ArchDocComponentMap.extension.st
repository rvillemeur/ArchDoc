Extension { #name : 'ArchDocComponentMap' }

{ #category : '*ArchDoc-Roassal' }
ArchDocComponentMap >> inspectionDiagram: aBuilder [
	"The map itself: one box per part in declaration order, the arrows between them, and a click
	 to open a part. It is the first tab, because it is the picture the whole altitude is for."

	<inspectorPresentationOrder: 0 title: 'Diagram'>
	^ aBuilder newRoassal
		canvas: (ArchDocComponentRenderer onMap: self) canvas;
		yourself
]
