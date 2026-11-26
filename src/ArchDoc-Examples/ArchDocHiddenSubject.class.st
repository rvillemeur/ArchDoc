"
I am a class that holds other objects and exposes none of them. My callers ask me derived questions — `name`, `outlineAt:` — and never for the objects I read them from.

I exist because real classes are built this way. `VGFontFace` in VectorGraphics holds a glyph source, a metadata record and a cache of outlines, and answers `familyName`, `styleName` and `outlineOfGlyphAt:` instead. Documentation must not widen such a class's public API, so a class that exposes no accessor declares its relations in a class-side table:

```
ArchDocHiddenSubject class >> archRelations
	^ #( #( #source #one #ArchDocDeclaredSubject nil ) ... )
```

Each row is `role`, multiplicity, target, opposite. The multiplicity is one of `#one`, `#many`, `#cacheOne` and `#cacheMany`, so one shape of row states a structural holding and a cache alike. The opposite is `nil` when the declaration names none.

A table is read by `ArchDocModel` exactly as a pragma is, and the relations it yields are the same objects.
"
Class {
	#name : 'ArchDocHiddenSubject',
	#superclass : 'Object',
	#instVars : [
		'source',
		'metadata',
		'outlines'
	],
	#category : 'ArchDoc-Examples-Subjects',
	#package : 'ArchDoc-Examples',
	#tag : 'Subjects'
}

{ #category : 'declarations' }
ArchDocHiddenSubject class >> archRelations [
	"My relations, declared here because I expose no accessor to carry a pragma. Each row is the
	 role, the multiplicity, the target and the opposite, and nil names no opposite."

	^ #(
		#( #source #one #ArchDocDeclaredSubject nil )
		#( #metadata #one #ArchDocDeclaredSubject nil )
		#( #outlines #cacheMany #ArchDocDeclaredSubject nil ) )
]

{ #category : 'initialization' }
ArchDocHiddenSubject >> initialize [
	"My slots are written here and nowhere else, as VGFontFace writes its own: a reader of my
	 API cannot reach what I hold, which is why my relations are declared in a class-side table."

	super initialize.
	source := ArchDocDeclaredSubject new.
	metadata := ArchDocDeclaredSubject new
]

{ #category : 'accessing' }
ArchDocHiddenSubject >> outlineCount [
	"Answers a number, never the objects: the cache is built on first use, as VGFontFace builds
	 its glyph outlines, and nothing of mine hands out what I hold."

	outlines ifNil: [ outlines := Array with: source with: metadata ].
	^ outlines size
]
