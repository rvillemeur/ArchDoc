"
I am the map of this examples package, and I am broken on purpose, so that the checker's own tests have one finding of each kind to read.

Three faults are declared deliberately: `ArchDocBrokenSubject` is named by both my components, which makes it ambiguous; `ArchDocNoSuchClass` is a name no image holds; and `ArchDocCheckerExamples` is named by neither component, which leaves it unmapped. Do not repair them — a test asserts each one, the way `ArchDocBrokenSubject` carries the declarations that cannot resolve.

My components are named after what the two groups of classes in this package do, not after the route of a real project: this package documents ArchDoc, so there is no route through it.
"
Class {
	#name : 'ArchDocExampleMap',
	#superclass : 'ArchDocComponentMap',
	#category : 'ArchDoc-Examples-Subjects',
	#package : 'ArchDoc-Examples',
	#tag : 'Subjects'
}

{ #category : 'declaring' }
ArchDocExampleMap class >> components [
	"A map of this examples package, in three parts, so that the lifted edges have something to
	 say: the holders hold the subject, and the examples only reference it.

	 It is also broken on purpose in three ways, so that the checker's own test has one finding of
	 each kind to read: ArchDocBrokenSubject is named twice, ArchDocNoSuchClass is a name no image
	 holds, and ArchDocCheckerExamples is named nowhere."

	<archDocDeliberatelyBroken>
	^ {
		#( 'Subjects'
			#( #ArchDocDeclaredSubject )
			'the class whose declarations every other test reads' ) .
		#( 'Holders'
			#( #ArchDocHiddenSubject #ArchDocBrokenSubject )
			'the two classes that declare a holding of the subject' ) .
		#( 'Examples'
			#( #ArchDocModelExamples #ArchDocRelationExamples #ArchDocRendererExamples
				#ArchDocComponentExamples #ArchDocBrokenSubject #ArchDocNoSuchClass )
			'the runnable examples a reader clicks' ) }
]

{ #category : 'declaring' }
ArchDocExampleMap class >> packageNames [
	^ #( 'ArchDoc-Examples' )
]
