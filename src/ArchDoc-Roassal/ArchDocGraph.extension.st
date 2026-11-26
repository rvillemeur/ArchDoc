Extension { #name : 'ArchDocGraph' }

{ #category : '*ArchDoc-Roassal' }
ArchDocGraph >> inspectionDiagram: aBuilder [
	"The picture, first of my tabs, with the tables beside it. This method lives in
	 ArchDoc-Roassal: ArchDoc-Core must load into an image that holds no graphics library."

	<inspectorPresentationOrder: 0 title: 'Diagram'>
	^ aBuilder newRoassal
		canvas: (ArchDocGraphRenderer on: self) canvas;
		yourself
]
