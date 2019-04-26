# filter

# Benchmarks

## Space benchmarks

    $ stack bench :space-bench

## Instructions benchmarks

    $ stack build --exec "sudo $(stack exec which instructions-bench)"

## Time benchmarks

    $ stack bench :time-bench

# Tests

## Space tests

    $ stack test :space-test
