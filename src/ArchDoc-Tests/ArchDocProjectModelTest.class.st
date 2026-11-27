Class {
	#name : 'ArchDocProjectModelTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocProjectModelTest >> testAnArrowAPackageManifestForbidsIsMarkedForbidden [
	"The manifest of ArchDoc-Examples forbids ArchDoc-Core on purpose, which is the fixture the
	 checker's own test reads. At package altitude that one declaration marks the whole arrow."

	| project forbidden |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	forbidden := project edges detect: [ :each |
		each source name = #'ArchDoc-Examples'
			and: [ each target name = #'ArchDoc-Core' ] ].
	self assert: forbidden kind equals: #forbidden.
	self assert: forbidden isForbidden.
	self deny: forbidden isUse
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testEveryNodeAndEveryArrowNamesAPackageByItsOwnName [
	"A node of this graph is a package and not a class, and a reader meets it in a box and in a
	 table. Both ask the node what it is called, so neither says 'a Package(ArchDoc-Core)'."

	| project graph |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	graph := project graph.
	self
		assert: (graph describe: (project packageNamed: 'ArchDoc-Core'))
		equals: 'ArchDoc-Core'.
	self assert: (graph edges allSatisfy: [ :each |
		each sourceDescription = each source name asString
			and: [ each targetDescription = each target name asString ] ])
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testTheDiagramDrawsWhatTheProjectDeclaresOutsideItselfAndNotWhatItMerelyUses [
	"Every package of a project reaches Kernel and the collections, so a diagram holding
	 everything the code touches says nothing about where the project sits. A declaration is the
	 design and a use is the wiring, so an outside package is drawn when a class of the project
	 declares a holding into it, and left to the tables otherwise."

	| project nodes outside |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	nodes := project graph nodes.
	self assert: (project packages allSatisfy: [ :each | nodes includes: each ]).
	self assert: (project edges anySatisfy: [ :each | each target name = 'Kernel' ]).
	self deny: (nodes anySatisfy: [ :each | each name = 'Kernel' ]).
	outside := nodes reject: [ :each | project packages includes: each ].
	self assert: (outside allSatisfy: [ :each |
		project drawnEdges anySatisfy: [ :edge |
			edge target = each and: [ edge isUse not ] ] ])
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testTheForbiddenArrowsAreExactlyWhatTheCheckerReports [
	"One rule, read two ways: the project marks an arrow, and the checker reports a class
	 reference. Both read the manifest, and this test holds them to the same answer, so a red
	 line in the picture is always a finding and a finding is always a red line."

	| project drawn reported |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	drawn := (project edges select: [ :each | each isForbidden ]) collect: [ :each |
		each source name -> each target name ].
	reported := Set new.
	project packages do: [ :package |
		(ArchDocChecker onPackage: package) forbiddenDependencies do: [ :finding |
			finding subject target package ifNotNil: [ :target |
				reported add: package name -> target name ] ] ].
	self assert: drawn asSet equals: reported
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testTheOmittedArrowsAreTheOnesTheDiagramDoesNotDraw [
	"The model holds the rule for what is drawn, so it answers what is left out as well: a view
	 that worked the difference out itself would hold the rule a second time."

	| project drawn omitted |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	drawn := project drawnEdges.
	omitted := project omittedEdges.
	self assert: drawn size + omitted size equals: project edges size.
	self assert: (omitted allSatisfy: [ :each | (drawn includes: each) not ]).
	self assert: (omitted allSatisfy: [ :each | each isUse ]).
	self deny: omitted isEmpty
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testThePackagesViewCountsTheClassesOfEachPackageAndTheArrowsItSends [
	"A reader opening a project wants the size of each package and how far it reaches before the
	 picture. The columns are counted from the project itself, so they cannot disagree with it."

	| project presenter core row |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	presenter := ArchDocArtefactTest new presenterOf: #inspectionPackages: on: project.
	core := project packageNamed: 'ArchDoc-Core'.
	row := presenter items detect: [ :each | each = core ].
	self assert: ((presenter columns second evaluation value: row) asString)
		equals: core definedClasses size printString.
	self assert: ((presenter columns third evaluation value: row) asString)
		equals: (project edges count: [ :each |
			each source = core and: [ each isUse not ] ]) printString.
	self assert: ((presenter columns fourth evaluation value: row) asString)
		equals: (project edges count: [ :each |
			each source = core and: [ each isUse ] ]) printString
]

{ #category : 'tests' }
ArchDocProjectModelTest >> testTheRoassalPackageReachesTheCoreAndTheCoreReachesNothingOfIt [
	"The drawing package names the core, because it draws what the core computes; the core names
	 no class of it, which is the rule that lets ArchDoc-Core load with no graphics library. The
	 arrow says how many class references it stands for."

	| project core roassal forward backward |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	core := project packageNamed: 'ArchDoc-Core'.
	roassal := project packageNamed: 'ArchDoc-Roassal'.
	forward := project edges select: [ :each |
		each source = roassal and: [ each target = core ] ].
	backward := project edges select: [ :each |
		each source = core and: [ each target = roassal ] ].
	self assert: forward size equals: 1.
	self assert: backward isEmpty.
	self assert: forward anyOne count > 1
]
