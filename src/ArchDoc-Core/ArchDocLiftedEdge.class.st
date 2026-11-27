"
I am one arrow between two components, standing for every class-level edge that runs between their
classes.

My kind is the strongest kind of those edges — a holding over a cache over a use — because a reader
asking how two parts of a project relate wants the strongest fact first. My count says how many
class-level edges I stand for, and my roles keep the declared roles that made me, so a reader who
clicks me is told which accessors the arrow came from.

An edge whose two classes belong to the same component is not lifted at all: that is how the part is
built, and it is drawn at class altitude instead.

```
ArchDocExampleMap new edges
```
"
Class {
	#name : 'ArchDocLiftedEdge',
	#superclass : 'ArchDocEdge',
	#instVars : [
		'count',
		'roles'
	],
	#category : 'ArchDoc-Core-Graphs',
	#package : 'ArchDoc-Core',
	#tag : 'Graphs'
}

{ #category : 'instance creation' }
ArchDocLiftedEdge class >> from: aComponent to: anotherComponent over: aCollection [
	"aCollection holds every class-level edge between the two components. The strongest kind of
	 those edges is the kind of mine, because a pair of parts that hold each other is read as a
	 holding however many references they also make."

	^ self new
		setSource: aComponent
		target: anotherComponent
		kind: (self strongestKindOf: aCollection)
		label: (aCollection size printString , ' class edges');
		setCount: aCollection size
			roles: ((aCollection collect: [ :each | each label ])
				reject: [ :each | each isEmptyOrNil ]) asArray;
		yourself
]

{ #category : 'instance creation' }
ArchDocLiftedEdge class >> strongestKindOf: aCollection [
	"A holding over a cache over a use: the strongest fact a reader can be told about the pair."

	^ #( #holding #cache #use )
		detect: [ :kind | aCollection anySatisfy: [ :each | each kind = kind ] ]
		ifNone: [ #use ]
]

{ #category : 'accessing' }
ArchDocLiftedEdge >> count [
	"How many class-level edges I stand for."

	^ count
]

{ #category : 'inspector' }
ArchDocLiftedEdge >> inspectionLiftedArrow: aBuilder [
	"What a reader clicking a component arrow asks: which parts, which kind, how many class edges
	 under it, and which roles stated them."

	<inspectorPresentationOrder: 1 title: 'Lifted arrow'>
	^ aBuilder newTable
		items: {
				'from' -> self sourceDescription.
				'to' -> self targetDescription.
				'kind' -> self kind.
				'class edges' -> self count.
				'roles' -> (self roles
					ifEmpty: [ 'none: inferred from references' ]
					ifNotEmpty: [ :some | ', ' join: some asSortedCollection ]) };
		addColumn: ((SpStringTableColumn title: 'What' evaluated: [ :each | each key ]) width: 110);
		addColumn: (SpStringTableColumn title: 'Says' evaluated: [ :each | each value asString ]);
		yourself
]

{ #category : 'accessing' }
ArchDocLiftedEdge >> roles [
	"The declared roles that made me, an inferred use having none."

	^ roles
]

{ #category : 'initialization' }
ArchDocLiftedEdge >> setCount: anInteger roles: anArray [
	count := anInteger.
	roles := anArray
]
