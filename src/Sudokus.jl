module Sudokus

using Random

"""
    function countZeros(r::Array{T}) where T <: Unsigned

Counts the amount of zero entries in `r`.
"""
function countZeros(r::Array{T}) where T <: Unsigned
    sum = T(0)
    for i in r
        if i == 0
            sum += 1
        end
    end
    sum
end

"""
    function gotMultiple(list::Array{T}, cache::Array{T}) where T <: Unsigned

Test if list has multiple entries of the same value.

`@assert length(cache) >= maximum(list)`
"""
function gotMultiple(list::Array{T}, cache::Array{T}) where T <: Unsigned
    fill!(cache, T(0))
    for i in list
        if i == 0
            continue
        end
        cache[i] += 1
        if cache[i] > 1
            return true
        end
    end
    false
end

"""
    function condenseNonZero!(cache::Array{T}, list::Array{T}, N::T) where T <: Unsigned

Writes indices of non zero entries of `list` sequencialy to `cache`. 

Returns index of last non zero entry in `cache`
"""
function condenseNonZero!(cache::Array{T}, list::Array{T}, N::T) where T <: Unsigned
    j = T(0)
    fill!(cache, T(0))
    for i in T(1):N*N
        if list[i] != 0
            j += 1
            cache[j] = i
        end
    end
    j
end

"""
    function discardPresent!(candidates::Array{T}, list::Array{T}) where T <: Unsigned

Sets entries of `candidates` at indices of `list` to zero.
"""
function discardPresent!(candidates::Array{T}, list::Array{T}) where T <: Unsigned
    for i in list
        if i == 0 || candidates[i] == 0
            continue
        end
        candidates[i] = 0
    end
end

"""
    function discardPresent!(candidates::Array{T}, i::T, j::T, n::T, sudoku::Array{T}) where T <: Unsigned

Sets entries of `candidates` to zero if they are already present in row, column or tile of sudoku at `i`, `j`. `n` beeing the `sqrt(size(sudoku, 1))`.
"""
function discardPresent!(candidates::Array{T}, i::T, j::T, n::T, sudoku::Array{T}) where T <: Unsigned
    I = ((i-1) ÷ n) * n +1
    J = ((j-1) ÷ n) * n +1
    discardPresent!(candidates, sudoku[I:I+n-1, J:J+n-1])
    discardPresent!(candidates, sudoku[i, :])
    discardPresent!(candidates, sudoku[:, j])
end

"""
    function check(sudoku::Array{T}, n::T, cache::Array{T}) where T <: Unsigned
    
Returns `true` if `sudoku` is a correct sudoku grid, zeros beeing ignored.
"""
function check(sudoku::Array{T}, n::T, cache::Array{T}) where T <: Unsigned
    N = n * n
    for i in T(1):N
        x = (i-1) ÷ n
        y = (i-1) % n
        if gotMultiple(sudoku[:, i], cache) ||
            gotMultiple(sudoku[i, :], cache) ||
            gotMultiple(sudoku[x*n+1:(x+1)*n, y*n+1:(y+1)*n], cache)
            return false
        end
    end
    true
end

"""
    function removeEntries!(sudoku::Array{T}) where T <: Unsigned

Removes entries step by step only removing uniquely solvable.
"""
function removeEntries!(sudoku::Array{T}) where T <: Unsigned
    N = T(size(sudoku, 1))
    n = T(sqrt(N))
    
    cand = ones(T, N, N)
    cache = zeros(T, N * N)

    init = collect(T, 1:N)
    r = Array{T}(undef, N)

    j = T(1)
    while true
        fill!(cand, T(0))
        for i in T(1):N, j in T(1):N
            if sudoku[i, j] == 0
                continue
            end
            value = sudoku[i, j]
            sudoku[i, j] = 0
            copy!(r, init)
            discardPresent!(r, i, j, n, sudoku)
            if countZeros(r) == N-1
                cand[i, j] = value
            end
            sudoku[i, j] = value
        end

        if sum(cand) == 0
            break
        end
        
        j = condenseNonZero!(cache, cand, N)
        sudoku[cache[(rand(T) % j)+1]] = 0
    end
    sudoku
end

"""
    function solve!(sudoku::Array{T}) where T <: Unsigned

Solves a sudoku in-place replacing all zero entries.

Throws ArgumentError when sudoku is not uniquely solvable.
"""
function solve!(sudoku::Array{T}) where T <: Unsigned
    N = T(size(sudoku, 1))
    n = T(sqrt(N))
    
    cand = zeros(T, N, N)
    cache = zeros(T, N * N)

    init = collect(T, 1:N)
    r = Array{T}(undef, N)

    j = T(1)
    while true
        fill!(cand, T(0))
        for i in T(1):N, j in T(1):N
            if sudoku[i, j] != 0
                continue
            end
            copy!(r, init)
            discardPresent!(r, i, j, n, sudoku)
            if countZeros(r) == N-1
                cand[i, j] = sum(r)
            end
        end
        
        if countZeros(cand) == N*N
            break
        end
        
        j = condenseNonZero!(cache, cand, N)
        entry = rand(T) % j +1
        sudoku[cache[entry]] = cand[cache[entry]]
    end
    if countZeros(sudoku) > 0
        throw(ArgumentError("Sudoku has no unique solution"))
    end
    sudoku
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
    r = Array{T}(undef, N)

    @label restart
    fill!(sudoku, T(0))
    for i in T(1):N, j in T(1):N
        copy!(r, init)
        discardPresent!(r, i, j, n, sudoku)
        if sum(r) == 0
            @goto restart
        end
        shuffle!(r)
        for c in r
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

"""
    function showSudoku(sudoku::Array{T}) where T <: Unsigned

Renders sudoku to io.
"""
function printSudoku(io, sudoku::Array{T}) where T <: Unsigned
    N = T(size(sudoku, 1))
    n = T(sqrt(N))

    s = Array{Int64}(undef, N, N)
    copy!(s, sudoku)
    printDevider = (io)->begin
        print(io, "+-")
        for j in 1:(N*2 + 2 * (n-1))-1
            if (j % (2*n + 2)) == (2*n + 1)
                print(io, "+")
            else
                print(io, "-")
            end
        end
        println(io, "-+")
    end
    printDevider(io)
    for i = 1:N
        print(io, "| ")
        for j = 1:N
            if s[i,j] != 0
                print(io, s[i,j])
            else
                print(io, ".")
            end
            if j % n == 0 && j != N
                print(io, " | ")
            elseif j == N
                println(io, " |")
            else
                print(io, " ")
            end
        end
        if i % n == 0
            printDevider(io)
        end
    end
end

export generateGrid, removeEntries!, solve!, printSudoku

end