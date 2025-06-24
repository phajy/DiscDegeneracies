#set page("a0", margin: (2.0cm), fill: orange.lighten(90%))
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

  X-ray studies of broad iron lines are a key diagnostic of the accretion environment of supermassive black holes. These lines are broadened and skewed in a characteristic manner by the relativistic effects of the disc and black hole. A typical assumption is that the spacetime is described by the Kerr metric for a spinning black hole, the disc is razor thin and in the equatorial plane, and that the corona is a "lamppost" positioned along the symmetry axis. Here we relax these assumptions and investigate potential degeneracies in recovering parameter values when fitting Kerr lamppost models to more sophisticated simulated accretion flows. In particular, we investigate thick discs at high inclination in which the innermost radii can be obscured. This is a _work in progress_ but we show some preliminary results and invite discussion.
]

// introduction
#let poster_intro = secblock(fill: COLOR_BLUE)[
  = Introduction

  X-ray observations of "broad iron lines" are an extremely powerful probe of the spacetime, corona, and accretion environment around black holes. 

  #figure(
    block(image("figs/disc_and_reflection.jpg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: ["Lamppost" corona illuminating a razor-thin accretion disc.]
  )

  #figure(
    block(image("figs/blurred_reflection.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [The reflection spectrum is relativistically blurred. The specifics of the broadening encode information about the disc, corona, and spacetime.]
  )

  #figure(
    block(image("figs/powerlaw_fit.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Power-law fit to MCG --6-30-15 observations by _XMM-Newton_ and _NuSTAR_. The residuals clearly show the broad iron line and Compton hump.]
  )
]

// our models with Gradus
#let poster_models = secblock(fill: COLOR_GREEN)[
  = Models

  We make use of the new general relativistic ray tracer #smallcaps[Gradus.jl] (Baker & Young 2025) which is able to model more realistic scenarios, specifically with arbitrary spacetimes, disc, and corona geometries. In this poster we restrict ourselves to an initial study of thick discs self-consistently illuminated by a lamppost corona (see, e.g., Taylor & Reynolds 2018).

  #figure(
    block(image("figs/disc_profile_a_0.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Disc cross sections for a range of Eddington fractions, $dot(m)$, illuminated by a lamppost corona.]
  )

  #figure(
    block(image("figs/disc_obscuration.svg", width: 80%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Razor-thin disc (a) and thick disc (b). Note the obscured innermost radii in (b) -- this will be more significant at high inclination.]
  )

  #place(top + right, dx: 60pt, dy: -110pt, image("logos/gradus.png", width: 15%))
]

// simulated spectra
#let poster_spectra = secblock(fill: COLOR_RED)[
  = Simulated Spectra

  As an initial test, we use #smallcaps[SpectralFitting.jl] to simulate high-quality _XMM-Newton_ observations of thin discs, and fit these simulations with thin disc models. We then try simulating thick discs at high inclination angles and fit these with thin disc models. This is an initial proof of concept and we will simulate a range of discs, coronae, and spacetimes in the future.

  // Figure of fit to a simulated spectrum with residuals.

  #place(top + right, dx: 80pt, dy: -80pt, image("logos/spectral_fitting.svg", width: 23%))
]

// preliminary results
#let poster_results = secblock(fill: COLOR_PURPLE)[
  = Preliminary Results

  Show some preliminary results with model degeneracy.

  // figure showing input and recovered spins
#figure(
    block(image("figs/confidence_thin.svg", width: 40%), stroke:6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Thin disc recovered spin parameters.]
  )
]

// acknowledgements
#let poster_acknowledgements = secblock(fill: COLOR_GREEN)[
  = Acknowledgements

  This work was supported by the Science and Technology Facilities Council grant number ST/Y001990/1. This is a work in progress and warmly welcome discussion with conference attendees!
]

// references
#let poster_references = secblock()[
  = References

  - Baker & Young (2025) MNRAS, in review
  - Taylor & Reynolds (2018) ApJ 855 120
]

#let title_space = 10cm
#let abstract_space = 12cm
#let first_block_space = 46cm
#let second_block_space = 11.8cm
#let third_block_space = 20cm

#grid(
  columns: (1fr, 1fr),
  rows: (title_space, abstract_space, first_block_space, second_block_space, third_block_space, 1fr),
  column-gutter: SPACING,
  row-gutter: SPACING,
  grid.cell(x:0, y:0, colspan:2, [#poster_title]),
  grid.cell(x:0, y:1, colspan:2, [#poster_abstract]),
  grid.cell(x:0, y:2, rowspan:3, [#poster_intro]),
  grid.cell(x:1, y:2, rowspan:1, [#poster_models]),
  grid.cell(x:1, y:3, rowspan:1, [#poster_spectra]),
  grid.cell(x:1, y:4, [#poster_results]),
  grid.cell(x:0, y:5, [#poster_acknowledgements]),
  grid.cell(x:1, y:5, [#poster_references])
)
