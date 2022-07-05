port module Playground exposing
    ( game, gameWithConfigurations, gameWithConfigurationsAndEditor
    , getColor, getFloat, getBool
    , Computer, Pointer, Screen, Keyboard, toX, toY, toXY
    , boolConfig, colorConfig, configBlock, floatConfig, getInt, intConfig
    )

{-|


# Playground

@docs game, gameWithConfigurations, gameWithConfigurationsAndEditor


# Configurations

@docs configurations, getColor, getFloat, getBool


# Groups

@docs group


# Time

@docs spin, wave, zigzag


# Computer

@docs Computer, Pointer, Screen, Keyboard, toX, toY, toXY

-}

import Browser
import Html exposing (Html, a, button, div, p, pre)
import Html.Attributes as HA exposing (class, href, id, style, target)
import Html.Events
import Playground.Computer as Computer exposing (Computer, Inputs, Wheel)
import Playground.Configurations as Configurations exposing (Block, Config(..), Configurations)
import Playground.ConfigurationsGUI as ConfigurationsGUI
import Playground.Icons as Icons
import Playground.Tape as Tape exposing (Tape, currentComputer, currentGameModel)
import Round



-- PORTS


port tick : (Inputs -> msg) -> Sub msg



-- FOR EXPOSING


type alias Computer =
    Computer.Computer


type alias Pointer =
    Computer.Pointer


type alias Screen =
    Computer.Screen


type alias Keyboard =
    Computer.Keyboard


toX =
    Computer.toX


toY =
    Computer.toY


toXY =
    Computer.toXY


configBlock =
    Configurations.configBlock


boolConfig key value =
    ( key, Configurations.BoolConfig value )


intConfig key ( min, max ) value =
    ( key, Configurations.IntConfig ( min, max ) value )


floatConfig key ( min, max ) value =
    ( key, Configurations.FloatConfig ( min, max ) value )


colorConfig key value =
    ( key, Configurations.ColorConfig value )


getBool =
    Computer.getBool


getColor =
    Computer.getColor


getInt =
    Computer.getInt


getFloat =
    Computer.getFloat



-- GAME


type alias Flags =
    { inputs : Inputs }



--


game :
    (Computer -> gameModel -> Html Never)
    -> (Computer -> gameModel -> gameModel)
    -> (Computer -> gameModel)
    -> Program Flags (Model gameModel) (Msg Never)
game viewGameModel updateGameModel initGameModel =
    gameWithConfigurations
        viewGameModel
        updateGameModel
        []
        initGameModel


gameWithConfigurations :
    (Computer -> gameModel -> Html Never)
    -> (Computer -> gameModel -> gameModel)
    -> Configurations
    -> (Computer -> gameModel)
    -> Program Flags (Model gameModel) (Msg Never)
gameWithConfigurations viewGameModel updateGameModel initialConfigurations initGameModel =
    gameWithConfigurationsAndEditor
        viewGameModel
        updateGameModel
        initialConfigurations
        initGameModel
        (\_ _ -> div [] [])
        (\_ _ gameModel -> gameModel)


gameWithConfigurationsAndEditor :
    (Computer -> gameModel -> Html Never)
    -> (Computer -> gameModel -> gameModel)
    -> Configurations
    -> (Computer -> gameModel)
    -> (Computer -> gameModel -> Html levelEditorMsg)
    -> (Computer -> levelEditorMsg -> gameModel -> gameModel)
    -> Program Flags (Model gameModel) (Msg levelEditorMsg)
gameWithConfigurationsAndEditor viewGameModel updateGameModel initialConfigurations initGameModel viewEditor updateFromEditor =
    let
        init flags =
            let
                initialComputer =
                    flags.inputs |> Computer.assignConfigurations initialConfigurations
            in
            ( { tape = Tape.init initialComputer initGameModel
              , distractionFree = flags.inputs.screen.width < 500
              }
            , Cmd.none
            )

        update msg model =
            ( gameUpdate updateGameModel updateFromEditor msg model
            , Cmd.none
            )
    in
    Browser.element
        { init = init
        , view = view viewGameModel viewEditor
        , update = update
        , subscriptions = always (tick Tick)
        }



-- SUBSCRIPTIONS


type alias Model gameModel =
    { tape : Tape gameModel
    , distractionFree : Bool
    }


type Msg levelEditorMsg
    = NoOp
    | ClickOnDistractionFreeButton
    | Tick Inputs
    | FromConfigurationsEditor Configurations.Msg
    | FromLevelEditor levelEditorMsg
    | FromTape Tape.Msg


gameUpdate :
    (Computer -> gameModel -> gameModel)
    -> (Computer -> levelEditorMsg -> gameModel -> gameModel)
    -> Msg levelEditorMsg
    -> Model gameModel
    -> Model gameModel
gameUpdate updateGameModel updateFromEditor msg model =
    case msg of
        NoOp ->
            model

        ClickOnDistractionFreeButton ->
            { model | distractionFree = not model.distractionFree }

        Tick inputs ->
            { model | tape = model.tape |> Tape.tick updateGameModel inputs }

        FromConfigurationsEditor computerMsg ->
            { model | tape = model.tape |> Tape.updateConfigurations computerMsg }

        FromLevelEditor levelEditorMsg ->
            { model | tape = model.tape |> Tape.updateCurrentGameModelWithEditorMsg updateFromEditor levelEditorMsg }

        FromTape tapeMsg ->
            { model | tape = model.tape |> Tape.update tapeMsg }



-- VIEW


view :
    (Computer -> gameModel -> Html Never)
    -> (Computer -> gameModel -> Html levelEditorMsg)
    -> Model gameModel
    -> Html (Msg levelEditorMsg)
view viewGameModel viewLevelEditor model =
    let
        computer =
            currentComputer model.tape

        gameModel =
            currentGameModel model.tape
    in
    div
        [ class "bg-black40"
        , class "select-none"
        , class "antialiased"
        , class "font-mono"
        , style "width" (String.fromFloat computer.screen.width ++ "px")
        , style "height" (String.fromFloat computer.screen.height ++ "px")
        ]
        [ div [ class "fixed" ] [ Html.map (always NoOp) (viewGameModel computer gameModel) ]
        , div [ id "gui" ]
            [ viewGUI computer model
            , Html.map FromLevelEditor (viewLevelEditor computer gameModel)
            ]
        ]


viewComputer : Computer -> Model gameModel -> Html msg
viewComputer computer model =
    let
        viewPointer =
            if Tape.isRecording model.tape then
                div [] []

            else
                div
                    [ class "absolute pointer-events-none w-8 h-8"
                    , style "left" (String.fromFloat (computer.pointer.x + 0.5 * computer.screen.width) ++ "px")
                    , style "top" (String.fromFloat (-computer.pointer.y + 0.5 * computer.screen.height) ++ "px")
                    ]
                    [ div
                        [ class <|
                            if computer.pointer.isDown then
                                "fill-black80"

                            else
                                "fill-white40"
                        ]
                        [ Icons.draw Icons.icons.pointer ]
                    ]
    in
    div []
        [ viewPointer

        --, pre
        --    [ class "fixed p-2 w-[300px] h-[130px] bottom-0 right-0 border-[0.5px] border-white20 bg-black20 text-xs text-white60"
        --    ]
        --    [ p [] [ Html.text ("pressedKeys: " ++ (computer.keyboard.pressedKeys |> List.intersperse " " |> String.concat)) ]
        --    , p [] [ Html.text ("delta time: " ++ Round.round 4 computer.dt) ]
        --    , p []
        --        [ Html.text
        --            ("pointer is down: "
        --                ++ (if computer.pointer.isDown then
        --                        "yes"
        --
        --                    else
        --                        "no"
        --                   )
        --            )
        --        ]
        --    , p [] [ Html.text ("pointer.x: " ++ Round.round 2 computer.pointer.x) ]
        --    , p [] [ Html.text ("pointer.y: " ++ Round.round 2 computer.pointer.y) ]
        --    , p [] [ Html.text ("wheel deltaX: " ++ String.fromFloat computer.wheel.deltaX) ]
        --    , p [] [ Html.text ("wheel deltaY: " ++ String.fromFloat computer.wheel.deltaY) ]
        --    ]
        ]


viewGUI : Computer -> Model gameModel -> Html (Msg levelEditorMsg)
viewGUI computer model =
    let
        yingYangButton =
            button
                [ class <|
                    if model.distractionFree then
                        "fill-black20 hover:fill-black80"

                    else
                        "fill-white40 hover:fill-white80"
                , Html.Events.onClick ClickOnDistractionFreeButton
                , HA.title "Distraction Free Mode"
                ]
                [ Icons.draw Icons.icons.yinAndYang ]

        twitterLink =
            div [ class "absolute w-8 bottom-12" ]
                [ a
                    [ class "fill-twitterBlue40 hover:fill-twitterBlue"
                    , href "https://twitter.com/AzizErkalSelman"
                    , target "_blank"
                    ]
                    [ Icons.draw Icons.icons.twitter ]
                ]

        githubLink =
            div [ class "absolute w-8 bottom-2" ]
                [ a
                    [ class "fill-githubCat40 hover:fill-githubCat"
                    , href "https://github.com/erkal/elm-3d-playground-exploration"
                    , target "_blank"
                    ]
                    [ Icons.draw Icons.icons.githubCat ]
                ]
    in
    if model.distractionFree then
        div [ class "fixed w-10 h-10 p-1" ]
            [ yingYangButton
            ]

    else
        div []
            [ div [ class "absolute h-full w-[40px] p-1 border-r-[0.5px] border-white20 bg-black80" ]
                [ yingYangButton, twitterLink, githubLink ]
            , div
                [ class "absolute overflow-y-auto left-10 w-[260px] bg-black20 border-x-[0.5px] border-white20"
                , style "height" <| String.fromFloat (computer.screen.height - 80) ++ "px"
                ]
                [ Html.map FromConfigurationsEditor (ConfigurationsGUI.view (currentComputer model.tape).configurations)
                ]
            , div
                [ class "absolute bottom-0 left-10 h-20"
                , style "width" <|
                    if computer.screen.width > 600 then
                        "600px"

                    else
                        String.fromFloat (computer.screen.width - 40) ++ "px"
                ]
                [ Html.map FromTape (Tape.view model.tape) ]
            , viewComputer computer model
            ]
