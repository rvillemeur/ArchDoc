"
I am the gate on the artefacts every class of `ArchDoc-Core` must carry: a class comment, at least one inspector view, a view that takes the presenter builder, and a view that builds without raising.

I also run every class-side `<sampleInstance>` example of `ArchDoc-Examples`, since an example that no longer runs is worse than none: a reader clicks it from the browser and meets a debugger.

I state the rules once, over the classes the image holds, rather than once per class, so a class added later is covered the moment it is in the package.
"
Class {
	#name : 'ArchDocArtefactTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'accessing' }
ArchDocArtefactTest >> documentedClasses [
	"Both code packages. The Roassal package carries one class, and it is held to the same rules.
	 A package manifest is left out: it is Pharo's own declaration object, it has no instances
	 and nothing inspects it."

	^ ((#( 'ArchDoc-Core' 'ArchDoc-Roassal' ) flatCollect: [ :each |
		(Smalltalk packageOrganizer packageNamed: each) definedClasses ])
		reject: [ :each | each inheritsFrom: PackageManifest ]) asArray
]

{ #category : 'accessing' }
ArchDocArtefactTest >> presenterOf: aSelector on: anObject [
	"Build one view the way the inspector builds it, through a context that carries the builder."

	| context |
	context := StInspectionContext new
		inspectedObject: anObject;
		methodSelector: aSelector;
		yourself.
	^ context newInspectionPresenterOnApplication: SpApplication new
]

{ #category : 'accessing' }
ArchDocArtefactTest >> sampleInstances [
	"Every object the class-side <sampleInstance> examples of ArchDoc-Examples answer, run now,
	 so that an example which no longer runs fails here rather than under a reader's click. An
	 example named open… is left out: a suite may not open windows."

	| found |
	found := OrderedCollection new.
	(Smalltalk packageOrganizer packageNamed: 'ArchDoc-Examples') definedClasses do: [ :each |
		each class methods do: [ :method |
			((method pragmas anySatisfy: [ :pragma | pragma selector = #sampleInstance ])
				and: [ (ArchDocChecker opensAWindow: method selector) not ])
					ifTrue: [ found add: (each perform: method selector) ] ] ].
	^ found asArray
]

{ #category : 'tests' }
ArchDocArtefactTest >> testEveryClassHasAClassComment [
	"A class with no comment tells a reader nothing about why it exists, which is the whole point
	 of this library."

	self documentedClasses do: [ :each |
		self
			deny: each comment isEmptyOrNil
			description: each name , ' has no class comment' ]
]

{ #category : 'tests' }
ArchDocArtefactTest >> testEveryClassHasASampleInstanceExample [
	"A reader meets these classes from the browser, so each one must have an object to click."

	| classes |
	classes := self sampleInstances collect: [ :each | each class ].
	self documentedClasses do: [ :each |
		self
			assert: (classes includes: each)
			description: each name , ' has no <sampleInstance> example' ]
]

{ #category : 'tests' }
ArchDocArtefactTest >> testEveryClassHasAtLeastOneInspectorView [
	self documentedClasses do: [ :each |
		self
			deny: (self viewMethodsOf: each) isEmpty
			description: each name , ' carries no inspector view' ]
]

{ #category : 'tests' }
ArchDocArtefactTest >> testEveryViewBuildsOnItsSampleAndEveryColumnReads [
	"A table column's block runs only when a row is drawn, so the test sends it by hand: a view
	 that builds but whose columns raise is still broken for the reader."

	self sampleInstances do: [ :subject |
		(self viewMethodsOf: subject class) do: [ :method |
			| presenter |
			presenter := self presenterOf: method selector on: subject.
			self deny: presenter isNil.
			(presenter isKindOf: SpTablePresenter) ifTrue: [
				presenter items do: [ :item |
					presenter columns do: [ :column |
						self deny: (column evaluation value: item) isNil ] ] ] ] ]
]

{ #category : 'tests' }
ArchDocArtefactTest >> testEveryViewTakesThePresenterBuilder [
	"Since Pharo 13 the inspector refuses a zero-argument view at the moment a reader opens the
	 object, and decides by the last character of the selector."

	self documentedClasses do: [ :aClass |
		(self viewMethodsOf: aClass) do: [ :each |
			self
				assert: each selector last = $:
				description: aClass name , '>>' , each selector , ' takes no builder' ] ]
]

{ #category : 'accessing' }
ArchDocArtefactTest >> viewMethodsOf: aClass [
	^ aClass methods select: [ :each |
		each pragmas anySatisfy: [ :pragma |
			pragma selector = #inspectorPresentationOrder:title: ] ]
]
