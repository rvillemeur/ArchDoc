"
I hold the examples of `ArchDocReadingOrder`.

The order a reader clicks here is the one over this library's own core package, since a reading order of three example classes says nothing about whether the formula sorts sensibly.

Every example is class-side, takes no argument, rebuilds its object on every call and asserts nothing.
"
Class {
	#name : 'ArchDocReadingOrderExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocReadingOrderExamples class >> readingOrderOfAPackageThatSaysWhereToStart [
	"The order over ArchDoc-Examples, whose manifest declares two entry points and one name it
	 does not define. Open the Where to start tab: the two declared rows head the table and are
	 marked, whatever they score, and the computed order follows under them."

	<sampleInstance>
	^ ArchDocReadingOrder on: (ArchDocModel onPackageNamed: 'ArchDoc-Examples') graph
]

{ #category : 'examples' }
ArchDocReadingOrderExamples class >> readingOrderOfTheCorePackage [
	"The order a newcomer should read ArchDoc-Core in: twelve classes, weighed by their source
	 and by how much of the package reaches them. Open the Where to start tab."

	<sampleInstance>
	^ ArchDocReadingOrder on: (ArchDocModel onPackageNamed: 'ArchDoc-Core') graph
]
