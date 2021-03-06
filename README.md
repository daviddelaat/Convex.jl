# Convex.jl

[![Build Status](https://travis-ci.org/JuliaOpt/Convex.jl.svg?branch=master)](https://travis-ci.org/JuliaOpt/Convex.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaOpt/Convex.jl/badge.svg?branch=master)](https://coveralls.io/r/JuliaOpt/Convex.jl?branch=master)

[![Convex](http://pkg.julialang.org/badges/Convex_0.3.svg)](http://pkg.julialang.org/?pkg=Convex&ver=0.3)
[![Convex](http://pkg.julialang.org/badges/Convex_0.4.svg)](http://pkg.julialang.org/?pkg=Convex&ver=0.4)

**Convex.jl** is a [Julia](http://julialang.org) package for [Disciplined Convex Programming](http://dcp.stanford.edu/). Convex.jl can solve linear programs, mixed-integer linear programs, and DCP-compliant convex programs using a variety of solvers, including [Mosek](https://github.com/JuliaOpt/Mosek.jl), [Gurobi](https://github.com/JuliaOpt/Gurobi.jl), [ECOS](https://github.com/JuliaOpt/ECOS.jl), [SCS](https://github.com/JuliaOpt/SCS.jl), [GLPK](https://github.com/JuliaOpt/GLPK.jl), through the [MathProgBase](http://mathprogbasejl.readthedocs.org/en/latest/) interface.

**Installation**: `julia> Pkg.add("Convex")`

- **Detailed documentation and examples** for Convex.jl can be found [here](http://convexjl.readthedocs.org/)
- If you're running into **bugs or have feature requests**, please use the [Github Issue Tracker](https://github.com/JuliaOpt/Convex.jl/issues>).
- For usage questions, please contact us via the [JuliaOpt mailing list](https://groups.google.com/forum/#!forum/julia-opt)

## Quick Example

Here's a quick example of code that solves a least-squares problem with inequality constraints
```julia
# Let us first make the Convex.jl module available
using Convex

# Generate random problem data
m = 4;  n = 5
A = randn(m, n); b = randn(m, 1)

# Create a (column vector) variable of size n x 1.
x = Variable(n)

# The problem is to minimize ||Ax - b||^2 subject to x >= 0
# This can be done by: minimize(objective, constraints)
problem = minimize(sumsquares(A * x - b), [x >= 0])

# Solve the problem by calling solve!
solve!(problem)

# Check the status of the problem
problem.status # :Optimal, :Infeasible, :Unbounded etc.

# Get the optimal value
problem.optval
```

## More Examples
A number of examples can be found [here](http://convexjl.readthedocs.org/en/latest/examples.html). 
The [basic usage notebook](http://nbviewer.ipython.org/github/JuliaOpt/Convex.jl/blob/master/examples/basic_usage.ipynb) gives a simple tutorial on problems that can be solved using Convex.jl


## Citing this package

If you use Convex.jl for published work, we encourage you to cite the software using the following BibTeX citation:
```
@article{convexjl,
 title = {Convex Optimization in {J}ulia},
 author ={Udell, Madeleine and Mohan, Karanveer and Zeng, David and Hong, Jenny and Diamond, Steven and Boyd, Stephen},
 year = {2014},
 journal = {SC14 Workshop on High Performance Technical Computing in Dynamic Languages},
 archivePrefix = "arXiv",
 eprint = {1410.4821},
 primaryClass = "math-oc",
}
```

> Convex.jl was previously called CVX.jl.
