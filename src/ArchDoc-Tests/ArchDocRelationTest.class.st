"
I test `ArchDocRelation`, the one declaration ArchDoc reads.

I read the pragmas of the compiled accessors of `ArchDocRelationFixture` rather than building a pragma by hand, so that a change in how Pharo stores a pragma fails here and not in a project's architecture test.
"
Class {
	#name : 'ArchDocRelationTest',
	#superclass : 'TestCase',
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'tests' }
ArchDocRelationTest >> testAClassSideTableDeclaresWhatTheClassItselfHolds [
	"A cache kept for the session lives in a class-side instance variable, so its holder is the
	 class and not an instance. archClassRelations declares those, and the relation says the
	 metaclass declares it, which is how a reader knows where to look for the slot."

	| relation |
	relation := (ArchDocRelation declaredBy: ArchDocDeclaredSubject class)
		detect: [ :each | each role = #defaultSubject ].
	self assert: relation declaringClass equals: ArchDocDeclaredSubject class.
	self assert: relation targetName equals: #ArchDocDeclaredSubject.
	self assert: relation isCache.
	self deny: relation isToMany
]

{ #category : 'tests' }
ArchDocRelationTest >> testCacheIsDeclaredByItsOwnPragmaAndIsNotStructural [
	| relation |
	relation := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #warmCache.
	self assert: relation isCache.
	self deny: relation isStructural.
	self assert: relation isToOne.
	self assert: relation targetName equals: #ArchDocDeclaredSubject
]

{ #category : 'tests - view' }
ArchDocRelationTest >> testDeclarationViewSaysWhenTheTargetDoesNotResolve [
	"Build the view the way the inspector builds it, and read the cells, because a column block
	 runs only when a row is drawn."

	| context presenter rows |
	context := StInspectionContext new
		inspectedObject: (ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #ghost);
		methodSelector: #inspectionDeclaration:;
		yourself.
	presenter := context basicNewInspectionPresenter:
		(SpPresenterBuilder newApplication: SpApplication new).
	rows := presenter items collect: [ :item |
		presenter columns collect: [ :column | column evaluation value: item ] ].
	self assert: (rows anySatisfy: [ :row | row first = 'target resolves' and: [ row second beginsWith: 'NO' ] ]).
	self assert: (rows anySatisfy: [ :row | row first = 'kind' and: [ row second = 'structural' ] ])
]

{ #category : 'tests' }
ArchDocRelationTest >> testManyRelationIsToManyAndHasNoOpposite [
	| relation |
	relation := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #children.
	self assert: relation isToMany.
	self deny: relation isToOne.
	self deny: relation hasOpposite.
	self assert: relation oppositeRole isNil
]

{ #category : 'tests' }
ArchDocRelationTest >> testMethodCarryingNoDeclarationAnswersNoRelation [
	"The degenerate case the model meets on nearly every method it reads."

	self assert: (ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #scratch) isNil
]

{ #category : 'tests' }
ArchDocRelationTest >> testOneRelationReadsItsRoleAndTargetFromAnAccessorPragma [
	| relation |
	relation := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #child.
	self assert: relation role equals: #child.
	self assert: relation targetName equals: #ArchDocDeclaredSubject.
	self assert: relation isToOne.
	self deny: relation isCache
]

{ #category : 'tests' }
ArchDocRelationTest >> testOppositeRoleIsReadFromTheDeclaration [
	| relation |
	relation := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #child.
	self assert: relation hasOpposite.
	self assert: relation oppositeRole equals: #children
]

{ #category : 'tests' }
ArchDocRelationTest >> testPrintingSaysHolderRoleMultiplicityAndTarget [
	self
		assert: ArchDocRelationExamples toOneRelationWithAnOpposite printString
		equals: 'ArchDocDeclaredSubject>>child one ArchDocDeclaredSubject'.
	self
		assert: ArchDocRelationExamples cacheRelation printString
		equals: 'ArchDocDeclaredSubject>>warmCache cache one ArchDocDeclaredSubject'
]

{ #category : 'tests' }
ArchDocRelationTest >> testTargetResolvesOnlyWhenTheNamedClassIsLoaded [
	| loaded ghost |
	loaded := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #child.
	ghost := ArchDocRelation fromMethod: ArchDocDeclaredSubject >> #ghost.
	self assert: loaded isTargetLoaded.
	self assert: loaded targetClass equals: ArchDocDeclaredSubject.
	self deny: ghost isTargetLoaded.
	self assert: ghost targetClass isNil
]
