port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Models exposing (..)
import Json.Decode as Json

type Msg = NoOp | KeyDown Int | TextInput String | Move Task | Drop TaskStatus


main = Html.program {
          init = init,
          update = update,
          subscriptions = subscriptions,
          view = view
        }


init : ( Model, Cmd msg )
init = ( Model ""
  [
    Task "Demo Task #1" OnGoing,
    Task "Demo Task #2" Todo,
    Task "Demo Task #3" Done
  ] Nothing, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model = Sub.none


addNewTask : Model -> ( Model, Cmd Msg )
addNewTask model =
  ( { model | 
      tasks = model.tasks ++ [ Task model.taskInput Todo ],
      taskInput = ""
    }
  , Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    NoOp -> 
      ( model, Cmd.none )

    KeyDown key ->
      if key == 13 then
         addNewTask model
      else
        ( model, Cmd.none )

    TextInput content ->
       ( { model | taskInput = content }, Cmd.none )

    Move selectedTask ->
      ( { model | movingTask = Just selectedTask }, Cmd.none )

    Drop targetStatus ->
         ( { model |
             movingTask = Nothing
           },
           Cmd.none )


getOnGoingTasks : Model -> List Task
getOnGoingTasks model =
  List.filter (\t -> t.status == OnGoing) model.tasks

getToDoTasks : Model -> List Task
getToDoTasks model =
  List.filter (\t -> t.status == Todo) model.tasks

getDoneTasks : Model -> List Task
getDoneTasks model =
  List.filter (\t -> t.status == Done) model.tasks



onKeyDown : (Int -> msg) -> Attribute msg
onKeyDown tagger = on "keydown" (Json.map tagger keyCode)

onDragStart : msg -> Attribute msg
onDragStart message = on "dragstart" (Json.succeed message)

onDrop : msg -> Attribute msg
onDrop message = onWithOptions "ondrop"
                  { preventDefault = True,
                    stopPropagation = False
                  }
                  (Json.succeed message)


taskItemView : Int -> Task -> Html Msg
taskItemView index task =
  li [  class "task-item",
        attribute "draggable" "true",
        onDragStart <| Move task,
        attribute "ondragstart" "event.dataTransfer.setData('text/plain', 'T')"
      ] [ text task.name ]


taskColumnView : TaskStatus -> List Task -> Html Msg
taskColumnView status list =
  div [ class <| "category " ++ String.toLower (toString status ),
        onDrop <| Drop status
      ] [
      h2 [] [ text (toString status) ],
      span [] [ text (toString (List.length list) ++ " item(s)") ],
      ul [] (List.indexedMap taskItemView list)
    ]

movingTaskView : Model -> Html Msg
movingTaskView model =
  case model.movingTask of
    Just task -> div [] [ text task.name ]
    Nothing -> div [] []

view : Model -> Html Msg
view model =
  let
      todos = getToDoTasks model
      ongoing = getOnGoingTasks model
      dones = getDoneTasks model
  in
      div [ class "container" ] [
        input [ 
          type_ "text", 
          class "task-input",
          placeholder "What's on your mind right now?",
          tabindex 0,
          onKeyDown KeyDown,
          onInput TextInput,
          value model.taskInput
        ] [ ],
        movingTaskView model,
        div [ class "kanban-board" ] [
          taskColumnView Todo todos,
          taskColumnView OnGoing ongoing,
          taskColumnView Done dones
        ]
      ]