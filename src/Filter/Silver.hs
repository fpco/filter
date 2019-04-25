{-# LANGUAGE ViewPatterns #-}

-- | Lazy bytestring.

module Filter.Silver where

import           Data.ByteString.Lazy (ByteString)
import qualified Data.ByteString.Lazy as L
import qualified Data.ByteString as S
import qualified Data.ByteString.Lazy.Char8 as L8
import qualified Data.ByteString.Char8 as S8
import           System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh (S8.pack -> arg) = do
  interactHandle inh outh (L8.unlines . filter (S.isInfixOf arg . L.toStrict) . L8.lines)

interactHandle :: Handle -> Handle -> (ByteString -> ByteString) -> IO ()
interactHandle inh outh f = do
  s <- L.hGetContents inh
  L8.hPutStrLn outh (f s)
