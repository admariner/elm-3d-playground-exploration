module Main exposing (main)

import Color exposing (hsl, white)
import Html exposing (Html)
import Playground3d exposing (Computer, configurations, gameWithConfigurations, getFloat, wave)
import Playground3d.Camera exposing (Camera, perspective)
import Playground3d.Scene as Scene exposing (..)


main =
    gameWithConfigurations view update initialConfigurations init


type alias Model =
    {}



-- INIT


init : Computer -> Model
init computer =
    {}



-- UPDATE


update : Computer -> Model -> Model
update computer model =
    model



-- VIEW


view : Computer -> Model -> Html Never
view computer model =
    Scene.sunny
        { devicePixelRatio = computer.devicePixelRatio
        , screen = computer.screen
        , camera =
            perspective
                { focalPoint = { x = 0, y = 0, z = 0 }
                , eyePoint =
                    { x = getFloat "camera x" computer
                    , y = getFloat "camera y" computer
                    , z = getFloat "camera z" computer
                    }
                , upDirection = { x = 0, y = 1, z = 0 }
                }
        , backgroundColor = white
        , sunlightAzimuth = -(degrees 135)
        , sunlightElevation = -(degrees 45)
        }
        [ cubes computer ]


initialConfigurations =
    configurations
        [ ( "radius", ( 0, 1, 6 ) )
        , ( "number of cubes", ( 1, 19, 100 ) )
        , ( "cube size", ( 0.1, 1, 4 ) )
        , ( "cycle duration", ( 1, 5, 10 ) )
        , ( "wave height", ( 0.5, 1.5, 6 ) )
        , ( "number of waves", ( 1, 2, 20 ) )
        , ( "camera x", ( 0, 8, 16 ) )
        , ( "camera y", ( 0, 0, 10 ) )
        , ( "camera z", ( 0, 6, 16 ) )
        , ( "saturation", ( 0, 0.8, 1 ) )
        , ( "lightness", ( 0, 0.7, 1 ) )
        ]
        []


cubes : Computer -> Shape
cubes computer =
    let
        n =
            floor (getFloat "number of cubes" computer)

        cycleDuration =
            getFloat "cycle duration" computer

        waveHeight =
            getFloat "wave height" computer

        numberOfWaves =
            toFloat (floor (getFloat "number of waves" computer))

        oneCube i =
            let
                ratio =
                    toFloat i / toFloat n

                delay =
                    numberOfWaves * cycleDuration * ratio
            in
            cube
                (hsl
                    ratio
                    (getFloat "saturation" computer)
                    (getFloat "lightness" computer)
                )
                (getFloat "cube size" computer)
                |> moveZ (getFloat "radius" computer)
                |> moveY
                    (wave
                        -waveHeight
                        waveHeight
                        cycleDuration
                        (computer.time + delay)
                    )
                |> rotateY (degrees 360 * ratio)
    in
    group
        (List.range 0 (n - 1) |> List.map oneCube)
