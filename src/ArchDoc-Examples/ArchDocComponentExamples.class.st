"
I hold the runnable examples of ArchDocComponent.

My `glyphCache` example builds one component over the two subjects of this examples package and one class name the image does not hold, so that a reader clicking it sees both answers the Classes view can give: loaded, and not loaded.

I am also the declaring class those examples name, which is honest — an example's component is declared by the example, not by a real map.
"
Class {
	#name : 'ArchDocComponentExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocComponentExamples class >> glyphCache [
	"A component of three classes, one of which this image does not hold, so that the Classes view
	 shows both answers of its second column."

	<sampleInstance>
	^ ArchDocComponent
		fromTableRow: #( 'Glyph cache'
			#( #ArchDocDeclaredSubject #ArchDocHiddenSubject #ArchDocNoSuchClass )
			'keeps the answer so the question is asked once' )
		declaredIn: self
]
