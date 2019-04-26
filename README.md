# filter

## Benchmarks

#### Space benchmarks

    $ stack bench :space-bench

#### Instructions benchmarks

    $ stack build --bench --no-run-benchmarks
    $ sudo stack bench :instructions-bench --allow-different-user

#### Time benchmarks

    $ stack bench :time-bench

## Tests

#### Space tests

    $ stack test :space-test

#### Instructions tests

    $ stack build --test --no-run-tests
    $ sudo stack test :instructions-test --allow-different-user
