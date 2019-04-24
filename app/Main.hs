-- |

module Main where

import Filter
import System.Environment
import System.IO

main :: IO ()
main = do
  arg:_ <- getArgs
  Filter.filterHandle stdin stdout arg
