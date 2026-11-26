"
I am the manifest of `ArchDoc-Examples`, and I carry one rule that is deliberately false: I forbid this package from reaching `ArchDoc-Core`, which it does reach on every line.

The rule is a fixture. `ArchDocChecker` reads `archDocForbiddenDependencies` from the manifest of the package it checks, and its tests need a package that breaks the rule in order to see the finding reported. A real manifest states a rule the package keeps.

A manifest is also where Pharo's critics keep what a package chooses to ignore, so a project that states a layering rule here states it where its own tools already look.
"
Class {
	#name : 'ManifestArchDocExamples',
	#superclass : 'PackageManifest',
	#category : 'ArchDoc-Examples-Manifest',
	#package : 'ArchDoc-Examples',
	#tag : 'Manifest'
}

{ #category : 'architecture' }
ManifestArchDocExamples class >> archDocForbiddenDependencies [
	"Deliberately false: this package reaches ArchDoc-Core everywhere, so the checker's tests
	 have a forbidden dependency to find. See my class comment."

	^ #( 'ArchDoc-Core' )
]
