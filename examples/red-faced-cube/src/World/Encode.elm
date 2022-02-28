module World.Encode exposing (encodeWorld)

import Cell exposing (Cell)
import Cube exposing (Axis(..), Cube(..), RedFaceDirection(..), Sign(..))
import Json.Encode as Encode exposing (Value)
import Path exposing (Path, PathSegment)
import World exposing (World)



{- Generated with <https://dkodaj.github.io/decgen/> with the following input

    type alias World =
        { playerCube : Cube
        , playerPath : Path
        , levelEditingCube : Cube
        , levelEditingPath : Path
        , calculatedSolutions : List Path
        }


   type alias Path =
       { last : Cell
       , rest : List Cell
       }


   type alias PathSegment =
       ( Cell, Cell )


   type Cube
       = Cube Cell RedFaceDirection


   type RedFaceDirection
       = RedFaceDirection Axis Sign


   type Sign
       = Positive
       | Negative


   type alias Cell =
       ( Int, Int )


   type Axis
       = X
       | Y
       | Z

-}


encodeAxis : Axis -> Value
encodeAxis a =
    Encode.string <|
        case a of
            X ->
                "X"

            Y ->
                "Y"

            Z ->
                "Z"


encodeCell : Cell -> Value
encodeCell ( a1, a2 ) =
    Encode.object
        [ ( "A1", Encode.int a1 )
        , ( "A2", Encode.int a2 )
        ]


encodeCube : Cube -> Value
encodeCube (Cube a1 a2) =
    Encode.object
        [ ( "A1", encodeCell a1 )
        , ( "A2", encodeRedFaceDirection a2 )
        ]


encodePath : Path -> Value
encodePath a =
    Encode.object
        [ ( "last", encodeCell a.last )
        , ( "rest", Encode.list encodeCell a.rest )
        ]


encodePathSegment : PathSegment -> Value
encodePathSegment ( a1, a2 ) =
    Encode.object
        [ ( "A1", encodeCell a1 )
        , ( "A2", encodeCell a2 )
        ]


encodeRedFaceDirection : RedFaceDirection -> Value
encodeRedFaceDirection (RedFaceDirection a1 a2) =
    Encode.object
        [ ( "A1", encodeAxis a1 )
        , ( "A2", encodeSign a2 )
        ]


encodeSign : Sign -> Value
encodeSign a =
    Encode.string <|
        case a of
            Positive ->
                "Positive"

            Negative ->
                "Negative"


encodeWorld : World -> Value
encodeWorld a =
    Encode.object
        [ ( "playerCube", encodeCube a.playerCube )
        , ( "playerPath", encodePath a.playerPath )
        , ( "levelEditingCube", encodeCube a.levelEditingCube )
        , ( "levelEditingPath", encodePath a.levelEditingPath )
        , ( "calculatedSolutions", Encode.list encodePath a.calculatedSolutions )
        ]
