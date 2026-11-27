# Altitude plan: components, package graph and reading order

This plan answers one complaint and one wish.

The complaint: the *Architecture* tab of `VectorGraphics-Canvas-Fonts` drew thirty-one boxes and
forty-three lines, and read as a heap of text.
Filtering the diagram to the classes the package defines and the classes its declarations point at
brought it to seventeen boxes, which is legible but still the wrong altitude: seventeen class names
do not say what the font engine *is*.

The wish: something closer to [archify](https://github.com/tt-a1i/archify), which draws a system as
eight to twelve components with drill-down, reach and a reading order.

This document says what of archify is worth copying, what is not, and in what order we build it.

## 1. What archify actually does, and what we keep

Archify is two tools under one skill.

**The diagram half** has no parser at all.
An agent reads the repository and writes a typed JSON intermediate representation; bundled
validators check schema, layout and label clearance; `deliver` renders one self-contained HTML file
with pan and zoom, node focus, upstream and downstream reach, route probes, lenses and exports.
Its quality comes from the instruction *"show 8–12 core components"* — from a human-chosen altitude,
not from a layout algorithm.

**The code-analysis half** is deterministic static analysis, one adapter per language: a bundled
TypeScript parser, a transplanted Pyright, `java-parser`, compiled Go and Rust helpers, libclang for
C and C++.
It produces a module graph, findings, an overview and an Atlas workbench, plus a `check` command
with CI exit codes and baselines, and a `drift` command that compares the authored IR against the
code at a given commit.

What this means for us:

| Archify feature | Our position |
| --- | --- |
| Per-language parser adapters | Not needed. The image holds the AST, the senders, the references and the package graph already. |
| Authored JSON IR plus schema validators | Not needed as a file. Our declarations are pragmas on the accessors, and the test suite is the validator. |
| `drift --ir` against a commit | Not needed. A declaration that lives on the accessor cannot drift from the accessor; the checker reports a declaration whose target has gone. |
| `check` CI gate with exit codes | Already held, in a better form: `VGArchitectureTest` fails the suite. |
| Self-contained HTML viewer, story video, share cards | Declined. The reader is working inside the image, where the inspector already gives pan, zoom and live objects. |
| Ten diagram types, lenses, route cards | Declined. One class diagram, one component diagram and one package diagram answer the questions we actually ask. |
| **Component altitude, authored by hand** | **Copied. This is the idea worth having.** |
| **Module-level graph (their Atlas ring)** | **Copied, as a package graph.** |
| **Hotspot ordering as a reading order** | **Copied, formula and caveat alike.** |

Archify's own caveat about its hotspot ordering — *"a reading order, not inferred business
importance"* — is repeated here because it is the honest claim, and the one we can keep.

## 2. Vocabulary

**Component.** A named part of a design, holding one or more classes, with a one-line statement of
what it is for. A component is authored, never inferred: inferring it is what produced the heap of
text in the first place.

**Resident and visitor.** Already drawn: a class the drawn package defines is a resident, a class a
declaration reaches into another package for is a visitor.

**Altitude.** Which of the three diagrams a reader is looking at: packages, components, or classes.
A fourth, the object graph of one live instance, already exists.

**Reading order.** The order in which the classes of a component, or the components of a project,
repay being read. A hint for a newcomer, not a ranking of importance.

## 3. The open decisions, to settle before any code

These are interview questions, in the order they must be answered, because each one changes the
next. The recommendation is stated first in each case.

1. **Does a component map belong to a package or to a project?**
   Recommended: to a project. The font route spans `VectorGraphics-Canvas-Fonts`,
   `VectorGraphics-Bloc-Text` and `VectorGraphics-TrueType`, and a component that stopped at a
   package boundary would cut the route in three. A package tab then shows the slice of the map that
   touches that package.
2. **Where is the map declared?** Recommended: a class-side method `archDocComponents` on the
   manifest of the package that owns the route, read the way `archDocForbiddenDependencies` already
   is. No new file, no new format, and Pharo already keeps a package's statements about itself
   there.
3. **May a class belong to two components?** Recommended: no, and the checker reports it. Overlap is
   how a map stops being a map.
4. **Must every class be mapped?** Recommended: yes for the classes of the packages the map claims,
   and an unmapped class is a finding rather than an error — a new class is unmapped until someone
   says where it belongs, and the finding is the reminder.
5. **How deep does drill-down go?** Recommended: packages → components → classes → one live object,
   with the existing tabs as the last two steps.
6. **Does a component diagram show inferred uses?** Recommended: yes, faint, as the class diagram
   does, because a use between two components that no declaration explains is exactly what the
   reader should see.

## 4. Phase A — component altitude

Seven units. Each unit ends with the five artefacts and clean critics (§7).

### A1 — `ArchDocComponent`

A value object over one row of the authored map: name, classes, intention.

```smalltalk
ManifestVectorGraphicsCanvasFonts class >> archDocComponents
	^ {
		#( 'Glyph cache' #( VGGlyphAtlas VGGlyphMask ) 'keeps the rasterised mask of a glyph so a
			 character is drawn once and blitted thereafter' ) .
		#( 'Font face' #( VGFontFace VGFontOptions ) 'the parsed font and the options a scaled font
			 is built with' ) }
```

- Red test: a row answers its name, its classes and its intention; a row naming a class the image
  does not hold answers that name through `unknownClassNames` and does not raise.
- Smallest code: `ArchDocComponent class >> fromRow:declaredIn:`, mirroring
  `ArchDocRelation class >> readFromPragma:`.
- Example: `ArchDocComponentExamples class >> componentOfTheExamplePackage`.
- View: `inspectionComponent: aBuilder` — a table of the classes, their package, and whether each is
  a resident of the declaring package.

### A2 — `ArchDocComponentMap`

The whole map of a project, built from one manifest.

- `ArchDocComponentMap class >> onManifest:` and `onPackageNamed:` (which finds the manifest).
- `components`, `componentOf: aClass`, `componentNamed:`, `packageNames` (every package the mapped
  classes live in), `unmappedClasses`, `ambiguousClasses`, `unknownClassNames`.
- Red test: a map over `ArchDoc-Examples` answers one component per row; a class named twice is
  ambiguous; a class of a claimed package named nowhere is unmapped.
- The example package gets its own `archDocComponents`, including, on purpose, one ambiguous class
  and one unmapped class, so the checker has something to find — the same trick as
  `ArchDocBrokenSubject`.

### A3 — checker findings at component altitude

Fold into `ArchDocChecker >> findings` three new kinds:

- `#unmappedClass` — a class of a claimed package that no component names.
- `#ambiguousClass` — a class two components name.
- `#unknownComponentClass` — a component naming a class the image does not hold.

Red test: the example map yields exactly one finding of each kind, and `findings` holds them beside
the existing ones. The counts tab (`inspectionCounts:`) shows the new kinds without being told about
them one by one.

### A4 — the component graph

Lift the class-level edges the model already computes.
An edge whose source class sits in component X and whose target sits in component Y becomes one edge
X → Y; an edge inside a component disappears; the strongest kind wins, `#holding` over `#cache` over
`#use`; the edge carries how many class-level edges it stands for and the roles that made it, for
the popup.

- Red test: two classes of one component holding each other draw no component edge; a holding and a
  use between the same two components draw one solid edge whose count is two.
- `ArchDocComponentMap >> graph` answers an `ArchDocGraph` whose nodes are components, so the
  existing renderer draws it unchanged — this is the check that the renderer was factored right.

### A5 — drawing a component

The renderer needs no new class, but it needs to describe a component rather than a class:

- the box holds the component name and the number of classes;
- the popup holds the intention and the class names;
- resident and visitor fills apply to the packages the component's classes live in: a component
  wholly outside the drawn package is a visitor.

Red test: the box label of a component names the component and not its first class; the legend
(`legendRows`) gains no new row, because the styles are the same ones.

### A6 — drill-down

`ArchDocGraphRenderer >> descendInto: aComponent` replaces the canvas contents with the class graph
of that component, and `ascend` returns to the component graph.
The click handler sends those messages; the test sends them directly, because a test that fakes a
mouse tests Roassal rather than us.

- Red test: after `descendInto:`, the node set is the component's classes, and a breadcrumb shape
  names the component; after `ascend`, the node set is the components again.
- The canvas stays one canvas, so the inspector tab does not have to be rebuilt.

### A7 — the tabs, and the first real map

In `VectorGraphics-Documentation`:

- `Package >> inspectionComponents: aBuilder`, order 85, gated as the *Architecture* tab is, so
  components come before classes.
- The *Architecture* tab stays, at class altitude, for the package in hand.

In VectorGraphics itself: write `archDocComponents` on `ManifestVectorGraphicsCanvasFonts`, covering
the font route across `VectorGraphics-Canvas-Fonts` and `VectorGraphics-Bloc-Text`, between six and
eight components.
`VGArchitectureTest` gains a test that every class of those packages is mapped, so a new class
cannot be added to the route silently.

**Cost: about two sessions.** This is the unit that answers the original complaint, and it should be
built before the rest of the font documentation (slice two of `FONT-ARCHDOC-PLAN.md`), because
`VectorGraphics-TrueType` has forty-seven classes and would reproduce the heap of text at class
altitude however well the boxes are spaced.

## 5. Phase B — the package graph

Four units.

### B1 — `ArchDocProjectModel`

Built from a package-name prefix or a list: nodes are packages, edges are references between them,
counted.
It reuses `ArchDocModel >> classesReferencedBy:` per package rather than inventing a second scan.

- Red test: a project of the four ArchDoc packages draws an edge from `ArchDoc-Roassal` to
  `ArchDoc-Core` and none the other way, and the edge carries its count.

### B2 — forbidden edges are marked

An edge that `archDocForbiddenDependencies` forbids is drawn in red and reported by the checker,
with one source of truth: the drawn red edges and `ArchDocChecker >> forbiddenDependencies`, lifted
to packages, must be the same set.

- Red test states exactly that equality, so neither can drift.

### B3 — drawing a package

Box holds the package name and its class count; the resident fill marks the packages of the project,
the visitor fill the packages it depends on from outside.

### B4 — the tab

`Package >> inspectionNeighbours: aBuilder`, order 80, showing the project graph with this package
highlighted, and `VGDocumentationExamples class >> projectPackageGraph` as the one-click example.

**Cost: about one session.** It is cheap because every ingredient exists; it is worth having because
it is the picture that says where a package sits, which no class diagram can.

## 6. Phase C — reading order

Three units.

### C1 — the score

Archify's formula, with the one substitution the image forces:

```
score := size * (1 + (1 + fanIn) log: 2)
```

where `fanIn` is the number of classes that reference the class, and `size` is the total source size
of its methods, both sides — Pharo has no file to count lines of.
Ties break by fan-in, then fan-out, then name, as archify's do.

- Red test: a class nothing references scores below an identical class that ten reference; the order
  is stable across runs.
- The method comment carries the caveat verbatim: a reading order, not importance.

### C2 — `Where to start`

An inspector tab on a package and on a component: the classes in reading order, with score, fan-in
and size, selecting one opening it.

### C3 — the same order over components

The component a newcomer should read first, by the same formula applied to the lifted graph.

**Cost: about half a session.**

## 7. Acceptance, per unit

No unit is done until all of this holds:

1. the failing test was written first and was seen to fail;
2. the smallest code that passes it is in the image, and the suite is green;
3. the duplication the green step introduced has been removed, and the names say what the code
   means;
4. a class-side `<sampleInstance>` example exists in `ArchDoc-Examples`, rebuilding its object every
   call, asserting nothing, runnable with one click;
5. a custom `inspection<Name>: aBuilder` view exists, taking the builder, mutating nothing, asking
   the real rule rather than restating it;
6. `run_critics` is clean on every class the unit touched;
7. the work is committed in Iceberg at that green step.

`ArchDoc-Tests` must be green at the end of every unit, and `VectorGraphics-Documentation-Tests`
and `VGArchitectureTest` at the end of every unit that touches VectorGraphics.

## 8. Deferred, with the condition that would start it

- **Mermaid or SVG export.** Start it when something outside the image has to read a diagram — a
  README, the book, a pull request. Write it as text out of `ArchDocGraph`, not as a viewer.
- **Narrative architecture prose in the manifests.** Slice two of `FONT-ARCHDOC-PLAN.md`; the
  component map should exist first, because the prose will be organised by component.
- **A route view traced from a real run** (`AlgoTrace`, MetaLinks). Start it only after two or three
  real component diagrams have been read and found useful. It is the largest piece of new machinery
  in either plan and the least proven.
- **PharoVulkan.** After the font route is documented end to end.
- **Anything from archify's delivery chrome** — HTML viewer, story video, share cards, route cards,
  presentation stage. Start it when a reader without a Pharo image has to be served, and not before.

## 9. Cost and benefit, stated plainly

Phases A, B and C together are roughly three and a half to four sessions of the usual cycle, with no
new external dependency beyond Roassal, which is already pinned, and no new file format.
They reuse `ArchDocModel`, `ArchDocChecker` and `ArchDocGraphRenderer` rather than displacing them.

The benefit is one thing: a reader who opens a package sees six components with a sentence each
before seeing any class, and descends only where the question leads.
That is what makes archify's pictures readable, and it is the part that costs us the least, because
the image already knows everything the parsers in that project were written to find out.
