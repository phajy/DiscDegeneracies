#set page("a0", margin: 2.0cm, fill: orange.lighten(90%))
#set text(size: 34pt)

// annoyingly the figure numbering doesn't work properly (it goes out of order and I can't figure out how to reset the counter!) so I'll do it by hand.
#set figure(supplement: none, numbering: none)

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

  #text(size: 40pt)[*Andy Young*, Fergus Baker, Darius Michienzi] \
  #text(size: 24pt)[HH Wills Physics Laboratory, Tyndall Avenue, Bristol BS8 1TL, UK]
]

// abstract
#let poster_abstract = secblock()[
  = Abstract

  X-ray studies of broad iron lines are a key diagnostic of the accretion environment of supermassive black holes. These lines are broadened and skewed in a characteristic manner by the relativistic effects of the disc and black hole. A typical assumption is that the spacetime is described by the Kerr metric for a spinning black hole, the disc is razor thin and in the equatorial plane, and that the corona is a "lamppost" positioned along the symmetry axis. Here we relax these assumptions and investigate potential degeneracies in recovering parameter values when fitting Kerr lamppost models to more sophisticated simulated accretion flows. In particular, we investigate thick discs at high inclination in which the innermost radii can be obscured. This is a _work in progress_ but we show some preliminary results and invite discussion about the implications of more realistic disc and corona modelling.
]

// introduction
#let poster_intro = secblock(fill: COLOR_BLUE)[
  = Introduction

  X-ray observations of "broad iron lines" are an extremely powerful probe of the spacetime, corona, and accretion environment around black holes.

  A hot corona produces X-rays by inverse-Compton scattering thermal photons from the accretion disc. These X-rays reach the observer directly as well as illuminating the disc itself. The back-scattered spectrum from the disc contains a strong iron K$alpha$ line that is broadened and skewed by the relativistic effects. The precise geometry of the disc and corona is uncertain.

  #figure(
    block(image("figs/disc_and_reflection.jpg", width: 50%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Figure 1: "Lamppost" corona illuminating a razor-thin accretion disc.]
  )

  #figure(
    block(image("figs/blurred_reflection.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Figure 2: The reflection spectrum is relativistically blurred. This broadening encodes information about the disc, corona, and spacetime.],
  )

  #figure(
    block(image("figs/powerlaw_fit.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Figure 3: Residuals to a power-law fit to MCG --6-30-15 observations by _XMM-Newton_ and _NuSTAR_ showing a broad iron line and Compton hump.],
  )
]

// our models with Gradus
#let poster_models = secblock(fill: COLOR_GREEN)[
  = Models

  We use of a new general relativistic ray tracer #smallcaps[Gradus.jl] (Baker & Young 2025) to model more realistic scenarios, with arbitrary spacetimes, disc, and corona geometries. Here we restrict ourselves to a study of thick discs self-consistently illuminated by a lamppost (see, e.g., Taylor & Reynolds 2018).

  #figure(
    block(image("figs/disc_profile_a_0.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Figure 4: Disc cross sections for a range of Eddington fractions, $dot(m)$, illuminated by a lamppost corona (indicated by the red star).],
  )

  #figure(
    block(image("figs/disc_obscuration.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
    caption: [Figure 5: Razor-thin disc (a) and thick disc (b). Note the obscured innermost radii in (b) -- this will be more significant at high inclination.],
  )

  #place(top + right, dx: 60pt, dy: -110pt, image("logos/gradus.png", width: 15%))
]

// simulated spectra
#let poster_spectra = secblock(fill: COLOR_RED)[
  = Simulated Spectra

  As an initial test, we use #smallcaps[SpectralFitting.jl] to simulate high-quality _XMM-Newton_ observations of thin discs, and fit these simulations with thin disc models. We then try simulating thick discs at high inclination angles and fit these with thin disc models. This is an initial proof of concept and we will simulate a broader range of discs, coronae, and spacetimes in the future.

  #place(top + right, dx: 80pt, dy: -80pt, image("logos/spectral_fitting.svg", width: 23%))
]

// preliminary results
#let poster_results = secblock(fill: COLOR_PURPLE)[
  = Preliminary Results and Conclusions

  // figures showing input and recovered spins
  #grid(
    columns: (1fr, 1fr),
    figure(
      block(image("figs/thin_disc_confidence.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
      caption: [Figure 6: Thin disc simulation / thin disc fit: good spin measurements.],
    ),
    figure(
      block(image("figs/thick_disc_confidence.svg", width: 80%), stroke: 6pt, inset: SPACING, radius: SPACING, fill: white),
      caption: [Figure 7: Thick disc simulation / thin disc fit: biased spin measurements.],
    )
  )

  Obscuration of the inner disc can bias spin measurements to lower values. This illustrates the need for new disc models to quantify fit uncertainties.
]

// acknowledgements
#let poster_acknowledgements = secblock(fill: COLOR_GREEN)[
  = Acknowledgements

  This work was supported by the Science and Technology Facilities Council grant number ST/Y001990/1. We warmly welcome discussion with conference attendees and/or email #link("mailto:Andy.Young@bristol.ac.uk").
]

// references
#let poster_references = secblock()[
  = References

  - Baker & Young (2025) MNRAS, in review
  - Taylor & Reynolds (2018) ApJ 855 120
  \

  #place(top + right, dx: -100pt, dy: 0pt, image("logos/gradus.png", width: 7%))
  #place(top + right, dx: -10pt, dy: 0pt, image("logos/gradus-qr-code.svg", width: 7%))
  #place(top + right, dx: -90pt, dy: 100pt, image("logos/spectral_fitting.svg", width: 12%))
  #place(top + right, dx: -10pt, dy: 100pt, image("logos/spectral-fitting-qr-code.svg", width: 7%))
]

#let title_space = 11cm
#let abstract_space = 12cm
#let first_block_space = 44cm
#let second_block_space = 11.0cm
#let third_block_space = 22cm
#let final_block_space = 8cm

#grid(
  columns: (1fr, 1fr),
  rows: (title_space, abstract_space, first_block_space, second_block_space, third_block_space, final_block_space),
  column-gutter: SPACING,
  row-gutter: SPACING,
  grid.cell(x: 0, y: 0, colspan: 2, [#poster_title]),
  grid.cell(x: 0, y: 1, colspan: 2, [#poster_abstract]),
  grid.cell(x: 0, y: 2, rowspan: 3, [#poster_intro]),
  grid.cell(x: 1, y: 2, rowspan: 1, [#poster_models]),
  grid.cell(x: 1, y: 3, rowspan: 1, [#poster_spectra]),
  grid.cell(x: 1, y: 4, [#poster_results]),
  grid.cell(x: 0, y: 5, [#poster_acknowledgements]),
  grid.cell(x: 1, y: 5, [#poster_references]),
)
