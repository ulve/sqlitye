{-# LANGUAGE OverloadedStrings #-}

module Lib
  ( runPersonExample 
  ) where

import           Control.Monad (mapM_)
import           Data.Int (Int64)
import           Data.Text (Text)
import qualified Data.Text as T
import           Database.SQLite.Simple
import           Database.SQLite.Simple.FromRow
import           Database.SQLite.Simple.FromField
import           Database.SQLite.Simple.ToField
import           Database.SQLite.Simple.Internal
import           Database.SQLite.Simple.Ok

data Person =
  Person 
    { personId   :: Int64
    , personName :: Text
    , personAge  :: Text
    } deriving (Eq,Read,Show)

instance FromRow Person where
    fromRow = Person <$> field <*> field <*> field

instance ToRow Person where
  toRow (Person _pId pName pAge) = toRow (pAge, pName)

runPersonExample :: IO ()
runPersonExample = do
  conn <- open "test.db"
  execute_ conn "CREATE TABLE IF NOT EXISTS people (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, age TEXT)"
  execute conn "INSERT INTO people (name, age) VALUES (?,?)" (Person 0 "Justina" "15")
  execute conn "INSERT INTO people (name, age) VALUES (?,?)" (Person 0 "Jordi" "11")
  people <- query_ conn "SELECT id, name, age from people" :: IO [Person]
  close conn
  print people
