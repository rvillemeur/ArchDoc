"
I hold the examples of `ArchDocChecker` and `ArchDocFinding`.

The checker I answer reads this very package, which declares a ghost target, a dangling opposite and a sample instance that contradicts its own declaration. So the checker a reader clicks reports all four kinds of finding at once, instead of an empty list that teaches nothing.

`subjectThatBreaksItsDeclarations` is the object the checker reads, and it is a sample instance in its own right: the checker finds it the way it finds any other.
"
Class {
	#name : 'ArchDocCheckerExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocCheckerExamples class >> checkerOfTheExamplesPackage [
	"A checker over a package written to be broken, so every answer has something in it."

	<sampleInstance>
	^ ArchDocChecker onPackageNamed: 'ArchDoc-Examples'
]

{ #category : 'examples' }
ArchDocCheckerExamples class >> findingAboutADeclarationThatPointsAtNothing [
	"One finding, as a reader meets it from the checker's table."

	<sampleInstance>
	^ self checkerOfTheExamplesPackage unresolvedRelations first
]

{ #category : 'examples' }
ArchDocCheckerExamples class >> subjectThatBreaksItsDeclarations [
	"The object the checker reads: it holds a String where its declaration promises a subject."

	<sampleInstance>
	^ ArchDocBrokenSubject new
]
