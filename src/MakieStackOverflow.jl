module MakieStackOverflow

using CairoMakie
using CSV
using DataFrames

function produceStackOverflow()
  usingVars = ["time", "groupBus1_1.Syn1.delta", "groupBus1_1.Syn1.e2d", "groupBus1_1.Syn1.e2q", "groupBus8_1.Syn4.e2d", "groupBus8_1.Syn4.e2q", "groupBus3_1.Syn2.delta", "groupBus3_1.Syn2.e2q", "groupBus3_1.Syn2.e2d", "groupBus2_1.Syn3.delta", "groupBus2_1.Syn3.e2q", "groupBus2_1.Syn3.e2d", "groupBus6_1.Syn5.delta", "groupBus6_1.Syn5.e2d", "groupBus6_1.Syn5.e2q", "groupBus8_1.Syn4.delta"]
  iterationVariables = ["L13.ir.re", "lPQ10.p.ir", "L13.ir.im", "L14.is.im", "pwLinewithOpeningSending.ir.im", "L8.ir.im", "L8.is.re", "lPQ2.p.ir", "L1.ir.im", "lPQ2.p.ii", "L1.is.im", "pwLinewithOpeningSending.is.im", "lPQ3.p.ii", "pwLinewithOpeningSending.is.re", "lPQ3.p.ir", "L6.ir.im", "L6.ir.re", "L8.ir.re", "L5.ir.re", "L5.ir.im", "L5.is.re", "L6.is.re", "lPQ12.p.ii", "L6.is.im", "L3.ir.re", "L7.ir.im", "pwLinewithOpeningSending.ir.re", "L1.ir.re", "lPQ5.p.ir", "lPQ5.p.ii", "L15.is.re", "lPQ9.p.ir", "L15.is.im", "lPQ9.p.ii", "L16.is.re", "L16.is.im", "L16.ir.im", "L17.is.im", "lPQ11.p.ir", "L17.ir.re", "L11.is.im", "lPQ7.p.ii", "L11.is.re", "L10.ir.re", "L17.ir.im", "L11.ir.im", "lPQ4.p.ir", "L10.is.re", "lPQ4.p.ii", "L10.is.im", "L12.is.im", "L12.is.re", "L12.ir.re", "L12.ir.im", "L16.ir.re", "L17.is.re", "lPQ8.p.ir", "L14.ir.re", "lPQ8.p.ii", "L14.ir.im", "groupBus6_1.Syn5.iq", "groupBus6_1.Syn5.id", "groupBus2_1.Syn3.id", "groupBus2_1.Syn3.iq", "groupBus3_1.Syn2.id", "groupBus3_1.Syn2.iq", "groupBus8_1.Syn4.id", "groupBus8_1.Syn4.iq", "L3.is.re", "L3.is.im", "groupBus1_1.Syn1.iq", "groupBus1_1.Syn1.id", "twoWindingTransformer.is.re", "twoWindingTransformer.ir.im", "L2.is.re", "tWTransformerWithFixedTapRatio2.ir.im", "tWTransformerWithFixedTapRatio2.is.im", "tWTransformerWithFixedTapRatio2.vr.im", "L3.vs.im", "L3.vs.re", "L5.vs.im", "L5.vs.re", "tWTransformerWithFixedTapRatio.is.re", "tWTransformerWithFixedTapRatio.ir.re", "tWTransformerWithFixedTapRatio.vs.re", "tWTransformerWithFixedTapRatio1.ir.im", "tWTransformerWithFixedTapRatio1.is.re", "tWTransformerWithFixedTapRatio1.vr.re", "tWTransformerWithFixedTapRatio.vr.im", "tWTransformerWithFixedTapRatio.vr.re", "pwLinewithOpeningSending.vr.re", "pwLinewithOpeningSending.vr.im", "pwLinewithOpeningSending.vs.im", "pwLinewithOpeningSending.vs.re", "lPQ9.a", "lPQ5.a", "lPQ12.a", "lPQ3.a", "lPQ2.a", "lPQ4.a", "L14.vs.re", "L15.vr.re", "L15.vr.im", "L17.vs.im", "L17.vs.re", "L11.vr.im", "L11.vr.re", "L11.vs.im", "L11.vs.re", "L14.vs.im"]
  ref_csv = normpath(joinpath(@__DIR__, "..", "data", "IEEE_14_Buses_ref.csv"))
  ref_results = CSV.read(ref_csv, DataFrame; ntasks=1)
  onnx_csv = normpath(joinpath(@__DIR__, "..", "data", "eq_1403_1000000_p_1.csv"))
  onnx_results = CSV.read(onnx_csv, DataFrame; ntasks=1)

  trainData = nothing

  figure = myPlot(iterationVariables, ref_results; df_surrogate=onnx_results, title="Some title", epsilon=0.1)
  save("test.png", figure)
end
export produceStackOverflow

function myPlot(vars::Array{String},
                df_ref::DataFrames.DataFrame;
                df_surrogate::DataFrames.DataFrame,
                title="",
                epsilon=0.01)

  nRows = Integer(ceil(sqrt(length(vars))))

  fig = Figure(fontsize=32,
               resolution=(nRows * 800, nRows * 600))

  Label(fig[0, :], text=title, fontsize=32, tellwidth=false, tellheight=true)
  grid = GridLayout(nRows, nRows; parent=fig)

  local l1, l2
  l3 = nothing
  l4 = nothing
  row = 1
  col = 1
  for (i, var) in enumerate(vars)
    axis = Axis(grid[row, col],
                xlabel="time",
                ylabel=var)

    # Plot reference solution
    l1 = CairoMakie.lines!(axis,
                           df_ref.time, df_ref[!, var],
                           label="ref")

    # Plot ϵ tube
    l2 = CairoMakie.lines!(axis,
                           df_ref.time, epsilonTube(df_ref[!, var], epsilon),
                           color=:seagreen,
                           linestyle=:dash)

    CairoMakie.lines!(axis,
                      df_ref.time, epsilonTube(df_ref[!, var], -epsilon),
                      color=:seagreen,
                      linestyle=:dash,
                      label="ϵ: ±$epsilon")

    # Plot surrogate solution
    if df_surrogate !== nothing
      l3 = CairoMakie.lines!(axis,
                             df_surrogate.time, df_surrogate[!, var],
                             color=:orangered1,
                             linestyle=:dashdot,
                             label="surrogate")
    end

    # Update row and col
    if i % nRows == 0
      row += 1
      col = 1
    else
      col += 1
    end
  end

  fig[1, 1] = grid

  labels = Vector{Any}([l1, l2])
  label_names = ["reference", "ϵ: ±$epsilon"]
  push!(labels, l3)
  push!(label_names, "surrogate")

  Legend(fig[2, 1],
         labels,
         label_names,
         orientation=:horizontal, tellwidth=false, tellheight=true)

  return fig
end

function epsilonTube(values::Vector{Float64}, ϵ=0.1)
  nominal = 0.5 * (minimum(abs.(values)) + maximum(abs.(values)))
  return values .+ ϵ * nominal
end

end # module MakieStackOverflow
