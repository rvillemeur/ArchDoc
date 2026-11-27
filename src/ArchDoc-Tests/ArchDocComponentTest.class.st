Class {
	#name : 'ArchDocComponentTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocComponentTest >> testAClassNameTheImageDoesNotHoldIsReportedAndNotDrawn [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject #ArchDocNoSuchClass )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: component classes asArray equals: { ArchDocDeclaredSubject }.
	self assert: component unknownClassNames asArray equals: #( #ArchDocNoSuchClass )
]

{ #category : 'tests' }
ArchDocComponentTest >> testAComponentReadsItsNameClassesAndIntentionFromItsRow [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject #ArchDocHiddenSubject )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: component name equals: 'Glyph cache'.
	self
		assert: component classes asArray
		equals: { ArchDocDeclaredSubject. ArchDocHiddenSubject }.
	self
		assert: component intention
		equals: 'keeps the answer so the question is asked once'.
	self assert: component declaringClass equals: ArchDocComponentExamples.
	self assert: component unknownClassNames isEmpty
]

{ #category : 'tests' }
ArchDocComponentTest >> testAComponentSaysWhichClassesItHolds [
	| component |
	component := ArchDocComponent
		fromTableRow: #( 'Glyph cache' #( #ArchDocDeclaredSubject )
			'keeps the answer so the question is asked once' )
		declaredIn: ArchDocComponentExamples.
	self assert: (component includes: ArchDocDeclaredSubject).
	self deny: (component includes: ArchDocHiddenSubject)
]

{ #category : 'tests - views' }
ArchDocComponentTest >> testTheClassesViewListsEveryClassNameOfTheRowLoadedOrNot [
	| component presenter rows |
	component := ArchDocComponentExamples glyphCache.
	presenter := ArchDocArtefactTest new
		presenterOf: #inspectionClasses:
		on: component.
	rows := presenter items collect: [ :each |
		presenter columns first evaluation value: each ].
	self
		assert: rows asArray
		equals: #( 'ArchDocDeclaredSubject' 'ArchDocHiddenSubject' 'ArchDocNoSuchClass' ).
	self
		assert: (presenter columns second evaluation value: #ArchDocDeclaredSubject)
		equals: 'loaded'.
	self
		assert: (presenter columns second evaluation value: #ArchDocNoSuchClass)
		equals: 'not loaded'
]
