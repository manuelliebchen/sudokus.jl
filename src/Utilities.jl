
function countZeros(sudoku::Array{T}) where T <: Unsigned
    sum = 0
    for s in sudoku
        if s == 0
            sum += 1
        end
    end
    sum
end

"""
    function reject!(candidates::Array{T}, present::Array{Bool}) where {T}

Equivalent to `candidates .*= present` but faster.
"""
function reject!(candidates::Array{T}, present::Array{Bool}) where {T}
    for i in 1:length(candidates)
        candidates[i] *= present[i]
    end
end

function firstNZ(vec::Vector{Bool})
    for (i, v) in enumerate(vec)
        if v
            return i
        end
    end
    0
end

"""
    function selectTile(i::T, j::T, n::T, sudoku::Array{T}) where {T}

Generates view on `sudoku` for all entries in tile of `i` in a `(n*n)^2` gird.

`rule` beeing:
 1. Rows
 2. Columns
 3. Tiles
"""
function selectTile(rule, i::T, n::T, sudoku::Matrix{U}) where {T, U}
    if rule == 1
        return view( sudoku, i, :)
    elseif rule == 2
        return view( sudoku, :, i)
    elseif rule == 3
        I = ((i-1) % n) * n +1
        J = ((i-1) ÷ n) * n +1
        return view(sudoku, I:I+n-1, J:J+n-1)
    end
    throw(ArgumentError("Rule unknown."))
end

"""
    function selectTile(i::T, j::T, n::T, sudoku::Array{T}) where {T}

Generates view on `sudoku` for all entries in tile of `i,j` in a `(n*n)^2` gird.

`rule` beeing:
 1. Rows
 2. Columns
 3. Tiles
"""
function selectTile(rule, i::T, j::T, n::T, sudoku::Matrix{U}) where {T, U}
    if rule == 1
        return view( sudoku, i, :)
    elseif rule == 2
        return view( sudoku, :, j)
    elseif rule == 3
        I = ((i-1) ÷ n) * n +1
        J = ((j-1) ÷ n) * n +1
        return view(sudoku, I:I+n-1, J:J+n-1)
    end
    throw(ArgumentError("Rule unknown."))
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
function condenseNonZero!(cache::Array{T}, list::Array{Vector{Bool}}, N::T) where T <: Unsigned
    j = T(0)
    fill!(cache, T(0))
    for (i,v) in enumerate(list)
        if sum(v) == 1
            j += 1
            cache[j] = i
        end
    end
    j
end

"""
    function discardPresent!(candidates::Array{T}, i::T, j::T, n::T, sudoku::Array{T}) where T <: Unsigned

Sets entries of `candidates` to zero if they are already present in row, column or tile of sudoku at `i`, `j`. `n` beeing the `sqrt(size(sudoku, 1))`.
"""
function discardPresent!(candidates::Array{Bool}, i::T, j::T, n::T, sudoku::Array{T}) where T <: Unsigned
    if sudoku[i,j] != 0
        fill!(candidates, false)
        return
    end
    for r in 1:3
        list = selectTile(r, i, j, n, sudoku)
        for i in list
            if i == 0 || !candidates[i]
                continue
            end
            candidates[i] = false
        end
    end
end

"""
    function check(sudoku::Array{T}, n::T, cache::Array{T}) where T <: Unsigned
    
Returns `true` if `sudoku` is a correct sudoku grid, zeros beeing ignored.
"""
function check(sudoku::Array{T}, n::T, cache::Array{T}) where T <: Unsigned
    N = n * n
    for i in T(1):N
        if gotMultiple(selectTile(1, i, n, sudoku), cache) ||
            gotMultiple(selectTile(2, i, n, sudoku), cache) ||
            gotMultiple(selectTile(3, i, n, sudoku), cache)
            return false
        end
    end
    true
end


"""
    function printSudoku(sudoku::Array{T}) where T <: Unsigned

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


function readSudoku(string)
    string = replace(string, "+"=>"", "-"=>"", "|"=>" ", "."=>"0", "\n\n"=>"\n", "\n"=>"",)
    string = replace(string, "   "=>" ", "    "=>" ")
    sudoku = parse.(UInt, filter(!isempty,  split(string, ' ')))
    N = UInt(sqrt(length(sudoku)))
    sudoku = Matrix(transpose(reshape(sudoku, (N,N))))
    sudoku
    # @show string
    # 

end