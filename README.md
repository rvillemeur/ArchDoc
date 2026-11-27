# ArchDoc

ArchDoc documents the architecture of a Pharo project from the project's own code, so that the
documentation cannot drift away from what the code does.

A project declares its relations where the code already is: a pragma on the accessor that reads the
instance variable, or — for a class that deliberately exposes no accessor — a class-side table. The
declarations cost the declaring package no dependency, because a pragma is a literal.

From those declarations ArchDoc generates:

- a class diagram of a package, with the declared holdings drawn as edges and the undeclared static
  references drawn as inferred uses;
- an object graph of a live instance, read through slot reflection;
- a checker, whose findings are the material of an architecture test: declarations that resolve to
  nothing, opposites that are missing or not reciprocal, sample instances whose actual holdings
  contradict their declarations, and forbidden dependencies between packages.

## Packages

| Package | Holds |
|---|---|
| `ArchDoc-Core` | The model: relations, edges, graphs, the object graph and the checker. No UI dependency. |
| `ArchDoc-Roassal` | The renderers of the class diagram and the object graph. |
| `ArchDoc-Examples` | One `<sampleInstance>` example per class of the library. |
| `ArchDoc-Tests` | The suite. |

## Loading

```smalltalk
Metacello new
	baseline: 'ArchDoc';
	repository: 'github://rvillemeur/ArchDoc:main/src';
	load
```

`load` alone loads the `default` group: the model and the Roassal renderers. The other groups are
loaded by name.

```smalltalk
"the model alone, with no graphics library"
Metacello new
	baseline: 'ArchDoc';
	repository: 'github://rvillemeur/ArchDoc:main/src';
	load: 'core'.

"the examples and the suite as well"
Metacello new
	baseline: 'ArchDoc';
	repository: 'github://rvillemeur/ArchDoc:main/src';
	load: #( 'default' 'examples' 'tests' )
```

| Group | Loads |
|---|---|
| `core` | `ArchDoc-Core` alone. No graphics library is fetched. |
| `default` | `ArchDoc-Core` and `ArchDoc-Roassal`, which pulls Roassal. |
| `examples` | `ArchDoc-Examples`. |
| `tests` | `ArchDoc-Tests`. |

Roassal is pinned by this baseline alone, at `github://pharo-graphics/Roassal:master`. A project
that loads ArchDoc must not pin Roassal a second time in the same load: two pins of one project
build a Metacello conflict.

### From a local checkout

```smalltalk
Metacello new
	baseline: 'ArchDoc';
	repository: 'gitlocal:///path/to/ArchDoc/src';
	onConflictUseIncoming;
	load
```

### From another project's baseline

```smalltalk
spec
	baseline: 'ArchDoc'
	with: [ spec repository: 'github://rvillemeur/ArchDoc:main/src'; loads: #( 'default' ) ]
```
