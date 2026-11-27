"
I am an `ArchDocReadingOrder` that counts how often it reads the source of a class.

A sort makes many more comparisons than it has nodes, and every comparison asks for a score. Whether the weight of a node is read once or once per comparison is therefore a fact about the class that no timing can state without being brittle, so I count the reads and the test states the count.
"
Class {
	#name : 'ArchDocReadingOrderSpy',
	#superclass : 'ArchDocReadingOrder',
	#instVars : [
		'reads'
	],
	#category : 'ArchDoc-Tests',
	#package : 'ArchDoc-Tests'
}

{ #category : 'accessing' }
ArchDocReadingOrderSpy >> reads [
	"How many times the source of a behaviour has been read through me."

	^ reads ifNil: [ 0 ]
]

{ #category : 'private' }
ArchDocReadingOrderSpy >> sourceSizeOfMethodsOf: aBehavior [
	reads := self reads + 1.
	^ super sourceSizeOfMethodsOf: aBehavior
]
