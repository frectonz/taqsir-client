module Main exposing (..)

import Browser
import Browser.Navigation exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import Url exposing (Url)



-- MAIN


main : Program String Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = \_ -> NoOp
        , onUrlRequest = \_ -> NoOp
        }



-- MODEL


type alias Model =
    { url : String
    , suffix : Maybe String
    , baseUrl : String
    , responseMsg : String
    }


type alias Data =
    { status : String
    , url : String
    }


init : String -> Url -> Key -> ( Model, Cmd Msg )
init baseUrl _ _ =
    ( Model "" Nothing baseUrl "Click `Cliam` to shorten your url", Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | UpdateUrlInput String
    | UpdateSuffixInput String
    | Claim
    | GotShortenedUrl (Result Http.Error Data)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        UpdateUrlInput url ->
            ( { model | url = url }, Cmd.none )

        UpdateSuffixInput suffix ->
            ( { model | suffix = Just suffix }, Cmd.none )

        Claim ->
            ( model, shortenUrl model.baseUrl { url = model.url, suffix = model.suffix } )

        GotShortenedUrl result ->
            case result of
                Ok data ->
                    ( { model | responseMsg = data.url }, Cmd.none )

                _ ->
                    ( { model | responseMsg = "Something Went Wrong!" }, Cmd.none )


shortenUrl : String -> { url : String, suffix : Maybe String } -> Cmd Msg
shortenUrl baseUrl data =
    let
        shortenUrlEncoder =
            case data.suffix of
                Just suffix ->
                    Encode.object
                        [ ( "url", Encode.string data.url )
                        , ( "suffix", Encode.string suffix )
                        ]

                Nothing ->
                    Encode.object
                        [ ( "url", Encode.string data.url )
                        ]

        shortenUrlDecoder =
            Decode.map2 Data
                (Decode.field "status" Decode.string)
                (Decode.field "url" Decode.string)
    in
    Http.post
        { url = baseUrl ++ "shorten"
        , body = Http.jsonBody shortenUrlEncoder
        , expect = Http.expectJson GotShortenedUrl shortenUrlDecoder
        }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Taqsir"
    , body =
        [ div
            [ class "window"
            , style "position" "fixed"
            , style "top" "50%"
            , style "left" "50%"
            , style "transform" "translate(-50%, -50%) scale(2)"
            ]
            [ div [ class "title-bar" ]
                [ div [ class "title-bar-text" ] [ text "تقصير === Taqsir" ]
                ]
            , div [ class "window-body" ]
                [ div [ class "field-row" ]
                    [ label [ for "url-input" ] [ text "URL" ]
                    , input
                        [ id "url-input"
                        , type_ "text"
                        , placeholder "https://www.google.com"
                        , style "width" "100%"
                        , onInput UpdateUrlInput
                        ]
                        []
                    ]
                , div [ class "field-row" ]
                    [ label [ for "suffix-input" ] [ text "Suffix" ]
                    , input
                        [ id "suffix-input"
                        , type_ "text"
                        , placeholder "optional suffix could be anything"
                        , style "width" "100%"
                        , onInput UpdateSuffixInput
                        ]
                        []
                    ]
                , let
                    suffix =
                        Maybe.withDefault "<random_suffix>" model.suffix
                  in
                  p [] [ text (model.baseUrl ++ suffix) ]
                , button [ style "margin-right" "auto", onClick Claim ] [ text "Claim" ]
                ]
            , pre [] [ text model.responseMsg ]
            ]
        , div
            [ class "window"
            , style "position" "fixed"
            , style "bottom" "10px"
            , style "left" "10px"
            ]
            [ div [ class "title-bar" ]
                [ div [ class "title-bar-text" ] [ text "Made By Frectonz" ]
                ]
            , div [ class "window-body", style "display" "flex", style "gap" "1rem" ]
                [ a [ href "https://www.youtube.com/@frectonz" ] [ text "YouTube" ]
                , a [ href "https://twitter.com/frectonz/" ] [ text "Twitter" ]
                , a [ href "https://github.com/frectonz" ] [ text "GitHub" ]
                , a [ href "https://www.linkedin.com/in/fraol-lemecha/" ] [ text "LinkedIn" ]
                , a [ href "https://thefrectonz.t.me/" ] [ text "Telegram" ]
                ]
            ]
        ]
    }
