# filter

## Benchmarks

#### Space benchmarks

    $ stack bench :space-bench

#### Time benchmarks

    $ stack bench :time-bench

#### Instructions benchmarks

    $ stack build --bench --no-run-benchmarks :instructions-bench --flag filter:instructions
    $ sudo stack bench :instructions-bench --allow-different-user --flag filter:instructions

## Tests

#### Existential tests

    $ stack test :existential-test --coverage

#### Space tests

    $ stack test :space-test

#### Instructions tests

    $ stack build --test --no-run-tests :instructions-test      --flag filter:instructions
    $ sudo stack test :instructions-test --allow-different-user --flag filter:instructions
