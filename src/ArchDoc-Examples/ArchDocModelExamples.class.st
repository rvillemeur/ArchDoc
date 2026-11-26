"
I hold the examples of `ArchDocModel`, `ArchDocGraph` and `ArchDocEdge`.

The package they read is `ArchDoc-Examples`, this very package, so an example answers a model of the classes that declare the three kinds of relation on purpose — including the declaration whose target no image holds.

Every example is class-side, takes no argument, rebuilds its object on every call and asserts nothing.
"
Class {
	#name : 'ArchDocModelExamples',
	#superclass : 'Object',
	#category : 'ArchDoc-Examples-Examples',
	#package : 'ArchDoc-Examples',
	#tag : 'Examples'
}

{ #category : 'examples' }
ArchDocModelExamples class >> cacheEdge [
	"One dashed arrow: a holding built on first use."

	<sampleInstance>
	^ (self graphOfTheExamplesPackage edgesOfKind: #cache) first
]

{ #category : 'examples' }
ArchDocModelExamples class >> graphOfTheExamplesPackage [
	"The class diagram the model answers: holdings, caches and inferred uses together."

	<sampleInstance>
	^ self modelOfTheExamplesPackage graph
]

{ #category : 'examples' }
ArchDocModelExamples class >> modelOfTheExamplesPackage [
	"A model of this very package: four pragma declarations, three table declarations, and one
	 of them pointing at a class no image holds."

	<sampleInstance>
	^ ArchDocModel onPackageNamed: 'ArchDoc-Examples'
]
