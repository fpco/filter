-- |

module Main where

import Filter
import System.Environment
import System.IO

main :: IO ()
main = do
  arg:_ <- getArgs
  devNull <- openFile "/dev/null" AppendMode
  Filter.filterHandle stdin devNull arg
