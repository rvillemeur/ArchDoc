"
I declare things that are wrong, on purpose, so that `ArchDocChecker` has something to report and its tests can see a real finding rather than a contrived one.

What is wrong with me:

- `partner` declares the opposite role `#nobody`, which `ArchDocDeclaredSubject` does not declare. A declared opposite that the target does not answer is a lie about the shape of the graph.
- `neighbour` declares one `ArchDocDeclaredSubject`, and my sample instance holds a `String` there instead. A declaration the live object contradicts is worse than no declaration.

Read me with `ArchDocCheckerTest`. Nothing but the checker and its tests should ever send to me.
"
Class {
	#name : 'ArchDocBrokenSubject',
	#superclass : 'Object',
	#instVars : [
		'partner',
		'neighbour'
	],
	#category : 'ArchDoc-Examples-Subjects',
	#package : 'ArchDoc-Examples',
	#tag : 'Subjects'
}

{ #category : 'initialization' }
ArchDocBrokenSubject >> initialize [
	super initialize.
	partner := ArchDocDeclaredSubject new.
	neighbour := self wrongKindOfNeighbour
]

{ #category : 'accessing' }
ArchDocBrokenSubject >> neighbour [
	"My sample instance holds a String here, against this declaration, which is the finding."

	<archRelation: #one to: #ArchDocDeclaredSubject>
	^ neighbour
]

{ #category : 'accessing' }
ArchDocBrokenSubject >> partner [
	"The opposite named here is declared by nothing, which is the finding."

	<archRelation: #one to: #ArchDocDeclaredSubject opposite: #nobody>
	^ partner
]

{ #category : 'private' }
ArchDocBrokenSubject >> wrongKindOfNeighbour [
	"Anything that is not an ArchDocDeclaredSubject will do: the point is that my declaration
	 promises one and I hold this instead."

	^ 'not a subject at all'
]
