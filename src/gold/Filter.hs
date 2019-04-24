{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Naive filter using bytestring.

module Filter where

import           Data.ByteString (ByteString)
import qualified Data.ByteString.Char8 as S8
import           Data.Conduit
import qualified Data.Conduit.Binary as CB
import qualified Data.Conduit.List as CL
import           System.IO

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle input out (S8.pack -> query) = do
  runConduit
    (CB.sourceHandle input .| CB.lines .| CL.filter (S8.isSuffixOf query) .| CL.map (<> "\n") .|
     CB.sinkHandle stdout)
