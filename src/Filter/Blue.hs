{-# LANGUAGE ViewPatterns #-}

-- | Naive filter using bytestring.

module Filter.Blue where

import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh (S8.pack -> arg) = do
  interactHandle inh outh (S8.unlines . filter (S.isInfixOf arg) . S8.lines)

interactHandle :: Handle -> Handle -> (ByteString -> ByteString) -> IO ()
interactHandle inh outh f = do
  s <- S.hGetContents inh
  S8.hPutStrLn outh (f s)
