module NoIgnoringErrors exposing (rule)

{-|

@docs rule

-}

import Review.Rule as Rule exposing (Rule)


{-| Reports... REPLACEME

    config =
        [ NoIgnoringErrors.rule
        ]


## Fail

    a =
        "REPLACEME example to replace"


## Success

    a =
        "REPLACEME example to replace"


## When (not) to enable this rule

This rule is useful when REPLACEME.
This rule is not useful when REPLACEME.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template jfmengels/elm-review-no-ignoring-errors/example --rules NoIgnoringErrors
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchema "NoIgnoringErrors" ()
        -- Add your visitors
        |> Rule.fromModuleRuleSchema
