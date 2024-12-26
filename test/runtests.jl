using Sudokus

using Test
using Random

@testset "swap" begin
    N = 0x09
    T = UInt8

    a = rand(T, N)
    b = rand(T, N)

    a_copy = copy(a)
    b_copy = copy(b)
    Sudokus.swap!(a,b)

    @test a == b_copy
    @test b == a_copy
end

@testset "countZeros" begin
    a = zeros(UInt8, 10)
    @test Sudokus.countZeros(a) == 10

    a[1:3] .= 1
    @test Sudokus.countZeros(a) == 7

    a[5:7] .= 1
    @test Sudokus.countZeros(a) == 4

    a[9] = 1
    @test Sudokus.countZeros(a) == 3
end

@testset "reject!" begin
    N = 0x09
    T = UInt8
    candidates = collect(T, 1:N)
    init = copy(candidates)
    Sudokus.reject!(candidates, ones(Bool, N))
    @test init == candidates

    r = rand(Bool, N)
    _sum = sum(r)
    Sudokus.reject!(candidates, r)
    @test Sudokus.countZeros(candidates) == N - _sum

    Sudokus.reject!(candidates, zeros(Bool, N))
    @test candidates == zeros(T, N)
end

@testset "firstNonZero" begin
    N = 0x09
    T = Bool

    @test Sudokus.firstNonZero(zeros(T, N)) == 0
    @test Sudokus.firstNonZero(ones(T, N)) == 1

    r = zeros(T, N)
    r[3] = 1
    @test Sudokus.firstNonZero(r) == 3
end


@testset "selectTile" begin
    sudoku = reshape(collect( 1:16), (4,4)) 

    @test Sudokus.selectTile(1, 1, 2, sudoku) == [ 1, 5, 9, 13]
    @test Sudokus.selectTile(2, 1, 2, sudoku) == [ 1, 2, 3, 4]
    @test Sudokus.selectTile(3, 1, 2, sudoku) == [ 1 5; 2 6]

    @test Sudokus.selectTile(1, 1, 1, 2, sudoku) == [ 1, 5, 9, 13]
    @test Sudokus.selectTile(2, 1, 1, 2, sudoku) == [ 1, 2, 3, 4]
    @test Sudokus.selectTile(3, 1, 1, 2, sudoku) == [ 1 5; 2 6]
end

@testset "gotMultiple" begin
    N = 9
    cache = zeros(UInt16, N)
    @test Sudokus.gotMultiple(UInt16.([1,2,3]), cache) == false
    @test Sudokus.gotMultiple(UInt16.([1,1,3]), cache) == true
    @test Sudokus.gotMultiple(UInt16.(collect(1:9)), cache) == false
    @test Sudokus.gotMultiple(zeros(UInt16, 9), cache) == false
    @test Sudokus.gotMultiple(ones(UInt16, 9), cache) == true

    @test Sudokus.gotMultiple(UInt16.([7  3  6  6  0  0  0  0  0]), cache) == true
    @test Sudokus.gotMultiple(UInt16.([7  3  6  2  0  0  0  0  0]), cache) == false

end

@testset "discardPresen" begin
    N = UInt16(9)
    n = UInt16(sqrt(N))
    init = ones(Bool, N)

    sudoku = [ 4 8 3 9 2 1 6 5 7
               9 6 7 3 4 5 8 2 1
               2 5 1 8 7 6 4 9 3
               5 4 8 1 3 2 9 7 6
               7 2 9 5 6 4 1 3 8
               1 3 6 7 9 8 2 4 5
               3 7 2 6 8 9 5 1 4
               8 1 4 2 5 3 7 6 9
               6 9 5 4 1 7 3 8 2
    ]
    sudoku = UInt16.(sudoku)
    r = copy(init)
    Sudokus.discardPresent!(r, UInt16(1), UInt16(2), n, sudoku) 
    @test sum(r) == 0

    value = sudoku[3,3]
    sudoku[3,3] = 0
    r = copy(init)
    Sudokus.discardPresent!(r, UInt16(3), UInt16(3), n, sudoku) 
    @test value == UInt16(1)
    @test sum(r) == value
end

@testset "check" begin

    N = UInt16(9)
    n = UInt16(3)
    cache = zeros(UInt16, N)
    sudoku = [ 4 8 3 9 2 1 6 5 7
               9 6 7 3 4 5 8 2 1
               2 5 1 8 7 6 4 9 3
               5 4 8 1 3 2 9 7 6
               7 2 9 5 6 4 1 3 8
               1 3 6 7 9 8 2 4 5
               3 7 2 6 8 9 5 1 4
               8 1 4 2 5 3 7 6 9
               6 9 5 4 1 7 3 8 2
    ]
    sudoku = UInt16.(sudoku)
    @test Sudokus.check(sudoku, n, cache) == true

    sudoku_with_zeros = [ 4 8 3 9 2 1 6 5 0
               9 6 7 3 4 5 8 2 0
               2 5 1 8 7 6 4 9 0
               5 4 8 1 3 2 9 7 0
               7 2 9 5 6 4 1 3 0
               1 3 6 7 9 8 2 4 0
               3 7 2 6 8 9 5 1 0
               8 1 4 2 5 3 7 6 0
               6 9 5 4 1 7 3 0 0
    ]
    sudoku_with_zeros = UInt16.(sudoku_with_zeros)
    @test Sudokus.check(sudoku_with_zeros, n, cache) == true

    not_a_sudoku = [7  2  6  3  5  8  1  1  7
    9  9  8  8  6  5  8  5  8
    2  8  3  7  6  7  3  3  9
    5  6  6  5  1  8  4  3  2
    5  3  9  4  1  2  7  2  4
    4  9  7  6  2  1  4  6  9
    4  2  7  4  3  7  1  7  1
    5  9  1  2  4  3  3  5  2
    1  6  8  8  4  5  9  9  6]
    not_a_sudoku = UInt16.(not_a_sudoku)
    @test Sudokus.check(not_a_sudoku, n, cache) == false

    not_a_sudoku_with₀ = [ 5  7  3  7  2  0  0  0  0
        2  4  6  3  0  0  0  0  0
        9  1  8  6  0  0  0  0  0
        4  2  1  9  0  0  0  0  0
        7  3  6  6  0  0  0  0  0
        8  5  9  7  0  0  0  0  0
        2  3  5  7  0  0  0  0  0
        7  1  6  8  0  0  0  0  0
        9  4  8  3  0  0  0  0  0]
    not_a_sudoku_with₀ = UInt16.(not_a_sudoku_with₀)
    @test Sudokus.check(not_a_sudoku_with₀, n, cache) == false
end

@testset "Generate" begin
    N = UInt8(9)

    sudoku = readSudoku("
        +-------+-------+-------+
        | 8 . 9 | . . . | . 6 . |
        | . 3 . | . . . | 9 7 4 |
        | 6 7 . | 4 . . | 2 8 . |
        +-------+-------+-------+
        | 4 . . | 2 . . | . 5 . |
        | . . 1 | 6 . . | 7 . 3 |
        | 2 . . | 3 1 . | 8 4 . |
        +-------+-------+-------+
        | . 2 . | . . . | . . . |
        | . . . | . . 5 | . 9 8 |
        | 7 . 6 | . . . | . . . |
        +-------+-------+-------+
    ")

    sudoku_copy = solve(sudoku)
    @test Sudokus.countZeros(sudoku_copy) == 0

    sudoku = generateGrid(N)
    sud = removeEntries(sudoku, UInt(32))
    @test Sudokus.countZeros(sud) == 49
    @test solve(sud) == sudoku

    reshuffled = shuffleSudoku(sud)
    @test uniquelySolvable(reshuffled)
    @test Sudokus.countZeros(reshuffled) == 49

    N = 0x04
    sudoku = generateGrid(N)
    sud = removeEntries(sudoku, UInt(4))
    @test Sudokus.countZeros(sud) == 12
    @test solve(sud) == sudoku
end