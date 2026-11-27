Extension { #name : 'ArchDocComponent' }

{ #category : '*ArchDoc-Roassal' }
ArchDocComponent >> inspectionDiagram: aBuilder [
	"My own classes and what holds what among them: the altitude below the map, so a reader who
	 clicked a box in the map diagram lands on the picture of its inside."

	<inspectorPresentationOrder: 1 title: 'Diagram'>
	^ aBuilder newRoassal
		canvas: (ArchDocGraphRenderer on: self graph) canvas;
		yourself
]
