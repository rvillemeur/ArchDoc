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
	#classInstVars : [
		'keptSubject'
	],
	#category : 'ArchDoc-Examples-Subjects',
	#package : 'ArchDoc-Examples',
	#tag : 'Subjects'
}

{ #category : 'architecture' }
ArchDocBrokenSubject class >> archClassRelations [
	"I declare that I keep one ArchDocDeclaredSubject for the session. I do not: buildWrongKeptSubject
	 fills the slot with a string, which is how the checker's class-side answer is shown to work."

	^ #( #( #keptSubject #cacheOne #ArchDocDeclaredSubject nil ) )
]

{ #category : 'breaking the rules' }
ArchDocBrokenSubject class >> buildWrongKeptSubject [
	"Fill the session cache with the wrong kind of object, so a reader can see the finding the
	 checker answers. A test undoes this with resetKeptSubject."

	keptSubject := 'not a subject at all'
]

{ #category : 'breaking the rules' }
ArchDocBrokenSubject class >> resetKeptSubject [
	"Forget the wrong cache, so the package is quiet again for every other reader."

	keptSubject := nil
]

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
