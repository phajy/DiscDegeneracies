using Gradus
using SpectralFitting

struct GradusModel{T,D} <: AbstractTableModel{T,Additive}
    table::D # to keep the emissivity function in
    K::T
    "Spin"
    a::T
    "Observer inclination (degrees off of the spin axis)."
    θ_obs::T
    "Inner radius of the accretion disc."
    inner_r::T
    "Outer radius of the accretion disc."
    outer_r::T
    "Central emission line energy (keV)."
    lineE::T
end

function GradusModel(
    # maps r to ϵ
    emissivity::Function;
    K = FitParam(1.0),
    a = FitParam(0.998, upper_limit = 1.0),
    θ_obs = FitParam(45.0, upper_limit = 90.0),
    inner_r = FitParam(1.0),
    outer_r = FitParam(100.0, upper_limit = 1000.0),
    lineE = FitParam(6.4),
    kwargs...,
)
    GradusModel((; emissivity), K, a, θ_obs, inner_r, outer_r, lineE)
end

function SpectralFitting.invoke!(output, domain, model::GradusModel)
    d = ThinDisc(0.0, Inf)
    x = SVector{4}(0.0, 10_000.0, deg2rad(model.θ_obs), 0.0)
    m = KerrMetric(1.0, model.a)
    _, flux = lineprofile(
        domain ./ model.lineE,
        model.table.emissivity,
        m,
        x,
        d;
        maxrₑ = model.outer_r,
        minrₑ = max(model.inner_r, Gradus.isco(m)),
        verbose = true,
    )
    output .= flux[1:(end-1)]
end

# use like:

m = KerrMetric(1.0, 0.998)
d = ThinDisc(0.0, Inf)
lp_model = LampPostModel(h = 10.0)
profile = emissivity_profile(m, d, lp_model)
model = GradusModel(r -> emissivity_at(profile, r))
# model = GradusModel(r -> r^-3)
domain = collect(range(1.0, 10.0, 150))
m = invokemodel(domain, model)
plot(domain[1:end-1], m)
