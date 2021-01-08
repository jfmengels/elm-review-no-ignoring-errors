# elm-review-no-ignoring-errors

Provides [`elm-review`](https://package.elm-lang.org/packages/jfmengels/elm-review/latest/) rules to REPLACEME.


## Provided rules

- [`NoIgnoringErrors`](https://package.elm-lang.org/packages/jfmengels/elm-review-no-ignoring-errors/1.0.0/NoIgnoringErrors) - Reports REPLACEME.


## Configuration

```elm
module ReviewConfig exposing (config)

import NoIgnoringErrors
import Review.Rule exposing (Rule)

config : List Rule
config =
    [ NoIgnoringErrors.rule
    ]
```


## Try it out

You can try the example configuration above out by running the following command:

```bash
elm-review --template jfmengels/elm-review-no-ignoring-errors/example
```
