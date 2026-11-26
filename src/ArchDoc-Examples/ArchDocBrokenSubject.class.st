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
		'neighbour',
		'neighbours'
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
ArchDocBrokenSubject class >> raisesOnPurpose [
	"An example that cannot run: a font file the image does not have, a device that is not
	 there. A reader of a package meets these, so the checker has to report one and carry on.
	 The second pragma says this one is a fixture, which is what keeps the artefact gate of this
	 project from reading it as a real example of mine."

	<sampleInstance>
	<archDocDeliberatelyBroken>
	^ self error: 'this example cannot run in this image'
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
	neighbour := self wrongKindOfNeighbour.
	neighbours := Array with: ArchDocDeclaredSubject new with: nil
]

{ #category : 'accessing' }
ArchDocBrokenSubject >> neighbour [
	"My sample instance holds a String here, against this declaration, which is the finding."

	<archRelation: #one to: #ArchDocDeclaredSubject>
	^ neighbour
]

{ #category : 'accessing' }
ArchDocBrokenSubject >> neighbours [
	"A structural holding of many with a nil among its elements, which is the finding: nothing
	 asked a question here, so nothing is remembering that the answer was nothing."

	<archRelation: #many to: #ArchDocDeclaredSubject>
	^ neighbours
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
