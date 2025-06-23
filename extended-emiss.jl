using Makie, CairoMakie
using Optim
using MultiLinearInterpolations

# the gamma indices
GAMMAS = collect(range(1.0, 4.0, 15))

struct DataContainer{V}
    values::V
end

MultiLinearInterpolations.restructure(::DataContainer, vs::AbstractVector) =
    DataContainer(vs)

struct EmissivityTable{T}
    "Spin, R, Inclination"
    params::NTuple{3,Vector{T}}
    grids::Array{DataContainer{Vector{T}},3}
    # radii grid only changes with
    radii::Array{DataContainer{Vector{T}},1}
    "Emissivity curve interpolator"
    emi_interp::MultilinearInterpolator{3,T}
    "Radii interpolator"
    rad_interp::MultilinearInterpolator{1,T}
end

function Base.show(io::IO, ::MIME"text/plain", @nospecialize(et::EmissivityTable))
    N = size(et.grids)
    a_ex = extrema(et.params[1])
    R_ex = extrema(et.params[2])
    i_ex = extrema(et.params[3])
    println(io, "EmissivityTable[shape = $N, a ∈ $a_ex, R ∈ $R_ex, i ∈ $i_ex]")
end

function interpolate_grid!(et::EmissivityTable, a, R, inc)
    em = MultiLinearInterpolations.interpolate!(
        et.emi_interp,
        et.params,
        et.grids,
        (a, R, inc),
    )
    r = MultiLinearInterpolations.interpolate!(
        et.rad_interp,
        (et.params[1],),
        et.radii,
        (a,),
    )
    (; r = r.values, e = 10 .^ em.values)
end

struct EmissivityData
    radii::Vector{Float64}
    # each column [:, i] is a single run
    emissivities::Matrix{Float64}
    "Spin"
    a::Float64
    "Radius away from BH (1 is isco, 15 is 50rg, geometrically spaced)"
    R::Float64
    "Inclination"
    i::Float64
end

function build_table(data::Vector{EmissivityData})
    a_range = sort!(unique(i.a for i in data))
    i_range = sort!(unique(i.i for i in data))
    R_range = collect(range(1.0, 15.0, 15))

    function get_data(a, i)
        v = filter(d -> (d.a == a) && (d.i == i), data)
        sort!(v, by = i->i.R)
    end

    ordered = [get_data(a, i)[k] for a in a_range, k in eachindex(R_range), i in i_range]
    # TODO: get all Γ (currently just selecting one)
    grids = [DataContainer(log10.(o.emissivities[:, 6])) for o in ordered]
    radii_grids = [DataContainer(o.radii) for o in @views ordered[1:length(a_range)]]
    emi_interp = MultilinearInterpolator{3}(grids)
    rad_interp = MultilinearInterpolator{1}(radii_grids)
    EmissivityTable((a_range, R_range, i_range), grids, radii_grids, emi_interp, rad_interp)
end

function read_emissivity(file)
    f, _ = splitext(file)
    components = split(f, "_")
    a::Union{Nothing,Float64} = nothing
    R::Union{Nothing,Float64} = nothing
    i::Union{Nothing,Float64} = nothing
    for c in components
        if c[1] == 'a'
            a = parse(Float64, c[2:end])
        elseif c[1] == 'R'
            R = parse(Float64, c[2:end])
        elseif c[1:2] == "th"
            i = parse(Float64, c[3:end])
        end
    end

    bytes = open(file, "r") do f
        readavailable(f)
    end
    v = reinterpret(Float64, bytes)
    dat = map(1:300:3900) do i
        v[i:(i+300-1)]
    end
    EmissivityData(dat[1], reduce(hcat, dat[2:end]), a, R, i)
end

# CHANGE ME
ROOT_DIR = "/data/astro/model-data/output/"

# The cleaned curves have had some noise removed with a simple interpolation
# script
all_cleaned = filter(i -> !occursin("clean", i), readdir(ROOT_DIR))

all_dats = map(i -> read_emissivity(joinpath(ROOT_DIR, i)), all_cleaned)

# Check one
begin
    dat = all_dats[2]
    fig = Figure()
    ax = Axis(fig[1, 1], xscale = log10, yscale = log10)
    ylims!(ax, 1e-7, 1e1)
    for em in eachcol(dat.emissivities)
        lines!(ax, dat.radii, em)
    end
    fig
end

# Create the interpolated table
table = build_table(all_dats)
dat = interpolate_grid!(table, 0.9, 1.0, 10.0)

# Varying angle of the source
begin
    fig = Figure()
    ax = Axis(fig[1, 1], xscale = log10, yscale = log10)
    th_range = range(5, 80, 100)
    for th in th_range
        dat = interpolate_grid!(table, 0.998, 2.0, th)
        lines!(
            ax,
            dat.r[1:(end-1)],
            dat.e[1:(end-1)],
            color = th,
            colorrange = extrema(th_range),
            colormap = :batlow,
        )
    end
    fig
end

# Varying radius of the source
begin
    fig = Figure()
    ax = Axis(fig[1, 1], xscale = log10, yscale = log10)
    th = 80
    ax.title = "Emissivity a=0.9, i=$(th)°"
    ax.xlabel = "r"
    ax.ylabel = "ϵ"
    r_range = range(1.5, 14.5, 15)
    for r in r_range
        dat = interpolate_grid!(table, 0.8, r, Float64(th))
        rs = dat.r[1:(end-1)]
        es = dat.e[1:(end-1)]
        lines!(ax, rs, es, color = r, colorrange = extrema(r_range), colormap = :batlow)
    end
    vlines!(ax, [2], color = :red)
    fig
end
