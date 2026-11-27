"
I hold the examples of `ArchDocGraphRenderer`, and the two that open a window.

`openClassDiagramOfTheExamplesPackage` and `openObjectGraphOfASubject` open a Roassal window on the spot: they are the one-click answer to ""what does this look like"". The others answer a renderer, so a reader can inspect it and read the legend beside the picture.

I am the only examples class that needs `ArchDoc-Roassal` loaded.
"
Class {
	#name : 'ArchDocRendererExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocRendererExamples class >> componentDiagram [
	"The component diagram of the example map: three parts in declaration order, the backward
	 edges under the row."

	<sampleInstance>
	^ ArchDocComponentRenderer onMap: ArchDocExampleMap new
]

{ #category : 'examples' }
ArchDocRendererExamples class >> openClassDiagramOfTheExamplesPackage [
	"Open the picture in a window, which is the one-click answer to what this looks like."

	<sampleInstance>
	^ self rendererOfTheExamplesPackage canvas open
]

{ #category : 'examples' }
ArchDocRendererExamples class >> openObjectGraphOfASubject [
	"The live walk as a picture: one child, one in the collection, and a cache nobody built."

	<sampleInstance>
	^ (ArchDocGraphRenderer on:
		ArchDocModelExamples objectGraphOfASubjectHoldingTwoOthers graph) canvas open
]

{ #category : 'examples' }
ArchDocRendererExamples class >> projectDiagram [
	"The package altitude of this library drawn: four packages, the arrows between them, and the
	 one arrow the manifest of the examples package forbids, in red."

	<sampleInstance>
	^ ArchDocPackageRenderer onProject: (ArchDocProjectModel onPrefix: 'ArchDoc')
]

{ #category : 'examples' }
ArchDocRendererExamples class >> rendererOfTheExamplesPackage [
	"A renderer over the class diagram of ArchDoc-Examples: holdings, caches and uses at once."

	<sampleInstance>
	^ ArchDocGraphRenderer on: ArchDocModelExamples graphOfTheExamplesPackage
]
