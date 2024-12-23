# Sudokus.jl

Fast Sudoku generator and solver implemented in Julia.

```julia
julia> sudoku = removeEntries!(generateGrid(UInt8(9)))
julia> printSudoku(stdout::IO, sudoku)
+-------+-------+-------+
| 3 2 7 | 6 . . | . 1 4 |
| 9 . 6 | . 1 7 | 3 . . |
| 1 . . | 4 3 . | . 2 6 |
+-------+-------+-------+
| . 6 . | . . 1 | . . 7 |
| . . . | . . 4 | . 5 8 |
| 7 5 1 | . 2 3 | 4 . . |
+-------+-------+-------+
| 6 . 8 | . . . | . 7 3 |
| . . 3 | 9 7 . | 8 . 2 |
| 4 . . | . . 5 | 6 . . |
+-------+-------+-------+

julia> printSudoku(stdout::IO, solve!(sudoku))
+-------+-------+-------+
| 3 2 7 | 6 5 8 | 9 1 4 |
| 9 4 6 | 2 1 7 | 3 8 5 |
| 1 8 5 | 4 3 9 | 7 2 6 |
+-------+-------+-------+
| 8 6 4 | 5 9 1 | 2 3 7 |
| 2 3 9 | 7 6 4 | 1 5 8 |
| 7 5 1 | 8 2 3 | 4 6 9 |
+-------+-------+-------+
| 6 9 8 | 1 4 2 | 5 7 3 |
| 5 1 3 | 9 7 6 | 8 4 2 |
| 4 7 2 | 3 8 5 | 6 9 1 |
+-------+-------+-------+
```
## Performence

Tested on a M1 MacBook Air 2020 Sudokus.jl averages 18.425 ms at generating a Sudoku Grid.
```julia
julia> @benchmark sudoku = generateGrid(0x09)
BenchmarkTools.Trial: 272 samples with 1 evaluation.
 Range (min … max):  201.042 μs … 111.643 ms  ┊ GC (min … max): 0.00% … 68.07%
 Time  (median):      12.745 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):    18.425 ms ±  18.317 ms  ┊ GC (mean ± σ):  3.17% ±  4.94%

  ▇█▅▂▆▅▇▁▂▄▄     ▁                                              
  ███████████▆▆█▅▆█▅▆▅▅▆▅▅▃▃▅▃▆▃▄▄▁▃▃▃▃▃▃▃▃▃▁▁▃▃▃▁▃▁▃▁▃▃▁▁▁▁▁▁▃ ▃
  201 μs           Histogram: frequency by time         82.1 ms <

 Memory estimate: 184.27 KiB, allocs estimate: 2947.
```