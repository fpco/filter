-- |

module Filter where

import Data.List
import System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh arg = do
  interactHandle inh outh (show . length . filter (isInfixOf arg) . lines)
  putChar '\n'

interactHandle :: Handle -> Handle -> (String -> String) -> IO ()
interactHandle inh outh f = do
  s <- hGetContents inh
  hPutStr outh (f s)
