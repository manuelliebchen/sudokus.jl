# Sudokus.jl

Fast Sudoku generator and solver implemented in Julia.

```julia
julia> sudoku = generate(0x09, UInt(30));
julia> printSudoku(sudoku)
+-------+-------+-------+
| . . . | 5 . 2 | 9 . . |
| . 3 . | . 4 7 | 5 . 6 |
| . . . | 9 . 1 | . . . |
+-------+-------+-------+
| . . . | 6 . 4 | . . 9 |
| 8 7 9 | . . . | 4 . . |
| 4 . . | . 9 . | 1 . . |
+-------+-------+-------+
| 6 9 2 | . . . | . 4 . |
| 1 . 3 | . . . | 2 . 5 |
| . 4 . | . 1 . | . . . |
+-------+-------+-------+

julia> printSudoku(solve(sudoku))
+-------+-------+-------+
| 7 6 8 | 5 3 2 | 9 1 4 |
| 9 3 1 | 8 4 7 | 5 2 6 |
| 2 5 4 | 9 6 1 | 3 8 7 |
+-------+-------+-------+
| 3 1 5 | 6 2 4 | 8 7 9 |
| 8 7 9 | 1 5 3 | 4 6 2 |
| 4 2 6 | 7 9 8 | 1 5 3 |
+-------+-------+-------+
| 6 9 2 | 3 8 5 | 7 4 1 |
| 1 8 3 | 4 7 6 | 2 9 5 |
| 5 4 7 | 2 1 9 | 6 3 8 |
+-------+-------+-------+
```
## Performence

Tested on a M1 MacBook Air 2020 Sudokus.jl averages 18.425 ms at generating a Sudoku Grid and 46.344 ms at generating a Sudoku with 32 Clues.

```julia
julia> @benchmark sudoku = generateGrid(0x09)
BenchmarkTools.Trial: 410 samples with 1 evaluation.
 Range (min … max):  100.708 μs … 93.537 ms  ┊ GC (min … max): 0.00% … 80.34%
 Time  (median):       8.420 ms              ┊ GC (median):    0.00%
 Time  (mean ± σ):    12.187 ms ± 12.463 ms  ┊ GC (mean ± σ):  5.95% ±  7.98%

  █▄▇▂▃█ ▃▁ ▁ ▂ ▁                                               
  ███████████▆█▄█▄█▆▅▆█▄▃▃▃▄▄▄▅▅▃▃▂▃▂▂▃▃▃▂▃▁▃▂▂▁▁▂▂▂▂▂▂▁▂▂▁▁▁▃ ▄
  101 μs          Histogram: frequency by time         55.1 ms <

 Memory estimate: 126.95 KiB, allocs estimate: 2435.

 julia> @benchmark sudoku = generate(0x09, UInt(32))
BenchmarkTools.Trial: 110 samples with 1 evaluation.
 Range (min … max):   1.496 ms … 184.399 ms  ┊ GC (min … max): 0.00% … 1.21%
 Time  (median):     33.494 ms               ┊ GC (median):    0.00%
 Time  (mean ± σ):   46.344 ms ±  36.413 ms  ┊ GC (mean ± σ):  3.45% ± 7.17%

     ▂  ▂  █ ▃       ▂                                          
  ▅▃▆█▅██▇▆█▆██▆▁▆▃▃▇███▁▁▃▅▅▃▃▃▁▁▁▃▃▁▁▆▁▁▅▁▁▁▁▃▅▅▃▁▁▁▁▁▁▁▁▃▁▃ ▃
  1.5 ms          Histogram: frequency by time          157 ms <

 Memory estimate: 756.73 KiB, allocs estimate: 14112.
```