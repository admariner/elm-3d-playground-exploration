module TailwindTest.Main exposing (main)

import Camera exposing (Camera, perspective)
import Color exposing (blue, gray, green, red, rgb255)
import Css.Global
import Html.Styled exposing (Html, div, text, toUnstyled)
import Html.Styled.Attributes exposing (css)
import Playground.Playground as Playground exposing (..)
import Scene exposing (..)
import Scene3d.Material exposing (matte)
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Tools.Animation.Animation exposing (..)


main =
    Playground.basic
        { initialConfigurations = initialConfigurations
        , init = init
        , update = update
        , view = view
        }


type alias Model =
    {}



-- INIT


initialConfigurations =
    []


init : Computer -> Model
init computer =
    {}



-- UPDATE


update computer model =
    model



-- VIEW


view computer model =
    toUnstyled <|
        div []
            [ Css.Global.global Tw.globalStyles
            , div
                [ css
                    [ Tw.absolute
                    , Tw.m_40
                    , Tw.p_10
                    , Tw.bg_color Tw.blue_500
                    , Tw.bg_opacity_40
                    , Tw.w_96
                    , Tw.h_96
                    , Tw.text_color Tw.white
                    , Tw.text_3xl
                    ]
                ]
                [ text "Hello Tailwind!" ]

            -- Continue with any other Html
            ]
