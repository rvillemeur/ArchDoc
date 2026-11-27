"
I am the manifest of `ArchDoc-Examples`, and I carry two rules that are deliberately false.

I forbid this package from reaching `ArchDoc-Core`, which it does reach on every line, and I name `ArchDocNoSuchSubject` among my entry points, which this package does not define.

Both are fixtures. `ArchDocChecker` reads `archDocForbiddenDependencies` and `archDocEntryPoints` from the manifest of the package it checks, and its tests need a package that breaks each rule in order to see the finding reported. A real manifest states rules the package keeps.

The two entry points I name rightly — `ArchDocHiddenSubject` first, then `ArchDocDeclaredSubject` — are what `ArchDocReadingOrder` puts at the head of its table, in that order, whatever they score.

A manifest is also where Pharo's critics keep what a package chooses to ignore, so a project that states a layering rule or an entry point here states it where its own tools already look.


"
Class {
	#name : 'ManifestArchDocExamples',
	#superclass : 'PackageManifest',
	#category : 'ArchDoc-Examples-Manifest',
	#package : 'ArchDoc-Examples',
	#tag : 'Manifest'
}

{ #category : 'architecture' }
ManifestArchDocExamples class >> archDocEntryPoints [
	"Where a reader of this package starts, in the order to read them. The third name is
	 deliberately false: nothing of that name is defined here, so the checker's tests have an
	 unknown entry point to find. See my class comment."

	^ #( #ArchDocHiddenSubject #ArchDocDeclaredSubject #ArchDocNoSuchSubject )
]

{ #category : 'architecture' }
ManifestArchDocExamples class >> archDocForbiddenDependencies [
	"Deliberately false: this package reaches ArchDoc-Core everywhere, so the checker's tests
	 have a forbidden dependency to find. See my class comment."

	^ #( 'ArchDoc-Core' )
]
