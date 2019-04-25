{-# LANGUAGE ViewPatterns #-}

module Filter.Lime where


import           Control.Exception
import           Control.Monad
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           System.IO
-- import           System.IO.ByteBuffer
import           System.IO.Error
import           UnsafeBuffer

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh (S8.pack -> arg) = do
  buffer <- newBuffer 4096
  let getLine next = do copied <- next
                        -- putStrLn ("Copied bytes: "++show copied)
                        if copied == 0
                           then pure Nothing
                           else slurp
        where slurp = do bs <- bufferUnsafeByteString buffer
                         case S.elemIndex 10 bs of
                           Just eolIdx -> do -- putStrLn ("Complete chunk: " ++ show (S.take eolIdx bs))
                                             pure (Just (S.take eolIdx bs, consume (eolIdx+1) buffer))
                           Nothing -> do -- putStrLn ("Incomplete chunk: " ++ show bs)
                                         getLine (copyIntoBuffer inh buffer)
      go next = do
        result <- getLine next
        case result of
          Nothing ->
            pure ()
          Just (line, consume) -> do
                -- putStrLn ("Line! " ++ show line)
                when (S8.isInfixOf arg line) (S8.hPutStrLn outh line)
                consume
                bs <- bufferUnsafeByteString buffer
                -- putStrLn ("Remainder: " ++ show bs)
                go (do avail <- bufferAvailable buffer
                       if avail == 0
                          then copyIntoBuffer inh buffer
                          else pure avail)
  go (copyIntoBuffer inh buffer)
