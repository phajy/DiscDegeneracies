# create simulated spectra from models

using SpectralFitting, XSPECModels
using Plots
using GradusSpectralModels, JLD2, CodecZlib

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

# load real dataset (in this case XMM observation of MCG -6-30-15)
# useful for getting reasonable normalisations of continuum and lines
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

model = PowerLaw() + LineProfile(x -> x^-3, DATA_TABLE) + XS_Gaussian()

# parameters based on mcg-6 fit
model.a1.K = 0.0127
model.a1.a = 1.99

model.a2.K = 9.49e-5
model.a2.θ_obs = 42.9
model.a2.lineE = 6.35

model.a3.K = 1.04e-5
model.a3.E = 6.4
model.a3.σ = 1.0e-5

model.a1.a.frozen = true
model.a2.a.frozen = true
model.a2.θ_obs.frozen = true
model.a2.inner_r.frozen = true
model.a2.outer_r.frozen = true
model.a2.lineE.frozen = true
model.a3.σ.frozen = true

model

prob = FittingProblem(model => xmm)
result = fit(prob, LevenbergMarquadt(); verbose=true)
update_model!(model, result)

plot_result(xmm, result)

# create simulations for a range of input spins
n_spin = 25
spin_values = collect(range(0.0, stop=0.998, length=n_spin))

result_grid = zeros(n_spin, n_spin)

for (i, spin_in) in enumerate(spin_values)
    println("Simulating spin ", spin_in)

    model.a1.K = 0.0127
    model.a1.a = 1.99

    model.a2.K = 9.49e-5
    model.a2.a = spin_in
    model.a2.θ_obs = 42.9
    model.a2.lineE = 6.35

    model.a3.K = 1.04e-5
    model.a3.E = 6.4
    model.a3.σ = 1.0e-5

    model.a1.a.frozen = false
    model.a2.a.frozen = true
    model.a2.θ_obs.frozen = false

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

    plot(xmm, xscale=:log10, yscale=:log10, label="XMM Data")
    plot!(new_spec)

    new_prob = FittingProblem(model => new_spec)

    # now fit for different spins and map the chi^2 of the recovered spins
    best_for_i = 1.0e4
    for (j, spin_out) in enumerate(spin_values)
        println("  Testing recovery spin ", spin_out)
        model.a1.K = 0.0127
        model.a1.a = 1.99

        model.a2.K = 9.49e-5
        model.a2.a = spin_out
        model.a2.θ_obs = 42.9
        model.a2.lineE = 6.35

        model.a3.K = 1.04e-5
        model.a3.E = 6.4
        model.a3.σ = 1.0e-5

        model.a1.a.frozen = false
        model.a2.a.frozen = true
        model.a2.θ_obs.frozen = false

        new_result = fit(new_prob, LevenbergMarquadt(); verbose=false)

        result_grid[i, j] = new_result.stats[1]
        # println("    stat = ", result_grid[i, j])

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

# contours of 90% and 99% confidence
heatmap(spin_values, spin_values, result_grid, xlabel="Recovered spin", ylabel="Simulated spin")
contour!(spin_values, spin_values, result_grid, color = :white, levels=[2.706, 6.635])
