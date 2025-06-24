# routine to fit data with model
# could be real data or simulated data

z_mcg = 0.00775

using SpectralFitting, XSPECModels
using Plots
using GradusSpectralModels, JLD2, CodecZlib

# nice plotting routine
function plot_result(data, results...)
    p1 = plot(data,
        ylims = (3.0e-2, 2.0),
        xscale = :log10,
        yscale = :log10,
        legend = :bottomleft,
        xticks = ([4, 5, 6, 7, 8, 9, 10], ["", "", "", "", "", "", ""]),
        xlabel = ""
    )
    p2 = plot(xscale = :log10)
    for r in results
        plot!(p1, r)
        residualplot!(p2, r, xticks = ([4, 5, 6, 7, 8, 9, 10], ["4", "5", "6", "7", "8", "9", "10"]))
    end
    plot(p1, p2, link = :x, layout = @layout [top{0.75h} ; bottom{0.25h}])
end

# load real dataset (in this case XMM observation of MCG -6-30-15)
# useful for getting reasonable normalisations of continuum and lines
data_path = "../Sesto2024/data"

spec = joinpath(data_path, "PN_spectrum_grp_0693781301_S003_total.fits")
back = joinpath(data_path, "PNbackground_spectrum_0693781301_S003_total.fits")
rmf = joinpath(data_path, "PN_0693781301_S003_total.rmf")
arf = joinpath(data_path, "PN_0693781301_S003_total.arf")
xmm = XmmData(spec, background = back, response = rmf, ancillary = arf)
regroup!(xmm)
drop_bad_channels!(xmm)
mask_energies!(xmm, 4.0, 10.0)
subtract_background!(xmm)
normalize!(xmm)

plot(xmm, xscale = :log10, yscale = :log10)

# fit a simple model
DATA_TABLE_PATH = "../Sesto2024/data/thin-disc-transfer-table-900.jld2"
DATA_TABLE = jldopen(DATA_TABLE_PATH, "r") do f
    f["table"]
end

model =  PowerLaw() + LineProfile(x -> x^-3, DATA_TABLE) + XS_Gaussian()

model.a1.K = 0.0116
model.a1.K.upper_limit = 0.1
model.a1.a = 1.94
model.a1.a.upper_limit = 4.0

model.a2.K = 1.18e-6
model.a2.K.upper_limit = 0.1
model.a2.a.upper_limit = 0.998
model.a2.θ = 30.0
model.a2.rin.frozen = true
model.a2.rout.frozen = true
model.a2.E₀.lower_limit = 6.4 / (1.0 + z_mcg)
model.a2.E₀.upper_limit = 6.9 / (1.0 + z_mcg)
model.a2.E₀.frozen = false

model.a3.K = 1.0e-5
model.a3.E = 6.4 / (1.0 + z_mcg)
model.a3.σ = 1.0e-5
model.a3.σ.frozen = true

model

prob = FittingProblem(model => xmm)
result = fit(prob, LevenbergMarquadt(); verbose = true)
update_model!(model, result)

plot_result(xmm, result)
