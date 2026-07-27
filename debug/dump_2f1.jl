using Enzyme, Gamma, HypergeometricFunctions
import Enzyme_jll
@assert Base.get_extension(Enzyme, :EnzymeGammaExt) !== nothing
println("libEnzyme: ", Enzyme_jll.libEnzyme); flush(stdout)

F(a, b, c, z) = HypergeometricFunctions._₂F₁(a, b, c, z)
println("2F1 reverse start"); flush(stdout)
g = Enzyme.gradient(Enzyme.Reverse, Enzyme.Const(F), 1.1, 1.3, 2.3, 0.4)
println("grad: ", g)
