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
		'project'
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

{ #category : 'inspector' }
ArchDocPackageRenderer >> inspectionOmissions: aBuilder [
	"What the picture leaves out: every reference out of the project that no declaration states.
	 It is the wiring — the kernel, the collections, the widgets — and a diagram holding it
	 answers no question, but a reader must be told it was dropped rather than guess."

	<inspectorPresentationOrder: 2 title: 'Left out'>
	^ aBuilder newTable
		items: (project edges reject: [ :each |
			project drawnEdges includes: each ]);
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
	 a project picture is which of these packages is the big one."

	^ (ArchDocGraph describe: aNode) , ' ('
		, aNode definedClasses size printString , ')'
]

{ #category : 'accessing' }
ArchDocPackageRenderer >> project [
	"The project I draw."

	<archRelation: #one to: #ArchDocProjectModel>
	^ project
]

{ #category : 'private' }
ArchDocPackageRenderer >> setProject: anArchDocProjectModel [
	project := anArchDocProjectModel
]
