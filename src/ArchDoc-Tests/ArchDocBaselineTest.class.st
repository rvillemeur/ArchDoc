"
I hold the agreement between what this image contains and what `BaselineOfArchDoc` declares.

Three facts:

- the baseline names every package of the project, and no package that does not exist;
- `Roassal` is the only project outside this repository that a load can reach, so nothing can be added without saying which group needs it;
- `ArchDoc-Core` names no class of `ArchDoc-Roassal`, which is what lets the core load into a headless image.

The third is a real architecture rule, checked against the references the code makes rather than against the declaration, and `ArchDocChecker` is what answers it — this library checks itself with itself.
"
Class {
	#name : 'ArchDocBaselineTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocBaselineTest >> testEachGroupLoadsWhatItsNameSays [
	"The core group is the headless one: one package, no drawing library behind it. The others
	 are named here so a package cannot be added to a group without saying so."

	| groups |
	groups := Dictionary new.
	BaselineOfArchDoc project version groups do: [ :each |
		groups at: each name put: each includes asSortedCollection asArray ].
	self assert: (groups at: 'core') equals: #( 'ArchDoc-Core' ).
	self assert: (groups at: 'default') equals: #( 'ArchDoc-Core' 'ArchDoc-Roassal' ).
	self assert: (groups at: 'examples') equals: #( 'ArchDoc-Examples' ).
	self assert: (groups at: 'tests') equals: #( 'ArchDoc-Tests' )
]

{ #category : 'tests' }
ArchDocBaselineTest >> testTheBaselineNamesEveryPackageOfTheProject [
	| declared present |
	declared := (BaselineOfArchDoc project version packages collect: [ :each | each name ])
		asSortedCollection asArray.
	present := (Smalltalk packageOrganizer packages
		select: [ :each | each name beginsWith: 'ArchDoc-' ]
		thenCollect: [ :each | each name asString ]) asSortedCollection asArray.
	self assert: declared equals: present
]

{ #category : 'tests' }
ArchDocBaselineTest >> testTheBaselineNamesOnlyRoassalAsAnExternalProject [
	"One project outside this repository, needed by one package. Everything else this library
	 uses — pragmas, slots, compiled methods, Spec tables — Pharo itself answers."

	self
		assert: (BaselineOfArchDoc project version projects collect: [ :each | each name ])
			asSortedCollection asArray
		equals: #( 'Roassal' )
]

{ #category : 'tests' }
ArchDocBaselineTest >> testTheCoreNamesNoGraphicsLibrary [
	"The rule that lets the core load where Roassal is absent, stated in the core's own manifest
	 and checked by this library against the references the code makes. Spec is not forbidden:
	 every Pharo image carries it, because the inspector is built on it."

	| checker |
	checker := ArchDocChecker onPackageNamed: 'ArchDoc-Core'.
	self assert: checker forbiddenPackageNames asSortedCollection asArray
		equals: #( 'ArchDoc-Roassal' 'Roassal*' ).
	self
		assertEmpty: (checker forbiddenDependencies collect: [ :each | each explanation ])
]
