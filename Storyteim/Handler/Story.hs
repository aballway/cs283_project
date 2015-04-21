module Handler.Story where

import Import

getStoryR :: EntryId -> Handler Html
getStoryR entryId = do
    entry <- runDB $ get404 entryId
    defaultLayout $ do
        setTitle $ toHtml $ entryTitle entry
        $(widgetFile "entry")
