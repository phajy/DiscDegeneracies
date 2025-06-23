#set page("a0", fill: orange.lighten(90%))
#set text(size: 34pt)

#let STROKE_WIDTH = 6pt

#let SPACING = 1.0cm

#let COLOR_GREEN = rgb("#389826")
#let COLOR_RED = rgb("#CB3C33")
#let COLOR_PURPLE = rgb("#9558B2")
#let COLOR_BLUE = rgb("#4063D8")

#let secblock(body, fill: luma(230), stroke: 0pt) = block(
  fill: fill.lighten(80%),
  inset: SPACING,
  radius: SPACING,
  width: 100%,
  stroke: fill + 6pt,
  below: SPACING,
  above: SPACING,
)[
  #body
]

// poster title
#let poster_title = [
  #text(size: 100pt, weight: "black")[Broad Iron Line Degeneracies]
  #h(1fr)
  #box(inset: (top: 1.5cm), image("./logos/UoB_CMYK_24.svg", height: 10cm), height: 7cm)

  #text(size: 40pt)[*Andrew Young*, Fergus Baker, Darius Michienzi]
  #v(1cm)
]

// abstract
#let poster_abstract = secblock()[
  = Abstract

  X-ray studies of broad iron lines are a key diagnostic of the accretion environment of supermassive black holes. These lines are broadened and skewed in a characteristic manner by the relativistic effects of the disc and black hole. A typical assumption is that the spacetime is described by the Kerr metric for a spinning black hole, the disc is razor thin and in the equatorial plane, and that the corona is a "lamp post" positioned along the symmetry axis. Here we relax these assumptions and investigate potential degeneracies in recovering parameter values when fitting Kerr lamp-post models to more sophisticated simulated accretion flows. This is a work in progress but we show some preliminary results and invite discussion.
]

// introduction
#let poster_intro = secblock(fill: COLOR_BLUE)[
  = Introduction

  Introduction to broad iron lines. Lamp post model. Nice figure.
]

// our models with Gradus
#let poster_models = secblock(fill: COLOR_GREEN)[
  = Models

  Description of Gradus and how we can produce thick discs, non-Kerr geometry, etc. Include a nice figure or two.
]

// simulated spectra
#let poster_spectra = secblock(fill: COLOR_RED)[
  = Simulated Spectra

  We use SpectralFitting.jl to simulate XMM data. We can simulate any observatory. Include an example spectrum. Include a figure showing a simulated spectrum. We fit these with a standard disc line you'd expect for a lamp post model. Include a ncie figure of a simulated spectrum.
]

// preliminary results
#let poster_results = secblock(fill: COLOR_PURPLE)[
  = Preliminary Results

  Show some preliminary results with model degeneracy.

]

#poster_title

#poster_abstract

#grid(
  columns: (1fr, 1fr),
  column-gutter: SPACING,
  row-gutter: SPACING,
  [#poster_intro],
  [#poster_spectra],
  [#poster_models],
  [#poster_results]
)