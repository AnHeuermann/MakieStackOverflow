# Issue 2582

Produce issue [Makie.jl #2582](https://github.com/MakieOrg/Makie.jl/issues/2582).

## How to reproduce

Run
```julia
julia --project=. --threads=auto -e "include(\"test/runtests.jl\")"
```

For me I only get the stack overflow when running file `test/runtests.jl` directly from
VS Code. Using the Julia extension and hit the `Julia: Execute active file in REPL` button.
