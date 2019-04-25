{-# LANGUAGE ViewPatterns #-}

-- | Naive filter using bytestring.

module Filter.Green where

import           Control.Exception
import           Control.Monad
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           System.IO
import           System.IO.Error

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh (S8.pack -> arg) = go
  where
    go = do
      result <- try (S8.hGetLine inh)
      case result of
        Left err ->
          if isEOFError err
            then pure ()
            else throw err
        Right line -> do
          when (S8.isInfixOf arg line) (S8.hPutStrLn outh line)
          go
