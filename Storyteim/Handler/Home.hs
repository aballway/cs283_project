module Handler.Home where

import Import

entryForm :: Form Entry
entryForm = renderDivs $ Entry
    <$> areq textField "Title" Nothing
    <*> areq textareaField "Story" Nothing
    <*> pure 0
    <*> lift (liftIO getCurrentTime)

getHomeR :: Handler Html
getHomeR = do
    (widget, enctype) <- generateFormPost entryForm
    defaultLayout
        [whamlet|
            <h3> The more your leave out, the more you highlight what you leave in
            <form method=post action=@{HomeR} enctype=#{enctype}>
                ^{widget}
                <button>Submit
        |]

postHomeR :: Handler Html
postHomeR = do
    ((res, entryWidget), enctype) <- runFormPost entryForm
    case res of
        FormSuccess story -> do
            storyId <- runDB $ insert story
            redirect $ StoryR storyId
        _ -> defaultLayout $ do
            setTitle "Pls fix"
            $(widgetFile "entryAddError")
