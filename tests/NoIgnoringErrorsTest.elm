module NoIgnoringErrorsTest exposing (all)

import Dependencies.ElmCore
import NoIgnoringErrors exposing (rule)
import Review.Project as Project exposing (Project)
import Review.Test
import Test exposing (Test, describe, test)


message : String
message =
    "The error is being ignored."


details : List String
details =
    [ "Please check whether the error can't be used to improve the situation for the user. You can for instance display the error message to the user or re-attempt the operation." ]


project : Project
project =
    Project.new
        |> Project.addDependency Dependencies.ElmCore.dependency


all : Test
all =
    describe "NoIgnoringErrors"
        [ test "should report an error when the argument to Err is not used" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Ok () -> 1
      Err _ -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should not report an error when re-defining Err" <|
            \() ->
                """module A exposing (..)
type Thing = Err ()
a =
  case foo of
      Ok () -> 1
      Err _ -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when using an Err not from Result" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Thing.Ok () -> 1
      Thing.Err _ -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectNoErrors
        , test "should not report an error when the argument to Err is used" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Ok () -> 1
      Err () -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectNoErrors
        , test "should report an error when Err is used with a qualified import" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Result.Ok _ -> 1
      Result.Err _ -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Result.Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is in a parens" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      (Ok ()) -> 1
      (Err _) -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is nested" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Just (Ok ()) -> 1
      Just (Err _) -> 1
      Nothing -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is :: to a list" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      Err _ :: list -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is in a list" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      [Err _] -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is in a tuple" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      (_, Err _) -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        , test "should report an error when the wildcard with error is aliased" <|
            \() ->
                """module A exposing (..)
a =
  case foo of
      ((Err _) as error) -> 1
"""
                    |> Review.Test.runWithProjectData project rule
                    |> Review.Test.expectErrors
                        [ Review.Test.error
                            { message = message
                            , details = details
                            , under = "Err _"
                            }
                        ]
        ]
