module Sudokus

using Random

include("Utilities.jl")

"""
    function removeEntries!(sudoku::Array{T}, clues::UInt) where T <: Unsigned

Removes entries until the number of clues is equal to `clues`.
"""
function removeEntries!(sudoku::Array{T}, clues::UInt) where T <: Unsigned
    N = T(size(sudoku, 1))

    cordSystem = [(i,j) for i in T(1):N, j in T(1):N]
    remove_sequence = Matrix{NTuple{2, T}}(undef, N, N)

    sud_copy = copy(sudoku)

    max_nz = 0
    numCand = T(1)
    while true
        copy!(sud_copy, sudoku)
        copy!(remove_sequence, cordSystem)
        shuffle!(remove_sequence)
        nnz = N*N
        for c in remove_sequence
            tmp = sud_copy[c...]
            sud_copy[c...] = 0
            try
                solve(sud_copy)
                nnz -= 1
                if nnz == clues
                    copy!(sudoku, sud_copy)
                    return
                end
            catch
                sud_copy[c...] = tmp
                break
            end
        end
    end
    copy!(sudoku, sud_copy)
end

"""
    function removeEntries(sudoku::Array{T}, clues::UInt) where T <: Unsigned

Removes entries until the number of clues is equal to `clues`.
"""
function removeEntries(sudoku::Array{T}, clues::UInt) where T <: Unsigned
    sud = copy(sudoku)
    removeEntries!(sud, clues)
    sud
end

"""
    function solve!(sudoku::Array{T}) where T <: Unsigned

Solves a sudoku in-place replacing all zero entries.

Throws ArgumentError when sudoku is not uniquely solvable.
"""
function solve!(sudoku::Matrix{T}) where T <: Unsigned
    N = T(size(sudoku, 1))
    n = T(sqrt(N))

    cordSystem = [(i,j) for i in T(1):N, j in T(1):N]

    # cand = [zeros(Bool, N) for i = 1:N, j = 1:N]
    cand = [zeros(Bool, N) for n = 1:N]
    cord_cand = zeros(Bool, N)

    last_nz = countZeros(sudoku)
    while true
        for r = T(1):3, t = T(1):N
            cords = selectTile(r, t, n, cordSystem)
            for (ic, c) in enumerate(cords)
                fill!(cand[ic], true)
                discardPresent!(cand[ic], c..., T(n), sudoku)
                if sum(cand[ic]) == 1
                    sudoku[cords[ic]...] = firstNonZero(cand[ ic])
                end
            end
            for in in 1:N
                fill!(cord_cand, false)
                for (ic, c) in enumerate(cords)
                    cord_cand[ic] = cand[ic][in]
                end
                if sum(cord_cand) == 1
                    sudoku[cords[firstNonZero(cord_cand)]...] = in
                end
            end
        end
        nz = countZeros(sudoku)
        if nz == 0
            last_nz = nz
            break
        end
        if last_nz == nz
            break
        end
        last_nz =nz
    end
    if last_nz > 0
        # printSudoku(sudoku)
        throw(ArgumentError("Sudoku has no unique solution"))
    end
end

"""
    function solve(sudoku::Array{T}) where T <: Unsigned

Solves a sudoku in-place replacing all zero entries.

Throws ArgumentError when sudoku is not uniquely solvable.
"""
function solve(sudoku::Matrix{T}) where T <: Unsigned
    sud = copy(sudoku)
    solve!(sud)
    sud
end

"""
    function generateGrid(N::T) where T <: Unsigned

Generates a full sudoku grid with dimension `N×N`. `N = n×n; n ∈ Integer`.

`T` is used for all calculations.
"""
function generateGrid(N::T) where T <: Unsigned
    @assert round(sqrt(N))^2 == N
    n = T(sqrt(N))
    sudoku = zeros(T, N, N)
    cache = zeros(T, N)

    init = collect(T, 1:N)
    r = ones(Bool, N)

    candidates = copy(init)

    @label restart
    fill!(sudoku, T(0))
    for i in T(1):N, j in T(1):N
        fill!(r, true)
        discardPresent!(r, i, j, n, sudoku)
        if sum(r) == 0
            @goto restart
        end
        copy!(candidates, init)
        reject!(candidates, r)
        shuffle!(candidates)
        for c in candidates
            if c == 0
                continue
            end
            sudoku[i, j] = c
            if check(sudoku, n, cache)
                break
            end
        end 
    end

    sudoku
end

"""
    function generate(N::T, num_clues::UInt) where T <: Unsigned

Generates Sudoku of size `N×N` with `num_clues` clues.

Beware less them 27 clues will take a long time!
"""
function generate(N::T, num_clues::UInt) where T <: Unsigned
    sudoku = generateGrid(N)
    removeEntries!(sudoku, num_clues)
    sudoku
end

export generate, generateGrid, removeEntries!, removeEntries, solve!, solve, printSudoku, readSudoku

end