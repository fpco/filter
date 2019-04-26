# filter

## Tests

#### Existential tests

    $ stack test :existential-test --coverage

#### Property tests

    $ stack test :property-test --coverage

#### Space tests

    $ stack test :space-test

#### Instructions tests

    $ stack build --test --no-run-tests :instructions-test      --flag filter:instructions
    $ sudo stack test :instructions-test --allow-different-user --flag filter:instructions

## Benchmarks

#### Space benchmarks

    $ stack bench :space-bench

#### Time benchmarks

    $ stack bench :time-bench

#### Instructions benchmarks

    $ stack build --bench --no-run-benchmarks :instructions-bench --flag filter:instructions
    $ sudo stack bench :instructions-bench --allow-different-user --flag filter:instructions

## Backends

Compile the different implementations:

``` bash
for i in $(ls src/ | grep '^[a-z]')
do
stack build --test --bench --pedantic --flag filter:instructions
--flag "filter:$i" --no-run-tests --no-run-benchmarks --fast
done
```
