"
I hold the examples of `ArchDocRelation`: one declaration of each of the three kinds ArchDoc reads, each built from a real pragma on a real accessor of `ArchDocDeclaredSubject`.

Every example is class-side, takes no argument, rebuilds its object on every call and asserts nothing. Click the icon in the browser to open one in the inspector.
"
Class {
	#name : 'ArchDocRelationExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocRelationExamples class >> cacheRelation [
	"A holding built on first use. A diagram draws it apart from a structural one, because an
	 object that has not built it yet contradicts nothing."

	<sampleInstance>
	^ ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #warmCache
]

{ #category : 'examples' }
ArchDocRelationExamples class >> toManyRelation [
	"A holding of several objects, naming no opposite."

	<sampleInstance>
	^ ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #children
]

{ #category : 'examples' }
ArchDocRelationExamples class >> toOneRelationWithAnOpposite [
	"The commonest declaration: one object holds one other, which holds it back under a named
	 role."

	<sampleInstance>
	^ ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #child
]

{ #category : 'examples' }
ArchDocRelationExamples class >> undeclaredAccessorAnswersNothing [
	"The degenerate case: an accessor carrying no declaration answers no relation at all, so
	 this example opens an inspector on nil."

	<sampleInstance>
	^ ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #scratch
]
