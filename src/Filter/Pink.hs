-- | Naive filter.

module Filter.Pink where

import Data.List
import System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh arg = do
  interactHandle inh outh (unlines . filter (isInfixOf arg) . lines)

interactHandle :: Handle -> Handle -> (String -> String) -> IO ()
interactHandle inh outh f = do
  s <- hGetContents inh
  hPutStrLn outh (f s)
