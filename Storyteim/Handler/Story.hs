module Handler.Story where

import Import

getStoryR :: Int -> Handler Html
getStoryR page
    | page < 0  = getStoryR 0
    | otherwise = do
    let resultsPerPage = 1
    entries <- runDB $ selectList [] [Desc EntryPosted, 
                                      LimitTo resultsPerPage,
                                      OffsetBy $ page * resultsPerPage ]
    defaultLayout $ do
        setTitle "it\'s storyteim"
        $(widgetFile "entry")

