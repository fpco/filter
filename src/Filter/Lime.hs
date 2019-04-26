{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE ViewPatterns #-}

module Filter.Lime where


import           Control.Exception
import           Control.Monad
import           Data.ByteString (ByteString)
import qualified Data.ByteString as S
import qualified Data.ByteString.Char8 as S8
import           Data.ByteString.Unsafe
import           Data.Mutable
import           System.IO
-- import           System.IO.ByteBuffer
import           System.IO.Error
import           UnsafeBuffer
import           Foreign.Ptr
import           GHC.IO.FD
import           GHC.IO.Handle.FD
import           System.Posix.Types (Fd (..))

filterHandle :: Handle -> Handle -> String -> IO ()
filterHandle inh outh (S8.pack -> arg) = unsafeUseAsCStringLen arg $ \(needle,needlelen)-> do
  fd <- fmap (Fd . fdFD) (handleToFd inh)
  fdOut <- fmap (Fd . fdFD) (handleToFd outh)
  buffer <- newBuffer (4096 )
  let getLine next = do copied <- next
                        -- putStrLn ("Copied bytes: "++show copied)
                        if copied == 0
                           then pure Nothing
                           else slurp
        where slurp = do {-bs <- bufferUnsafeByteString buffer-}
                         ptr <- readRef (bufferPtr buffer)
                         copied <- readRef (bufferCopied buffer)
                         result <- s_elemIndex 10 copied ptr
                         case result of
                           Just eolIdx -> do -- putStrLn ("Complete chunk: " ++ show (S.take eolIdx bs))
                                             pure (Just (ptr, eolIdx ,consume (eolIdx+1) buffer))
                           Nothing -> do -- putStrLn ("Incomplete chunk: " ++ show bs)
                                         getLine (copyIntoBuffer fd buffer)
      go next = do
        result <- getLine next
        case result of
          Nothing ->
            pure ()
          Just (ptr, eolIdx, consume) -> do
                -- putStrLn ("Line! " ++ show line)
                is <- s_isInfixOf ptr (fromIntegral eolIdx) needle (fromIntegral needlelen)
                -- when (S8.isInfixOf arg line) (S8.hPutStrLn outh line)
                case is of
                  Just{} -> do str <- bufferUnsafeByteString buffer
                               -- written <-  (c_write 1 ptr (fromIntegral eolIdx))
                               -- if written < fromIntegral eolIdx
                               --    then error "Noooo"
                               --    else pure ()
                               S.hPutStrLn outh (S.take eolIdx str)
                  Nothing -> pure ()
                consume
                -- bs <- bufferUnsafeByteString buffer
                -- putStrLn ("Remainder: " ++ show bs)
                go (do avail <- bufferAvailable buffer
                       if avail == 0
                          then copyIntoBuffer fd buffer
                          else pure avail)
  go (copyIntoBuffer fd buffer)
  c_fsync fdOut
  pure ()
