module Handler.Home where

import Import

entryForm :: Form Entry
entryForm = renderDivs $ Entry
    <$> areq titleField "Title" Nothing
    <*> areq storyField "Story" Nothing
    <*> pure 0
    <*> lift (liftIO getCurrentTime)
    where
        titleError :: Text
        titleError = "the title must be under 80 characters!"
        storyError :: Text
        storyError = "the story must be at least 140 characters!"
        validateTitle y
            | length y > 80 = Left titleError
            | otherwise = Right y
        validateStory y
            | length (show y) <= 140 = Left storyError
            | otherwise = Right y
        titleField :: Field (HandlerT App IO) Text
        titleField = check validateTitle textField
        storyField :: Field (HandlerT App IO) Textarea
        storyField = check validateStory textareaField

getHomeR :: Handler Html
getHomeR = do
    (widget, enctype) <- generateFormPost entryForm
    defaultLayout
        [whamlet|
            <h3> the more your leave out, the more you highlight what you leave in
            <form method=post action=@{HomeR} enctype=#{enctype}>
                ^{widget}
                <button>press for storyteim
        |]

postHomeR :: Handler Html
postHomeR = do
    ((res, entryWidget), enctype) <- runFormPost entryForm
    case res of
        FormSuccess story -> do
            _ <- runDB $ insert story
            redirect $ StoryR 0
        _ -> defaultLayout $ do
            setTitle "pls fix teh error"
            $(widgetFile "entryAddError")
