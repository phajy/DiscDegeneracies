# simulate thick discs

using Gradus
using SpectralFitting, XSPECModels
using Plots
using GradusSpectralModels, JLD2, CodecZlib
using Relxill

# nice plotting routine
function plot_result(data, results...)
    p1 = plot(data,
        ylims=(3.0e-2, 2.0),
        xscale=:log10,
        yscale=:log10,
        legend=:bottomleft,
        xticks=([4, 5, 6, 7, 8, 9, 10], ["", "", "", "", "", "", ""]),
        xlabel=""
    )
    p2 = plot(xscale=:log10)
    for r in results
        plot!(p1, r)
        residualplot!(p2, r, xticks=([4, 5, 6, 7, 8, 9, 10], ["4", "5", "6", "7", "8", "9", "10"]))
    end
    plot(p1, p2, link=:x, layout=@layout [top{0.75h}; bottom{0.25h}])
end

# thick disc model we want to simulate
struct GradusModel{T,D} <: AbstractTableModel{T,Additive}
    table::D # to keep the emissivity function in
    K::T
    "Spin"
    a::T
    "Eddington fraction"
    eddington_ratio::T
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
    K=FitParam(1.0),
    a=FitParam(0.998, upper_limit=1.0),
    eddington_ratio=FitParam(0.1, upper_limit=0.3),
    θ_obs=FitParam(75.0, upper_limit=90.0),
    inner_r=FitParam(1.0),
    outer_r=FitParam(100.0, upper_limit=1000.0),
    lineE=FitParam(6.4),
    kwargs...,
)
    GradusModel((; emissivity), K, a, eddington_ratio, θ_obs, inner_r, outer_r, lineE)
end

function SpectralFitting.invoke!(output, domain, model::GradusModel)
    m = KerrMetric(1.0, model.a)
    d = ShakuraSunyaev(m; eddington_ratio=model.eddington_ratio)
    x = SVector{4}(0.0, 10_000.0, deg2rad(model.θ_obs), 0.0)
    _, flux = lineprofile(
        domain ./ model.lineE,
        model.table.emissivity,
        m,
        x,
        d;
        maxrₑ=model.outer_r,
        minrₑ=max(model.inner_r, Gradus.isco(m)),
        verbose=true,
    )
    output .= flux[1:(end-1)]
end

# use like:

# emissivity profile must be consistent with metric
m = KerrMetric(1.0, 0.998)
d = ShakuraSunyaev(m; eddington_ratio=0.1)
lp_model = LampPostModel(h=5.0)
profile = emissivity_profile(m, d, lp_model)

model = GradusModel(r -> emissivity_at(profile, r))
# model = GradusModel(r -> r^-3)
domain = collect(range(1.0, 10.0, 150))
m = invokemodel(domain, model)
plot(domain[1:end-1], m)

# load real dataset (in this case XMM observation of MCG -6-30-15)
# useful for getting reasonable normalisations of continuum and lines
# and having a response matrix
data_path = "../Sesto2024/data"

spec = joinpath(data_path, "PN_spectrum_grp_0693781301_S003_total.fits")
back = joinpath(data_path, "PNbackground_spectrum_0693781301_S003_total.fits")
rmf = joinpath(data_path, "PN_0693781301_S003_total.rmf")
arf = joinpath(data_path, "PN_0693781301_S003_total.arf")
xmm = XmmData(spec, background=back, response=rmf, ancillary=arf)
regroup!(xmm)
drop_bad_channels!(xmm)
mask_energies!(xmm, 4.0, 10.0)
subtract_background!(xmm)
normalize!(xmm)

# setup model to simulate
DATA_TABLE_PATH = "../Sesto2024/data/thin-disc-transfer-table-900.jld2"
DATA_TABLE = jldopen(DATA_TABLE_PATH, "r") do f
    f["table"]
end

model = PowerLaw() + GradusModel(r -> emissivity_at(profile, r)) + XS_Gaussian()

# parameters based on mcg-6 fit
model.a1.K = 0.0127
model.a1.a = 1.99
model.a1.a.frozen = true

model.a2.K = 9.49e-5
model.a2.a.frozen = true
model.a2.eddington_ratio.frozen = true
model.a2.θ_obs = 40.0
model.a2.θ_obs.frozen = true
model.a2.lineE = 6.35
model.a2.lineE.frozen = true
model.a2.inner_r.frozen = true
model.a2.outer_r.frozen = true

model.a3.K = 1.04e-5
model.a3.E = 6.35
model.a3.E.frozen = true
model.a3.σ = 1.0e-5
model.a3.σ.frozen = true

model

prob = FittingProblem(model => xmm)
result = fit(prob, LevenbergMarquadt(); verbose=true)
update_model!(model, result)

plot_result(xmm, result)

# model that will be used to fit the data
# fit_model = PowerLaw() + LineProfile(x -> x^-3, DATA_TABLE) + XS_Gaussian()
fit_model = PowerLaw() + XS_Relline() + XS_Gaussian()

fit_model.a1.K = 0.0127
fit_model.a1.a = 1.99

fit_model.a2.K = 9.49e-5
fit_model.a2.lineE = 6.35
fit_model.a2.lineE.frozen = true
fit_model.a2.a = 0.5
fit_model.a2.a.frozen = false
fit_model.a2.θ_obs = 70.0
fit_model.a2.inner_r.frozen = true
fit_model.a2.outer_r.frozen = true

fit_model.a3.K = 1.04e-5
fit_model.a3.E = 6.35
fit_model.a3.σ = 1.0e-5
fit_model.a3.σ.frozen = true

fit_model.a1.a.frozen = false
fit_model.a2.a.frozen = true
fit_model.a2.θ_obs.frozen = false

fit_model

fit_prob = FittingProblem(fit_model => xmm)
fit_result = fit(fit_prob, LevenbergMarquadt(); verbose=true)
update_model!(fit_model, fit_result)

plot_result(xmm, fit_result)

# create simulations for a range of input spins
n_spin = 25
spin_values = collect(range(0.0, stop=0.998, length=n_spin))

result_grid = zeros(n_spin, n_spin)

for (i, spin_in) in enumerate(spin_values)
    println("Simulating spin ", spin_in)

    # m = KerrMetric(1.0, spin_in)
    # d = ShakuraSunyaev(m; eddington_ratio=0.1)
    # lp_model = LampPostModel(h=10.0)
    # profile = emissivity_profile(m, d, lp_model)

    # model = PowerLaw() + GradusModel(r -> emissivity_at(profile, r))
    model = PowerLaw() + GradusModel(r -> r^-3)

    model.a1.K = 0.0127
    model.a1.a = 1.99

    model.a2.K = 9.49e-5
    model.a2.eddington_ratio = 0.1
    model.a2.a = spin_in
    model.a2.θ_obs = 40.0
    model.a2.lineE = 6.4

    # new_exposure_time = xmm.spectrum.exposure_time
    # increase exposure time for better S/N
    new_exposure_time = 300_000.0

    sims = @time simulate(model, xmm.response, xmm.ancillary; exposure_time=new_exposure_time, seed=42)

    new_spec = deepcopy(xmm)
    new_spec.spectrum.exposure_time = new_exposure_time
    new_spec.spectrum.data = copy(sims.data)
    new_spec.spectrum.errors = copy(sims.variance)

    new_spec.spectrum.errors = sqrt.(new_spec.spectrum.data .* new_exposure_time) ./ (new_exposure_time .* (new_spec.energy_high .- new_spec.energy_low))
    new_spec.spectrum.data = new_spec.spectrum.data ./ (new_spec.energy_high .- new_spec.energy_low)

    # now fit for different spins and map the chi^2 of the recovered spins
    best_for_i = 1.0e4
    for (j, spin_out) in enumerate(spin_values)
        println("  Testing recovery spin ", spin_out)
        
        fit_model = PowerLaw() + XS_Relline()

        fit_model.a1.K = 0.0127
        fit_model.a1.a = 1.99

        fit_model.a2.K = 9.49e-5
        fit_model.a2.a = spin_out
        fit_model.a2.θ_obs = 40.0
        fit_model.a2.lineE = 6.4
        fit_model.a2.lineE.frozen = true
        fit_model.a2.r_break = 400.0
        fit_model.a2.index1 = 3.0
        fit_model.a2.index1.frozen = true

        fit_model.a1.a.frozen = false
        fit_model.a2.a.frozen = true
        fit_model.a2.θ_obs.frozen = false

        fit_prob = FittingProblem(fit_model => new_spec)
        fit_result = fit(fit_prob, LevenbergMarquadt(); verbose=false)

        result_grid[i, j] = fit_result.stats[1]
        println("    stat = ", result_grid[i, j])

        if result_grid[i, j] < best_for_i
            best_for_i = result_grid[i, j]
        end
        # plot_result(new_spec, new_result)
    end
    # renormalise to get Δχ^2
    for j in range(1, n_spin)
        result_grid[i, j] -= best_for_i
    end
end

# contour map of Δχ^2 values
# add contours showing goodness of fit
# perhaps also invert the colour map
heatmap(spin_values, spin_values, result_grid, xlabel="Recovered spin", ylabel="Simulated spin")
contour!(spin_values, spin_values, result_grid, color = :white, levels=[2.706, 6.635])

############ repeat analysis for thick disc ###############

# create simulations for a range of input spins
n_spin = 25
spin_values = collect(range(0.0, stop=0.998, length=n_spin))

result_grid = zeros(n_spin, n_spin)

for (i, spin_in) in enumerate(spin_values)
    println("Simulating spin ", spin_in)

    m = KerrMetric(1.0, spin_in)
    d = ShakuraSunyaev(m; eddington_ratio=0.3)
    lp_model = LampPostModel(h=4.0)
    profile = emissivity_profile(m, d, lp_model)

    model = PowerLaw() + GradusModel(r -> emissivity_at(profile, r))
    # model = PowerLaw() + GradusModel(r -> r^-3)

    model.a1.K = 0.0127
    model.a1.a = 1.99

    model.a2.K = 9.49e-5
    model.a2.eddington_ratio = 0.3
    model.a2.a = spin_in
    model.a2.θ_obs = 60.0
    model.a2.lineE = 6.4

    # new_exposure_time = xmm.spectrum.exposure_time
    # increase exposure time for better S/N
    new_exposure_time = 300_000.0

    sims = @time simulate(model, xmm.response, xmm.ancillary; exposure_time=new_exposure_time, seed=42)

    new_spec = deepcopy(xmm)
    new_spec.spectrum.exposure_time = new_exposure_time
    new_spec.spectrum.data = copy(sims.data)
    new_spec.spectrum.errors = copy(sims.variance)

    new_spec.spectrum.errors = sqrt.(new_spec.spectrum.data .* new_exposure_time) ./ (new_exposure_time .* (new_spec.energy_high .- new_spec.energy_low))
    new_spec.spectrum.data = new_spec.spectrum.data ./ (new_spec.energy_high .- new_spec.energy_low)

    # now fit for different spins and map the chi^2 of the recovered spins
    best_for_i = 1.0e4
    for (j, spin_out) in enumerate(spin_values)
        println("  Testing recovery spin ", spin_out)
        
        fit_model = PowerLaw() + XS_Relline()

        fit_model.a1.K = 0.0127
        fit_model.a1.a = 1.99

        fit_model.a2.K = 9.49e-5
        fit_model.a2.a = spin_out
        fit_model.a2.θ_obs = 40.0
        fit_model.a2.lineE = 6.4
        fit_model.a2.lineE.frozen = true
        fit_model.a2.r_break = 400.0
        fit_model.a2.index1 = 3.0
        fit_model.a2.index1.frozen = true

        fit_model.a1.a.frozen = false
        fit_model.a2.a.frozen = true
        fit_model.a2.θ_obs.frozen = false

        fit_prob = FittingProblem(fit_model => new_spec)
        fit_result = fit(fit_prob, LevenbergMarquadt(); verbose=false)

        result_grid[i, j] = fit_result.stats[1]
        println("    stat = ", result_grid[i, j])

        if result_grid[i, j] < best_for_i
            best_for_i = result_grid[i, j]
        end
        # plot_result(new_spec, new_result)
    end
    # renormalise to get Δχ^2
    for j in range(1, n_spin)
        result_grid[i, j] -= best_for_i
    end
end

# contour map of Δχ^2 values
# add contours showing goodness of fit
# perhaps also invert the colour map
heatmap(spin_values, spin_values, result_grid, xlabel="Recovered spin", ylabel="Simulated spin")
contour!(spin_values, spin_values, result_grid, color = :white, levels=[2.706, 6.635])
