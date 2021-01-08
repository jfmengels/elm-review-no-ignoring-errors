module NoIgnoringErrors exposing (rule)

{-|

@docs rule

-}

import Elm.Syntax.Expression as Expression exposing (Expression)
import Elm.Syntax.Node as Node exposing (Node)
import Elm.Syntax.Pattern as Pattern
import Review.ModuleNameLookupTable as ModuleNameLookupTable exposing (ModuleNameLookupTable)
import Review.Rule as Rule exposing (Error, Rule)


{-| Reports when error details are not being used.

    config =
        [ NoIgnoringErrors.rule
        ]


## Fail

    notificationMessage =
        case foo of
            Ok () ->
                "Success!"

            Err _ ->
                "Failure!"


## Success

    notificationMessage =
        case foo of
            Ok () ->
                "Success!"

            Err errorMessage ->
                "Failed to make this work because " ++ errorMessage

As shown in the following example, the rule will only check whether a wildcard (`_`) is used for `Err`. I recommend enabling the
[`NoUnused.Patterns`](https://package.elm-lang.org/packages/jfmengels/elm-review-unused/latest/NoUnused-Patterns) rule
to help get you to the state where the noise is removed.

    notificationMessage =
        case foo of
            Ok () ->
                "Success!"

            Err errorMessage ->
                -- `errorMessage` is not used, but the rule only checks whether a wildcard is being used.
                "Failure!"

In some cases, you will genuinely only care about whether something has failed or not. In those cases, you can transform the result
in a way where you explicitly show that you don't care about the error.

    hasFailed =
        case Result.mapError (\_ -> ()) foo of
            Ok data -> ...
            Err () -> ...

To do the above, I recommend using [`Result.mapError`](https://package.elm-lang.org/packages/elm/core/latest/Result#mapError) or [`Result.toMaybe`](https://package.elm-lang.org/packages/elm/core/latest/Result#toMaybe),
and to use them at the earliest possible convenience, such as when you are creating the `Task`, so that your the associated constructor shows you will ignore the error.

    type Msg
        = UserClickedOnSend
        | GotServerResponse (Result () Data)

    update : Msg -> Model -> ( Model, Cmd Msg )
    update msg model =
        case msg of
            UserClickedOnSend ->
                ( model
                , Http.get
                    { url = "https://elm-lang.org/assets/public-opinion.txt"
                    , expect =
                        Http.expectString
                            (Result.mapError (\_ -> ()) >> GotServerResponse)
                    }
                )

            GotServerResponse (Ok data) ->
                ( { model | data = data }, Cmd.none )

            GotServerResponse (Err ()) ->
                ( { model | errorWasReceived = True }, Cmd.none )


## When (not) to enable this rule

This rule is still experimental. I am trying to figure out if this error is always useful or how to tweak it to remove
false positives and discover more cases where errors are ignored.


## Try it out

You can try this rule out by running the following command:

```bash
elm-review --template jfmengels/elm-review-no-ignoring-errors/preview --rules NoIgnoringErrors
```

-}
rule : Rule
rule =
    Rule.newModuleRuleSchemaUsingContextCreator "NoIgnoringErrors" initialContext
        |> Rule.withExpressionEnterVisitor expressionVisitor
        |> Rule.fromModuleRuleSchema


type alias Context =
    { lookupTable : ModuleNameLookupTable
    }


initialContext : Rule.ContextCreator () Context
initialContext =
    Rule.initContextCreator
        (\lookupTable () -> { lookupTable = lookupTable })
        |> Rule.withModuleNameLookupTable


expressionVisitor : Node Expression -> Context -> ( List (Error {}), Context )
expressionVisitor node context =
    case Node.value node of
        Expression.CaseExpression { cases } ->
            ( List.concatMap (\( pattern, _ ) -> patternProblems context.lookupTable pattern) cases
            , context
            )

        _ ->
            ( [], context )


patternProblems : ModuleNameLookupTable -> Node Pattern.Pattern -> List (Error {})
patternProblems lookupTable node =
    case Node.value node of
        Pattern.NamedPattern { name } patterns ->
            if name == "Err" && List.map Node.value patterns == [ Pattern.AllPattern ] then
                case ModuleNameLookupTable.moduleNameFor lookupTable node of
                    Just [ "Result" ] ->
                        [ Rule.error
                            { message = "The error is being ignored."
                            , details = [ "Please check whether the error can't be used to improve the situation for the user. You can for instance display the error message to the user or re-attempt the operation." ]
                            }
                            (Node.range node)
                        ]

                    _ ->
                        List.concatMap (patternProblems lookupTable) patterns

            else
                List.concatMap (patternProblems lookupTable) patterns

        Pattern.ParenthesizedPattern pattern ->
            patternProblems lookupTable pattern

        Pattern.UnConsPattern left right ->
            patternProblems lookupTable left ++ patternProblems lookupTable right

        Pattern.ListPattern patterns ->
            List.concatMap (patternProblems lookupTable) patterns

        Pattern.TuplePattern patterns ->
            List.concatMap (patternProblems lookupTable) patterns

        Pattern.AsPattern pattern _ ->
            patternProblems lookupTable pattern

        _ ->
            []
