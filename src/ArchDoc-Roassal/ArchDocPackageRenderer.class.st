"
I draw a project at package altitude: one box per package, named with how many classes it
holds, and one line per arrow between two of them.

I keep the force layout of my superclass. A project holds cycles between its own packages
and a layered layout raises on them, so the picture is pushed into shape rather than
ordered. A component map is the altitude where order is declared and drawn.

I keep the project as well as its graph, because the question a reader asks of this picture
is what it does not show: the references out of the project that no declaration states. My
*Left out* tab answers it.

ArchDocPackageRenderer onProject: (ArchDocProjectModel onPrefix: 'ArchDoc')
"
Class {
	#name : 'ArchDocPackageRenderer',
	#superclass : 'ArchDocGraphRenderer',
	#instVars : [
		'project',
		'focus'
	],
	#category : 'ArchDoc-Roassal',
	#package : 'ArchDoc-Roassal'
}

{ #category : 'instance creation' }
ArchDocPackageRenderer class >> onProject: anArchDocProjectModel [
	"I keep the project as well as its graph: a reader asks me what the picture leaves out, and
	 that is a question about the project and not about the graph it answered."

	^ (self on: anArchDocProjectModel graph)
		setProject: anArchDocProjectModel;
		yourself
]

{ #category : 'instance creation' }
ArchDocPackageRenderer class >> onProject: anArchDocProjectModel focusing: aPackage [
	"The project drawn for a reader who came from one of its packages: that package carries a
	 fill of its own, so the picture answers where it sits."

	^ (self onProject: anArchDocProjectModel)
		setFocus: aPackage;
		yourself
]

{ #category : 'rendering' }
ArchDocPackageRenderer >> fillFor: aNode [
	"The package the reader came from first, then the residents and the visitors as my
	 superclass fills them."

	^ aNode = focus
		ifTrue: [ self focusColor ]
		ifFalse: [ super fillFor: aNode ]
]

{ #category : 'accessing' }
ArchDocPackageRenderer >> focus [
	"The package the reader came from, drawn apart from the rest, or nothing when the whole
	 project was asked for."

	^ focus
]

{ #category : 'styles' }
ArchDocPackageRenderer >> focusColor [
	"The fill of the package the reader came from. Named here and nowhere else, so the legend
	 and the boxes cannot disagree."

	^ Color r: 0.99 g: 0.9 b: 0.6
]

{ #category : 'inspector' }
ArchDocPackageRenderer >> inspectionOmissions: aBuilder [
	"What the picture leaves out: every reference out of the project that no declaration states.
	 It is the wiring — the kernel, the collections, the widgets — and a diagram holding it
	 answers no question, but a reader must be told it was dropped rather than guess. The project
	 answers which arrows those are; this tab only writes them down."

	<inspectorPresentationOrder: 2 title: 'Left out'>
	^ aBuilder newTable
		items: project omittedEdges;
		addColumn: ((SpStringTableColumn title: 'Reaches from' evaluated: [ :each |
			each sourceDescription ]) width: 240);
		addColumn: ((SpStringTableColumn title: 'To' evaluated: [ :each |
			each targetDescription ]) width: 240);
		addColumn: (SpStringTableColumn title: 'Class references' evaluated: [ :each |
			each count printString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocPackageRenderer >> labelFor: aNode [
	"A package box names the package and how many classes it holds: the first question asked of
	 a project picture is which of these packages is the big one. The name is asked of the graph,
	 as my superclass asks it, so one altitude cannot call a node what another does not."

	^ (graph describe: aNode) , ' ('
		, aNode definedClasses size printString , ')'
]

{ #category : 'styles' }
ArchDocPackageRenderer >> legendRows [
	"My superclass's rows, and the one fill of my own, which is there only when a reader came
	 from a package."

	^ focus
		ifNil: [ super legendRows ]
		ifNotNil: [ super legendRows , { { 'in focus'. 'filled box'. self focusColor } } ]
]

{ #category : 'accessing' }
ArchDocPackageRenderer >> project [
	"The project I draw."

	<archRelation: #one to: #ArchDocProjectModel>
	^ project
]

{ #category : 'private' }
ArchDocPackageRenderer >> setFocus: aPackage [
	focus := aPackage
]

{ #category : 'private' }
ArchDocPackageRenderer >> setProject: anArchDocProjectModel [
	project := anArchDocProjectModel
]
