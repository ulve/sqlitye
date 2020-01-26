{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}

module Lib
  ( initDB
  , runApp 
  ) where

import Control.Concurrent
import Control.Monad.IO.Class
import Database.SQLite.Simple
import Network.Wai.Handler.Warp
import Servant

type Message = String

type API = ReqBody '[PlainText] Message :> Post '[JSON] NoContent :<|> Get '[JSON] [Message]

api :: Proxy API
api = Proxy

initDB :: FilePath -> IO ()
initDB dbFile = withConnection dbFile $ \conn -> execute_ conn "CREATE TABLE IF NOT EXISTS messages (msg text not null)"

server :: FilePath -> Server API
server dbFile = postMessage :<|> getMessages
  where postMessage :: Message -> Handler NoContent
        postMessage msg = do 
          liftIO . withConnection dbFile $ \conn ->
            execute conn "INSERT INTO messages VALUES (?)" (Only msg)
          return NoContent

        getMessages :: Handler [Message]
        getMessages = fmap (map fromOnly) . liftIO $
          withConnection dbFile $ \conn -> query_ conn "SELECT msg FROM messages"


runApp :: FilePath -> IO ()
runApp dbFile = run 8080 (serve api $ server dbFile)