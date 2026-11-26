"
I am a small class that declares its relations the way a documented project declares them. I exist so that the examples and the tests of ArchDoc read real pragmas on real compiled accessors, rather than pragmas built by hand.

My four accessors cover every case the reader of a declaration meets:

- `child` — a to-one holding that names its opposite;
- `children` — a to-many holding with no opposite;
- `warmCache` — a holding built on first use, declared as a cache;
- `scratch` — an accessor carrying no declaration at all, which is what most methods of a real project look like.

I point at myself in all three declarations, so a graph built from me is a tree of my own kind and needs no second class to be legible.
"
Class {
	#name : 'ArchDocDeclaredSubject',
	#superclass : 'Object',
	#instVars : [
		'child',
		'children',
		'warmCache',
		'scratch',
		'ghost',
		'warmCacheWithOpposite',
		'answers',
		'stamp'
	],
	#classInstVars : [
		'defaultSubject'
	],
	#category : 'ArchDoc-Examples',
	#package : 'ArchDoc-Examples'
}

{ #category : 'architecture' }
ArchDocDeclaredSubject class >> archClassRelations [
	"What I hold myself, rather than what my instances hold. One row, the cache a session keeps,
	 shaped exactly like a row of archRelations."

	^ #( #( #defaultSubject #cacheOne #ArchDocDeclaredSubject nil ) )
]

{ #category : 'accessing' }
ArchDocDeclaredSubject class >> default [
	"The kept subject, built on first use, the shape of every session-long cache."

	^ defaultSubject ifNil: [ defaultSubject := self new ]
]

{ #category : 'initialization' }
ArchDocDeclaredSubject class >> resetDefault [
	"Forget the kept subject, so a test can hold that it is built once and a reader starts from
	 an empty cache."

	defaultSubject := nil
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> answerFor: aKey [
	"Fill the cache for one question. Odd keys answer a subject, even keys answer nothing, which
	 is the shape of a glyph atlas: a space inks nothing, and the nil is remembered so the space
	 is looked at once and never again."

	^ self answers
		at: aKey
		ifAbsentPut: [ aKey odd ifTrue: [ self class new ] ifFalse: [ nil ] ]
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> answers [
	"The answers already worked out, by the question that was asked. A cache of many, so a
	 remembered nothing is one of the answers and not a fault."

	<archCache: #many to: #ArchDocDeclaredSubject>
	^ answers ifNil: [ answers := Dictionary new ]
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> child [
	<archRelation: #one to: #ArchDocDeclaredSubject opposite: #children>
	^ child
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> child: aSubject [
	child := aSubject
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> children [
	<archRelation: #many to: #ArchDocDeclaredSubject>
	^ children ifNil: [ children := OrderedCollection new ]
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> ghost [
	"A declaration whose target no image holds. The checker must report it, so something has to
	 declare it on purpose."

	<archRelation: #one to: #ArchDocNoSuchClassExists>
	^ ghost
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> scratch [
	"An accessor carrying no declaration: an instance variable that is no part of the
	 architecture. The model meets one of these on nearly every method it reads."

	^ scratch
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> stamp [
	"A holding of a class from another package: the diagram draws such a target as a node too,
	 and marks it a visitor, so a reader sees where the package stops."

	<archRelation: #one to: #Date>
	^ stamp ifNil: [ stamp := Date today ]
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> warmCache [
	"Built on first use, like the glyph caches of a font: its absence says nothing about the
	 declaration."

	<archCache: #one to: #ArchDocDeclaredSubject>
	^ warmCache ifNil: [ warmCache := self class new ]
]

{ #category : 'accessing' }
ArchDocDeclaredSubject >> warmCacheWithOpposite [
	"A cache that points back: built on first use, and the object it answers reaches me again
	 under child. This is the shape of an adapter a subject builds for another library."

	<archCache: #one to: #ArchDocDeclaredSubject opposite: #child>
	^ warmCacheWithOpposite ifNil: [
		warmCacheWithOpposite := self class new
			child: self;
			yourself ]
]
