using SpectralFitting, Plots, GradusSpectralModels, XSPECModels
using JLD2, CodecZlib
using Relxill

function plot_result(data, results...)
    p1 = plot(data,
        ylims = (0.001, 2.0),
        xscale = :log10,
        yscale = :log10,
        legend = :bottomleft,
    )
    p2 = plot(xscale = :log10)
    for r in results
        plot!(p1, r)
        residualplot!(p2, r)
    end
    plot(p1, p2, link = :x, layout = @layout [top{0.75h} ; bottom{0.25h}])
end

data_path = "/data/repos/andy_sesto2024/data"

spec = joinpath(data_path, "PN_spectrum_grp_0693781301_S003_total.fits")
back = joinpath(data_path, "PNbackground_spectrum_0693781301_S003_total.fits")
rmf = joinpath(data_path, "PN_0693781301_S003_total.rmf")
arf = joinpath(data_path, "PN_0693781301_S003_total.arf")
xmm = XmmData(spec, background = back, response = rmf, ancillary = arf)
regroup!(xmm)
drop_bad_channels!(xmm)
mask_energies!(xmm, 3.0, 10.0)
subtract_background!(xmm)
normalize!(xmm)

plot(xmm, xscale = :log10, yscale = :log10)

DATA_TABLE_PATH = "/data/repos/andy_sesto2024/data/thin-disc-transfer-table-900.jld2"
DATA_TABLE = jldopen(DATA_TABLE_PATH, "r") do f
    f["table"]
end

m = XS_Relline()
# m = LineProfile(x -> x^-3, DATA_TABLE)
model = XS_NeutralHydrogenAbsorption() * ( PowerLaw() + m )

for p in SpectralFitting.parameter_vector(model)
    p.frozen = true
end
model.a1.K.frozen = false
model.a2.K.frozen = false
model.a2.lineE = 6.4
model.a2.outer_r = 400
# model.a3.K.frozen = false

model

prob = FittingProblem(model => xmm)
result = fit(prob, LevenbergMarquadt(); verbose = true)
update_model!(model, result[1])

model.a1.a.frozen = false
model.a2.a.frozen = false
# model.a3.μ.frozen = false
# model.a3.σ.frozen = false
model.a2.θ_obs.frozen = false
model.m1.nH.frozen = false

model

prob = FittingProblem(model => xmm)
result = fit(prob, LevenbergMarquadt(); verbose = true)
update_model!(model, result[1])

plot_result(xmm, result[1])

model2


domain = collect(range(0.1, 10.0, 200))
o1 = invokemodel(domain, model.a2)
o2 = invokemodel(domain, model2.a2)


plot(domain[1:end-1], o1)
plot!(domain[1:end-1], o2)