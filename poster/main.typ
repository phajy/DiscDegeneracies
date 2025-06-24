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

// would be nice to include gradus and spectralfitting logos here
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

  X-ray studies of broad iron lines are a key diagnostic of the accretion environment of supermassive black holes. These lines are broadened and skewed in a characteristic manner by the relativistic effects of the disc and black hole. A typical assumption is that the spacetime is described by the Kerr metric for a spinning black hole, the disc is razor thin and in the equatorial plane, and that the corona is a "lamp post" positioned along the symmetry axis. Here we relax these assumptions and investigate potential degeneracies in recovering parameter values when fitting Kerr lamp-post models to more sophisticated simulated accretion flows. This is a _work in progress_ but we show some preliminary results and invite discussion.
]

// introduction
#let poster_intro = secblock(fill: COLOR_BLUE)[
  = Introduction

  Introduction to broad iron lines. Lamp post model. Nice figure.

  #figure(
    block(image("figs/disc_and_reflection.jpg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Cartoon.]
  )

  #figure(
    block(image("figs/blurred_reflection.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Blurred reflection.]
  )

  #figure(
    block(image("figs/powerlaw_fit.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Power-law fit to MCG --6-30-15. NuSTAR and XMM. Broad iron line and Compton hump.]
  )
]

// our models with Gradus
#let poster_models = secblock(fill: COLOR_GREEN)[
  = Models

  Description of Gradus and how we can produce thick discs, non-Kerr geometry, etc. Include a nice figure or two.

  Image of thick disc and eclipsed inner disc.

  #figure(
    block(image("figs/disc_profile_a_0.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Disc profiles for different values of the Eddington fraction, $dot(m)$.]
  )

  #figure(
    block(image("figs/disc_obscuration.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Obscuration of the inner disc which is responsible for the largest gravitational redshift.]
  )

  // include a gradus logo
]

// simulated spectra
#let poster_spectra = secblock(fill: COLOR_RED)[
  = Simulated Spectra

  We use SpectralFitting.jl to simulate XMM data. We can simulate any observatory. Include an example spectrum. Include a figure showing a simulated spectrum. We fit these with a standard disc line you'd expect for a lamp post model.
  
  Figure of fit to a simulated spectrum with residuals.

  // include a spectral fitting logo
]

// preliminary results
#let poster_results = secblock(fill: COLOR_PURPLE)[
  = Preliminary Results

  Show some preliminary results with model degeneracy.

  // figure showing input and recovered spins

]

// acknowledgements and references need to be added
#let poster_acknowledgements = secblock(fill: COLOR_GREEN)[
  = Acknowledgements and References

  This work was supported by the Science and Technology Facilities Council grant number ST/Y001990/1.
]

#let title_space = 11cm
#let abstract_space = 13cm
#let first_block_space = 38cm
#let second_block_space = 14cm

#grid(
  columns: (1fr, 1fr),
  rows: (title_space, abstract_space, first_block_space, second_block_space, 1fr, 1fr),
  column-gutter: SPACING,
  row-gutter: SPACING,
  grid.cell(x:0, y:0, colspan:2, [#poster_title]),
  grid.cell(x:0, y:1, colspan:2, [#poster_abstract]),
  grid.cell(x:0, y:2, rowspan:4, [#poster_intro]),
  grid.cell(x:1, y:2, rowspan:1, [#poster_models]),
  grid.cell(x:1, y:3, rowspan:1, [#poster_spectra]),
  grid.cell(x:1, y:4, [#poster_results]),
  grid.cell(x:0, y:6, colspan:2, [#poster_acknowledgements])
)
