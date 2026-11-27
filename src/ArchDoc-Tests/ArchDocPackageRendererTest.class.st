Class {
	#name : 'ArchDocPackageRendererTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocPackageRendererTest >> testABoxNamesThePackageAndHowManyClassesItHolds [
	"A package box answers the first question asked of a project picture: how big is that
	 package. The name alone leaves a reader counting classes in the browser."

	| project renderer core label |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	renderer := ArchDocPackageRenderer onProject: project.
	core := project packageNamed: 'ArchDoc-Core'.
	label := renderer labelFor: core.
	self assert: (label beginsWith: 'ArchDoc-Core').
	self assert: (label includesSubstring: core definedClasses size printString)
]

{ #category : 'tests' }
ArchDocPackageRendererTest >> testAPackageOfTheProjectIsFilledAndOneItDependsOnIsLeftWhite [
	"The boundary of the project is read off the picture: its own packages are filled, and a
	 package it declares a holding into, which lives elsewhere, is a visitor."

	| project renderer outside |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	renderer := ArchDocPackageRenderer onProject: project.
	outside := project graph nodes reject: [ :each |
		project packages includes: each ].
	self assert: (project packages allSatisfy: [ :each |
		(renderer fillFor: each) = renderer residentColor ]).
	self deny: outside isEmpty.
	self assert: (outside allSatisfy: [ :each |
		(renderer fillFor: each) = renderer visitorColor ])
]

{ #category : 'tests' }
ArchDocPackageRendererTest >> testTheOmissionsViewNamesEveryOutsidePackageTheDiagramLeavesOut [
	"The picture drops a use pointing out of the project, so the renderer says what it dropped.
	 A reader who wonders where the collections went reads it there rather than mistrusting the
	 diagram."

	| project renderer presenter dropped |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	renderer := ArchDocPackageRenderer onProject: project.
	presenter := ArchDocArtefactTest new
		presenterOf: #inspectionOmissions:
		on: renderer.
	dropped := project edges reject: [ :each |
		project drawnEdges includes: each ].
	self deny: dropped isEmpty.
	self assert: presenter items size equals: dropped size.
	self assert: (presenter items allSatisfy: [ :each |
		(renderer canvas nodes anySatisfy: [ :node | node model = each target ]) not ])
]

{ #category : 'tests' }
ArchDocPackageRendererTest >> testThePackageInFocusIsFilledApartFromTheOtherPackagesOfTheProject [
	"A reader opening one package wants to see where that package sits. Every package of the
	 project is a resident, so the one asked about carries a fill of its own, named in the
	 legend like every other style."

	| project core renderer |
	project := ArchDocProjectModel onPrefix: 'ArchDoc'.
	core := project packageNamed: 'ArchDoc-Core'.
	renderer := ArchDocPackageRenderer onProject: project focusing: core.
	self assert: (renderer fillFor: core) equals: renderer focusColor.
	self assert: renderer focusColor ~= renderer residentColor.
	self assert: ((project packages reject: [ :each | each = core ]) allSatisfy: [ :each |
		(renderer fillFor: each) = renderer residentColor ]).
	self assert: (renderer legendRows anySatisfy: [ :each | each first = 'in focus' ])
]
