# Staged reproducer for the ext/gamma CI hang (PR #3298).
# Run in an environment with Enzyme (dev), Gamma, HypergeometricFunctions,
# FiniteDifferences. Prints STAGE START/DONE markers so a watchdog can tell
# exactly which stage stalls.

macro stage(name, ex)
    return quote
        println("STAGE START: ", $name); flush(stdout)
        t = time()
        $(esc(ex))
        println("STAGE DONE:  ", $name, "  (", round(time() - t; digits = 1), "s)"); flush(stdout)
    end
end

println("JULIA PID: ", getpid())
println("VERSION: ", VERSION); flush(stdout)

@stage "load" begin
    using Enzyme, Gamma, HypergeometricFunctions, FiniteDifferences
    @assert Base.get_extension(Enzyme, :EnzymeGammaExt) !== nothing
end

@stage "scalar reverse" begin
    autodiff(ReverseHolomorphic, Gamma.gamma, Active, Active(0.5))
end

@stage "scalar forward" begin
    autodiff(Forward, Gamma.gamma, Duplicated(0.5, 1.0))
end

F(a, b, c, z) = HypergeometricFunctions._₂F₁(a, b, c, z)

@stage "2F1 reverse" begin
    g = Enzyme.gradient(Enzyme.Reverse, Enzyme.Const(F), 1.1, 1.3, 2.3, 0.4)
    println("  -> ", g)
end

@stage "2F1 forward" begin
    g = Enzyme.gradient(Enzyme.Forward, Enzyme.Const(F), 1.1, 1.3, 2.3, 0.4)
    println("  -> ", g)
end

println("ALL STAGES COMPLETE")
