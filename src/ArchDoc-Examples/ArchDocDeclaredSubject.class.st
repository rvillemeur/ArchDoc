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
		'ghost'
	],
	#category : 'ArchDoc-Examples',
	#package : 'ArchDoc-Examples'
}

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
ArchDocDeclaredSubject >> warmCache [
	"Built on first use, like the glyph caches of a font: its absence says nothing about the
	 declaration."

	<archCache: #one to: #ArchDocDeclaredSubject>
	^ warmCache ifNil: [ warmCache := self class new ]
]
