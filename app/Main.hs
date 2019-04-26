-- |

module Main where

import Data.Maybe
import Data.Semigroup ((<>))
import Filter
import Options.Applicative.Simple
import System.IO

data Config =
  Config
    { configFiles :: [FilePath]
    , configNeedles :: String
    } deriving (Show)

main :: IO ()
main = do
  (config, ()) <-
    simpleOptions
      "0"
      "Filter"
      "Filter lines in a file"
      (Config <$>
       many (strOption (short 'f' <> metavar "FILE" <> help "File to search through")) <*>
       strArgument (metavar "NEEDLE" <> help "A string to search for"))
      empty
  mapM_
    (\file -> do
       handle <- openFile file ReadMode
       Filter.filterHandle handle stdout (configNeedles config)
       hClose handle)
    (configFiles config)
