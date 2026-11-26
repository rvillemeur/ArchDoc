"
I am the manifest of `ArchDoc-Core`, and I state the one architecture rule this package has: it may name no drawing library.

`ArchDocChecker` reads `archDocForbiddenDependencies` from me, matches each pattern against the package of every class the code of this package reaches, and reports an edge that breaks the rule as a finding. `ArchDocBaselineTest` runs that check, so the rule is enforced where it is written and not in a markdown file that drifts.

This is also how a project using ArchDoc states its own layering: a method on its package manifest, one pattern per line, with the reason beside it.
"
Class {
	#name : 'ManifestArchDocCore',
	#superclass : 'PackageManifest',
	#category : 'ArchDoc-Core-Manifest',
	#package : 'ArchDoc-Core',
	#tag : 'Manifest'
}

{ #category : 'architecture' }
ManifestArchDocCore class >> archDocForbiddenDependencies [
	"ArchDoc-Core reads pragmas, slots and compiled methods, all of which Pharo itself answers,
	 and builds its tabs with Spec, which every Pharo image carries because the inspector is
	 built on it. It must name no drawing library: Roassal is a separate project, and a package
	 that reads another's architecture has to load where that project is absent. The patterns are
	 matched against the package of every class an edge reaches, so 'Roassal*' covers the whole
	 project at once. ArchDocGraphRenderer and the two Diagram tabs live in ArchDoc-Roassal for
	 this reason."

	^ #( 'ArchDoc-Roassal' 'Roassal*' )
]
