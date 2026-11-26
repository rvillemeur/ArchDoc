"
I declare the packages of ArchDoc and how they load, for Metacello.

Four groups:

- `core` — `ArchDoc-Core` alone. It names no graphics library, so it loads into a headless image and an architecture test built on it runs where no window can open.
- `default` — the core and `ArchDoc-Roassal`, which requires the Roassal project.
- `examples` — the examples, which need Roassal because one renderer example is there.
- `tests` — everything, since the suite reads the examples.

Metacello finds me by name, so nothing in the image references me.
"
Class {
	#name : 'BaselineOfArchDoc',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfArchDoc-Baseline',
	#package : 'BaselineOfArchDoc',
	#tag : 'Baseline'
}

{ #category : 'baselines' }
BaselineOfArchDoc >> baseline: spec [
	"ArchDoc-Core requires nothing: it reads pragmas, slots and compiled methods, all of which
	 Pharo itself answers. Only ArchDoc-Roassal knows a graphics library exists, which is why it
	 is a package and a group apart."

	<baseline>
	spec for: #common do: [
		spec
			baseline: 'Roassal' with: [ spec repository: 'github://pharo-graphics/Roassal:master' ].
		spec
			package: 'ArchDoc-Core';
			package: 'ArchDoc-Roassal'
			with: [ spec requires: #( 'ArchDoc-Core' 'Roassal' ) ];
			package: 'ArchDoc-Examples'
			with: [ spec requires: #( 'ArchDoc-Core' 'ArchDoc-Roassal' ) ];
			package: 'ArchDoc-Tests'
			with: [ spec requires: #( 'ArchDoc-Core' 'ArchDoc-Roassal' 'ArchDoc-Examples' ) ].
		spec
			group: 'core' with: #( 'ArchDoc-Core' );
			group: 'default' with: #( 'ArchDoc-Core' 'ArchDoc-Roassal' );
			group: 'examples' with: #( 'ArchDoc-Examples' );
			group: 'tests' with: #( 'ArchDoc-Tests' ) ]
]
