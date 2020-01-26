module Main where

import Lib

main :: IO ()
main = do
  let dbFile = "test2.db"
  initDB dbFile
  runApp dbFile 
