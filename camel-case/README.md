# count

# Weigh

    $ stack build --test :space --flag camel-case:string

    Case          Allocated  GCs      Max    Live
    lazy100         387,040    0   49,560  49,560
    lazy1000      3,294,816    3   49,560  49,560
    lazy10000    32,403,192   31   49,560  49,560
    lazy100000  323,484,680  311  103,712  49,560

    $ stack build --test :space --flag camel-case:bytestring

    Case         Allocated  GCs     Max    Live
    lazy100        189,056    0  41,424  41,424
    lazy1000       805,128    0  41,424  41,424
    lazy10000    6,984,160    6  41,400  41,400
    lazy100000  68,755,072   66  41,400  41,400

    $ stack build --test :space --flag camel-case:bytestring

    Case        Allocated  GCs     Max    Live
    lazy100        85,136    0  17,856  17,856
    lazy1000       85,136    0  17,856  17,856
    lazy10000      85,784    0  17,856  17,856
    lazy100000  3,785,160    3  17,800  17,800

# Benchmarks

    $ stack build --test :time --flag camel-case:string

    benchmarking CamelCase/100
    time                 66.98 μs   (66.37 μs .. 67.58 μs)
                         0.998 R²   (0.997 R² .. 0.999 R²)
    mean                 67.71 μs   (66.93 μs .. 69.31 μs)
    std dev              3.539 μs   (2.174 μs .. 6.321 μs)
    variance introduced by outliers: 56% (severely inflated)

    benchmarking CamelCase/1000
    time                 584.4 μs   (579.1 μs .. 589.3 μs)
                         0.999 R²   (0.998 R² .. 0.999 R²)
    mean                 588.3 μs   (583.4 μs .. 597.1 μs)
    std dev              22.15 μs   (13.66 μs .. 40.17 μs)
    variance introduced by outliers: 30% (moderately inflated)

    benchmarking CamelCase/10000
    time                 5.675 ms   (5.585 ms .. 5.764 ms)
                         0.998 R²   (0.997 R² .. 0.999 R²)
    mean                 5.831 ms   (5.726 ms .. 6.087 ms)
    std dev              472.6 μs   (238.7 μs .. 863.8 μs)
    variance introduced by outliers: 50% (moderately inflated)

    benchmarking CamelCase/100000
    time                 59.02 ms   (58.22 ms .. 59.84 ms)
                         1.000 R²   (0.999 R² .. 1.000 R²)
    mean                 60.34 ms   (59.24 ms .. 63.50 ms)
    std dev              3.411 ms   (445.3 μs .. 5.999 ms)
    variance introduced by outliers: 16% (moderately inflated)

    $ stack build --test :time --flag camel-case:bytestring

    benchmarking CamelCase/100
    time                 18.47 μs   (18.26 μs .. 18.71 μs)
                         0.999 R²   (0.998 R² .. 0.999 R²)
    mean                 18.75 μs   (18.56 μs .. 19.11 μs)
    std dev              886.5 ns   (597.6 ns .. 1.418 μs)
    variance introduced by outliers: 55% (severely inflated)

    benchmarking CamelCase/1000
    time                 147.6 μs   (146.3 μs .. 149.1 μs)
                         0.999 R²   (0.997 R² .. 0.999 R²)
    mean                 152.6 μs   (150.1 μs .. 160.1 μs)
    std dev              13.60 μs   (5.237 μs .. 27.06 μs)
    variance introduced by outliers: 77% (severely inflated)

    benchmarking CamelCase/10000
    time                 1.468 ms   (1.450 ms .. 1.486 ms)
                         0.998 R²   (0.996 R² .. 0.999 R²)
    mean                 1.492 ms   (1.472 ms .. 1.529 ms)
    std dev              90.63 μs   (55.49 μs .. 145.7 μs)
    variance introduced by outliers: 46% (moderately inflated)

    benchmarking CamelCase/100000
    time                 14.61 ms   (14.46 ms .. 14.82 ms)
                         0.999 R²   (0.999 R² .. 1.000 R²)
    mean                 14.74 ms   (14.61 ms .. 15.02 ms)
    std dev              450.0 μs   (268.7 μs .. 735.4 μs)
    variance introduced by outliers: 11% (moderately inflated)

    $ stack build --test :time --flag camel-case:inplace

    time                 13.17 μs   (12.94 μs .. 13.49 μs)
                         0.996 R²   (0.994 R² .. 0.997 R²)
    mean                 13.79 μs   (13.52 μs .. 14.09 μs)
    std dev              981.1 ns   (819.7 ns .. 1.184 μs)
    variance introduced by outliers: 75% (severely inflated)

    benchmarking CamelCase/1000
    time                 28.50 μs   (28.15 μs .. 28.89 μs)
                         0.999 R²   (0.998 R² .. 0.999 R²)
    mean                 28.70 μs   (28.42 μs .. 29.02 μs)
    std dev              950.4 ns   (793.5 ns .. 1.168 μs)
    variance introduced by outliers: 37% (moderately inflated)

    benchmarking CamelCase/10000
    time                 189.9 μs   (187.9 μs .. 192.1 μs)
                         0.999 R²   (0.999 R² .. 0.999 R²)
    mean                 189.7 μs   (188.0 μs .. 191.7 μs)
    std dev              6.212 μs   (5.011 μs .. 8.417 μs)
    variance introduced by outliers: 29% (moderately inflated)

    benchmarking CamelCase/100000
    time                 1.778 ms   (1.756 ms .. 1.798 ms)
                         0.999 R²   (0.998 R² .. 0.999 R²)
    mean                 1.783 ms   (1.770 ms .. 1.800 ms)
    std dev              51.81 μs   (41.15 μs .. 75.30 μs)
    variance introduced by outliers: 16% (moderately inflated)
