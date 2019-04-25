-- |

module UnsafeBuffer where

import Control.Monad
import Data.ByteString (ByteString)
import Data.ByteString.Unsafe
import Data.Mutable
import Foreign
import Foreign.C
import System.IO

data Buffer =
  Buffer
    { bufferPtr :: !(IOSRef (Ptr CChar))
    , bufferSize :: !(IOURef Int)
    , bufferCopied :: !(IOURef Int)
    , bufferChunkSize :: !Int
    }

newBuffer :: Int -> IO Buffer
newBuffer size = do
  ptr <- callocBytes (fromIntegral size)
  ptrRef <- newRef ptr
  sizeRef <- newRef size
  copiedRef <- newRef 0
  pure
    Buffer
      { bufferPtr = ptrRef
      , bufferSize = sizeRef
      , bufferCopied = copiedRef
      , bufferChunkSize = size
      }

copyIntoBuffer :: Handle -> Buffer -> IO Int
copyIntoBuffer handle buffer = do
  copiedSoFar <- readRef (bufferCopied buffer)
  ptr <- readRef (bufferPtr buffer)
  copied <- hGetBuf handle (plusPtr ptr copiedSoFar) (bufferChunkSize buffer)
  when
    (copied > 0)
    (do let copiedSoFar' = copiedSoFar + copied
        writeRef (bufferCopied buffer) copiedSoFar'
        size <- readRef (bufferSize buffer)
        when
          (copiedSoFar' + bufferChunkSize buffer > size)
          (do ptr' <- reallocBytes ptr (size + bufferChunkSize buffer)
              writeRef (bufferSize buffer) (size + bufferChunkSize buffer)
              writeRef (bufferPtr buffer) ptr'))
  pure copied
{-# INLINE copyIntoBuffer #-}

consume :: Int -> Buffer -> IO ()
consume bytes buffer = do
  -- out <- bufferUnsafeByteString buffer
  -- print ("consume", out)
  -- putStrLn ("Consume: " ++ show bytes)
  ptr <- readRef (bufferPtr buffer)
  size <- readRef (bufferSize buffer)
  modifyRef (bufferCopied buffer) (subtract bytes)
  -- putStrLn "Moving ... "
  -- print ptr
  -- print (plusPtr ptr (bytes - 1))
  -- print size
  -- print bytes
  -- print (size-bytes)
  moveBytes ptr (plusPtr ptr bytes) (size - bytes)
  -- out <- bufferUnsafeByteString buffer
  -- print ("remainder", out)
  -- putStrLn "Done consuming."

{-# INLINE consume #-}
bufferUnsafeByteString :: Buffer -> IO ByteString
bufferUnsafeByteString buffer = do
  ptr <- readRef (bufferPtr buffer)
  len <- readRef (bufferCopied buffer)
  unsafePackCStringLen (ptr, len)
{-# INLINE bufferUnsafeByteString #-}

bufferAvailable :: Buffer -> IO Int
bufferAvailable = readRef . bufferCopied
