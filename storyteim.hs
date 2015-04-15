{-# LANGUAGE OverloadedStrings, TypeFamilies, QuasiQuotes, TemplateHaskell, GADTs, FlexibleContexts, MultiParamTypeClasses, DeriveDataTypeable, GeneralizedNewtypeDeriving, ViewPatterns #-}

import Yesod
import Yesod.Auth
import Yesod.Form.Nic (YesodNic, nicHtmlField)
import Data.Text (Text)
import Network.HTTP.Client.TLS (tlsManagerSettings)
import Network.HTTP.Conduit (Manager, newManager)
import Database.Persist.Postgresql
import Data.Time (UTCTime, getCurrentTime)
import Control.Applicative ((<$>), (<*>), pure)
import Data.Typeable (Typeable)
import Control.Monad.Logger (runStdoutLoggingT)

share [mkPersist sqlSettings, mkMigrate "migrateAll"] [persistLowerCase|
Entry
    title Text
    story Textarea
    score Int
    posted UTCTime
    deriving Show
|]

connStr = "host=localhost dbname=networks user=postgres password=password port=5432"

data Storyteim = Storyteim
    { connPool      :: ConnectionPool
    , httpManager   :: Manager
    }

mkYesod "Storyteim" [parseRoutes|
/                       HomeR   GET POST
/story/#EntryId         StoryR  GET
|]

instance Yesod Storyteim where
    approot = ApprootStatic "http://localhost:3000"

instance YesodPersist Storyteim where
    type YesodPersistBackend Storyteim = SqlBackend
    runDB f = do
        master <- getYesod
        let pool = connPool master
        runSqlPool f pool

storyForm = renderDivs $ Entry
    <$> lift (liftIO getCurrentTime)
    <*> areq textField "Title" Nothing
    <*> areq textareaField "Story" Nothing

getHomeR = do
    (widget, enctype) <- generateFormPost storyForm
    defaultLayout
        [whamlet|
            <h3> The more your leave out, the more you highlight what you leave in
            <form method=post action=@{HomeR} enctype=#{enctype}>
                ^{widget}
                <button>Submit
        |]

postHomeR = do
    ((result, widget), enctype) <- runFormPost storyForm
    case result of
        FormSuccess story -> do
            _ <- runDB $ insert story
            redirect $ StoryR 1
        e -> defaultLayout $ do
            setTitleI "Please fix the error"
            [whamlet|
                <form method=post enctype=#{enctype}>
                    ^{widget}
                    <button>Submit
            |]

getStoryR entryId = do
    entry <- runDB $ do
        return $ get404 entryId
    defaultLayout $ do
        [whamlet|
            <h1>#{entryTitle entry}
            <article>#{entryStory entry}
            <a href=@{getStoryR (entryId + 1)}>Next Story
        |]

main = do
    pool <- runStdoutLoggingT $ createPostgresqlPool connStr 10 
    runSqlPersistMPool (runMigration migrateAll) pool
    manager <- newManager tlsManagerSettings
    warp 3000 $ Storyteim pool manager
