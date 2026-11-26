Extension { #name : 'ArchDocObjectGraph' }

{ #category : '*ArchDoc-Roassal' }
ArchDocObjectGraph >> inspectionDiagram: aBuilder [
	"The live graph as a picture. It is built by walking my root again, so what a reader sees is
	 the object as it stands now and not as it stood when the tab was first opened."

	<inspectorPresentationOrder: 0 title: 'Diagram'>
	^ aBuilder newRoassal
		canvas: (ArchDocGraphRenderer on: self graph) canvas;
		yourself
]
