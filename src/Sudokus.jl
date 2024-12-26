module Sudokus

using Random

include("Utilities.jl")

"""
    function removeEntries!(sudoku::Array{T}) where T <: Unsigned

Removes entries step by step only removing uniquely solvable.
"""
function removeEntries!(sudoku::Array{T}) where T <: Unsigned
    N = T(size(sudoku, 1))
    n = T(sqrt(N))
    
    cand = [zeros(Bool, N) for i = 1:N, j = 1:N]
    cache = zeros(T, N * N)

    r = ones(Bool, N)

    numCand = T(1)
    while true
        nnz = 0
        for i in T(1):N, j in T(1):N
            if sudoku[i, j] == 0
                fill!(cand[i,j], false)
                continue
            end
            value = sudoku[i, j]
            sudoku[i, j] = 0
            fill!(r, true)
            discardPresent!(r, i, j, n, sudoku)
            if sum(r) == 1
                copy!(cand[i, j], r)
                nnz += 1 
            end
            sudoku[i, j] = value
        end

        if nnz == 0
            break
        end
        
        numCand = condenseNonZero!(cache, cand, N)
        sudoku[cache[(rand(T) % numCand)+1]] = 0
    end
    sudoku
end

"""
    function removeEntries(sudoku::Array{T}) where T <: Unsigned

Removes entries step by step only removing uniquely solvable.
"""
function removeEntries(sudoku::Array{T}) where T <: Unsigned
    sud = copy(sudoku)
    removeEntries!(sud)
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
                    sudoku[cords[ic]...] = firstNZ(cand[ ic])
                end
            end
            for in in 1:N
                fill!(cord_cand, false)
                for (ic, c) in enumerate(cords)
                    cord_cand[ic] = cand[ic][in]
                end
                if sum(cord_cand) == 1
                    sudoku[cords[firstNZ(cord_cand)]...] = in
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
        printSudoku(stderr::IO, sudoku)
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

# """
#     function solve!(sudoku::Array{T}) where T <: Unsigned

# Solves a sudoku in-place replacing all zero entries.

# Throws ArgumentError when sudoku is not uniquely solvable.
# """
# function solve!(sudoku::Array{T}) where T <: Unsigned
#     N = T(size(sudoku, 1))
#     n = T(sqrt(N))
    
#     cand = zeros(T, N, N)
#     cache = zeros(T, N * N)

#     init = collect(T, 1:N)
#     r = Array{T}(undef, N)

#     j = T(1)
#     while true
#         fill!(cand, T(0))
#         for i in T(1):N, j in T(1):N
#             if sudoku[i, j] != 0
#                 continue
#             end
#             copy!(r, init)
#             discardPresent!(r, i, j, n, sudoku)
#             if countZeros(r) == N-1
#                 cand[i, j] = sum(r)
#             end
#         end
        
#         if countZeros(cand) == N*N
#             break
#         end
        
#         j = condenseNonZero!(cache, cand, N)
#         entry = rand(T) % j +1
#         sudoku[cache[entry]] = cand[cache[entry]]
#     end
#     if countZeros(sudoku) > 0
#         throw(ArgumentError("Sudoku has no unique solution"))
#     end
#     sudoku
# end

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
    
    return sudoku
end

export generateGrid, randomPlacement, removeEntries!, removeEntries, solve!, solve, printSudoku

end